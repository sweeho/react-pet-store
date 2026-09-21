## 1. Cart Data Model

- [ ] 1.1 Define CartItem value object with 7 fields
- [ ] 1.2 Implement getTotalCost() calculation
- [ ] 1.3 Create ShoppingCart entity with HashMap storage

## 2. Cart Operations

- [ ] 2.1 Implement addItem(String) with default quantity 1
- [ ] 2.2 Implement addItem(String, int) with explicit quantity
- [ ] 2.3 Implement deleteItem(String)
- [ ] 2.4 Implement updateItemQuantity with <= 0 removal logic
- [ ] 2.5 Implement empty() to clear all items
- [ ] 2.6 Implement getCount()

## 3. Cart Display

- [ ] 3.1 Implement getSubTotal() calculation
- [ ] 3.2 Implement getItems() collection with locale
- [ ] 3.3 Create cart view template

## 4. Catalog Integration

- [ ] 4.1 Wire CatalogHelper local EJB reference
- [ ] 4.2 Implement item enrichment from catalog
- [ ] 4.3 Handle CatalogException in getItems()

## 5. Web Integration

- [ ] 5.1 Create CartEvent with action types
- [ ] 5.2 Implement CartHTMLAction routing
- [ ] 5.3 Implement CartEJBAction dispatch

## 6. Locale Support

- [ ] 6.1 Initialize cart with Locale.US
- [ ] 6.2 Implement setLocale() override

## 7. Quantity Validation

- [ ] 7.1 Implement NumberFormatException handling
- [ ] 7.2 Default invalid quantities to 0

## 8. Testing

- [ ] 8.1 Test add/remove/update operations
- [ ] 8.2 Test quantity 0 removal logic
- [ ] 8.3 Test cart total calculation
- [ ] 8.4 Test empty cart state
- [ ] 8.5 Test catalog integration
