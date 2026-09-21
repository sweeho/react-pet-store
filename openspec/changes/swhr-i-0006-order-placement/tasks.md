## 1. Order Validation

- [ ] 1.1 Implement cart validation to prevent empty cart orders
- [ ] 1.2 Define ShoppingCartEmptyOrderException type
- [ ] 1.3 Wire validation exception to error response

## 2. Order ID Generation

- [ ] 2.1 Create UniqueIdGenerator service or delegate
- [ ] 2.2 Implement getUniqueId() with counter prefix support
- [ ] 2.3 Configure "1001" counter prefix for order ID namespace
- [ ] 2.4 Wire ID generation into order creation flow

## 3. Contact Information Collection

- [ ] 3.1 Create ContactInfo and Address data models
- [ ] 3.2 Implement extractContactInfo() for billing information
- [ ] 3.3 Implement extractContactInfo() for shipping information
- [ ] 3.4 Validate all required contact fields
- [ ] 3.5 Wire field validation errors back to form

## 4. Order Data Model

- [ ] 4.1 Create PurchaseOrder entity with all required fields
- [ ] 4.2 Create LineItem entity
- [ ] 4.3 Define orderId, userId, orderDate, emailId fields
- [ ] 4.4 Wire shippingInfo and billingInfo ContactInfo references
- [ ] 4.5 Implement lineItems collection

## 5. Order Processing

- [ ] 5.1 Create OrderEJBAction handler
- [ ] 5.2 Implement OrderEvent parsing
- [ ] 5.3 Calculate order total from cart items
- [ ] 5.4 Create LineItem objects from CartItems
- [ ] 5.5 Persist PurchaseOrder to database

## 6. Payment Information

- [ ] 6.1 Create CreditCard data model
- [ ] 6.2 Implement credit card extraction from form
- [ ] 6.3 Store credit card with purchase order
- [ ] 6.4 Implement card field validation

## 7. Screen Templates

- [ ] 7.1 Create enter_order_information template
- [ ] 7.2 Implement billing address fields (suffix \_a)
- [ ] 7.3 Implement shipping address fields (suffix \_b)
- [ ] 7.4 Add form validation attributes to template
- [ ] 7.5 Create order_completed confirmation template
- [ ] 7.6 Implement locale variants (en_US, ja_JP, zh_CN)

## 8. Transaction Management

- [ ] 8.1 Configure container-managed transactions (Required)
- [ ] 8.2 Enable transaction isolation for order persistence
- [ ] 8.3 Test rollback on validation failures

## 9. Testing

- [ ] 9.1 Test empty cart rejection
- [ ] 9.2 Test successful order creation with valid data
- [ ] 9.3 Test contact field validation
- [ ] 9.4 Test order ID uniqueness
- [ ] 9.5 Test order total calculation
- [ ] 9.6 Test transaction rollback on errors
- [ ] 9.7 Test locale-specific screen rendering
