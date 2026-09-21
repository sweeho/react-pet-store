## 1. Category Retrieval

- [ ] 1.1 Implement getCategory() returning localized category with ID, name, description
- [ ] 1.2 Implement transaction semantics (Required)
- [ ] 1.3 Handle locale parameter for multi-language support

## 2. Paginated Listing

- [ ] 2.1 Implement getCategories(startIndex, count, locale) pagination
- [ ] 2.2 Return Page object with result list and hasNextPage flag
- [ ] 2.3 Support arbitrary start indices and page sizes

## 3. Product/Item Search

- [ ] 3.1 Implement item retrieval by category
- [ ] 3.2 Support pagination for item lists
- [ ] 3.3 Return item details (ID, name, attribute, unitCost)

## 4. Locale Support

- [ ] 4.1 Configure supported locales (en_US, ja_JP, zh_CN)
- [ ] 4.2 Implement locale-aware data retrieval
- [ ] 4.3 Default to en_US when locale not specified
