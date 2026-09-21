# Order Tracking Specification Extraction

## Summary

This specification documents the order tracking capability of the legacy Java Pet Store application, covering order status management, workflow state transitions, and administrative query capabilities for order visibility and reporting.

## Scope

- Order status tracking through workflow states
- Order status retrieval and querying
- Administrative order queries by status
- Order analytics and reporting (revenue, order counts by category)
- Date range-based order filtering
- Order workflow state machine transitions

## Key Components

- **OPC Admin Facade** (`apps/opc`): Admin query interface for order status and analytics
- **ProcessManager** (`components/processmanager`): Workflow state management
- **PurchaseOrder** (`components/purchaseorder`): Order entity with status tracking
- **Order Approval MDB** (`apps/opc`): Order status transition processing

## Design Decisions

1. **State Machine Enforcement**: Orders follow explicit state transitions (PENDING → APPROVED/DENIED → SHIPPED_PART/COMPLETED)
2. **Idempotent Processing**: Non-PENDING orders are skipped to prevent re-processing
3. **Admin Facade Pattern**: Stateless session bean provides coarse-grained admin access without exposing MDB architecture
4. **Date Range Filtering**: Orders queryable within configurable date windows for reporting
5. **Category-Based Analytics**: Revenue and order counts aggregatable by product category

## Implementation Considerations

- Container-managed transactions ensure consistency across status updates
- Process manager maintains authoritative order state
- Admin facade delegates to process manager and purchase order EJBs
- No role-based authorization on workflow operations (unchecked access)
- Date formatting applied at facade layer (MM/DD/YYYY format)
