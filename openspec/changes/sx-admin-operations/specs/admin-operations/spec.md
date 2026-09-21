## ADDED Requirements

### Requirement: Admin authentication and authorization

The system SHALL enforce form-based authentication with username and password for access to administrative endpoints. Only users with the 'administrator' role SHALL be permitted to access admin operations.

#### Scenario: Authorized admin accesses admin portal

- **GIVEN** a user with the administrator role
- **WHEN** the user submits username and password credentials via the login form
- **THEN** the system grants access to the admin portal and creates an authenticated session

#### Scenario: Unauthorized user attempts to access admin endpoint

- **GIVEN** a user without the administrator role
- **WHEN** the user attempts to access /AdminRequestProcessor
- **THEN** the system redirects to the login page and denies access

### Requirement: Session management for authenticated admins

The system SHALL maintain authenticated sessions for admin users. Session IDs SHALL be passed from the web tier to rich client applications to enable client authentication without additional login.

#### Scenario: Session timeout enforcement

- **GIVEN** an authenticated admin user with an active session
- **WHEN** the session remains inactive for 54 minutes
- **THEN** the system terminates the session and requires re-authentication

#### Scenario: Rich client receives session ID

- **GIVEN** an authenticated admin user in the web portal
- **WHEN** the user launches the Java Web Start rich client
- **THEN** the system passes the current session ID as an application argument to the rich client

### Requirement: Admin order query interface

The system SHALL allow authenticated admin users to retrieve orders filtered by order status. Orders SHALL be queried via XML request/response protocol and return order details including OrderId, UserId, OrderDate, OrderAmount, and OrderStatus.

#### Scenario: Retrieve orders by status

- **GIVEN** an authenticated admin user
- **WHEN** the admin submits an XML request with a Status element specifying a status value
- **THEN** the system returns an XML response containing all orders matching that status with their OrderId, UserId, OrderDate, OrderAmount, and OrderStatus fields

#### Scenario: Empty order result set

- **GIVEN** an authenticated admin user
- **WHEN** the admin queries for orders with a status that has no matching orders
- **THEN** the system returns an XML response with a TotalCount of 0 and an empty order list

### Requirement: Order date formatting

Dates in admin requests and responses SHALL be formatted in mm/dd/yyyy format. The system SHALL convert date strings in this format to Date objects for internal processing.

#### Scenario: Parse admin-submitted date

- **GIVEN** an admin submitting an order date in mm/dd/yyyy format
- **WHEN** the system processes the date string (e.g., "12/25/2005")
- **THEN** the system converts it to a Date object for database queries and responds with the same format

### Requirement: Admin order status update operations

The system SHALL allow authenticated admin users to update order statuses. Update requests SHALL be submitted as XML containing Order elements with OrderId and OrderStatus fields. Status updates SHALL be processed asynchronously via message queue.

#### Scenario: Update single order status

- **GIVEN** an authenticated admin user
- **WHEN** the admin submits an XML update request with an OrderId and new OrderStatus value
- **THEN** the system queues the status change for asynchronous processing and returns success

#### Scenario: Batch update multiple order statuses

- **GIVEN** an authenticated admin user
- **WHEN** the admin submits an XML update request containing multiple Order elements
- **THEN** the system processes each order update and returns a success response with the total count of updated orders

### Requirement: Revenue reporting by date range

The system SHALL support revenue reporting by date range with optional category filtering. Revenue SHALL be calculated as quantity multiplied by unit price per line item, aggregated by category or individual item based on filter parameters.

#### Scenario: Generate revenue report without category filter

- **GIVEN** a date range (start and end dates in mm/dd/yyyy format)
- **WHEN** an admin requests revenue aggregation without specifying a category filter
- **THEN** the system returns revenue totals grouped by category, including a TotalSales sum of all categories

#### Scenario: Generate revenue report with category filter

- **GIVEN** a date range and a specific category ID
- **WHEN** an admin requests revenue aggregation for that category
- **THEN** the system returns revenue totals grouped by individual item within that category, with a TotalSales sum

### Requirement: Order volume (quantity) reporting

The system SHALL support order volume reporting counting orders by date range with optional category filtering. Quantity aggregation SHALL sum the quantity of items by category or individual item based on filter parameters.

#### Scenario: Generate order quantity report without filter

- **GIVEN** a date range
- **WHEN** an admin requests order volume aggregation without a category filter
- **THEN** the system returns quantity totals grouped by category with a TotalSales sum representing total quantities

#### Scenario: Generate order quantity report with category filter

- **GIVEN** a date range and a specific category ID
- **WHEN** an admin requests order volume aggregation for that category
- **THEN** the system returns quantity totals grouped by item within that category with a TotalSales sum

### Requirement: Revenue calculation formula

The system SHALL calculate revenue as the product of quantity and unit price for each line item. Aggregations SHALL accumulate individual line item revenue values using summation.

#### Scenario: Calculate revenue from order line items

- **GIVEN** an order containing line items with quantities and unit prices
- **WHEN** the system generates a revenue report
- **THEN** for each line item, the system computes (quantity × unit price) and includes this value in the appropriate aggregate bucket

### Requirement: Data aggregation by category or item

Chart reporting and analytics SHALL support aggregation by CategoryId or by ItemId. When no category filter is specified, data SHALL be grouped by CategoryId. When a category filter is specified, data SHALL be grouped by ItemId within that category.

#### Scenario: Aggregate data by category (no filter)

- **GIVEN** multiple line items from different categories
- **WHEN** generating a report without a category filter
- **THEN** the system groups the data by CategoryId, creating one result per category

#### Scenario: Aggregate data by item (with category filter)

- **GIVEN** multiple line items within a specified category
- **WHEN** generating a report with a category filter
- **THEN** the system groups the data by ItemId within that category, creating one result per item

### Requirement: XML protocol for admin client communication

The system SHALL support XML-based protocol for communication between the rich client and web tier. Request format SHALL include a Type element specifying the operation (GETORDERS, UPDATESTATUS, REVENUE, ORDERS). Response format SHALL include a Type element and either data elements or an Error element.

#### Scenario: Client sends XML request

- **GIVEN** a rich client application
- **WHEN** the client sends an XML request with Type=GETORDERS
- **THEN** the system parses the request, executes the corresponding operation, and returns an XML response with Type=GETORDERS and order data

#### Scenario: Server returns error response

- **GIVEN** a malformed or invalid admin request
- **WHEN** the system processes the request
- **THEN** the system returns an XML response containing an Error element describing the issue

### Requirement: Java Web Start rich client deployment

The system SHALL support launching a Java Web Start (JNLP) based rich client application from the web interface. The rich client SHALL be the primary UI for admin order management operations, accessible via a launch button on the admin portal login page.

#### Scenario: Admin launches rich client from web portal

- **GIVEN** an authenticated admin user on the admin portal login page
- **WHEN** the user clicks the "Launch Rich Client" button
- **THEN** the system generates a JNLP file with the current session ID and server details, triggering Java Web Start to download and launch PetStoreAdminClient

#### Scenario: Rich client starts with server configuration

- **GIVEN** a JNLP file generated by the admin web application
- **WHEN** Java Web Start executes the JNLP
- **THEN** the rich client application starts and receives the server name, port, and session ID as arguments

### Requirement: Supplier inventory update interface

The system SHALL display a supplier inventory update screen that shows all items in inventory with their current quantities, allows administrators to enter new quantities, and provides a checkbox to select items for update.

#### Scenario: Admin views inventory table

- **GIVEN** an authenticated admin user accessing the inventory update screen
- **WHEN** the screen displays the inventory
- **THEN** the screen shows a table with columns for Item ID, Existing Quantity, New Quantity input field, and a checkbox for each item, populated with all current inventory items

#### Scenario: Admin updates selected inventory items

- **GIVEN** the inventory update screen displayed with multiple items
- **WHEN** the admin enters new quantities and checks the checkboxes for items to update
- **THEN** the system submits the update request with the selected items and new quantities

### Requirement: Admin portal login interface

The system SHALL present a login page with username and password input fields, pre-populated with default credentials for testing. The login form SHALL submit to the j_security_check servlet endpoint using POST method with j_username and j_password parameters.

#### Scenario: Admin login form display

- **GIVEN** an unauthenticated user accessing the admin portal
- **WHEN** the browser loads the admin login page
- **THEN** the page displays a form with "User ID" and "Password" input fields, with "jps_admin" and "admin" as default values, and a login submit button

#### Scenario: Admin submits login credentials

- **GIVEN** the admin login form
- **WHEN** the admin enters credentials and clicks submit
- **THEN** the form POSTs to /j_security_check with j_username and j_password parameters

### Requirement: Admin debug utility availability

The system SHALL provide a Debug utility class available throughout the admin application and related modules for conditional debug message output. The utility SHALL support multiple output methods for different message types (plain messages, messages with newlines, exception traces).

#### Scenario: Debug output is disabled in production

- **GIVEN** the Debug.debuggingOn flag set to false (default)
- **WHEN** admin code calls Debug.print() or Debug.println()
- **THEN** no output is produced and the application continues without performance impact

#### Scenario: Debug exception information with stack trace

- **GIVEN** an exception occurs in admin code
- **WHEN** the code calls Debug.print(Throwable t)
- **THEN** if debugging is enabled, the exception message and full stack trace are output to standard streams

### Requirement: Admin operations integration with order processing

The admin module SHALL integrate with the Order Processing Component (OPC) via remote OPCAdminFacade EJB for querying and reporting operations, and with the AsyncSender EJB (local) for asynchronous order approval workflow processing.

#### Scenario: Admin queries orders via OPC integration

- **GIVEN** an authenticated admin user requesting orders
- **WHEN** the system looks up the remote OPCAdminFacadeRemote EJB and calls getOrdersByStatus()
- **THEN** the system returns OrderDetails transfer objects with order information

#### Scenario: Admin status update triggers async processing

- **GIVEN** an admin order status update request
- **WHEN** the system looks up the AsyncSender local EJB and calls sendAMessage()
- **THEN** the system queues the OrderApproval XML for asynchronous processing in the fulfillment workflow
