## ADDED Requirements

### Requirement: Credit card entity definition

The system SHALL maintain a CreditCard entity with three core attributes: cardNumber, cardType, and expiryDate. All three fields MUST be defined and accessible through the entity interface.

#### Scenario: Credit card created with all fields

- **GIVEN** a request to create a new credit card
- **WHEN** the credit card is created with cardNumber "4111-1111-1111-1111", cardType "VISA", and expiryDate "12/2025"
- **THEN** the entity stores all three values and makes them accessible via getters

#### Scenario: Credit card fields are persistent

- **GIVEN** a credit card entity that has been created and committed
- **WHEN** the entity is retrieved later by primary key
- **THEN** all three fields are restored from persistent storage with their original values

### Requirement: Credit card database persistence

The system SHALL persist credit card entities in a database table with VARCHAR(255) columns for cardNumber, cardType, and expiryDate fields. Each field SHALL support storage of up to 255 characters.

#### Scenario: Credit card persisted to database

- **GIVEN** a credit card entity created in memory
- **WHEN** the entity is committed to the database
- **THEN** a row is inserted into the CreditCard table with all field values

#### Scenario: Large values are stored

- **GIVEN** a card number field with maximum length text (255 characters)
- **WHEN** the credit card is persisted
- **THEN** the full value is stored without truncation

### Requirement: Credit card CRUD operations

The system SHALL provide create, retrieve, and find operations on credit card entities through the CreditCardLocalHome interface. The interface MUST expose create() and findByPrimaryKey() methods with container-managed transaction support.

#### Scenario: Credit card retrieved by primary key

- **GIVEN** a credit card with primary key 12345
- **WHEN** findByPrimaryKey(12345) is called
- **THEN** the corresponding credit card entity is returned

#### Scenario: Multiple creation methods are supported

- **GIVEN** three different ways to create a credit card (empty, with parameters, from POJO)
- **WHEN** each creation method is invoked
- **THEN** all result in valid entities with the appropriate field values

### Requirement: Credit card field accessors

The system SHALL provide getter and setter methods for cardNumber, cardType, and expiryDate. Additionally, the system SHALL provide getExpiryMonth() and getExpiryYear() methods that parse the expiryDate string.

#### Scenario: Field values are readable and writable

- **GIVEN** a credit card entity
- **WHEN** a field is set via setter and retrieved via getter
- **THEN** the value round-trips correctly

#### Scenario: Expiry month and year are extracted from date string

- **GIVEN** an expiryDate stored as "MM/YYYY" format (e.g., "12/2025")
- **WHEN** getExpiryMonth() is called
- **THEN** the system returns "12" (substring before "/" delimiter)

#### Scenario: Expiry year is extracted from date string

- **GIVEN** an expiryDate stored as "MM/YYYY" format (e.g., "12/2025")
- **WHEN** getExpiryYear() is called
- **THEN** the system returns "2025" (substring after "/" delimiter)

### Requirement: Date parsing with default values

The system SHALL parse expiryDate strings on the "/" delimiter to extract month and year. If the expiryDate is null or does not contain a "/" delimiter, the system SHALL return default values: "01" for month and "2010" for year.

#### Scenario: Month parsing with missing slash

- **GIVEN** an expiryDate of null or a string without "/"
- **WHEN** getExpiryMonth() is called
- **THEN** the system returns "01"

#### Scenario: Year parsing with missing slash

- **GIVEN** an expiryDate of null or a string without "/"
- **WHEN** getExpiryYear() is called
- **THEN** the system returns "2010"

### Requirement: Credit card creation with parameters

The system SHALL allow creation of a CreditCard entity with three parameters (cardNumber, cardType, expiryDate) and SHALL initialize all entity fields through the creation process. The ejbCreate() method MUST call individual setters to initialize each field.

#### Scenario: Credit card created with three parameters

- **GIVEN** a create request with cardNumber, cardType, and expiryDate
- **WHEN** the create method completes
- **THEN** the entity is initialized with all three values set correctly

### Requirement: Credit card creation from data transfer object

The system SHALL allow creation of a CreditCard entity from a CreditCard data transfer object by extracting values through the DTO's getters and setting them on the newly created entity. The ejbCreate() method SHALL accept a CreditCard POJO parameter.

#### Scenario: Credit card created from POJO

- **GIVEN** a CreditCard POJO with populated fields
- **WHEN** create(CreditCard) is called with the POJO
- **THEN** the entity is initialized with values copied from the POJO

### Requirement: Data transfer object export

The system SHALL provide a getData() method that returns a CreditCard data transfer object populated with the current entity's field values. The returned POJO SHALL be independent of the entity and suitable for transmission to other components.

#### Scenario: Entity fields are copied to POJO

- **GIVEN** a credit card entity with values cardNumber="4111-1111-1111-1111", cardType="VISA", expiryDate="12/2025"
- **WHEN** getData() is called
- **THEN** a CreditCard POJO is returned with identical field values

### Requirement: Transactional consistency

All credit card entity operations (create, retrieve, remove, field access) SHALL execute within a container-managed transaction with Required transaction attribute. Each operation MUST either commit fully or roll back completely without partial updates.

#### Scenario: Successful operation commits

- **GIVEN** a credit card creation operation that completes successfully
- **WHEN** the transaction commits
- **THEN** the credit card is permanently stored in the database

#### Scenario: Failed operation rolls back

- **GIVEN** a credit card operation that encounters an error mid-execution
- **WHEN** the transaction rolls back
- **THEN** no partial updates are persisted and the database remains consistent

### Requirement: Unchecked authorization for payment operations

All credit card entity methods SHALL be accessible without authorization checks. The ejb-jar.xml declares an unchecked method-permission for all methods on CreditCardEJB, indicating no role-based restrictions.

#### Scenario: Methods are callable without role restrictions

- **GIVEN** any caller without specific roles
- **WHEN** a credit card method is invoked
- **THEN** the call is allowed without permission checking

### Requirement: JNDI component registration

The CreditCard component SHALL be registered in the application server JNDI namespace under the name "ejb/petstore/customer/CreditCard". Other components that reference CreditCard through the ejb/CreditCard reference SHALL be able to locate and access the component.

#### Scenario: Component is accessible via JNDI lookup

- **GIVEN** a component that needs to access CreditCard
- **WHEN** InitialContext.lookup("java:comp/env/ejb/CreditCard") is called
- **THEN** the CreditCardLocalHome is returned and ready for use

### Requirement: Credit card creation initialization

The system SHALL support three creation methods: no-argument create(), three-parameter create(String, String, String), and DTO-based create(CreditCard). All creation paths MUST delegate to ejbCreate() which initializes fields by calling individual setters.

#### Scenario: Empty credit card is created

- **GIVEN** a create() call with no arguments
- **WHEN** the creation completes
- **THEN** an entity is created with uninitialized fields

#### Scenario: Credit card fields are set via individual setters

- **GIVEN** any creation method
- **WHEN** the ejbCreate() initializer runs
- **THEN** cardNumber, cardType, and expiryDate are set via their respective setter methods

### Requirement: Primary key lookup

The system SHALL support finding credit card entities by primary key through the findByPrimaryKey() method. GIVEN a primary key, WHEN the method is invoked, THEN the corresponding CreditCard entity is returned or a FinderException is raised if not found.

#### Scenario: Entity found by primary key

- **GIVEN** a primary key that corresponds to an existing credit card
- **WHEN** findByPrimaryKey(key) is called
- **THEN** the CreditCard entity is returned

#### Scenario: Primary key not found

- **GIVEN** a primary key that does not exist
- **WHEN** findByPrimaryKey(key) is called
- **THEN** a FinderException is raised
