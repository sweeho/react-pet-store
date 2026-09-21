## ADDED Requirements

### Requirement: Cart item structure

The system SHALL store cart items with itemId, productId, category, name, attribute, quantity (int), and unitCost (double).

#### Scenario: Cart item created with all fields

- **GIVEN** a new cart item
- **WHEN** the item is stored with all 7 fields
- **THEN** all fields are accessible via getters

### Requirement: Add item to cart

The system SHALL support adding items to cart with addItem(String itemId) defaulting quantity to 1, or addItem(String itemId, int quantity) with explicit quantity.

#### Scenario: Item added with default quantity

- **GIVEN** addItem("ITEM123") called
- **WHEN** the operation completes
- **THEN** quantity is set to 1

### Requirement: Remove item from cart

The system SHALL support removing items from cart by itemId via deleteItem().

#### Scenario: Item removed successfully

- **GIVEN** an item in the cart
- **WHEN** deleteItem(itemId) is called
- **THEN** the item is removed

### Requirement: Update item quantity

The system SHALL support updating quantities; quantity <= 0 triggers removal.

#### Scenario: Quantity updated to positive value

- **GIVEN** an item with quantity 2
- **WHEN** updateItemQuantity(itemId, 5) is called
- **THEN** quantity becomes 5

#### Scenario: Quantity updated to 0 removes item

- **GIVEN** an item in the cart
- **WHEN** updateItemQuantity(itemId, 0) is called
- **THEN** the item is removed

### Requirement: Empty cart

The system SHALL support emptying the cart, removing all items.

#### Scenario: Cart is cleared

- **GIVEN** a cart with items
- **WHEN** empty() is called
- **THEN** all items are removed

### Requirement: Cart total calculation

The system SHALL calculate cart subtotal as sum of (unitCost × quantity) for all items.

#### Scenario: Total calculated correctly

- **GIVEN** items: (2 × $10.00) + (3 × $5.00)
- **WHEN** getSubTotal() is called
- **THEN** the result is $35.00

### Requirement: Cart item count

The system SHALL provide getCount() returning number of items in cart.

#### Scenario: Count returns correct value

- **GIVEN** a cart with 3 items
- **WHEN** getCount() is called
- **THEN** 3 is returned

### Requirement: Cart display with empty state

The cart display screen SHALL show an "empty cart" message when cart.count == 0.

#### Scenario: Empty cart message displayed

- **GIVEN** a shopping cart with no items
- **WHEN** the cart screen is displayed
- **THEN** "Your Shopping Cart is Empty" message appears

### Requirement: Cart display with items

The cart display screen SHALL show each item's itemId, name, attribute, quantity (in input field), unit cost, and line total (quantity × unitCost), all formatted as currency.

#### Scenario: Cart items displayed with all details

- **GIVEN** a cart with one item (ITEM123, Widget A, Red, qty=2, $10.00)
- **WHEN** the cart screen is displayed
- **THEN** all item details are shown including formatted prices

### Requirement: Checkout link

The cart display screen SHALL provide a "Check Out" link navigating to order placement when cart is not empty.

#### Scenario: Checkout link displayed for non-empty cart

- **GIVEN** a cart with items
- **WHEN** the cart screen is displayed
- **THEN** a "Check Out" link appears pointing to enter_order_information.screen

### Requirement: Cart enrichment from catalog

The system SHALL enrich cart data (itemId → quantity) by calling the Catalog component to fetch full item details.

#### Scenario: Cart items enriched with catalog data

- **GIVEN** cart with itemId "ITEM123" (quantity 2)
- **WHEN** getItems() is called
- **WHEN** each item is enriched from catalog
- **THEN** a CartItem is returned with full details

### Requirement: Locale-aware cart

The system SHALL support Locale.US by default with setLocale() override for catalog lookups.

#### Scenario: Cart locale set and used

- **GIVEN** a cart with setLocale(Locale.FRANCE)
- **WHEN** getItems() enriches items from catalog
- **THEN** catalog items are fetched using FRANCE locale

### Requirement: Quantity validation

The system SHALL treat non-numeric quantity inputs as 0, triggering item removal.

#### Scenario: Non-numeric input defaults to removal

- **GIVEN** a quantity input with value "abc"
- **WHEN** the input is parsed
- **THEN** quantity 0 is used, removing the item
