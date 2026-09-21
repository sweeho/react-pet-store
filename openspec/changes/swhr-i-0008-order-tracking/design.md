# Order Tracking Design Notes

## User interface

No screen records were extracted for this capability; its user interface is unspecified.

## Legacy Implementation Architecture

### Process Manager State Machine

**ProcessManagerEJB** (`components/processmanager/ejb/ProcessManagerEJB.java`)

- Stateless session bean managing order workflow state
- Methods: createManager(), updateStatus(), getStatus(), getOrdersByStatus()
- Uses ManagerEJB entity bean to persist workflow state
- All methods execute within Required transaction context
- No authorization checks (unchecked access in ejb-jar.xml)

### Workflow State Model

**OrderStatusNames** (`components/processmanager/ejb/OrderStatusNames.java`)

- Central registry of order status constants
- Valid states: PENDING, APPROVED, DENIED, SHIPPED_PART, COMPLETED
- State transition rules documented in javadoc (not enforced programmatically):
  - PENDING → APPROVED → SHIPPED_PART → COMPLETED (normal path)
  - PENDING → DENIED (rejection path)
- No programmatic validation preventing invalid state transitions

### Manager Entity

**ManagerEJB** (`components/processmanager/manager/ejb/ManagerEJB.java`)

- CMP 2.x entity bean with orderId as primary key
- CMP fields: orderId, status
- Container-managed persistence
- Used to track order workflow state by order ID

### Admin Query Facade

**OPCAdminFacadeEJB** (`apps/opc/admin/ejb/OPCAdminFacadeEJB.java`)

- Stateless session bean with Remote interface
- Business methods:
  - `getOrdersByStatus(String status)`: Returns OrdersTO with OrderDetails
  - `getChartInfo(String request, Date start, Date end, String categ)`: Returns Map of analytics
- All methods have transaction attribute Required
- Unchecked access (public)
- Date formatting: MM/DD/YYYY via `(month+1) + "/" + date + "/" + (year+1900)`

### Order Query by Status

ProcessManagerEJB.getOrdersByStatus() uses EJB-QL query:

```
SELECT DISTINCT OBJECT(a) FROM Manager a WHERE a.status = ?1
```

This returns all ManagerLocal entities matching the given status.

### Order Retrieval

Admin facade flow:

1. Call ProcessManager.getOrdersByStatus(status)
2. For each returned Manager entity, retrieve orderId
3. Look up PurchaseOrderLocal via PurchaseOrderLocalHome.findByPrimaryKey(orderId)
4. Extract order properties: poId, poUserId, poDate (formatted), poValue
5. Build OrderDetails object with ID, user ID, date, value, status

### Analytics Aggregation

**getChartInfo() flow:**

1. Accept parameters: request type (ORDERS|REVENUE), start date, end date, optional category
2. Call PurchaseOrderLocalHome.findPOBetweenDates(startTime, endTime)
3. For each purchase order returned:
   - Retrieve all line items via po.getAllItems()
   - Iterate line items
   - Apply aggregation based on request type:
     - REVENUE: Accumulate (quantity × unitPrice) by category
     - ORDERS: Count items by category
4. Return HashMap with category ID as key and aggregated value

### Order Status Transition

**OrderApprovalMDB** (`apps/opc/ejb/OrderApprovalMDB.java`)

- Enforces status state machine before updating
- Only processes PENDING orders
- Skip logic (lines 201-207):
  ```
  String curStatus = processManager.getStatus(co.getOrderId());
  if(!curStatus.equals(OrderStatusNames.PENDING)) {
    continue;  // Skip non-PENDING orders
  }
  ```
- Transitions orders to APPROVED or DENIED status

**InvoiceMDB** (`apps/opc/ejb/InvoiceMDB.java`)

- Processes supplier invoices
- Updates order status to SHIPPED_PART or COMPLETED based on fulfillment
- Uses join condition pattern: only transitions to COMPLETED when all items shipped

### Configuration (ejb-jar.xml)

- ProcessManagerEJB: Local stateless session bean
- ManagerEJB: Local CMP 2.x entity bean
- OPCAdminFacadeEJB: Remote stateless session bean
- All methods require container-managed transactions
- All methods have unchecked access

## Known Limitations

1. State transition rules in javadoc not enforced in code (no invalid transition prevention)
2. No programmatic join condition validation for COMPLETED transition
3. Date formatting with string concatenation (month+1 pattern) - off-by-one risk
4. Category filtering in analytics accepts null (treated as "all categories")
5. No pagination on large result sets from getOrdersByStatus()
6. No audit trail for status transitions
7. No timestamp tracking for when status changed
