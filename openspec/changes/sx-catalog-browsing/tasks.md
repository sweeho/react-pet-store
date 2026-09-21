## 1. Data Model

- [ ] 1.1 Define the Category entity with id, name, and description fields
- [ ] 1.2 Define the Product entity with id, name, and description fields
- [ ] 1.3 Define the Item entity with 13 fields (category, productId, productName, itemId, imageLocation, description, five attributes, listPrice, unitCost)
- [ ] 1.4 Define the Page container with objects list, start position, hasNext flag, and navigation methods
- [ ] 1.5 Implement Page.EMPTY_PAGE constant for empty result scenarios
- [ ] 1.6 Create model classes as Serializable for EJB communication

## 2. Catalog EJB Service Interface

- [ ] 2.1 Create CatalogEJB local session bean with required transaction attribute
- [ ] 2.2 Implement getCategory(categoryID, locale) method returning single Category or null
- [ ] 2.3 Implement getCategories(start, count, locale) method returning paginated Page
- [ ] 2.4 Implement getProduct(productID, locale) method returning single Product or null
- [ ] 2.5 Implement getProducts(categoryID, start, count, locale) method returning paginated Page
- [ ] 2.6 Implement getItem(itemID, locale) method returning single Item with 13 fields or null
- [ ] 2.7 Implement getItems(productID, start, count, locale) method returning paginated Page
- [ ] 2.8 Implement searchItems(keyword, start, count, locale) method for full-text search
- [ ] 2.9 Add exception handling to wrap DAO CatalogDAOSysException as EJBException
- [ ] 2.10 Configure EJB transaction attributes in deployment descriptor

## 3. DAO Interface and Implementation

- [ ] 3.1 Define CatalogDAO interface with all catalog query method signatures
- [ ] 3.2 Implement GenericCatalogDAO extending DAO interface
- [ ] 3.3 Implement getCategory DAO method with locale-aware query
- [ ] 3.4 Implement getCategories DAO method with pagination logic
- [ ] 3.5 Implement getProduct DAO method with locale-aware query
- [ ] 3.6 Implement getProducts DAO method with category filtering and pagination
- [ ] 3.7 Implement getItem DAO method with 13-field result set mapping
- [ ] 3.8 Implement getItems DAO method with product filtering and pagination
- [ ] 3.9 Implement searchItems DAO method with full-text search and pagination
- [ ] 3.10 Add CatalogDAOSysException wrapper for DAO layer exceptions

## 4. Pagination Implementation

- [ ] 4.1 Implement ResultSet cursor positioning with absolute() method
- [ ] 4.2 Implement next-page detection via resultSet.next() flag
- [ ] 4.3 Implement result collection loop with count decrement control
- [ ] 4.4 Implement Page.isNextPageAvailable() method returning hasNext flag
- [ ] 4.5 Implement Page.isPreviousPageAvailable() returning start > 0
- [ ] 4.6 Implement Page.getStartOfNextPage() calculating start + size
- [ ] 4.7 Implement Page.getStartOfPreviousPage() calculating Math.max(start - size, 0)
- [ ] 4.8 Implement empty page handling when start position exceeds results

## 5. Localization Support

- [ ] 5.1 Add Locale parameter to all catalog query methods
- [ ] 5.2 Implement Locale.toString() conversion for database queries
- [ ] 5.3 Configure SQL statements for locale-based filtering
- [ ] 5.4 Implement locale-aware result set mapping for descriptions
- [ ] 5.5 Document locale fallback behavior (if any)
- [ ] 5.6 Test localized queries for multiple language Locales

## 6. Database Access

- [ ] 6.1 Create SQL statement templates for all catalog queries
- [ ] 6.2 Implement prepared statement building with parameter substitution
- [ ] 6.3 Implement parameter array construction for locale and other params
- [ ] 6.4 Implement buildSQLStatement() helper method
- [ ] 6.5 Implement result set row mapping for Category construction
- [ ] 6.6 Implement result set row mapping for Product construction
- [ ] 6.7 Implement result set row mapping for Item construction (13 fields)
- [ ] 6.8 Implement resource cleanup in finally blocks (connection, statement, resultSet)
- [ ] 6.9 Implement string trimming for category ID and image location fields

## 7. Single Item Retrieval

- [ ] 7.1 Implement single-record retrieval using resultSet.first()
- [ ] 7.2 Implement null return for not-found scenarios
- [ ] 7.3 Implement exception handling for database errors
- [ ] 7.4 Implement Item construction with all 13 required fields
- [ ] 7.5 Test retrieval of items with complete and sparse attributes

## 8. Batch Item Retrieval

- [ ] 8.1 Implement multi-record retrieval with pagination
- [ ] 8.2 Implement result list collection from result set rows
- [ ] 8.3 Implement hasNext flag detection during iteration
- [ ] 8.4 Implement count decrement control for result limiting
- [ ] 8.5 Implement Page object construction with results and metadata
- [ ] 8.6 Test pagination with various start positions and counts

## 9. Search Functionality

- [ ] 9.1 Define full-text search query strategy
- [ ] 9.2 Implement searchItems() method with keyword parameter
- [ ] 9.3 Implement search result pagination
- [ ] 9.4 Implement search result ranking or sorting (if applicable)
- [ ] 9.5 Test search with single and multiple keyword matches
- [ ] 9.6 Test search returning empty results

## 10. Item Attributes

- [ ] 10.1 Define five attribute fields (attribute1 through attribute5)
- [ ] 10.2 Implement attribute mapping from result set columns
- [ ] 10.3 Implement null/empty attribute handling
- [ ] 10.4 Support attribute storage and retrieval in all query methods
- [ ] 10.5 Test items with full and partial attributes populated

## 11. Item Pricing

- [ ] 11.1 Implement listPrice field (Double) storage and retrieval
- [ ] 11.2 Implement unitCost field (Double) storage and retrieval
- [ ] 11.3 Ensure prices included in Item result set mapping
- [ ] 11.4 Test price precision and null/zero value handling

## 12. Item Images

- [ ] 12.1 Implement imageLocation field as String
- [ ] 12.2 Include imageLocation in Item result set mapping
- [ ] 12.3 Support imageLocation in all item queries
- [ ] 12.4 Note: Image validation/resolution is not catalog responsibility

## 13. Exception Handling and Errors

- [ ] 13.1 Implement CatalogDAOSysException for DAO layer errors
- [ ] 13.2 Wrap SQLException with original message in CatalogDAOSysException
- [ ] 13.3 Catch CatalogDAOSysException in EJB and rethrow as EJBException
- [ ] 13.4 Implement resource cleanup in exception scenarios
- [ ] 13.5 Test error handling for database connection failures
- [ ] 13.6 Test error handling for invalid SQL parameters

## 14. Transaction Management

- [ ] 14.1 Configure CatalogEJB with Required transaction attribute
- [ ] 14.2 Update ejb-jar.xml with transaction declarations for all methods
- [ ] 14.3 Test transactional consistency for concurrent queries
- [ ] 14.4 Verify transaction rollback on exceptions

## 15. Configuration and Deployment

- [ ] 15.1 Create ejb-jar.xml descriptor with CatalogEJB definition
- [ ] 15.2 Define SQL statement templates in configuration
- [ ] 15.3 Configure JNDI naming for CatalogEJB local reference
- [ ] 15.4 Set up database connection pool for catalog access
- [ ] 15.5 Configure locale-aware queries at database level

## 16. Testing and Validation

- [ ] 16.1 Write unit tests for all model classes
- [ ] 16.2 Write integration tests for single-item retrieval
- [ ] 16.3 Write integration tests for paginated listing
- [ ] 16.4 Write integration tests for search functionality
- [ ] 16.5 Write tests for locale-based localization
- [ ] 16.6 Write tests for pagination boundary conditions (first page, last page, beyond)
- [ ] 16.7 Write tests for exception handling and error scenarios
- [ ] 16.8 Write performance tests for large catalog pagination
- [ ] 16.9 Test with multiple Locale configurations
- [ ] 16.10 Smoke test all query paths end-to-end
