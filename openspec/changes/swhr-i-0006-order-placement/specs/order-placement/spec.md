## ADDED Requirements

### Requirement: Non-empty cart validation

The system SHALL prevent order placement from an empty shopping cart. GIVEN a customer with an empty cart attempts to place an order, WHEN the order placement is initiated, THEN the system SHALL throw ShoppingCartEmptyOrderException and display cart_empty_order_error.screen.

#### Scenario: Order with items succeeds

- **GIVEN** a shopping cart containing 2 items
- **WHEN** the customer proceeds to checkout
- **THEN** the order placement is allowed to proceed

#### Scenario: Order with empty cart is rejected

- **GIVEN** a shopping cart with no items
- **WHEN** the customer attempts to place an order
- **THEN** ShoppingCartEmptyOrderException is thrown and the cart_empty_order_error.screen is displayed

### Requirement: Unique order ID generation

The system SHALL assign a unique order ID to each purchase order using the UniqueIdGenerator EJB with counter prefix "1001". Order IDs are generated as strings and stored in the orderId field.

#### Scenario: Order ID is generated and assigned

- **GIVEN** a new order being created
- **WHEN** the order handler calls UniqueIdGenerator.getUniqueId("1001")
- **THEN** a unique string identifier is returned and assigned to the order

#### Scenario: Multiple orders receive different IDs

- **GIVEN** two orders placed in sequence
- **WHEN** each order is assigned an ID via the UniqueIdGenerator
- **THEN** each order receives a unique ID

### Requirement: Billing address collection

The system SHALL collect and validate billing address information from the customer. Billing information MUST include: given name, family name, street address (primary), city, state/province, postal code, and email address. All fields are required for order completion.

#### Scenario: Valid billing address provided

- **GIVEN** an order entry form with all billing fields completed correctly
- **WHEN** the customer submits the billing information
- **THEN** the system accepts the information and proceeds

#### Scenario: Missing required billing field

- **GIVEN** an order entry form with last name field empty
- **WHEN** the customer attempts to submit
- **THEN** the system rejects the submission and displays a missing field error

### Requirement: Shipping address collection

The system SHALL collect and validate shipping address information from the customer. Shipping information MUST include: given name, family name, street address (primary), city, state/province, postal code, and email address. All fields are required for order completion. Shipping information is maintained separately from billing information.

#### Scenario: Shipping differs from billing

- **GIVEN** a customer with different billing and shipping addresses
- **WHEN** both billing and shipping sections are completed with different data
- **THEN** the system captures both address sets independently

#### Scenario: Missing required shipping field

- **GIVEN** shipping address form with telephone field empty
- **WHEN** the customer attempts to submit
- **THEN** the system rejects the submission and displays an error

### Requirement: Order data capture

The system SHALL capture order data including: order ID, user ID, customer email, order date, shipping address (as ContactInfo), billing address (as ContactInfo), credit card information, and line items. The system SHALL calculate order total price as the sum of (unit cost × quantity) for all line items, storing the result as a float.

#### Scenario: Complete order is captured

- **GIVEN** a customer completing order entry with billing, shipping, and payment information
- **WHEN** the order is submitted
- **THEN** all order data is captured with calculated total price

#### Scenario: Order total is calculated correctly

- **GIVEN** an order with line items: (Item A: $10.00 × 2 units), (Item B: $5.00 × 3 units)
- **WHEN** the order total is calculated
- **THEN** the system computes: (10.00 × 2) + (5.00 × 3) = $35.00

### Requirement: Shopping cart clearing

The system SHALL clear the shopping cart (empty it) after a successful order has been placed and submitted. The cart is emptied only after order processing completes.

#### Scenario: Cart is cleared after successful order

- **GIVEN** a customer who has successfully placed an order
- **WHEN** the order processing completes
- **THEN** the shopping cart is emptied and the customer's session cart is reset

#### Scenario: Cart is not cleared on error

- **GIVEN** an order that fails validation
- **WHEN** the order is rejected
- **THEN** the cart retains its items for resubmission or modification

### Requirement: Order entry screen

The order entry screen (enter_order_information.jsp) SHALL display form fields to collect shipping address, billing address, and payment information. The screen SHALL display separate sections for billing information (suffix \_a) and shipping information (suffix \_b), each containing fields for given name, family name, street address, city, state/province, postal code, and email address. The screen SHALL be available in localized variants for en_US, ja_JP, and zh_CN.

#### Scenario: Order entry screen is displayed with all fields

- **GIVEN** a customer navigating to the order entry point
- **WHEN** the enter_order_information.jsp screen is rendered
- **THEN** the screen displays billing section with all required address fields, shipping section with all required address fields, and payment information section

#### Scenario: Locale-specific screen is displayed

- **GIVEN** a customer with locale preference set to ja_JP
- **WHEN** the order entry screen is rendered
- **THEN** the system displays the Japanese localized variant of the order entry form

### Requirement: Order confirmation screen

The order confirmation screen (order_completed.jsp) SHALL be displayed to the customer after successful order placement. The screen SHALL show the order has been completed. The screen SHALL be available in localized variants for en_US, ja_JP, and zh_CN.

#### Scenario: Confirmation screen shown after successful order

- **GIVEN** a customer who has successfully submitted a valid order
- **WHEN** the order processing completes
- **THEN** the order_completed.jsp confirmation screen is displayed

#### Scenario: Locale-specific confirmation screen

- **GIVEN** a customer with locale preference set to zh_CN
- **WHEN** the confirmation screen is rendered after order completion
- **THEN** the system displays the Chinese localized variant of the confirmation screen
