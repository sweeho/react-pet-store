# Shopping Cart Design Notes

## User interface

Three screen records were extracted for this capability; screen-specific visible contracts are in spec.md as requirements.

## Legacy Implementation Architecture

### Cart Data Model

**CartItem** - Value object with fields: itemId, productId, category, name, attribute, quantity (int), unitCost (double)

**ShoppingCartLocalEJB** - Stateful session bean managing HashMap<String, Integer> (itemId → quantity)

### Core Operations

**addItem(String)** - Default quantity 1
**addItem(String, int)** - Explicit quantity
**deleteItem(String)** - Remove by itemId
**updateItemQuantity(String, int)** - Update or remove if qty <= 0
**empty()** - Clear all items
**getCount()** - Return cart size
**getItems()** - Return enriched CartItem collection
**getSubTotal()** - Return sum of (quantity × unitCost)

### Catalog Integration

ShoppingCartLocalEJB.getItems() calls CatalogHelper to enrich stored cart data with full Item details. CatalogException caught and logged (System.out) but not re-thrown.

### Locale Support

Cart defaults to Locale.US; setLocale() overrides for catalog lookups.

### HTML Actions

CartHTMLAction routes "purchase" (add), "remove" (delete), "update" (batch quantity), "empty" actions to CartEvent dispatch.

### Quantity Validation

CartHTMLAction catches NumberFormatException on quantity parsing; defaults to 0 (triggers removal).

## Known Limitations

1. Silent exception handling on catalog lookup failures
2. Two code paths for total calculation (Model vs EJB)
3. No server-side quantity field length validation
4. Incomplete error handling for item enrichment failures
