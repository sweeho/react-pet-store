## 1. Status Model

- [ ] 1.1 Define OrderStatus enum with PENDING, APPROVED, DENIED, SHIPPED_PART, COMPLETED states
- [ ] 1.2 Document state transition rules (PENDING→APPROVED→SHIPPED_PART→COMPLETED OR PENDING→DENIED)
- [ ] 1.3 Create status constants registry

## 2. Process Manager Service

- [ ] 2.1 Implement ProcessManager service (or EJB) to manage workflow state
- [ ] 2.2 Implement createManager(orderId, initialStatus) method
- [ ] 2.3 Implement getStatus(orderId) method
- [ ] 2.4 Implement updateStatus(orderId, newStatus) method
- [ ] 2.5 Implement getOrdersByStatus(status) method with query
- [ ] 2.6 Add Required transaction attribute to all methods

## 3. Order Status Persistence

- [ ] 3.1 Create or wire Manager entity for persisting order workflow state
- [ ] 3.2 Define orderId as primary key
- [ ] 3.3 Define status as queryable field
- [ ] 3.4 Set up CMP or ORM mapping for persistence

## 4. Order Status Transitions

- [ ] 4.1 Implement transition logic in approval handlers
- [ ] 4.2 Enforce idempotent processing (skip non-PENDING orders)
- [ ] 4.3 Implement status check before processing: `getStatus(orderId) == PENDING`
- [ ] 4.4 Implement transition from PENDING to APPROVED
- [ ] 4.5 Implement transition from PENDING to DENIED
- [ ] 4.6 Implement transition to SHIPPED_PART (partial fulfillment)
- [ ] 4.7 Implement transition to COMPLETED (full fulfillment)

## 5. Admin Query Facade

- [ ] 5.1 Create admin facade session bean
- [ ] 5.2 Implement Remote interface for admin access
- [ ] 5.3 Set transaction attribute to Required
- [ ] 5.4 Configure unchecked (public) access
- [ ] 5.5 Wire dependency to ProcessManager
- [ ] 5.6 Wire dependency to PurchaseOrder home

## 6. Order Status Query

- [ ] 6.1 Implement getOrdersByStatus(status) method
- [ ] 6.2 Query ProcessManager for orders in given status
- [ ] 6.3 For each order ID, retrieve PurchaseOrder entity
- [ ] 6.4 Extract order details: ID, user ID, date, value
- [ ] 6.5 Format date as MM/DD/YYYY
- [ ] 6.6 Build OrderDetails transfer objects
- [ ] 6.7 Return ordered collection

## 7. Order Analytics and Reporting

- [ ] 7.1 Implement getChartInfo() method
- [ ] 7.2 Accept parameters: request type (ORDERS|REVENUE), start date, end date, category filter
- [ ] 7.3 Query PurchaseOrders within date range
- [ ] 7.4 Iterate line items for each order
- [ ] 7.5 For REVENUE requests: aggregate (quantity × unitPrice) by category
- [ ] 7.6 For ORDERS requests: aggregate order counts by category
- [ ] 7.7 Support null category filter (all categories)
- [ ] 7.8 Return HashMap with aggregated results

## 8. State Machine Validation

- [ ] 8.1 Validate PENDING status before allowing transitions
- [ ] 8.2 Implement skip logic for already-processed orders
- [ ] 8.3 Test state machine enforcement with multiple state changes

## 9. Transaction Management

- [ ] 9.1 Configure container-managed transactions for all methods
- [ ] 9.2 Ensure atomicity of status updates
- [ ] 9.3 Test rollback on validation errors

## 10. Testing

- [ ] 10.1 Test status retrieval for single order
- [ ] 10.2 Test status transitions (PENDING→APPROVED, PENDING→DENIED)
- [ ] 10.3 Test idempotent processing (skip non-PENDING orders)
- [ ] 10.4 Test getOrdersByStatus() with each status value
- [ ] 10.5 Test date range filtering
- [ ] 10.6 Test analytics aggregation by category
- [ ] 10.7 Test global aggregation (null category filter)
- [ ] 10.8 Test concurrent status updates
- [ ] 10.9 Test transaction rollback scenarios
