# Order Placement Design Notes

## User Interface

Two screen records were extracted for this capability (order entry and confirmation screens). Screen-specific visible contracts are documented in spec.md as requirements; legacy implementation details are included below.

## Legacy Implementation Architecture

### Order Action Handler

**OrderEJBAction** (`apps/petstore/controller/ejb/actions/OrderEJBAction.java`)

- Event handler for order placement
- Validates that shopping cart is not empty
- Retrieves cart items via ShoppingClientFacadeLocal
- Throws ShoppingCartEmptyOrderException if cart.getItems().size() == 0
- Extracts order data from OrderEvent (billTo, shipTo, creditCard)
- Generates unique order ID via UniqueIdGeneratorLocal.getUniqueId("1001")
- Creates PurchaseOrder object with all order details
- Sets total price by iterating through cart items: totalCost += (item.getUnitCost() \* item.getQuantity())
- Creates LineItem objects for each cart item with category, product ID, item ID, quantity, and unit cost

### Unique ID Generation

**UniqueIdGeneratorLocal** EJB

- Session bean for generating unique identifiers
- Called with counter prefix "1001" for order IDs
- Returns String identifier for use as order ID
- Located via ServiceLocator JNDI lookup

### Contact Information Handling

**OrderHTMLAction** (`apps/petstore/controller/web/actions/OrderHTMLAction.java`)

- Web action handler for order information entry
- Extracts billing contact info via extractContactInfo() with suffix "\_a"
- Extracts shipping contact info via extractContactInfo() with suffix "\_b"
- Validates all contact fields as required:
  - familyName (last name)
  - givenName (first name)
  - address1 (street)
  - city
  - stateOrProvince
  - postalCode
  - telephone
  - email
- Missing field validation builds missingFields ArrayList
- Returns form errors if any required fields are missing

### Order Data Model

**PurchaseOrder** entity

- Fields: orderId, userId, orderDate, emailId, shippingInfo (ContactInfo), billingInfo (ContactInfo), creditCard, lineItems
- Maps to database via ORM
- Constructed in OrderEJBAction and populated with order details

**LineItem** model

- Represents individual items within an order
- Fields: category, productId, itemId, lineItemCount, quantity, unitCost
- Created from CartItem objects
- Stored within PurchaseOrder

### Screen Templates (Legacy JSP)

**enter_order_information.jsp**

- Collects shipping and billing address information
- Form posts to order.do endpoint
- Fields: familyName, givenName, address1, address2, city, stateOrProvince, postalCode, telephone, email
- Localized variants: en_US, ja_JP, zh_CN
- Suffix \_a denotes billing fields
- Suffix \_b denotes shipping fields

**order_completed.jsp**

- Confirmation screen shown after successful order processing
- Displays completed order information
- Localized variants for internationalization

### Exception Handling

**ShoppingCartEmptyOrderException**

- Thrown when cart.getItems().size() == 0
- Mapped to cart_empty_order_error.screen in mappings.xml
- Programmatic validation in OrderEJBAction

### Configuration (ejb-jar.xml)

- OrderEJBAction transaction attribute: Required (container-managed)
- OrderFacadeEJB transaction attribute: Required
- JNDI resource references for UIGen EJB home

## Known Limitations

1. Cart validation is size-based; item validity not checked
2. Unique ID counter prefix "1001" purpose unclear (counter type vs category ID)
3. Email address extraction and validation not visible in order handler
4. Order date set to system time at order creation; no future-dated order support visible
5. LineItem count is incremented but purpose unclear (sequential numbering vs order ID reference)
