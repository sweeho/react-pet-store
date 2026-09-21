# Shopping Cart Specification Extraction

## Summary

Specification for shopping cart functionality in the legacy Java Pet Store application, covering cart management, item operations, and user interface.

## Scope

- Cart item storage and retrieval
- Add, remove, update, and empty operations
- Quantity management and validation
- Cart total calculation
- Locale-aware cart display
- Catalog integration for item enrichment

## Key Components

- **ShoppingCart Component** (`components/cart`): Core cart EJB and data models
- **Catalog Component** (`components/catalog`): Item enrichment via local EJB
- **Petstore App** (`apps/petstore`): Cart UI and web actions

## Design Decisions

1. **HashMap-based Storage**: Cart uses itemId → quantity HashMap
2. **Stateful Session Bean**: ShoppingCartLocalEJB maintains session state
3. **Lazy Enrichment**: Cart items enriched from catalog on retrieval
4. **Currency Formatting**: Cart totals displayed as formatted currency
5. **Locale Support**: Cart defaults to Locale.US with override capability
6. **Quantity Validation**: Non-numeric quantities default to 0 (removal)

## Implementation Considerations

- Catalog integration via local EJB reference
- Exception handling for failed catalog lookups
- Stateful session bean lifecycle management
- Currency formatting at display layer
