# Admin Operations Specification Extraction

## Summary

This specification documents the admin operations capability of the legacy Java Pet Store application. The admin module provides authenticated administrators with a rich client interface for order management, analytics, and inventory control via a Java Web Start deployment model.

## Scope

The admin-operations capability encompasses:

1. **Authentication & Authorization**: Form-based login with role-based access control
2. **Session Management**: 54-minute timeout for authenticated sessions, session passing to rich client
3. **Rich Client Deployment**: Java Web Start (JNLP) based UI for order management
4. **Order Management**: Query, filter, and update order statuses via XML protocol
5. **Analytics & Reporting**: Revenue and order volume reporting with optional category filtering
6. **Supplier Operations**: Inventory update interface for suppliers via admin portal
7. **System Integration**: Integration with Order Processing Component and async message queues
8. **Operational Utilities**: Debug logging and tracing utilities

## Extracted from Legacy Application

Source: Java Pet Store 1.3.2 reference application

### Key Modules

- **Admin Web Application** (`apps/admin`): Web tier, authentication, and request processing
- **Order Processing Center** (`apps/opc`): Admin facade for order queries and analytics
- **Supplier Application** (`apps/supplier`): Inventory management and order fulfillment
- **Utility Components** (`components/util`): Debug and tracing utilities

### Key Classes

- `ApplRequestProcessor`: Rich client request handler
- `AdminRequestProcessor`: JNLP builder and login handler
- `AdminRequestBD`: Business delegate for admin operations
- `OPCAdminFacadeEJB`: Admin facade for order and analytics queries
- `OrderFulfillmentFacadeEJB`: Supplier order fulfillment
- `Debug`: Static debug utility for conditional logging

## Design Decisions

1. **XML Protocol**: Admin-to-rich-client communication uses XML for structured data exchange
2. **Asynchronous Updates**: Order status changes are processed asynchronously via JMS to decouple admin portal from fulfillment processing
3. **Rich Client Model**: Primary UI is a Java Web Start application rather than web forms, enabling richer interaction patterns
4. **Session-Based Auth**: Session IDs are passed to rich client to maintain authentication context without re-login
5. **Immutable Debug Control**: Debug output is globally disabled via immutable flag; no runtime configuration mechanism

## Known Ambiguities

1. **Order Status Values**: The valid set of order status values and any required transformations between request and storage schemas are not explicitly documented
2. **Date Range Semantics**: Whether date range queries are inclusive/exclusive at boundaries is not specified
3. **Error Handling**: Behavior when queries return no results versus actual errors is not clearly differentiated
4. **Debug Configuration**: The debuggingOn flag is immutable and hardcoded to false, with no documented mechanism for enabling debug output at runtime

## Implementation Considerations

- Admin module depends on EJB infrastructure (remote OPCAdminFacade, local AsyncSender)
- Rich client requires Java Web Start support in deployment environment
- Session management integrates with servlet container
- Date handling uses legacy Java Date API with deprecated constructors
- XML parsing and generation uses standard JAXP APIs
