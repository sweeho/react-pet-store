# Catalog Browsing Specification Extraction

## Summary

This specification documents the catalog browsing capability of the legacy Java Pet Store application. The catalog provides a hierarchical product catalog with multi-level browsing (categories → products → items), pagination support, localization, and search functionality.

## Scope

The catalog-browsing capability encompasses:

1. **Catalog Hierarchy**: Four-level structure of Categories containing Products containing Items with Attributes
2. **Single Item Retrieval**: Get individual categories, products, and items by ID
3. **Paginated Listing**: Support pagination across categories, products, and items
4. **Search Functionality**: Full-text search across items with pagination
5. **Localization**: Multi-language support for all catalog descriptions
6. **Item Attributes**: Five text attributes per item for metadata storage
7. **Pricing Model**: List price and unit cost fields for items
8. **Image References**: Image location field for item images
9. **Transaction Management**: EJB-based transaction semantics
10. **Exception Handling**: Standardized exception wrapping and propagation

## Extracted from Legacy Application

Source: Java Pet Store 1.3.2 reference application (28 records across 5 IR pass files)

### Key Components

- **Catalog Component** (`components/catalog`): Core catalog data model, DAOs, and EJB service
- **Pet Store Application** (`apps/petstore`): Web presentation layer usage of catalog

### Key Classes

- `CatalogEJB`: Local session bean providing catalog query interface
- `GenericCatalogDAO`: DAO implementation for catalog database access
- `Category`, `Product`, `Item`: Model classes representing catalog hierarchy
- `Page`: Pagination container for catalog results

## Design Decisions

1. **EJB-based Service**: Catalog access is mediated through an EJB local session bean with container-managed transactions
2. **DAO Pattern**: Database access is abstracted through a DAO layer supporting multiple implementations
3. **Locale-based Localization**: Localization is query-driven using Locale.toString() as a parameter
4. **Pagination Abstraction**: All multi-result queries return a Page object with consistent pagination semantics
5. **Null for Not Found**: Single-item queries return null instead of throwing exceptions when items are not found
6. **Exception Wrapping**: DAO exceptions are wrapped and propagated as EJBException to clients
7. **ResultSet-based Pagination**: Pagination uses JDBC ResultSet.absolute() and tracking of next-page availability

## Known Ambiguities

1. **Search Implementation**: The search() method is referenced but implementation details are not fully documented
2. **Pagination Behavior**: Exact behavior when start position is negative or exceeds total results
3. **Locale Handling**: How unsupported locales are handled; whether fallback to default language occurs
4. **Query Ordering**: The specific ordering (if any) of results is not documented except where implicit in DAO implementation
5. **Result Set Size Limits**: Maximum pagination result set sizes are not enforced or documented

## Implementation Considerations

- Catalog queries operate within EJB container-managed transactions
- Database access uses prepared statements for security and performance
- Pagination relies on JDBC result set cursor positioning
- Localized content is queried from database rather than loaded into memory
- The Page object computes navigation positions based on result set contents
- No caching layer is documented; each query hits the database
- Image location references are stored as strings and not validated by the catalog service
