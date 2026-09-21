# User Accounts Design Notes

## User interface

Five screen records were extracted for this capability; screen-specific visible contracts are in spec.md as requirements.

## Legacy Implementation Architecture

### User Entity Model

**UserEJB** (`components/signon/user/ejb/UserEJB.java`)

- Container-managed persistence (CMP 2.x) entity bean
- Primary key: String (userName)
- CMP fields: userName (String, primary key), password (String)
- Constraints enforced in ejbCreate():
  - Maximum username length: 25 characters (MAX_USERID_LENGTH constant)
  - No '%' or '\*' characters in username
  - Maximum password length (value redacted in source)
- Methods: matchPassword() performs direct string equality check
- Local interfaces: UserLocalHome, UserLocal

### Authentication Flow

**SignOnEJB** (`components/signon/ejb/SignOnEJB.java`)

- Stateless session bean managing authentication
- Method: authenticate(String userName, String password)
  - Looks up User entity by primary key
  - Calls matchPassword() for password validation
  - Returns false on FinderException (user not found)
- Method: createUser(String userName, String password)
  - Delegates to UserEJB.ejbCreate() for validation
  - Throws CreateException on constraint violation or duplicate

### Session-Based Authentication

**SignOnFilter** (`components/signon/web/SignOnFilter.java`)

- Servlet filter intercepting all requests
- Session attribute: 'j_signon' (Boolean) tracks authentication state
- Session attribute: 'j_signon_username' (String) stores authenticated username
- Session attribute: 'j_signon_original_url' (String) stores requested URL for post-auth redirect
- Protected resources defined in signon-config.xml with url-pattern matching
- Cookie handling:
  - Cookie name: 'bp_signon'
  - Stores username if "Remember My User Name" checkbox checked
  - MaxAge: 2678400 seconds (approximately 31 days)
  - Pre-populates username field on return visit if cookie present

### Protected Resource Configuration

**signon-config.xml**

Protected resources requiring authentication:

- customer.screen
- customer.do
- enter_order_information.screen
- signon_welcome.screen

Filter redirects unauthenticated requests to sign-on page, storing original URL in session for post-authentication redirection.

### Customer Entity Composition

**CustomerEJBAction** (`petstore/controller/ejb/actions/CustomerEJBAction.java`)

Customer entity includes:

- Account: billing contact information
- ContactInfo: givenName, familyName, telephone, email
- Address: street1, street2, city, zipCode, state, country
- CreditCard: cardNumber, cardType, expiryDate
- Profile: preferredLanguage, favoriteCategory, myListPreference, bannerPreference

### Profile Management

**ProfileLocal** (EJB CMP entity)

- preferredLanguage: Locale identifier (en_US, ja_JP, zh_CN)
- favoriteCategory: Customer's preferred product category
- myListPreference: Boolean preference for "my list" feature
- bannerPreference: Boolean preference for promotional banners
- Set during account creation or via profile update workflow

### Sign-On Page Structure

**signon.jsp** (`petstore/docroot/signon.jsp`)

Two-column form layout:

- Left: "Existing Customer" form
  - Action: j_signon_check (POST)
  - Fields: j_username, j_password
  - Checkbox: j_remember_username ("Remember My User Name")
  - Button: "Sign In"
  - Pre-populated username from bp_signon cookie if present
- Right: "New Customer" form
  - Action: createuser.do (POST)
  - Fields: j_username, j_password, j_password_2
  - Button: "Create New Account"

### Account Creation Flow

**CreateUserServlet/CreateUserEJBAction** (`petstore/controller/`)

- Maps to createuser.do URL
- Accepts username and password from registration form
- Throws DuplicateAccountException if username already exists
- Maps to duplicate_account.screen on error
- Redirects to create_customer.screen for profile/contact info collection

### Locale Support

**TemplateServlet** (web.xml configuration)

- Supported locales: en_US, ja_JP, zh_CN
- Default locale: en_US
- Locale-specific JSP variants exist for:
  - signon.jsp (en_US, ja/signon.jsp, zh/signon.jsp)
  - create_customer.jsp (locale variants)
  - All user-facing screens

### Authentication Integration

**SignOnEJBAction** (`petstore/controller/ejb/actions/SignOnEJBAction.java`)

On successful authentication:

1. Retrieves customer profile via ServiceClientFacade
2. Extracts preferredLanguage from ProfileLocal
3. Converts to Locale via I18nUtil.getLocaleFromString()
4. Sets locale in machine attributes
5. Updates shopping cart locale via cart.setLocale()
6. Handles FinderException for first-time users (no profile yet)

## Known Limitations

1. Passwords stored in plain text with direct string comparison (no hashing)
2. Password maximum length constant is redacted; exact value unknown
3. No account lockout mechanism after failed authentication attempts
4. Cookie persistence is optional and relies on user behavior
5. No password reset or recovery mechanism documented
6. Session timeout and invalidation mechanism not fully visible
7. CreateUserServlet implementation incomplete in provided source
8. No audit logging for authentication events
9. ContactInfo/Address validation rules not fully documented
10. Profile creation may be deferred until first update (FinderException handling)
