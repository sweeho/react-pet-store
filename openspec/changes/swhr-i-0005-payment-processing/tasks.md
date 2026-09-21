## 1. Credit Card Data Model

- [ ] 1.1 Define CreditCard entity with cardNumber, cardType, expiryDate fields
- [ ] 1.2 Create CreditCard POJO for data transfer
- [ ] 1.3 Define primary key strategy (auto-generated)
- [ ] 1.4 Set up persistence mapping to database table

## 2. Credit Card Entity Persistence

- [ ] 2.1 Create database table schema for credit card storage
- [ ] 2.2 Define VARCHAR(255) columns for all credit card fields
- [ ] 2.3 Set up ORM/CMP configuration
- [ ] 2.4 Configure primary key constraint

## 3. Credit Card Home Interface

- [ ] 3.1 Define CreditCardLocalHome with create() methods
- [ ] 3.2 Implement no-argument create() method
- [ ] 3.3 Implement three-parameter create(cardNumber, cardType, expiryDate)
- [ ] 3.4 Implement create(CreditCard creditCard) overload
- [ ] 3.5 Implement findByPrimaryKey() method
- [ ] 3.6 Configure Required transaction attribute for all methods

## 4. Credit Card Business Interface

- [ ] 4.1 Define CreditCardLocal interface
- [ ] 4.2 Add getCardNumber() and setCardNumber()
- [ ] 4.3 Add getCardType() and setCardType()
- [ ] 4.4 Add getExpiryDate() and setExpiryDate()
- [ ] 4.5 Add getExpiryMonth() with "/" parsing
- [ ] 4.6 Add getExpiryYear() with "/" parsing
- [ ] 4.7 Add getData() to return CreditCard POJO
- [ ] 4.8 Configure Required transaction attribute for all methods

## 5. Credit Card Entity Implementation

- [ ] 5.1 Implement ejbCreate() with no arguments
- [ ] 5.2 Implement ejbCreate(String, String, String) initialization
- [ ] 5.3 Implement ejbCreate(CreditCard) DTO-based initialization
- [ ] 5.4 Implement ejbPostCreate() lifecycle hook
- [ ] 5.5 Implement field accessors (getters/setters)
- [ ] 5.6 Implement ejbRemove() for entity deletion

## 6. Date Parsing Logic

- [ ] 6.1 Implement getExpiryMonth() with "/" delimiter search
- [ ] 6.2 Set default month value "01" if "/" not found
- [ ] 6.3 Implement getExpiryYear() with "/" delimiter search
- [ ] 6.4 Set default year value "2010" if "/" not found
- [ ] 6.5 Test date parsing with various formats

## 7. Data Transfer Object Pattern

- [ ] 7.1 Implement CreditCard.getData() to create POJO copy
- [ ] 7.2 Copy cardNumber to POJO
- [ ] 7.3 Copy cardType to POJO
- [ ] 7.4 Copy expiryDate to POJO
- [ ] 7.5 Return fully populated POJO

## 8. Transaction Management

- [ ] 8.1 Configure container-managed transactions
- [ ] 8.2 Set Required transaction attribute for all methods
- [ ] 8.3 Enable automatic rollback on errors
- [ ] 8.4 Test transactional integrity

## 9. Authorization and Access Control

- [ ] 9.1 Configure unchecked access for all methods
- [ ] 9.2 No role-based restrictions
- [ ] 9.3 Document authorization assumptions

## 10. JNDI Registration

- [ ] 10.1 Register CreditCardEJB in JNDI namespace
- [ ] 10.2 Bind to "ejb/petstore/customer/CreditCard"
- [ ] 10.3 Create ejb-ref declarations for dependent components
- [ ] 10.4 Configure JNDI lookups in dependent beans

## 11. Integration Testing

- [ ] 11.1 Test credit card creation with all three methods
- [ ] 11.2 Test findByPrimaryKey() retrieval
- [ ] 11.3 Test field getters and setters
- [ ] 11.4 Test expiry month/year parsing
- [ ] 11.5 Test date parsing with missing "/" delimiter
- [ ] 11.6 Test getData() POJO population
- [ ] 11.7 Test DTO-based creation
- [ ] 11.8 Test transactional isolation
- [ ] 11.9 Test rollback on validation errors

## 12. Security Testing

- [ ] 12.1 Verify unchecked access is intentional
- [ ] 12.2 Test JNDI binding accessibility
- [ ] 12.3 Test removal operations
