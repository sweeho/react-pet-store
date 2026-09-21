## ADDED Requirements

### Requirement: Order Query by Status

The system SHALL provide a method to retrieve all orders currently in a specific workflow status, returning a collection of orders filtered by status for administrative dashboard and reporting purposes.

#### Scenario: Query orders in PENDING status

- **GIVEN** multiple orders exist with statuses PENDING, APPROVED, COMPLETED
- **WHEN** getOrdersByStatus("PENDING") is called
- **THEN** only orders with status PENDING are returned

#### Scenario: Query orders in COMPLETED status

- **GIVEN** multiple orders exist in various statuses
- **WHEN** getOrdersByStatus("COMPLETED") is called
- **THEN** only COMPLETED orders are returned with full order details

### Requirement: Order Query by Date Range

The system SHALL retrieve all orders placed within a specified date range for administrative reporting and analytics.

#### Scenario: Query orders by date range

- **GIVEN** orders placed on dates 2026-01-01, 2026-06-01, 2026-12-01
- **WHEN** getOrdersByDateRange(2026-01-01, 2026-09-01) is called
- **THEN** orders from Jan 1 through Sep 1 are returned

### Requirement: Order Query by Category

The system SHALL retrieve all orders containing line items from a specific product category within a date range.

#### Scenario: Query orders with items from category

- **GIVEN** orders containing items from "cats", "dogs", "fish" categories
- **WHEN** getOrdersByCategory("dogs", 2026-01-01, 2026-12-31) is called
- **THEN** only orders containing items from "dogs" category in the date range are returned

### Requirement: Admin Role Restriction

The system SHALL restrict administrative order operations to users with the "administrator" role via role-based access control.

#### Scenario: Admin user can access order queries

- **GIVEN** a user with "administrator" role
- **WHEN** admin order queries are called
- **THEN** the user is authorized and results are returned

#### Scenario: Non-admin user cannot access admin operations

- **GIVEN** a user without "administrator" role
- **WHEN** admin order query methods are called
- **THEN** access is denied and no results are returned

### Requirement: Order Status Transitions

The system SHALL manage order status state machine with transitions: PENDING → APPROVED → COMPLETED or PENDING → DENIED.

#### Scenario: Approve pending order

- **GIVEN** an order in PENDING status
- **WHEN** approve(orderId) is called
- **THEN** order status changes to APPROVED

#### Scenario: Deny pending order

- **GIVEN** an order in PENDING status
- **WHEN** deny(orderId) is called
- **THEN** order status changes to DENIED
