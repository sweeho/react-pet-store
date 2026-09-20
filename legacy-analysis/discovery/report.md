# SX-0001 Discovery Report: Petstore 1.3.2

## Executive Summary

Sun Microsystems J2EE Petstore 1.3.2 is a reference implementation demonstrating J2EE blueprints and patterns circa 2002. The application is a multi-tier B2C/B2B system for online pet retailing, featuring a customer-facing storefront, admin operations portal, and supplier integrations via async messaging.

**Key Metrics:**

- Total LOC: ~61,000 (approximate)
- Modules: 4 applications + 19 reusable components
- Architecture: Stateful Struts web tier + stateful/stateless EJB business logic + entity beans
- Async: JMS-based order fulfillment workflow (OrderApprovalMDB, PurchaseOrderMDB)
- Data: Entity beans with CMP (container-managed persistence) 2.x, no ORM

## Architectural Layers

### Presentation Tier (JSP + Struts)

**Location:** `apps/petstore/src/docroot/` + `WEB-INF/mappings.xml`

- Struts action mappings for events (OrderEvent, CartEvent, SignOnEvent, etc.)
- Custom WAF (Web Application Framework) layer for event-driven architecture
- 67 JSP screens in petstore app; 4 in admin app

### Business Logic Tier (EJB Session Beans)

**Location:** `apps/*/src/com/sun/j2ee/blueprints/*/controller/ejb/`

- ShoppingControllerEJB: stateful session facade
- ShoppingClientFacadeEJB: shopping state holder
- OrderEJBAction, CartEJBAction, etc.: event handlers
- Message-driven beans in OPC (OrderApprovalMDB, PurchaseOrderMDB)

### Entity/Data Tier (EJB Entity Beans + DAO)

**Location:** `components/*/src/ejb-jar.xml` + Java beans

- Entity beans: CreditCardEJB (CMP 2.x), CatalogEJB (session + DAO), etc.
- Service locator pattern for JNDI lookups
- XML document transformation (XMLDocumentException handling)
- Catalog DAO uses SQL configuration (CatalogDAOSQL.xml)

## Component Dependency Graph

**High-Dependency Core:**

- **ShoppingControllerEJB** (app controller) → Catalog, Cart, CreditCard, Customer, LineItem, PurchaseOrder, SignOn, UniqueIdGenerator, AsyncSender
- **PurchaseOrderEJB** → Address, ContactInfo, CreditCard, LineItem, ServiceLocator, XMLDocuments
- **ProcessManagerEJB** (workflow) → Manager entity, order status enum

**Cross-Component Calls:**

- OrderEJBAction: Catalog, Cart, PurchaseOrder, UniqueIdGenerator, AsyncSender, CreditCard, SignOn, ProcessManager
- OPC MDBs: PurchaseOrder, ProcessManager, ContactInfo, Address, LineItem, XMLDocuments

**Isolated Components:**

- UID Generator, Encoding Filter, ServiceLocator: utilities with no reverse dependencies
- Mailer, AsyncSender: outbound integrations only

## Key Business Flows

### 1. Order Creation Flow

OrderEvent → OrderEJBAction:

1. Retrieve shopping cart items
2. Create PurchaseOrder bean
3. Generate unique order ID (UIDGeneratorEJB)
4. Collect billing, shipping, credit card info
5. Call AsyncSender.sendAMessage(purchaseOrder.toXML())
6. Empty cart

### 2. Order Approval Flow (Async)

1. OrderApprovalMDB listens to JMS queue
2. Receives list of approved orders
3. Updates order status via ProcessManager
4. Generates supplier purchase orders (TPASupplierOrderXDE)
5. Sends approval emails via MailOrderApprovalTransitionDelegate

### 3. User Management

- SignOn: authentication (SignOnEJB)
- Customer: profile + address + contact info
- CreditCard: stored with customer, validated on order

### 4. Catalog Navigation

- CatalogEJB: browse categories, products, items
- Uses CatalogDAO with SQL-based data access
- Locale support for i18n

## Data Model Observations

**Entity Beans (CMP):**

- CreditCard: cardNumber, cardType, expiryDate
- LineItem: quantity, unitCost (implies pricing stored per order line)
- Address, ContactInfo: reused across customers and orders

**Calculated Fields:**

- PurchaseOrder.totalPrice: summed from line item costs (OrderEJBAction, line 146: `totalCost += (cost*item.getQuantity())`)
- Order status state machine: "1001" prefix for order IDs (UID generator), status enum (OrderStatusNames)

**Schema Evidence:**

- CMP fields indicate a relational schema (CreditCard has expiryDate, cardType, cardNumber)
- Foreign keys inferred from entity references (Customer→CreditCard, PurchaseOrder→LineItem, Address, ContactInfo, CreditCard)

## Configuration & Declarative Rules

**EJB Descriptors:**

- ejb-jar.xml: transaction attributes (Required, Supports), method-level permissions
- sun-j2ee-ri.xml: app server-specific bindings
- web.xml: servlet mappings, security constraints (presumably)

**Struts Configuration:**

- mappings.xml: event→action mappings, flow handlers (CreateUserFlowHandler)
- signon-config.xml: authentication configuration
- screendefinitions: locale-specific screen metadata (en_US, ja_JP, zh_CN)

**Validation:**

- Inline validation in actions (e.g., cart empty check in OrderEJBAction)
- No explicit declarative validator config found yet

## Known Gotchas & Ambiguities

1. **Order ID Generation:** Hardcoded "1001" prefix in UID generator lookup (`uidgen.getUniqueId("1001")`) — seed/sequence strategy unclear
2. **Cart Quantity Calculation:** `totalCost += (cost*item.getQuantity())` — order of operations ambiguous if item prices are formatted strings
3. **CreditCard Validation:** CreditCardEJB has expiryDate field; validation logic not yet located (may be in JSP scriptlet or SignOn component)
4. **Async Failure Handling:** OrderApprovalMDB message handling — no explicit retry/DLQ strategy documented yet
5. **Locale Handling:** Multiple locale-specific screen definition files; how fallback is handled is unclear
6. **PO Status Transitions:** ProcessManager tracks status as string (line 66); valid status enum (OrderStatusNames) exists but transition rules not yet found

## Exclusion Summary

**Out of Scope (Not Extracted):**

- WAF (Web Application Framework) base classes — these are framework, not business logic
- Ant build files, deployment descriptors (application.xml, sun-j2ee-ri.xml) — build-time, not runtime requirements
- Internationalization string bundles — UI content, not business logic
- JSTL and JSP tag libraries — template infrastructure

**Deferred (Partial Clarity):**

- Supplier integration details (SupplierPO component) — appears to use TPASupplierOrderXDE for XML transformation
- Mail delivery configuration (Mailer component) — integrates with order approval flow but endpoint/template unknown
- Admin approval workflow (Admin app) — MDBs handle async approval but manual approval entry point unclear

## Extraction Boundaries

**Recommended Module Shards (for parallel extraction):**

| Module                    | Primary                                                  | Depends On                                 | Risk            |
| ------------------------- | -------------------------------------------------------- | ------------------------------------------ | --------------- |
| apps/petstore             | Catalog, Cart, Order                                     | Many                                       | HIGH            |
| apps/opc                  | Order Approval, Fulfillment                              | ProcessManager, PO, LineItem               | HIGH            |
| apps/admin                | Admin Portal                                             | OPC, ProcessManager                        | MEDIUM          |
| apps/supplier             | Supplier Orders                                          | SupplierPO, LineItem                       | MEDIUM          |
| components/catalog        | Catalog Browsing                                         | none                                       | HIGH            |
| components/processmanager | Workflow State                                           | none                                       | HIGH            |
| components/purchaseorder  | Order Model                                              | Address, ContactInfo, CreditCard, LineItem | HIGH            |
| components/creditcard     | Payment Info                                             | none                                       | HIGH (security) |
| components/customer       | User Profiles                                            | ContactInfo, CreditCard                    | MEDIUM          |
| components/signon         | Authentication                                           | none                                       | MEDIUM          |
| components/cart           | Shopping Cart                                            | Catalog                                    | LOW             |
| Utility Components        | Address, ContactInfo, LineItem, UID, Mailer, AsyncSender | none                                       | LOW             |

## Next Steps

1. **Requirements Extraction:** Focus on high-risk modules (petstore, opc, catalog, processmanager, purchaseorder) first
2. **Ambiguity Resolution:** Locate CreditCard validation logic, PO status enum, async retry strategy
3. **Third-Party Integration Points:** Clarify supplier order XML schema (TPASupplierOrderXDE), mailer endpoint
4. **Security Review:** Credential handling in signon, CreditCard storage/transmission
