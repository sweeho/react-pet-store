## ADDED Requirements

### Requirement: Catalog hierarchy model

The system SHALL model catalog data as a four-level hierarchy of Categories containing Products containing Items, where each Item has five text attributes and pricing information. Categories, Products, and Items SHALL each have ID, name, and description fields localized for the requested Locale.

#### Scenario: Retrieve category details

- **GIVEN** a catalog with categories for birds, cats, and dogs
- **WHEN** a request is made to retrieve the "birds" category by ID
- **THEN** the system returns a Category object with the category ID, name, and localized description

#### Scenario: Retrieve product within category

- **GIVEN** a category containing multiple products
- **WHEN** a request is made to retrieve a specific product by ID
- **THEN** the system returns a Product object with the product ID, name, and localized description

#### Scenario: Retrieve item with full details

- **GIVEN** a product containing multiple items
- **WHEN** a request is made to retrieve a specific item by ID
- **THEN** the system returns an Item object containing category, product ID, product name, item ID, image location, description, five attribute fields, list price, and unit cost

### Requirement: Pagination support for catalog results

The system SHALL support pagination of catalog query results (categories, products, items, and search results) by returning a Page object containing: a list of results, a starting position index, a boolean indicating whether a next page exists, and computed methods to determine prior page availability and calculate next/previous page start positions.

#### Scenario: Retrieve first page of categories

- **GIVEN** 50 categories exist in the catalog
- **WHEN** a request is made for categories with start=0 and count=10
- **THEN** the system returns a Page containing 10 Category objects, with isNextPageAvailable()=true and getStartOfNextPage()=10

#### Scenario: Retrieve middle page of results

- **GIVEN** pagination state showing current start position of 20
- **WHEN** the Page method isPreviousPageAvailable() is called
- **THEN** the system returns true

#### Scenario: Retrieve last page of results

- **GIVEN** 50 items total with current pagination showing 45-49
- **WHEN** a request is made for the next page
- **THEN** the system returns an empty or partial page with isNextPageAvailable()=false

### Requirement: Single category retrieval

The system SHALL support retrieval of a single Category by category ID, returning a Category object containing the ID, name, and description localized for the specified Locale. If the category is not found, the system SHALL return null.

#### Scenario: Category exists

- **GIVEN** a category with ID "birds" exists in the catalog
- **WHEN** a request is made to retrieve category by ID "birds"
- **THEN** the system returns a non-null Category object with matching ID

#### Scenario: Category does not exist

- **GIVEN** the catalog does not contain a category with ID "nonexistent"
- **WHEN** a request is made to retrieve category by ID "nonexistent"
- **THEN** the system returns null

### Requirement: Paginated categories retrieval

The system SHALL support retrieval of a paginated list of all Categories, ordered and localized according to a specified Locale, supporting pagination via start position and count parameters.

#### Scenario: Get all categories with pagination

- **GIVEN** a catalog with multiple categories and a specified Locale
- **WHEN** a request is made for categories with start=0, count=5, and the user's Locale
- **THEN** the system returns a Page of Category objects, localized in the requested language

### Requirement: Single product retrieval

The system SHALL support retrieval of a single Product by product ID, returning a Product object containing the ID, name, and description localized for the specified Locale. If the product is not found, the system SHALL return null.

#### Scenario: Product exists in category

- **GIVEN** a product with ID "AmazonParrot" exists in the "birds" category
- **WHEN** a request is made to retrieve product by ID "AmazonParrot"
- **THEN** the system returns a non-null Product object with matching ID and localized description

#### Scenario: Product does not exist

- **GIVEN** the catalog does not contain a product with ID "unknownproduct"
- **WHEN** a request is made to retrieve product by ID "unknownproduct"
- **THEN** the system returns null

### Requirement: Paginated products retrieval by category

The system SHALL support retrieval of a paginated list of Products within a specific Category, ordered and localized according to a specified Locale, supporting pagination via start position and count parameters.

#### Scenario: Get products in category with pagination

- **GIVEN** a category containing 15 products and a request with start=0, count=5, and Locale
- **WHEN** the request is made
- **THEN** the system returns a Page of Product objects for that category, localized in the requested language, with pagination metadata

### Requirement: Single item retrieval with full details

The system SHALL support retrieval of a single Item by item ID, returning an Item object containing category, product ID, product name, item ID, image location, description, five attribute fields, list price, and unit cost. If the item is not found, the system SHALL return null.

#### Scenario: Item exists with complete details

- **GIVEN** an item with ID "AmazonParrot1" containing all required fields
- **WHEN** a request is made to retrieve item by ID "AmazonParrot1"
- **THEN** the system returns an Item object containing all 13 required fields including the five attributes and pricing

#### Scenario: Item does not exist

- **GIVEN** the catalog does not contain an item with ID "unknownitem"
- **WHEN** a request is made to retrieve item by ID "unknownitem"
- **THEN** the system returns null

### Requirement: Paginated items retrieval by product

The system SHALL support retrieval of a paginated list of Items within a specific Product, ordered and localized according to a specified Locale, supporting pagination via start position and count parameters.

#### Scenario: Get items in product with pagination

- **GIVEN** a product containing 20 items and a request with start=0, count=5, and Locale
- **WHEN** the request is made
- **THEN** the system returns a Page of Item objects for that product, localized in the requested language

### Requirement: Item search functionality

The system SHALL support full-text search of Items across the entire catalog, returning a paginated list of Items matching the search keywords. Search results SHALL support the same pagination interface as category/product listing and SHALL return complete Item objects with all attributes and pricing information.

#### Scenario: Search for items by keyword

- **GIVEN** items containing "parrot" and "finch" in their descriptions
- **WHEN** a search request is made with keyword "parrot" and pagination parameters
- **THEN** the system returns a Page of Item objects matching the search criteria

#### Scenario: Search returns empty results

- **GIVEN** a search keyword that matches no items in the catalog
- **WHEN** the search request is made
- **THEN** the system returns an empty Page with size=0 and isNextPageAvailable()=false

### Requirement: Locale-based localization

The system SHALL support localization of Category, Product, and Item descriptions based on the specified Locale parameter. All catalog queries SHALL accept a Locale parameter and return descriptions in the corresponding language. The system SHALL use the Locale.toString() value to query localized content from the database.

#### Scenario: Retrieve category in English

- **GIVEN** a category with descriptions available in English and Spanish
- **WHEN** a request is made with Locale for English
- **THEN** the system returns the category with English description

#### Scenario: Retrieve category in different language

- **GIVEN** a category with descriptions available in English and Spanish
- **WHEN** a request is made with Locale for Spanish
- **THEN** the system returns the category with Spanish description

### Requirement: Item attribute structure

Items in the catalog SHALL support exactly five text attribute fields (attribute1 through attribute5) that can store additional product-specific metadata. Each attribute field SHALL be a String value that can be null or empty.

#### Scenario: Item with all attributes populated

- **GIVEN** an item with all five attributes containing data
- **WHEN** the item is retrieved
- **THEN** the system returns all five attribute values in the Item object

#### Scenario: Item with sparse attributes

- **GIVEN** an item where only attribute1 and attribute3 contain values
- **WHEN** the item is retrieved
- **THEN** the system returns the Item with attribute1 and attribute3 populated and attribute2, attribute4, attribute5 as null or empty

### Requirement: Item pricing model

Items in the catalog SHALL support two price fields: listPrice (the retail list price) and unitCost (the cost to the vendor). Both prices SHALL be stored and returned as Double values. Prices are component parts of the Item and are never null.

#### Scenario: Retrieve item with pricing

- **GIVEN** an item with listPrice=89.99 and unitCost=45.50
- **WHEN** the item is retrieved
- **THEN** the system returns both price values in the Item object

### Requirement: Item image reference

Items in the catalog SHALL contain an imageLocation field specifying the path or URL to an item image. The image location is stored as a String and is used by the presentation layer for displaying product images.

#### Scenario: Retrieve item with image location

- **GIVEN** an item with imageLocation="/images/birds/parrot1.jpg"
- **WHEN** the item is retrieved
- **THEN** the system returns the imageLocation string in the Item object

### Requirement: Pagination arithmetic

When a Page is returned containing results, the Page object SHALL provide methods to calculate navigation positions. The getStartOfNextPage() method SHALL return start + objects.size(). The getStartOfPreviousPage() method SHALL return Math.max(start - objects.size(), 0), never returning a negative value.

#### Scenario: Calculate next page position

- **GIVEN** a Page with start=0 and objects.size()=10
- **WHEN** getStartOfNextPage() is called
- **THEN** the system returns 10

#### Scenario: Calculate previous page position from middle

- **GIVEN** a Page with start=20 and objects.size()=10
- **WHEN** getStartOfPreviousPage() is called
- **THEN** the system returns 10

#### Scenario: Calculate previous page position from first page

- **GIVEN** a Page with start=0 and objects.size()=10
- **WHEN** getStartOfPreviousPage() is called
- **THEN** the system returns 0 (never negative)

### Requirement: Catalog query exception handling

All catalog query operations (getCategory, getProduct, getItem, getCategories, getProducts, getItems, searchItems) SHALL wrap database exceptions in a CatalogDAOSysException and propagate them as EJBException to the calling layer, preserving the original error message.

#### Scenario: Database error during query

- **GIVEN** a database connection failure occurs
- **WHEN** a catalog query method is called
- **THEN** the system wraps the SQLException in CatalogDAOSysException and throws EJBException to the caller

### Requirement: Transaction management for catalog operations

All catalog query operations executed through the CatalogEJB layer SHALL operate within a container-managed transaction with "Required" semantics, ensuring transactional consistency for all database access operations.

#### Scenario: Query within transaction boundary

- **GIVEN** a catalog query method invoked from a client
- **WHEN** the method executes database queries
- **THEN** all queries operate within a single transaction managed by the container

### Requirement: Pagination starting position bounds

When paginating catalog results, if the requested start position is greater than or equal to the total number of results, the system SHALL return a Page.EMPTY_PAGE with no results rather than raising an error.

#### Scenario: Request page beyond available results

- **GIVEN** a catalog with 50 total items and a request for start=100, count=10
- **WHEN** the pagination query is executed
- **THEN** the system returns an empty Page with size=0 and isNextPageAvailable()=false
