# Catalog Browsing Design Notes

## User Interface

No screen records were extracted for this capability; its user interface is unspecified.

## Legacy Implementation Architecture

### EJB Service Layer

**CatalogEJB** (`components/catalog/src/com/sun/j2ee/blueprints/catalog/ejb/CatalogEJB.java`)

- Local session bean providing catalog query interface
- Methods:
  - `getCategory(String categoryID, Locale l)` — retrieve single category by ID
  - `getCategories(int start, int count, Locale l)` — retrieve paginated categories
  - `getProduct(String productID, Locale l)` — retrieve single product by ID
  - `getProducts(String categoryID, int start, int count, Locale l)` — retrieve paginated products for category
  - `getItem(String itemID, Locale l)` — retrieve single item by ID
  - `getItems(String productID, int start, int count, Locale l)` — retrieve paginated items for product
  - `searchItems(String keyword, int start, int count, Locale l)` — full-text search items
- Transaction attribute: Required (container-managed)
- Exception handling: Wraps DAO CatalogDAOSysException as EJBException

### DAO Layer

**CatalogDAO Interface** (`components/catalog/src/com/sun/j2ee/blueprints/catalog/dao/CatalogDAO.java`)

- Defines contract for catalog data access
- Multiple implementation strategies (GenericCatalogDAO, etc.)

**GenericCatalogDAO** (`components/catalog/src/com/sun/j2ee/blueprints/catalog/dao/GenericCatalogDAO.java`)

- JDBC-based implementation using prepared statements
- Methods mirror CatalogEJB interface but throw CatalogDAOSysException
- Key implementation patterns:
  - Locale-based parameterization: `locale.toString()` used as query parameter
  - Pagination positioning: `resultSet.absolute(start + 1)` to position cursor
  - Next-page detection: `resultSet.next()` called to check for additional records
  - Result set iteration: Loop controlled by `--count > 0` to limit results
  - Resource cleanup: try-finally blocks close connections, statements, result sets

### Model Classes

**Category.java** (`components/catalog/src/com/sun/j2ee/blueprints/catalog/model/Category.java`)

- Fields: `id`, `name`, `description`
- Serializable for EJB remote communication

**Product.java** (`components/catalog/src/com/sun/j2ee/blueprints/catalog/model/Product.java`)

- Fields: `id`, `name`, `description`
- Serializable for EJB remote communication

**Item.java** (`components/catalog/src/com/sun/j2ee/blueprints/catalog/model/Item.java`)

- Fields (13 total):
  1. `category` — category ID containing this item
  2. `productId` — product ID containing this item
  3. `productName` — name of containing product
  4. `itemId` — unique identifier for this item
  5. `imageLocation` — path/URL to item image
  6. `description` — item description
     7-11. `attribute1` through `attribute5` — five text attributes for metadata
  7. `listPrice` — retail list price (Double)
  8. `unitCost` — vendor cost (Double)
- Serializable for EJB remote communication

**Page.java** (`components/catalog/src/com/sun/j2ee/blueprints/catalog/model/Page.java`)

- Container for paginated results
- Fields:
  - `objects` — List of results (Category, Product, or Item)
  - `start` — starting position of current page
  - `hasNext` — boolean indicating if next page exists
- Methods:
  - `getList()` — returns result list
  - `isNextPageAvailable()` — returns hasNext
  - `isPreviousPageAvailable()` — returns `start > 0`
  - `getStartOfNextPage()` — returns `start + objects.size()`
  - `getStartOfPreviousPage()` — returns `Math.max(start - objects.size(), 0)`
  - `getSize()` — returns `objects.size()`
- `Page.EMPTY_PAGE` — constant empty page for not-found cases

### Configuration and Deployment

**ejb-jar.xml** (`components/catalog/src/ejb-jar.xml`)

- CatalogEJB bean definition with transaction attributes
- All query methods defined with transaction attribute: Required
- Exception handling declarations for CatalogException

### Database Access Patterns

**Prepared Statement Execution**

- SQL statements stored in XML configuration file: `sqlStatements`
- Statement templates accessed by key: `XML_GET_CATEGORY`, `XML_GET_CATEGORIES`, etc.
- Parameters passed as String array: `new String[] { locale.toString(), categoryID }`
- Method: `buildSQLStatement(connection, sqlStatements, statementKey, parameterValues)`

**Result Set Pagination**

- Cursor positioning: `resultSet.absolute(start + 1)` — JDBC 1-based positioning
- Result collection loop:
  ```java
  do {
      // add item to results
  } while ((hasNext = resultSet.next()) && (--count > 0));
  ```
- Empty page condition: `start >= 0 && resultSet.absolute(start + 1)` — false returns `Page.EMPTY_PAGE`

**Locale-based Queries**

- Locale parameter passed to SQL query: `locale.toString()` value used in WHERE clause
- Enables multi-language descriptions in single table or via join to localization table
- No documented fallback for missing locale

### Exception Handling

**CatalogDAOSysException**

- Custom exception wrapping SQLException from DAO layer
- Contains original error message: `"SQLException: " + exception.getMessage()`

**EJBException Wrapping**

- DAO CatalogDAOSysException caught and rethrown as EJBException
- Pattern in CatalogEJB methods: `throw new EJBException(se.getMessage())`
- Propagates to calling layer

### Data Retrieval Examples

**Single Category Retrieval** (from GenericCatalogDAO)

```java
resultSet = statement.executeQuery();
if (resultSet.first()) {
    return new Category(categoryID, resultSet.getString(1), resultSet.getString(2));
}
return null;
```

**Item Retrieval** (from GenericCatalogDAO)

```java
if (resultSet.first()) {
    int i = 1;
    return new Item(
        resultSet.getString(i++).trim(),      // category
        resultSet.getString(i++).trim(),      // productId
        resultSet.getString(i++),             // productName
        itemID,                               // itemId (from parameter)
        resultSet.getString(i++).trim(),      // imageLocation
        resultSet.getString(i++),             // description
        resultSet.getString(i++),             // attribute1
        resultSet.getString(i++),             // attribute2
        resultSet.getString(i++),             // attribute3
        resultSet.getString(i++),             // attribute4
        resultSet.getString(i++),             // attribute5
        resultSet.getDouble(i++),             // listPrice
        resultSet.getDouble(i++)              // unitCost
    );
}
return null;
```

## Known Implementation Details

### JDBC Cursor Positioning

- Uses deprecated JDBC 1.0 `ResultSet.absolute(int)` method
- Position is 1-based: `start + 1` converts 0-based start position to 1-based cursor position
- May not be supported by all JDBC drivers (potential portability issue)

### String Trimming

- Category ID and image location are trimmed: `.trim()`
- Product ID is trimmed
- Other fields are not trimmed (may contain leading/trailing whitespace)

### Null Return vs Empty Page

- Single-item queries return `null` if not found
- Multi-item queries return `Page.EMPTY_PAGE` if start position is invalid
- Inconsistent behavior between single and multi-item scenarios

### Resource Management

- Connection, Statement, and ResultSet closed in finally block
- Pattern: `closeAll(connection, statement, resultSet)`

### Locale Handling

- Locale parameter never validated or defaulted
- If Locale not found in database, method returns empty results silently

## Search Implementation

SearchItems method referenced in CatalogEJB but implementation details not fully documented in extracted records. Implementation likely follows same patterns:

- Accepts keyword and pagination parameters
- Returns Page of matching Item objects
- Full-text search on item names, descriptions, or attributes (implementation detail unspecified)

## Integration Points

- **Pet Store Application**: Calls CatalogEJB methods to retrieve catalog data for presentation
- **JNDI Lookup**: CatalogEJB is a local session bean; accessed via EJB local interface
- **Database**: Accesses catalog and localization tables via JDBC

## Performance Considerations

- No caching documented; each query hits database
- No query result limiting documented; searches may return large result sets
- JDBC cursor positioning may be inefficient for large catalogs with high start positions
- Prepared statements enable connection pooling and query caching at database layer

## Known Limitations

1. No pagination limit enforcement; caller can request arbitrarily large result sets
2. Search implementation not fully documented; sorting/ranking behavior unknown
3. Locale fallback behavior not documented; missing locale silently returns empty results
4. No filtering or authorization at catalog layer; all users see all products
5. Image location not validated or resolved; referenced as string only
6. Attribute structure fixed at exactly five fields; no flexibility for additional attributes
