# Admin Operations Design Notes

## Legacy Implementation Architecture

### Web Tier Components

**AdminRequestProcessor** (`apps/admin/src/admin/com/sun/j2ee/blueprints/admin/web/AdminRequestProcessor.java`)

- Servlet handler for login page and JNLP generation
- Entry point: POST to /AdminRequestProcessor with currentScreen parameter
- Builds JNLP XML dynamically with server details and session ID
- References: `buildJNLP()` method

**ApplRequestProcessor** (`apps/admin/src/admin/com/sun/j2ee/blueprints/admin/web/ApplRequestProcessor.java`)

- Request handler for rich client XML messages
- Validates session existence before processing requests
- Dispatches to handlers based on request Type:
  - GETORDERS → getOrders()
  - UPDATESTATUS → updateOrders()
  - REVENUE → getChartInfo()
  - ORDERS → getChartInfo() with different aggregation
- Date parsing via `getProperDate()` using StringTokenizer to parse mm/dd/yyyy

**AdminRequestBD** (`apps/admin/src/admin/com/sun/j2ee/blueprints/admin/web/AdminRequestBD.java`)

- Business delegate pattern implementation
- JNDI lookups:
  - Remote: `java:comp/env/ejb/OPCAdminFacadeRemote` (OPCAdminFacadeHome)
  - Local: AsyncSender via ServiceLocator
- Methods: getOrdersByStatus(), updateOrders()

### EJB Components

**OPCAdminFacadeEJB** (`apps/opc/src/com/sun/j2ee/blueprints/opc/admin/ejb/OPCAdminFacadeEJB.java`)

- Remote session bean providing order and analytics queries
- Methods:
  - `getOrdersByStatus(String status)`: Returns OrdersTO (transfer object collection)
  - `getChartInfo(Date start, Date end, String reqType, String category)`: Analytics aggregation
- Revenue calculation: `loc.getQuantity() * loc.getUnitPrice()`
- Quantity aggregation: Sum of `loc.getQuantity()`
- OrderDetails transfer object: Contains OrderId, UserId, OrderDate (mm/dd/yyyy format), OrderValue, OrderStatus

**OrderFulfillmentFacadeEJB** (`apps/supplier/src/com/sun/j2ee/blueprints/supplier/orderfulfillment/ejb/OrderFulfillmentFacadeEJB.java`)

- Supplier side fulfillment processing
- Core inventory check: `inv.getQuantity() < item.getQuantity()` returns false if insufficient stock
- Inventory reduction: `inv.reduceQuantity(item.getQuantity())`

### JSP Pages

**login.jsp** (`apps/admin/src/docroot/login.jsp`)

- Form-based authentication interface
- Form action: `j_security_check` (servlet container standard)
- Parameters: `j_username`, `j_password`
- Default test credentials: username="jps_admin", password="admin"
- Also displays login.jsp for GET (error handling)

**index.jsp** (`apps/admin/src/docroot/index.jsp`)

- Post-login portal page
- Form with hidden currentScreen="manageorders"
- Submits to AdminRequestProcessor to trigger JNLP generation

**displayinventory.jsp** (`apps/supplier/src/docroot/displayinventory.jsp`)

- Supplier inventory update interface
- Uses DisplayInventoryBean to retrieve inventory via getInventory()
- Renders table with columns: Item ID, Existing Quantity, New Quantity (input), Checkbox
- Iterates through inventory items rendering form fields
- References in RcvrRequestProcessor at displayinventory action

### Message-Driven Processing

**AsyncSender** (local EJB)

- Receives OrderApproval XML via sendAMessage()
- Queues status changes for asynchronous processing
- Decouples admin portal from fulfillment workflow

## Configuration & Deployment

### web.xml Configuration

**Security Constraints** (apps/admin/src/docroot/WEB-INF/web.xml)

- URL pattern: `/AdminRequestProcessor`
- HTTP methods: GET, POST
- Required role: `administrator`
- Transport guarantee: NONE
- Auth method: FORM
- Login page: `/login.jsp`
- Error page: `/error.jsp`

**Session Configuration**

- Timeout: 54 minutes

**EJB References**

- OPCAdminFacadeRemote: Remote session bean reference
- AsyncSender: Local session bean reference via ejb-link

### JNLP Application Descriptor

Generated dynamically by AdminRequestProcessor.buildJNLP():

```xml
<?xml version="1.0" encoding="UTF-8"?>
<jnlp codebase="http://[server]:[port]/admin">
  ...
  <application-desc main-class="com.sun.j2ee.blueprints.admin.client.PetStoreAdminClient">
    <argument>[proxy class name]</argument>
    <argument>[server name]</argument>
    <argument>[server port]</argument>
    <argument>[session ID]</argument>
  </application-desc>
</jnlp>
```

## Data Transfer Objects (Transfer Objects)

**OrderDetails**

- Fields: OrderId, UserId, OrderDate (mm/dd/yyyy), OrderValue, OrderStatus
- Created in OPCAdminFacadeEJB
- Date formatting: `(month+1) + "/" + day + "/" + (year+1900)` using deprecated Date constructor

**OrdersTO**

- Collection container for OrderDetails objects
- Returned by OPCAdminFacadeEJB.getOrdersByStatus()

**OrderApproval**

- Contains collection of ChangedOrder objects
- Serialized to XML and sent via AsyncSender

**ChangedOrder**

- Contains OrderId and OrderStatus
- Built from XML request elements in ApplRequestProcessor

## Database Objects

### PurchaseOrder Entity

- Related to OrderDetails via OPC-PO mapping
- Date field: `po.getPoDate()` accessed via deprecated Date API

### LineItem Entity

- Fields: quantity, unitPrice, categoryId, itemId
- Used in both order fulfillment and analytics queries
- References inventory items for fulfillment checking

### Inventory Entity

- Field: quantity (current stock)
- Method: `reduceQuantity(int)` for decrementing on fulfillment
- Located via InventoryHome.findByPrimaryKey(itemId)

## Utilities

### Debug Class (`components/util/tracer/src/com/sun/j2ee/blueprints/util/tracer/Debug.java`)

- Static utility for debug output
- Field: `debuggingOn` (static final boolean = false) - controls all output
- Methods:
  - `print(String msg)` → System.err.print() if debuggingOn
  - `println(String msg)` → System.err.println(">>" + msg) if debuggingOn
  - `print(Exception e, String msg)` → delegates to Throwable variant
  - `print(Exception e)` → delegates with msg=null
  - `print(Throwable t, String msg)` → System.out.println() + optional msg + t.printStackTrace()
  - `print(Throwable t)` → delegates with msg=null
- Note: Output streams differ (stderr for messages, stdout for exceptions)

## Error Handling

ApplRequestProcessor methods return null on exceptions:

- getOrders() lines 200-201
- updateOrders() lines 301-303
- getChartInfo() - similar pattern

When null is returned, the servlet response is unclear (potential bug).

## Known Limitations

1. Date handling uses deprecated Java Date API (Date(year-1900, month-1, day))
2. No centralized logging framework integration; uses System.out/System.err
3. Debug output has no runtime configuration mechanism
4. Order status validation happens only in backend (OrderApproval/ChangedOrder)
5. Error responses not clearly differentiated from empty result sets
6. XML parsing creates new DocumentBuilder for each request (performance concern)

## Integration Points

### With Order Processing Component (OPC)

- Remote EJB call to OPCAdminFacadeRemote
- Query operations: getOrdersByStatus(), getChartInfo()
- JNDI name: java:comp/env/ejb/OPCAdminFacadeRemote

### With Async Messaging

- Local EJB call to AsyncSender
- Method: sendAMessage(String xmlMessage)
- JNDI lookup via ServiceLocator.getLocalHome()
- Decouples admin updates from fulfillment processing

### With Supplier Module

- Inventory queries via DisplayInventoryBean
- Supplier-side fulfillment via OrderFulfillmentFacadeEJB
- Inventory reduction during fulfillment

### With Process Manager

- Order status transitions via ProcessManager.getOrdersByStatus()
- Reconciliation with OPC purchase orders
