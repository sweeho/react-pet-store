## 1. Supplier Order Entity

- [ ] 1.1 Define SupplierOrder CMP entity with poId (String), poDate (long), poStatus (String) fields
- [ ] 1.2 Implement primary key as String-typed poId field
- [ ] 1.3 Implement abstract getters/setters for poId, poDate, poStatus
- [ ] 1.4 Implement ejbCreate() and ejbPostCreate() lifecycle methods
- [ ] 1.5 Initialize new orders with PENDING status
- [ ] 1.6 Declare container-managed persistence (CMP 2.x) configuration
- [ ] 1.7 Set up local home and local interfaces (SupplierOrderLocalHome, SupplierOrderLocal)

## 2. Order Status Workflow

- [ ] 2.1 Define OrderStatusNames constants (PENDING, APPROVED, DENIED, COMPLETED)
- [ ] 2.2 Document valid state transitions (PENDING→APPROVED→COMPLETED or PENDING→DENIED)
- [ ] 2.3 Implement setPoStatus() to update order status
- [ ] 2.4 Ensure all status-related operations are transactional

## 3. Order-ContactInfo Relationship

- [ ] 3.1 Create one-to-one unidirectional relationship from SupplierOrder to ContactInfo
- [ ] 3.2 Configure cascade delete on ContactInfo side
- [ ] 3.3 Implement CMR field contactInfo in SupplierOrder entity
- [ ] 3.4 Create ContactInfo entity in ejbPostCreate() when order is created
- [ ] 3.5 Implement getContactInfo() and setContactInfo() methods

## 4. Order-LineItem Relationship

- [ ] 4.1 Create one-to-many relationship from SupplierOrder to LineItem
- [ ] 4.2 Configure cascade delete on LineItem side
- [ ] 4.3 Implement CMR field lineItems as Collection in SupplierOrder entity
- [ ] 4.4 Create LineItem entities in ejbPostCreate() for each item in order
- [ ] 4.5 Implement getLineItems() and addLineItem() methods
- [ ] 4.6 Implement getAllItems() method to return detached LineItem data objects

## 5. Supplier Order Query

- [ ] 5.1 Implement findOrdersByStatus(String status) finder method
- [ ] 5.2 Define EJB-QL query: SELECT DISTINCT OBJECT(a) FROM SupplierOrder a WHERE a.poStatus = ?1
- [ ] 5.3 Add finder to SupplierOrderLocalHome interface

## 6. Order Data Transfer

- [ ] 6.1 Create SupplierOrder POJO value object with orderId, orderDate, shippingInfo, lineItems
- [ ] 6.2 Implement getData() method on SupplierOrderEJB to return complete POJO
- [ ] 6.3 Convert long timestamps back to Date objects in getData()
- [ ] 6.4 Convert LineItemLocal managed objects to LineItem data objects in getData()
- [ ] 6.5 Implement XML serialization (toXML, fromXML, toDOM, fromDOM)
- [ ] 6.6 Define DTD structure for SupplierOrder XML representation

## 7. Inventory Entity

- [ ] 7.1 Define Inventory CMP entity with itemId (String), quantity (int) fields
- [ ] 7.2 Implement primary key as String-typed itemId field
- [ ] 7.3 Implement abstract getters/setters for itemId and quantity
- [ ] 7.4 Declare container-managed persistence (CMP 2.x) configuration
- [ ] 7.5 Create finder interface and home for Inventory

## 8. Inventory Operations

- [ ] 8.1 Implement getQuantity() method
- [ ] 8.2 Implement setQuantity() method for absolute quantity replacement
- [ ] 8.3 Implement reduceQuantity(int amount) method for inventory reduction
- [ ] 8.4 Initialize default inventory: 29 items (EST-1 through EST-29) with 10000 units each
- [ ] 8.5 Implement findByItemId() finder to retrieve inventory by item ID

## 9. Order Fulfillment Facade

- [ ] 9.1 Create OrderFulfillmentFacadeEJB stateless session bean
- [ ] 9.2 Implement processPO(String xmlDoc) method to accept and persist XML purchase orders
- [ ] 9.3 Implement processAnOrder(SupplierOrderLocal) to fulfill individual orders
- [ ] 9.4 Implement checkInventory(LineItemLocal) to verify and reduce inventory
- [ ] 9.5 Implement processPendingPO() to re-process pending orders after inventory update
- [ ] 9.6 Implement createInvoice() to generate XML invoice for fulfilled items only
- [ ] 9.7 Set all methods to Required transaction attribute

## 10. Asynchronous Order Processing

- [ ] 10.1 Create SupplierOrderMDB message-driven bean
- [ ] 10.2 Configure MDB to listen on JMS Queue for purchase orders
- [ ] 10.3 Implement MessageListener.onMessage() to receive TextMessage
- [ ] 10.4 Extract XML content from received messages
- [ ] 10.5 Call OrderFulfillmentFacadeEJB.processPO() for message processing
- [ ] 10.6 Implement doTransition() to send invoices back to OPC via JMS
- [ ] 10.7 Set transaction attribute to Required

## 11. Service Integration

- [ ] 11.1 Define JNDI names in JNDINames class for SupplierOrder, ContactInfo, LineItem, Address
- [ ] 11.2 Configure EJB local references in ejb-jar.xml
- [ ] 11.3 Implement ServiceLocator usage in ejbPostCreate() to resolve references
- [ ] 11.4 Map JNDI references to ejb-link targets in deployment descriptor

## 12. Administration Interface

- [ ] 12.1 Create displayinventory.jsp screen to display inventory items
- [ ] 12.2 Implement inventory quantity input form for administrators
- [ ] 12.3 Create DisplayInventoryBean to fetch all inventory items
- [ ] 12.4 Implement RcvrRequestProcessor servlet to handle inventory updates
- [ ] 12.5 Implement updateInventory() to persist new quantities
- [ ] 12.6 Implement sendInvoices() to transmit fulfilled invoices
- [ ] 12.7 Wrap inventory update and pending order processing in UserTransaction
- [ ] 12.8 Configure administrator role requirement in web.xml security-constraint
- [ ] 12.9 Create login.jsp with j_security_check form-based authentication
- [ ] 12.10 Configure 54-minute session timeout in web.xml

## 13. Transaction and Security

- [ ] 13.1 Configure container-transaction Required for all SupplierOrderEJB methods
- [ ] 13.2 Configure container-transaction Required for all InventoryEJB methods
- [ ] 13.3 Configure container-transaction Required for OrderFulfillmentFacadeEJB methods
- [ ] 13.4 Configure unchecked method permissions for SupplierOrderEJB
- [ ] 13.5 Configure security-constraint for RcvrRequestProcessor with administrator role
- [ ] 13.6 Implement role-based authorization in web tier
