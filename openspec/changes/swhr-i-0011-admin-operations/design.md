# Admin Operations Design Notes

## Legacy Implementation

### Order Status Management

**ProcessManagerEJB** - Stateless session bean for order administration:

- `getOrdersByStatus(String status)` - Retrieves all orders in a given status for admin dashboard
- `getOrdersByDateRange(Date start, Date end)` - Returns orders placed within date range
- `getOrdersByCategory(String categoryId, Date start, Date end)` - Returns orders with items from specific category
- Transaction attribute: Required (all operations)

### Status Workflow

**OrderStatus entity** - Defines workflow states:

- PENDING - Order received, awaiting approval
- APPROVED - Order approved for fulfillment
- COMPLETED - Order fulfilled and shipped
- DENIED - Order denied or cancelled
- SHIPPED_PART - Partially shipped items

Transitions: PENDING → APPROVED → COMPLETED or PENDING → DENIED

### Admin Interface

**SupplierAdmin application** - Web interface for inventory and order management:

- Form-based authentication with "administrator" role
- Inventory update screen displaying current stock levels
- Order status view with filtering and sorting

### Order Reprocessing

When inventory is updated, previously PENDING orders are re-attempted for fulfillment.
