# Order Placement Specification Extraction

## Summary

This specification documents the order placement capability of the legacy Java Pet Store application, covering the workflow from shopping cart validation through order confirmation.

## Scope

- Order validation (non-empty cart requirement)
- Order ID generation via unique ID service
- Customer information collection (shipping and billing addresses)
- Payment information handling
- Order status and workflow management
- Screen requirements for order entry and confirmation

## Key Components

- **Petstore App** (`apps/petstore`): Web tier order actions
- **OPC** (`apps/opc`): Business logic and facades
- **UIGen** (`components/uidgen`): Unique ID generation
- **LineItem** (`components/lineitem`): Order line item management
- **PurchaseOrder** (`components/purchaseorder`): Order data model
- **XMLDocuments** (`components/xmldocuments`): Order serialization

## Design Decisions

1. **Non-Empty Validation**: Orders rejected if cart is empty
2. **Unique ID Generation**: Order IDs generated via EJB service with counter prefix "1001"
3. **Dual Address Handling**: Separate billing and shipping contact information
4. **Screen-Based Workflow**: Two dedicated screens for order entry and confirmation
5. **Payment Data Collection**: Credit card information captured at order time

## Implementation Considerations

- Container-managed transactions for data consistency
- Exception-based validation with domain-specific exceptions
- Locale-aware screen templates for internationalization
- Two-phase order entry: information collection followed by confirmation
