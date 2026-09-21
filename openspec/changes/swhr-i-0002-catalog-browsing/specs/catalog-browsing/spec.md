## ADDED Requirements

### Requirement: Category Retrieval with Localization

The system SHALL retrieve a product category by its ID and return a Category object containing the category ID, name, and description localized for the specified Locale.

#### Scenario: Retrieve category in English

- **GIVEN** a category with ID "cats" exists
- **WHEN** getCategory("cats", Locale.US) is called
- **THEN** a Category object is returned with ID "cats" and localized name in English

#### Scenario: Retrieve category in alternate locale

- **GIVEN** a category with ID "dogs" exists with translations
- **WHEN** getCategory("dogs", Locale.forLanguageTag("ja-JP")) is called
- **THEN** a Category object is returned with name and description localized to Japanese

### Requirement: Paginated Category Listing

The system SHALL retrieve a paginated list of product categories and return a Page object containing the requested categories with pagination metadata indicating whether additional pages are available.

#### Scenario: Retrieve first page of categories

- **GIVEN** the catalog contains 50 categories
- **WHEN** getCategories(0, 10, Locale.US) is called
- **THEN** a Page is returned with 10 categories and hasNextPage=true

#### Scenario: Retrieve last page of categories

- **GIVEN** the catalog contains 50 categories
- **WHEN** getCategories(40, 10, Locale.US) is called
- **THEN** a Page is returned with 10 categories and hasNextPage=false

### Requirement: Item Retrieval by Category

The system SHALL retrieve products within a category and return a paginated list of items with product ID, name, attributes, and unit cost.

#### Scenario: Get items in category

- **GIVEN** category "dogs" contains items
- **WHEN** getItems("dogs", 0, 20, Locale.US) is called
- **THEN** a Page is returned with items sorted by name, unit cost, and attributes

### Requirement: Multi-Locale Support

The system SHALL support product data localization for English (en_US), Japanese (ja_JP), and Chinese (zh_CN) locales, defaulting to en_US when locale is not specified.

#### Scenario: Default locale when unspecified

- **GIVEN** getCategory("cats") is called without explicit Locale
- **WHEN** the request is processed
- **THEN** the data is retrieved and returned in en_US locale
