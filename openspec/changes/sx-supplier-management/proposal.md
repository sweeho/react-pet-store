# Supplier Management Specification Extraction

## Summary

Specification for supplier order management functionality in the legacy Java Pet Store application, covering purchase order lifecycle, inventory tracking, and order fulfillment workflow.

## Scope

- Supplier purchase order entity management
- Purchase order status workflow and state transitions
- Inventory tracking and quantity management
- Order fulfillment via asynchronous JMS message processing
- Invoice generation for fulfilled orders
- Inventory update and pending order re-processing
- Supplier contact information and line item associations

## Key Components

- **SupplierPO Component** (`components/supplierpo`): Supplier order entity, DTD schema, XML serialization
- **Supplier App** (`apps/supplier`): Order fulfillment, inventory management, JMS message processing
- **SupplierOrderEJB** (CMP 2.x entity bean): Core purchase order persistence
- **InventoryEJB** (CMP 2.x entity bean): Inventory item tracking
- **OrderFulfillmentFacadeEJB** (Session bean): Order processing logic
- **SupplierOrderMDB** (Message-driven bean): Asynchronous order intake

## Design Decisions

1. **CMP 2.x Entity Persistence**: SupplierOrder and Inventory use container-managed persistence with declarative configuration
2. **Asynchronous Order Processing**: Orders received via JMS queues, processed by MDB with message translation
3. **Transactional Integrity**: All order and inventory operations use Required transaction attribute for ACID guarantees
4. **XML Serialization**: Purchase orders and invoices use DTD-validated XML format for data transfer
5. **Status State Machine**: Orders transition through PENDING → APPROVED → COMPLETED or PENDING → DENIED states
6. **Cascade Relationships**: ContactInfo and LineItems deleted when parent SupplierOrder is deleted
7. **Inventory Atomicity**: Single inventory check+reduce operation prevents concurrent over-allocation

## Implementation Considerations

- Relationship cardinality: SupplierOrder has one ContactInfo and many LineItems
- Local EJB references resolved via ServiceLocator with JNDI lookup
- Inventory reduction only occurs when sufficient stock available
- Pending orders re-processed when new inventory becomes available
- Invoice generation tracks only fulfilled items
