# Catalog Browsing Design Notes

## Legacy Implementation

### Category Retrieval

**CatalogEJB** - Stateless session bean providing catalog access:

- `getCategory(String categoryID, Locale locale)` - Retrieves single category with localization
- `getCategories(int startIndex, int count, Locale locale)` - Returns paginated category list
- Transaction attribute: Required (all operations)

### Product/Item Retrieval

**GenericCatalogDAO** - Data access layer:

- Category queries use `SELECT * FROM categories WHERE categoryId = ?`
- Item queries filter by category and support pagination with `resultSet.absolute()`
- Locale-aware data retrieval for multi-language support

### Pagination

**Page object** - Wraps result collections with metadata:

- Contains result list, start index, page size
- `isNextPageAvailable()` flag indicates if more results exist
- Enables UI-side pagination controls

### Multi-Locale Support

All queries execute locale-aware retrieval; default locale is en_US.
