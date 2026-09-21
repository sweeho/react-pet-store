## ADDED Requirements

### Requirement: Order status retrieval

The system SHALL provide a method to retrieve the current workflow status of an order by its orderId. GIVEN an order ID, WHEN the status is requested, THEN the system SHALL return the current status string (PENDING, APPROVED, DENIED, SHIPPED_PART, or COMPLETED).

#### Scenario: Status retrieved successfully

- **GIVEN** an order with ID "ORD-12345" currently in APPROVED status
- **WHEN** getStatus("ORD-12345") is called
- **THEN** the system returns "APPROVED"

#### Scenario: Multiple orders have different statuses

- **GIVEN** three orders in the system with different statuses
- **WHEN** each order's status is retrieved
- **THEN** the system returns the correct status for each order independently

### Requirement: Order status tracking through workflow states

The system SHALL track order status through defined state transitions: PENDING → (APPROVED or DENIED) → (SHIPPED_PART or COMPLETED). Orders already in APPROVED, DENIED, SHIPPED_PART, or COMPLETED states SHALL NOT be re-processed; only PENDING orders are eligible for status updates.

#### Scenario: Status transitions from PENDING to APPROVED

- **GIVEN** an order currently in PENDING status
- **WHEN** the order is approved
- **THEN** the status transitions to APPROVED

#### Scenario: Order in APPROVED status skips re-processing

- **GIVEN** an order already in APPROVED status
- **WHEN** an approval message is received again for this order
- **THEN** the system skips processing and leaves status unchanged

#### Scenario: PENDING order transitions to DENIED

- **GIVEN** a PENDING order that does not meet approval criteria
- **WHEN** the order is explicitly denied
- **THEN** the status transitions to DENIED

#### Scenario: APPROVED order transitions to SHIPPED_PART

- **GIVEN** an APPROVED order with partial supplier fulfillment
- **WHEN** partial inventory is received
- **THEN** the status transitions to SHIPPED_PART

#### Scenario: Order transitions to COMPLETED when all items shipped

- **GIVEN** an order in SHIPPED_PART status with all remaining items received
- **WHEN** all line items for the order have been fulfilled
- **THEN** the status transitions to COMPLETED

### Requirement: Administrative order status query

The system SHALL provide administrative capability to query all orders by status and retrieve order details. GIVEN a status value (PENDING, APPROVED, DENIED, SHIPPED_PART, or COMPLETED), WHEN the query is executed, THEN the system SHALL return all orders in that status with details including order ID, user ID, order date (formatted as MM/DD/YYYY), and total order value.

#### Scenario: Query returns all PENDING orders

- **GIVEN** three PENDING orders and two APPROVED orders in the system
- **WHEN** getOrdersByStatus("PENDING") is called
- **THEN** the system returns exactly three order details records

#### Scenario: Order date is formatted correctly

- **GIVEN** an order placed on January 15, 2024
- **WHEN** the order details are retrieved via status query
- **THEN** the order date is formatted as "01/15/2024"

#### Scenario: Complete order details are returned

- **GIVEN** an order with ID "PO-98765", user ID "user-001", date "03/20/2024", value 249.99
- **WHEN** the order is queried by status
- **THEN** all four details (ID, user ID, date, value) are included in the result

### Requirement: Order analytics by date range

The system SHALL provide administrative capability to generate analytics data for orders by querying orders within a date range and aggregating revenue and order counts by product category. GIVEN a request type (ORDERS for count or REVENUE for dollar amount), start date, end date, and optional category filter, WHEN the query is executed, THEN the system SHALL return a map with category ID as key and aggregated value as value. For REVENUE requests, the value SHALL be the sum of (line item quantity × unit price) for all items in that category within the date range. For ORDERS requests, the value SHALL be the count of line items ordered. If category filter is null, aggregation SHALL be global across all categories.

#### Scenario: Revenue aggregation by category

- **GIVEN** orders placed between 01/01/2024 and 12/31/2024 with:
  - Category "ELECTRONICS": Item A (qty 2 @ $100) + Item B (qty 1 @ $50) = $250
  - Category "BOOKS": Item C (qty 5 @ $20) = $100
- **WHEN** getChartInfo("REVENUE", start, end, null) is called
- **THEN** the result is a map with {"ELECTRONICS": 250.0, "BOOKS": 100.0}

#### Scenario: Order count by category

- **GIVEN** orders with 7 line items in ELECTRONICS and 3 in BOOKS within the date range
- **WHEN** getChartInfo("ORDERS", start, end, null) is called
- **THEN** the result is a map with {"ELECTRONICS": 7, "BOOKS": 3}

#### Scenario: Filtered aggregation by single category

- **GIVEN** orders with items in ELECTRONICS, BOOKS, and TOYS categories
- **WHEN** getChartInfo("REVENUE", start, end, "ELECTRONICS") is called
- **THEN** only ELECTRONICS revenue is returned

#### Scenario: Empty date range returns empty results

- **GIVEN** a date range with no orders
- **WHEN** getChartInfo() is called with that date range
- **THEN** an empty map is returned

### Requirement: Idempotent order processing

The system SHALL skip processing of orders that are not in PENDING status. When an order status update message is received, the system SHALL first retrieve the current status via getStatus(). If the status is not PENDING, the system SHALL skip the order and continue with the next order.

#### Scenario: Non-PENDING order is skipped

- **GIVEN** an order in APPROVED status and a batch approval message including this order
- **WHEN** the batch is processed
- **THEN** the order is skipped and not re-processed

#### Scenario: Multiple orders in batch, mixed states

- **GIVEN** a batch of three orders: two PENDING and one already APPROVED
- **WHEN** the batch is processed
- **THEN** the two PENDING orders are processed and the APPROVED order is skipped

### Requirement: Order status update within transaction

The system SHALL execute all order status updates within a container-managed transaction with Required transaction attribute. GIVEN a status update request, WHEN updateStatus() is called, THEN the status field is updated atomically; if an error occurs, the entire transaction rolls back and the status remains unchanged.

#### Scenario: Status update commits successfully

- **GIVEN** an order ready for status update from PENDING to APPROVED
- **WHEN** updateStatus(orderId, "APPROVED") completes successfully
- **THEN** the status is persisted and visible to subsequent queries

#### Scenario: Transaction rolls back on error

- **GIVEN** a status update that fails partway through
- **WHEN** an exception occurs during processing
- **THEN** the container rolls back the transaction and the original status is preserved
