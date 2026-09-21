# Order Fulfillment Design Notes

## User interface

No screen records were extracted for this capability; its user interface is unspecified.

## Legacy Implementation Architecture

### Order Fulfillment Facade

**OrderFulfillmentFacadeEJB** provides fulfillment workflow processing with methods for checking inventory availability, reducing quantities, and processing shipments.

### Inventory Management

**Inventory Entity** contains quantity field reduced via `reduceQuantity()` method when orders are fulfilled. Availability checking uses `inv.getQuantity() < item.getQuantity()` comparison.

### Order Status Model

Orders progress through states: PENDING → PROCESSING → PARTIAL/COMPLETED. Status transitions driven by inventory availability and partial fulfillment completion.

### Line Item Processing

LineItem entities carry quantity, unit price, category ID, and item ID. Each line item checked independently for inventory availability, enabling partial fulfillment.

### Supplier Integration

When customer orders cannot be fulfilled from inventory, system generates PurchaseOrder records for suppliers via supplier module. Supplier fulfillment triggers shipment generation.

### Message Processing

AsyncSender EJB queues fulfillment requests as XML messages. Message-driven beans process asynchronously, decoupling fulfillment from request receipt.

### Transaction Management

Container-managed transactions with "Required" semantics ensure inventory operations are atomic. Failed transactions trigger order status rollback.

### Configuration

**ejb-jar.xml** declares fulfillment beans with transaction attributes. Resource references configure supplier and inventory data sources.

## Known Limitations

1. No visible retry mechanism for failed supplier orders
2. Fulfillment deadline enforcement not implemented in visible code
3. Partial fulfillment logic depends on line item processing sequence
4. Inventory locking strategy for concurrent orders not documented
5. Shipment tracking functionality not fully visible in extracted records
