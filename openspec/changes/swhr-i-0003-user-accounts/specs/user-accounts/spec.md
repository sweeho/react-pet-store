## ADDED Requirements

### Requirement: User authentication by username and password

The system SHALL authenticate a user by accepting a username and password, verifying the password matches the stored password for that username, and returning success only if both match.

#### Scenario: Successful authentication

- **GIVEN** a registered user with username "alice" and password "secret"
- **WHEN** the authenticate() method is called with matching username and password
- **THEN** authentication succeeds and returns true

#### Scenario: Authentication failure with wrong password

- **GIVEN** a registered user with username "alice"
- **WHEN** authenticate() is called with username "alice" but wrong password "wrong"
- **THEN** authentication fails and returns false

#### Scenario: Authentication failure with non-existent username

- **GIVEN** no user registered with username "nonexistent"
- **WHEN** authenticate() is called with "nonexistent" and any password
- **THEN** authentication fails and returns false

### Requirement: User account creation with validation

The system SHALL create a new user account when given a username and password, enforcing that the username is 25 characters or fewer, the password meets maximum length constraints, the username does not contain '%' or '\*' characters, and throwing a CreateException if any constraint is violated.

#### Scenario: Valid account creation

- **GIVEN** a username "bob" and password "newpass"
- **WHEN** createUser() is called with valid credentials
- **THEN** the user account is created successfully

#### Scenario: Username too long

- **GIVEN** a username longer than 25 characters
- **WHEN** createUser() is called with this username
- **THEN** CreateException is thrown with length constraint message

#### Scenario: Username contains forbidden characters

- **GIVEN** a username "test%user" or "test*user" containing '%' or '*'
- **WHEN** createUser() is called
- **THEN** CreateException is thrown with character restriction message

#### Scenario: Password exceeds maximum length

- **GIVEN** a password exceeding the maximum allowed length
- **WHEN** createUser() is called
- **THEN** CreateException is thrown with password length constraint message

### Requirement: Username length constraint

The system SHALL enforce that a username is a maximum of 25 characters.

#### Scenario: Username at maximum length accepted

- **GIVEN** a username exactly 25 characters long
- **WHEN** createUser() is called
- **THEN** the account is created successfully

#### Scenario: Username exceeding maximum length rejected

- **GIVEN** a username 26 characters long
- **WHEN** createUser() is called
- **THEN** CreateException is thrown

### Requirement: Username character restrictions

The system SHALL reject usernames containing the '%' or '\*' characters during user creation, throwing a CreateException with appropriate error message.

#### Scenario: Username with % character rejected

- **GIVEN** a username "user%name"
- **WHEN** createUser() is called
- **THEN** CreateException is thrown

#### Scenario: Username with \* character rejected

- **GIVEN** a username "user\*name"
- **WHEN** createUser() is called
- **THEN** CreateException is thrown

### Requirement: Session-based authentication

The system SHALL enforce session-based authentication wherein a user's authenticated status is stored in the HTTP session under the attribute 'j_signon', and subsequent requests are allowed to access protected resources only if this session attribute is present and set to true.

#### Scenario: Protected resource accessible after authentication

- **GIVEN** a user who has successfully authenticated (j_signon = true in session)
- **WHEN** the user requests a protected resource
- **THEN** the resource is served without redirection

#### Scenario: Protected resource requires authentication

- **GIVEN** an unauthenticated user (j_signon not present or false)
- **WHEN** the user requests a protected resource
- **THEN** the SignOnFilter redirects to the sign-on page

### Requirement: Protected resource redirection

When an unauthenticated user attempts to access a protected resource, the system SHALL redirect to a sign-on login page and store the original requested URL in the session for post-login redirection.

#### Scenario: Original URL stored and user redirected to sign-on

- **GIVEN** an unauthenticated user requesting protected URL "customer.screen"
- **WHEN** the SignOnFilter processes the request
- **THEN** the filter stores "customer.screen" in session attribute 'j_signon_original_url' and redirects to sign-on page

#### Scenario: Redirect to original URL after authentication

- **GIVEN** a user who has authenticated and the original URL is stored in session
- **WHEN** authentication succeeds
- **THEN** the system redirects to the stored original URL

### Requirement: Username persistence cookie

The system MAY optionally persist a username in a cookie named 'bp_signon' when the user checks the "Remember My User Name" checkbox. The cookie SHALL be set to expire after one month (2678400 seconds).

#### Scenario: Cookie set when checkbox checked

- **GIVEN** a user entering username "alice" and checking the "Remember My User Name" checkbox
- **WHEN** the sign-on form is submitted
- **THEN** a cookie 'bp_signon' is set with value "alice" and MaxAge 2678400

#### Scenario: Username pre-populated from cookie

- **GIVEN** a previous visit where username was saved in 'bp_signon' cookie
- **WHEN** the sign-on page is loaded
- **THEN** the username field is pre-populated with the value from the cookie

#### Scenario: Cookie removed when checkbox unchecked

- **GIVEN** a user with existing 'bp_signon' cookie not checking the "Remember My User Name" checkbox
- **WHEN** the sign-on form is submitted
- **THEN** the cookie is removed by setting MaxAge to 0

### Requirement: Customer profile management

The system SHALL support customer profile management including preferred language, favorite product category, and display preferences (list and banner).

#### Scenario: Profile preferences set during account creation

- **GIVEN** a new customer account being created
- **WHEN** the customer selects preferredLanguage, favoriteCategory, myListPreference, and bannerPreference
- **THEN** these profile fields are persisted to the ProfileLocal entity

#### Scenario: Profile preferences retrieved on authentication

- **GIVEN** an authenticated customer with saved profile preferences
- **WHEN** the customer logs in
- **THEN** the system retrieves the profile and applies preferredLanguage to the session locale

### Requirement: Customer contact and address information

The system SHALL store and manage customer contact information including given name, family name, telephone, email, and complete address (street name, city, state, country, zip code).

#### Scenario: Contact information collected during account creation

- **GIVEN** a new customer account being created
- **WHEN** contact information form is completed with all required fields
- **THEN** givenName, familyName, telephone, and email are stored in ContactInfoLocal

#### Scenario: Address information collected and associated

- **GIVEN** contact information with address data
- **WHEN** the form is submitted
- **THEN** streetName1, streetName2, city, zipCode, state, and country are stored in AddressLocal associated with ContactInfo

### Requirement: Duplicate account prevention

The system SHALL reject duplicate usernames when a customer attempts to create an account with a username that already exists, throwing a DuplicateAccountException.

#### Scenario: Account creation with existing username fails

- **GIVEN** an existing account with username "alice"
- **WHEN** a customer attempts to create an account with the same username "alice"
- **THEN** DuplicateAccountException is thrown and mapped to duplicate_account.screen

### Requirement: Multi-locale support

The system SHALL support multiple locales: en_US, ja_JP, and zh_CN. The application initializes these locales on startup, with en_US as the default locale when no locale is explicitly set.

#### Scenario: Default locale applied when not set

- **GIVEN** a user session with no explicit locale preference
- **WHEN** the application processes a request
- **THEN** the locale defaults to en_US

#### Scenario: User's preferred locale applied after authentication

- **GIVEN** an authenticated user with preferredLanguage set to "ja_JP"
- **WHEN** the user logs in successfully
- **THEN** the system sets the session locale to ja_JP

### Requirement: Sign-on screen with dual login forms

The sign-on screen (signon.screen) SHALL present a two-column layout with separate forms for existing and new customers. The existing customer form SHALL accept username and password with a "Remember My User Name" checkbox and "Sign In" button posting to j_signon_check. The new customer form SHALL accept username, password, and password confirmation with a "Create New Account" button posting to createuser.do. The username field SHALL be pre-populated from the 'bp_signon' cookie if present.

#### Scenario: Sign-on screen displays both forms

- **GIVEN** an unauthenticated user accessing the sign-on page
- **WHEN** signon.jsp is rendered
- **THEN** a two-column layout displays the existing customer form on the left and new customer form on the right

#### Scenario: Existing customer form submits to j_signon_check

- **GIVEN** a user entering credentials in the existing customer form with username, password, and "Remember My User Name" checkbox
- **WHEN** the "Sign In" button is clicked
- **THEN** the form POSTs to j_signon_check with fields j_username, j_password, and j_remember_username

#### Scenario: New customer form submits to createuser.do

- **GIVEN** a user entering new account credentials in the new customer form
- **WHEN** the "Create New Account" button is clicked
- **THEN** the form POSTs to createuser.do with fields j_username, j_password, and j_password_2

### Requirement: Create account screen

The create account screen (create_customer.screen) SHALL collect customer contact information, address, credit card details, and profile preferences. The screen SHALL display form sections for given name, family name, telephone, email, street address, city, state, country, zip code, card number, card type, expiry date, preferred language, favorite category, and optional preferences (list and banner). The screen SHALL be available in localized variants for en_US, ja_JP, and zh_CN.

#### Scenario: Account creation form displays all required fields

- **GIVEN** a user who clicked "Create New Account" on the sign-on screen
- **WHEN** create_customer.screen is rendered
- **THEN** form sections display input fields for contact info, address, credit card, and profile preferences

#### Scenario: Locale-specific account creation screen

- **GIVEN** a user with locale set to ja_JP
- **WHEN** the account creation screen is rendered
- **THEN** the system displays the Japanese variant of create_customer.jsp

### Requirement: Customer account profile and preference management screen

The customer account management screen (customer.screen) SHALL allow authenticated customers to view and update their profile, contact information, address, credit card, and preferences. The screen SHALL display current information and provide form controls to modify all customer fields including language preference and category preference. Access to this screen SHALL be restricted to authenticated users.

#### Scenario: Authenticated customer accesses account management

- **GIVEN** an authenticated customer with valid session (j_signon = true)
- **WHEN** the customer requests customer.screen
- **THEN** the customer's current profile and contact information are displayed in editable form fields

#### Scenario: Unauthenticated access to account management is denied

- **GIVEN** an unauthenticated user with no valid session
- **WHEN** the user requests customer.screen
- **THEN** the SignOnFilter redirects to sign-on page with original URL stored in session

#### Scenario: Customer updates profile preferences

- **GIVEN** an authenticated customer viewing their profile
- **WHEN** the customer modifies preferredLanguage and favoriteCategory and submits
- **THEN** the ProfileLocal entity is updated with new preference values

### Requirement: Sign-off functionality

The system SHALL provide a sign-off endpoint that clears the user's session and logs them out. When a user accesses signoff.do, the system SHALL invalidate the session and redirect to the application home page.

#### Scenario: User logs off via signoff.do

- **GIVEN** an authenticated user in an active session
- **WHEN** the user accesses signoff.do
- **THEN** the session attribute 'j_signon' is cleared and the user is redirected to the home page
