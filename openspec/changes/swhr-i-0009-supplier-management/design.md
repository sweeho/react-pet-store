# Supplier Management Design Notes

## User interface

One screen record was extracted for this capability; screen-specific visible contracts are in spec.md as requirements.

## Legacy Implementation Architecture

### Supplier Order Entity Model

**SupplierOrderEJB** (`components/supplierpo/ejb/SupplierOrderEJB.java`)

- Container-managed persistence (CMP 2.x) entity bean
- Primary key: String (poId)
- CMP fields: poId (String, primary key), poDate (long, timestamp), poStatus (String)
- Relationship to ContactInfo: one-to-one unidirectional with cascade delete
- Relationship to LineItem: one-to-many with cascade delete
- All methods use Required transaction attribute
- Unchecked access (no authorization)

### Purchase Order Status Model

**OrderStatusNames** (`components/supplierpo/ejb/OrderStatusNames.java`)

Constants define four valid states:

- **PENDING**: Initial state when order created
- **APPROVED**: Order approved, ready for fulfillment
- **COMPLETED**: All items fulfilled
- **DENIED**: Order rejected

State transitions: PENDING → APPROVED → COMPLETED OR PENDING → DENIED

### Inventory Entity Model

**InventoryEJB** (`apps/supplier/inventory/ejb/InventoryEJB.java`)

- Container-managed persistence (CMP 2.x) entity bean
- Primary key: String (itemId)
- CMP fields: itemId (String, primary key), quantity (int)
- Methods: getQuantity(), setQuantity(), reduceQuantity()
- Supports initialization with 29 items (EST-1 through EST-29), each with 10000 units

### Order Fulfillment Processing

**OrderFulfillmentFacadeEJB** (`apps/supplier/orderfulfillment/ejb/OrderFulfillmentFacadeEJB.java`)

Stateless session bean managing order fulfillment workflow:

- **processPO(xmlString)**: Accepts XML purchase order, persists as SupplierOrderLocal entity, attempts fulfillment
- **processAnOrder(SupplierOrderLocal)**: Iterates through line items, checks inventory availability, reduces quantities for available items, generates invoice for fulfilled items only
- **processPendingPO()**: Finds all PENDING orders, re-attempts fulfillment for each (triggered after inventory update)
- **checkInventory(LineItemLocal)**: Checks if inventory quantity >= requested quantity, reduces inventory if available, returns success/failure

### Asynchronous Order Intake

**SupplierOrderMDB** (`apps/supplier/processpo/ejb/SupplierOrderMDB.java`)

- Message-driven bean listening on JMS Queue
- onMessage() receives TextMessage containing XML purchase order
- Calls OrderFulfillmentFacadeEJB.processPO() to process order
- Calls doTransition() to send invoice back to OPC via message queue if fulfilled

### Invoice Generation

**OrderFulfillmentFacadeEJB.createInvoice()**

- Generates XML invoice document for fulfilled line items
- Includes order ID, user ID, order date, shipping date
- Lists only items that were successfully fulfilled (marked as shipped)
- Returns invoice as serialized XML string

### Supplier Order Data Transfer

**SupplierOrder** POJO value object:

- orderId (String)
- orderDate (Date, formatted as yyyy-MM-dd in XML)
- shippingInfo (ContactInfo object)
- lineItems (ArrayList<LineItem>)

**getData()** method on SupplierOrderEJB returns complete SupplierOrder POJO from EJB-managed fields and relationships.

### XML Serialization

- DTD validation enabled (DTD_PUBLIC_ID and DTD_SYSTEM_ID constants)
- toXML() / fromXML() / toDOM() / fromDOM() methods on SupplierOrder class
- SupplierOrder DTD defines element structure: SupplierOrder (OrderId, OrderDate, ShippingInfo, LineItem+)
- Date format in XML: yyyy-MM-dd

### Service Integration

**JNDINames** constants:

- `java:comp/env/ejb/ContactInfo` - ContactInfo EJB
- `java:comp/env/ejb/Address` - Address EJB
- `java:comp/env/ejb/LineItem` - LineItem EJB
- `java:comp/env/ejb/SupplierOrder` - SupplierOrder EJB

All resolved via ServiceLocator during object creation.

### Inventory Update Workflow

**RcvrRequestProcessor** servlet:

1. User updates inventory quantities via displayinventory.jsp form
2. updateInventory() method persists new quantities
3. processPendingPO() finds all PENDING purchase orders
4. Re-processes each pending order to fulfill against newly available inventory
5. sendInvoices() transmits fulfilled invoices back to OPC
6. Entire sequence wrapped in UserTransaction for atomicity

### Transaction Management

All supplier order and inventory operations execute with Required transaction attribute:

- Order creation and relationship establishment (ejbCreate/ejbPostCreate)
- Status updates and queries
- Inventory reduction
- Invoice generation and transmission
- All operations roll back together on failure

### Authentication

Inventory update operations require "administrator" role:

- RcvrRequestProcessor protected by security-constraint in web.xml
- displayinventory.jsp checks request.isUserInRole("administrator")
- Session timeout: 54 minutes

## Known Limitations

1. Line item fulfillment tracked via quantityShipped field; no fulfillment history or auditing
2. getData() method on SupplierOrderEJB contains apparent bug (circular assignment of shippingInfo)
3. DTD file referenced in SupplierOrder.java may not exist in all deployments
4. Silent exception handling in OrderFulfillmentFacadeEJB.processPendingPO() masks fulfillment failures
5. Inventory updates accept any non-negative integer; no increment/decrement semantics
6. No pagination support for large order or inventory collections
7. CMR field access (lineItems) requires transaction context; getLineItems() not accessible from web tier without getAllItems() wrapper
