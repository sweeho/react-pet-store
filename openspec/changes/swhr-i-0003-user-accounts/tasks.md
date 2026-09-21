## 1. User Entity and Persistence

- [ ] 1.1 Define User CMP entity with userName (String, primary key) and password (String) fields
- [ ] 1.2 Implement primary key as String-typed userName
- [ ] 1.3 Implement abstract getters/setters for userName and password
- [ ] 1.4 Set up container-managed persistence (CMP 2.x) configuration
- [ ] 1.5 Create UserLocalHome and UserLocal interfaces
- [ ] 1.6 Implement ejbCreate() with validation for username length (25 chars max)
- [ ] 1.7 Implement ejbCreate() validation rejecting '%' and '\*' in username
- [ ] 1.8 Implement ejbCreate() validation for password maximum length

## 2. Authentication Logic

- [ ] 2.1 Create SignOnEJB stateless session bean
- [ ] 2.2 Implement authenticate(String userName, String password) method
- [ ] 2.3 Implement UserLocal.matchPassword() for password validation
- [ ] 2.4 Handle FinderException when user not found
- [ ] 2.5 Implement createUser(String userName, String password) method
- [ ] 2.6 Throw CreateException for duplicate username attempt

## 3. Session-Based Authorization

- [ ] 3.1 Create SignOnFilter servlet filter
- [ ] 3.2 Implement session attribute management for 'j_signon' (Boolean)
- [ ] 3.3 Implement session attribute management for 'j_signon_username' (String)
- [ ] 3.4 Implement session attribute management for 'j_signon_original_url' (String)
- [ ] 3.5 Parse protected resources from signon-config.xml
- [ ] 3.6 Implement URL pattern matching against protected resources
- [ ] 3.7 Redirect unauthenticated requests to sign-on page
- [ ] 3.8 Store original request URL in session before redirect
- [ ] 3.9 Support post-authentication redirect to original URL

## 4. Username Persistence

- [ ] 4.1 Implement "Remember My User Name" checkbox support
- [ ] 4.2 Create cookie 'bp_signon' with username on checkbox check
- [ ] 4.3 Set cookie MaxAge to 2678400 seconds (31 days)
- [ ] 4.4 Pre-populate username field from cookie on form load
- [ ] 4.5 Remove cookie (set MaxAge to 0) when checkbox unchecked

## 5. Sign-On Screen

- [ ] 5.1 Create signon.jsp with two-column form layout
- [ ] 5.2 Implement existing customer login form
- [ ] 5.3 Add form fields: j_username, j_password, j_remember_username
- [ ] 5.4 Add form action: j_signon_check (POST)
- [ ] 5.5 Add "Sign In" button
- [ ] 5.6 Implement new customer registration form
- [ ] 5.7 Add form fields: j_username, j_password, j_password_2
- [ ] 5.8 Add form action: createuser.do (POST)
- [ ] 5.9 Add "Create New Account" button
- [ ] 5.10 Pre-populate username from 'bp_signon' cookie if present

## 6. Account Creation Screen

- [ ] 6.1 Create create_customer.jsp screen
- [ ] 6.2 Implement contact information collection form
- [ ] 6.3 Add fields: givenName, familyName, telephone, email
- [ ] 6.4 Implement address information collection form
- [ ] 6.5 Add fields: streetName1, streetName2, city, zipCode, state, country
- [ ] 6.6 Implement profile preferences form
- [ ] 6.7 Add fields: preferredLanguage, favoriteCategory, myListPreference, bannerPreference
- [ ] 6.8 Implement credit card information form
- [ ] 6.9 Add fields: cardNumber, cardType, expiryDate
- [ ] 6.10 Create locale-specific variants (en_US, ja_JP, zh_CN)

## 7. Profile Management

- [ ] 7.1 Define ProfileLocal entity with CMP fields
- [ ] 7.2 Implement preferredLanguage field (Locale identifier)
- [ ] 7.3 Implement favoriteCategory field
- [ ] 7.4 Implement myListPreference field (Boolean)
- [ ] 7.5 Implement bannerPreference field (Boolean)
- [ ] 7.6 Create ProfileLocalHome interface
- [ ] 7.7 Implement one-to-one relationship from Customer to Profile

## 8. Customer Contact Information

- [ ] 8.1 Create ContactInfoLocal entity
- [ ] 8.2 Implement fields: givenName, familyName, telephone, email
- [ ] 8.3 Create one-to-one relationship from ContactInfo to Address
- [ ] 8.4 Implement AddressLocal entity
- [ ] 8.5 Implement address fields: streetName1, streetName2, city, zipCode, state, country
- [ ] 8.6 Create one-to-one relationship from Account to ContactInfo

## 9. Customer Entity Composition

- [ ] 9.1 Create CustomerLocal entity with Account, Profile, ContactInfo relationships
- [ ] 9.2 Implement Customer.getAccount() to return AccountLocal
- [ ] 9.3 Implement Customer.getProfile() to return ProfileLocal
- [ ] 9.4 Implement Account.getContactInfo() to return ContactInfoLocal
- [ ] 9.5 Implement Account.getCreditCard() to return CreditCardLocal
- [ ] 9.6 Handle FinderException when profile not created yet

## 10. Sign-On Action and Workflow

- [ ] 10.1 Create SignOnEJBAction for authentication workflow
- [ ] 10.2 Extract username and password from SignOnEvent
- [ ] 10.3 Call SignOnEJB.authenticate() to validate credentials
- [ ] 10.4 Retrieve customer profile on successful authentication
- [ ] 10.5 Extract preferredLanguage from ProfileLocal
- [ ] 10.6 Convert locale string to Locale object via I18nUtil
- [ ] 10.7 Set locale in machine attributes for request scope
- [ ] 10.8 Update shopping cart locale via cart.setLocale()
- [ ] 10.9 Handle CreateUserEJBAction for account creation
- [ ] 10.10 Throw DuplicateAccountException for existing usernames

## 11. Locale Support

- [ ] 11.1 Configure TemplateServlet with supported locales
- [ ] 11.2 Set supported locales: en_US, ja_JP, zh_CN
- [ ] 11.3 Set default locale: en_US
- [ ] 11.4 Implement I18nUtil.getLocaleFromString() conversion
- [ ] 11.5 Create signon.jsp locale variants (ja/, zh/)
- [ ] 11.6 Create create_customer.jsp locale variants
- [ ] 11.7 Create profile and customer screens in all locales

## 12. Protected Resource Configuration

- [ ] 12.1 Create signon-config.xml configuration file
- [ ] 12.2 Declare protected resources with url-pattern elements
- [ ] 12.3 Add protected patterns: customer.screen, customer.do
- [ ] 12.4 Add protected patterns: enter_order_information.screen
- [ ] 12.5 Add protected patterns: signon_welcome.screen
- [ ] 12.6 Integrate signon-config.xml into web.xml
- [ ] 12.7 Register SignOnFilter in web.xml

## 13. Error Handling and Mapping

- [ ] 13.1 Create CreateUserEJBAction for new account creation
- [ ] 13.2 Catch CreateException and throw DuplicateAccountException
- [ ] 13.3 Configure exception mapping to duplicate_account.screen
- [ ] 13.4 Implement authentication failure handling
- [ ] 13.5 Implement validation error handling for account creation
- [ ] 13.6 Display appropriate error messages for constraint violations
