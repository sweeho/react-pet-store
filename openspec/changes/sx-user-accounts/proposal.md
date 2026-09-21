# User Accounts Specification Extraction

## Summary

Specification for user account and authentication management in the legacy Java Pet Store application, covering account creation, login, session management, profile preferences, and customer contact information.

## Scope

- User account creation with username and password
- User authentication and password validation
- Session-based authentication and authorization
- Protected resource access control
- Customer profile preferences (language, category, etc.)
- Contact information and address management
- Optional username persistence via cookies
- Multi-locale support (en_US, ja_JP, zh_CN)
- Sign-on and account creation user interfaces

## Key Components

- **SignOn Component** (`components/signon`): User authentication, account creation, session management
- **Customer Component** (`components/customer`): Customer profile, contact info, and address management
- **User Entity** (EJB CMP): Username/password storage
- **Profile Entity** (EJB CMP): Locale and preference settings
- **ContactInfo Component** (`components/contactinfo`): Customer contact and address data
- **SignOnFilter**: Request filtering for protected resources
- **Petstore App** (`apps/petstore`): User account screens and workflows

## Design Decisions

1. **EJB CMP Persistence**: User, Profile, ContactInfo, and Address use container-managed persistence
2. **Session-Based Auth**: Authentication state stored in HTTP session attribute 'j_signon'
3. **Filter-Based Protection**: SignOnFilter enforces authentication before protected resource access
4. **Declarative Security**: Protected resources declared in signon-config.xml
5. **Cookie Persistence**: Optional username persistence in 'bp_signon' cookie (31-day expiry)
6. **Multi-Locale Support**: Three supported locales with en_US as default
7. **Password Validation**: Direct string equality check (no hashing)

## Implementation Considerations

- Username max length: 25 characters
- Username character restrictions: no '%' or '\*' characters
- Password max length enforced but exact value redacted in source
- Locale defaults to en_US if not set
- Original URL stored for post-authentication redirect
- Customer data collected during account creation or via profile updates
