## ADDED Requirements

### Requirement: Supplier Order entity structure

The system SHALL maintain a SupplierOrder entity with container-managed persistence containing at minimum the fields: purchase order identifier (poId as String primary key), purchase order date (poDate as long), and purchase order status (poStatus as String).

#### Scenario: SupplierOrder created with all fields

- **GIVEN** a purchase order object with ID, date, and status
- **WHEN** the SupplierOrder entity is created via ejbCreate()
- **THEN** all three fields are persisted and retrievable via getters

### Requirement: Initial order status

When a new supplier purchase order is created, the system SHALL automatically initialize its status to PENDING.

#### Scenario: New order starts in PENDING state

- **GIVEN** a new SupplierOrder being created
- **WHEN** ejbCreate() is called
- **THEN** setPoStatus() is called with OrderStatusNames.PENDING

### Requirement: Purchase order status transitions

The system SHALL support purchase order status transitions following one of two paths: PENDING → APPROVED → COMPLETED, or PENDING → DENIED. No other state transitions are permitted.

#### Scenario: Valid transition from PENDING to APPROVED

- **GIVEN** an order in PENDING status
- **WHEN** the order is approved
- **THEN** status is transitioned to APPROVED

#### Scenario: Valid transition from APPROVED to COMPLETED

- **GIVEN** an order in APPROVED status
- **WHEN** order fulfillment completes
- **THEN** status is transitioned to COMPLETED

#### Scenario: Valid transition from PENDING to DENIED

- **GIVEN** an order in PENDING status
- **WHEN** the order is denied
- **THEN** status is transitioned to DENIED

### Requirement: Supplier Order to ContactInfo relationship

Every SupplierOrder SHALL have exactly one associated ContactInfo entity containing supplier contact information. This relationship SHALL be one-to-one and unidirectional from SupplierOrder to ContactInfo. If the SupplierOrder is deleted, the associated ContactInfo SHALL also be deleted (cascade delete).

#### Scenario: ContactInfo created with SupplierOrder

- **GIVEN** a SupplierOrder being created with shipping information
- **WHEN** ejbPostCreate() executes
- **THEN** a ContactInfo entity is created and associated via setContactInfo()

#### Scenario: ContactInfo deleted when SupplierOrder deleted

- **GIVEN** a SupplierOrder with associated ContactInfo
- **WHEN** the SupplierOrder is removed
- **THEN** the ContactInfo is automatically deleted via cascade delete

### Requirement: Supplier Order to LineItem relationship

Every SupplierOrder SHALL contain one or more LineItem entities representing the line items in the purchase order. This relationship SHALL be one-to-many from SupplierOrder to LineItem. If the SupplierOrder is deleted, all associated LineItems SHALL also be deleted (cascade delete).

#### Scenario: LineItems created with SupplierOrder

- **GIVEN** a SupplierOrder with 3 line items
- **WHEN** ejbPostCreate() executes
- **THEN** three LineItem entities are created and associated via addLineItem()

#### Scenario: LineItems deleted when SupplierOrder deleted

- **GIVEN** a SupplierOrder with multiple LineItems
- **WHEN** the SupplierOrder is removed
- **THEN** all associated LineItems are automatically deleted via cascade delete

### Requirement: Supplier Order query by status

The system SHALL provide a finder operation to retrieve all SupplierOrders by their current status. GIVEN a status value, the system WHEN queried THEN SHALL return a collection of all orders with that status.

#### Scenario: Find PENDING orders

- **GIVEN** a database with orders in multiple states
- **WHEN** findOrdersByStatus(OrderStatusNames.PENDING) is called
- **THEN** only orders with status PENDING are returned

#### Scenario: Find COMPLETED orders

- **GIVEN** a database with orders in multiple states
- **WHEN** findOrdersByStatus(OrderStatusNames.COMPLETED) is called
- **THEN** only orders with status COMPLETED are returned

### Requirement: Supplier Order web-tier access to line items

When accessing line items through the SupplierOrder interface from the web tier, the system SHALL provide an getAllItems() method that returns line item data without exposing container-managed relationship (CMR) field references. This allows web-tier access to line items outside of a transactional context.

#### Scenario: Web tier retrieves line items

- **GIVEN** a SupplierOrder with 2 LineItems in a web-tier request (outside transaction)
- **WHEN** getAllItems() is called
- **THEN** a collection of LineItem data objects is returned (not managed CMR objects)

### Requirement: Supplier Order data transfer object

The system SHALL provide a getData() method on SupplierOrder that returns a complete data transfer object (SupplierOrder POJO) containing all order information: identifier, date, shipping contact, and all associated line items. All data conversions from EJB-managed types to serializable POJOs SHALL be performed by this method.

#### Scenario: SupplierOrder converted to POJO

- **GIVEN** a SupplierOrder entity with ID, date, contact info, and line items
- **WHEN** getData() is called
- **THEN** a complete SupplierOrder POJO is returned with all fields populated

### Requirement: XML serialization of purchase orders

The system SHALL support converting a SupplierOrder to and from XML representation, including serialization to XML with DTD validation and deserialization from XML strings or DOM structures.

#### Scenario: SupplierOrder serialized to XML

- **GIVEN** a SupplierOrder object with all fields
- **WHEN** toXML() is called
- **THEN** a valid XML string is returned conforming to SupplierOrder.dtd

#### Scenario: SupplierOrder deserialized from XML

- **GIVEN** an XML string containing purchase order data
- **WHEN** fromXML() is called
- **THEN** a SupplierOrder object is populated with all elements from XML

### Requirement: Inventory entity structure

The system SHALL maintain Inventory entities with container-managed persistence containing the following attributes: itemId (String primary key) and quantity (integer representing current stock level).

#### Scenario: Inventory created with itemId and quantity

- **GIVEN** an inventory item with ID EST-1 and quantity 10000
- **WHEN** the Inventory entity is created
- **THEN** itemId and quantity fields are persisted and retrievable

### Requirement: Inventory fulfillment check

The system SHALL only fulfill an order if inventory quantity is greater than or equal to the line item quantity requested. If insufficient stock exists, the system SHALL NOT reduce inventory for that item and SHALL NOT mark it as shipped. Instead, the line item SHALL remain in PENDING state for later fulfillment when inventory becomes available.

#### Scenario: Order fulfilled when inventory sufficient

- **GIVEN** inventory with 100 units of item EST-5 and order requesting 50 units
- **WHEN** checkInventory() is called
- **THEN** inventory is reduced by 50 and method returns success

#### Scenario: Order not fulfilled when inventory insufficient

- **GIVEN** inventory with 30 units of item EST-5 and order requesting 50 units
- **WHEN** checkInventory() is called
- **THEN** inventory is NOT modified and method returns failure

### Requirement: Inventory quantity reduction atomicity

When inventory quantity is reduced during order fulfillment, the comparison and reduction operations SHALL occur atomically in a single database operation to prevent concurrent over-allocation.

#### Scenario: Inventory reduction is atomic

- **GIVEN** inventory with 100 units and two concurrent requests for 60 units each
- **WHEN** both requests attempt fulfillment simultaneously
- **THEN** only one request succeeds (reduces to 40) and the other fails (insufficient stock)

### Requirement: Invoice generation for fulfilled items

The system SHALL generate an invoice XML document for each purchase order that has been partially or fully fulfilled, containing the item details of all line items that were shipped.

#### Scenario: Invoice created after fulfillment

- **GIVEN** a purchase order with 3 line items, 2 of which are fulfilled
- **WHEN** createInvoice() is called
- **THEN** an XML invoice is generated containing only the 2 fulfilled items

### Requirement: Asynchronous purchase order intake

The system SHALL accept purchase orders from the Order Processing Center via asynchronous JMS message queue processing, with SupplierOrderMDB listening for and processing TextMessage objects containing XML purchase order documents.

#### Scenario: JMS message received and processed

- **GIVEN** a TextMessage containing XML purchase order document on the JMS queue
- **WHEN** SupplierOrderMDB.onMessage() receives the message
- **THEN** the message content is extracted and passed to OrderFulfillmentFacadeEJB.processPO()

### Requirement: Pending purchase order re-processing

WHEN new inventory arrives and is recorded via inventory update, the system SHALL call processPendingPO() on the OrderFulfillmentFacade to re-attempt fulfilling all purchase orders that are still in PENDING status. For each pending order that can now be fulfilled with the newly arrived inventory, an invoice SHALL be generated and sent to the OPC.

#### Scenario: Pending orders fulfilled after inventory update

- **GIVEN** a PENDING purchase order and inventory update adding 100 units of needed item
- **WHEN** inventory update completes and processPendingPO() is called
- **THEN** the pending order is fulfilled and invoice is generated

### Requirement: Order fulfillment transactionality

All order fulfillment operations (inventory checking, quantity reduction, order status updates, invoice generation, and message transmission) SHALL execute within a single container-managed transaction with Required transaction attribute. If any step fails, the entire transaction SHALL rollback, leaving inventory and order state unchanged.

#### Scenario: Transaction rollback on fulfillment failure

- **GIVEN** fulfillment operation mid-execution that encounters an error
- **WHEN** an exception is thrown during invoice generation
- **THEN** the entire transaction is rolled back, inventory is restored, and order status unchanged

### Requirement: Supplier inventory update screen

The supplier inventory management screen SHALL display all items in inventory with their current quantities, allow administrators to enter new quantities, and provide controls to select items for update. The screen SHALL show columns for Item ID, Existing Quantity, and New Quantity input field, and a checkbox to select items for update.

#### Scenario: Administrator views all inventory items

- **GIVEN** an authenticated administrator accessing the inventory update screen
- **WHEN** displayinventory.jsp is rendered
- **THEN** a table is displayed with all inventory items (EST-1 through EST-29), their current quantities, and input controls for new quantities

#### Scenario: Non-administrator denied access to inventory

- **GIVEN** a non-administrator user attempting to access the inventory screen
- **WHEN** displayinventory.jsp is requested
- **THEN** an authorization message is displayed instead of the inventory update form
