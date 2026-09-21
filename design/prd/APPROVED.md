# React Pet Store

_PRD v10 · approved 2026-09-21 · by sweeho@gmail.com. Published from the Design Workbench — edit it there, not here._

## Summary

React Pet Store is an online pet shop where customers browse a catalogue, fill a cart, and place orders through a web storefront. Orders route through an approval workflow for high-value items, then through fulfillment against supplier inventory. The system enables fast ordering by not waiting for approval or stock checks at checkout — instead, orders move asynchronously through a workflow, keeping the customer informed by email at every step.

The product spans four applications: a customer-facing storefront, an async order-processing pipeline, an admin interface for approving high-value orders, and a supplier app for managing inventory. Each owns its data and communicates through durable message passing, so none of them block each other when one is slow or down.

## Context

This is a modernization of Sun Microsystems J2EE Pet Store 1.3.2 (circa 2002), a reference implementation of J2EE patterns. The original system used Struts, JSP, and EJB entity beans. The React version targets a contemporary stack: a Vite SPA frontend, Nitro server backend, SQLite persistence.

The rebuild preserves the functional scope and user-facing behavior of the original, with specific modernizations:

- **Payment handling:** The legacy system captured but never processed credit cards. The rebuild must tokenize card data and show only the last four digits (NF-1.4 modernized).
- **Admin interface:** The legacy admin client was a Java desktop application. The rebuild uses a browser-based interface (no Java runtime required).
- **Approval rules:** The legacy system hard-coded a $500 approval threshold in source. The rebuild makes this configurable, and allows rule-based approval logic beyond a single monetary threshold (see open questions).

The scope boundary is explicit: this is e-commerce from cart to order confirmation, not a full retail platform. Returns, refunds, shipment tracking, and payment authorization are out of scope.

## Goals

1. **Frictionless browsing and ordering.** Let customers find pets, browse without creating an account, and complete a purchase with minimal form-filling.
2. **Safe high-value orders.** Hold orders above a risk threshold for human review, so review effort scales with financial risk rather than order volume.
3. **Automatic order completion.** Once an order is approved and stock exists, fulfill it without anyone watching the queue.
4. **Customer confidence.** Email every order status change so the customer never needs to return to the site to check order progress.
5. **Availability in multiple languages.** Serve the entire storefront (catalog, labels, and descriptions) in English, Japanese, and Chinese.
6. **Resilience to component slowness.** Allow orders even when the supplier is slow or the admin queue is backed up — neither should block customer checkout.
7. **Visibility for operations.** Give administrators insight into what is selling, broken down by category and time period.

## Non-goals

- **Real-time stock visibility.** The storefront does not show inventory levels before checkout. Availability is resolved after ordering, intentionally decoupling the customer experience from supplier systems.
- **Payment processing.** Card data is validated and stored, but orders are not charged, declined, or authorized through a payment gateway.
- **Customer order history.** Customers receive a confirmation number at checkout and status emails thereafter. No "my orders" page or historical lookup.
- **Shipment tracking.** Completed is the final status. There is no tracking, carrier data, or updates after fulfillment.
- **Order modification.** Once submitted, an order cannot be changed, cancelled, or refunded from the customer interface.
- **Returns and refunds.** The system does not handle returns, exchanges, or refund processing.
- **Multiple suppliers or sourcing.** One supplier fills all orders. There is no sourcing choice or fallback supplier.
- **Responsive design.** The storefront is designed for desktop browsers; mobile and narrow-screen layouts are out of scope.

## Users

### Shopper

**Who:** Customers browsing and buying pets online.

**Needs:** Find pets quickly, see prices, add to cart with minimal friction, and complete purchase with the fewest form fields. Willing to create an account to finish a purchase; unwilling to create one just to browse.

**Access:** Web browser. Can browse anonymously; must sign in before checkout.

**Constraints:** Can only view and edit their own account; receives no order status visibility on-site (only via email).

### Administrator

**Who:** Store staff reviewing orders that exceed the approval threshold (default $500).

**Needs:** Review pending orders in batches, stage approval/denial decisions, and commit them together. Also needs visibility into sales by category to understand what is moving.

**Access:** Browser-based admin console. Requires authentication on every session.

**Constraints:** Cannot modify orders, customer data, or the catalog. The only action available is status decisions (approve/deny).

### Supplier Staff

**Who:** Warehouse or inventory team managing stock levels.

**Needs:** Update inventory quantities in bulk and know that their updates trigger order fulfillment.

**Access:** Web-based inventory management. Requires authentication.

**Constraints:** No visibility into orders or customer data. Receives only line items to fulfill, not shipping addresses or personal information.

## User journeys

### Shopper: Browse and Buy

1. **Home** — Customer arrives. Sees category image map and five pet categories.
2. **Category listing** — Clicks a category (e.g., Dogs). Sees products with descriptions, paginated.
3. **Product page** — Clicks a product (e.g., Bulldog). Sees items with prices and Add to Cart links.
4. **Item detail** — (Optional) Clicks an item name to see full description, image, and price.
5. **Cart** — Adds items. Updates quantities. Reviews subtotal.
6. **Sign in** — Redirected to sign in if not already authenticated.
7. **Checkout** — Enters or confirms billing and shipping addresses. Card is pre-filled from account.
8. **Confirmation** — Receives order number and confirmation email address on screen. Order is submitted asynchronously.

### Shopper: Search

1. **Search box** — Enters keywords in the banner search.
2. **Results** — Sees matching items, paginated, with Add to Cart links.
3. **Cart** — Proceeds to cart and checkout.

### Shopper: Account Management

1. **Account page** — Views current contact info, card type, and profile settings.
2. **Edit account** — Changes contact, card, language preference, or feature toggles (MyList, pet tips).
3. **Language switch** — Clicks a flag icon to change language for the session. (Permanent change on account page.)

### Administrator: Review Orders

1. **Login** — Signs in to admin console.
2. **Pending tab** — Views orders with total ≥ $500.
3. **Decision staging** — Clicks rows and sets status to Approved or Denied.
4. **Commit** — Sends staged decisions to server. Customer receives status email.
5. **Refresh** — Refreshes table (does not auto-poll).

### Administrator: View Sales

1. **Sales tab** — Switches to reporting view.
2. **Date range** — Enters start and end dates.
3. **Fetch** — Fetches sales by category for that period.
4. **Charts** — Views pie chart (category share) and bar chart (sales volume by category).

### Supplier: Update Inventory

1. **Login** — Signs in to supplier app.
2. **Inventory listing** — Sees all items with current quantities.
3. **Bulk update** — Types new quantities, checks "Update" checkbox on rows to modify.
4. **Submit** — Sends changes. Order Processing Centre re-evaluates approved orders; any that can now be filled complete automatically.

## Capability map

- **catalog-browsing** — Navigate categories, products, and items; search by keyword; paginate results.
- **shopping-cart** — Add items; adjust quantities; remove items; persist cart across session.
- **order-placement** — Submit cart as order; collect billing, shipping, and payment info; asynchronously hand off to approval workflow.
- **payment-processing** — Capture and store credit card details (tokenized); validate on order.
- **user-accounts** — Register, sign in, profile management; store contact info and payment method; language and feature preferences.
- **order-fulfillment** — Async approval workflow; auto-approve under threshold; hold high-value orders for admin; move approved orders to fulfillment once stock available; deny orders with feedback.
- **order-tracking** — Track order through pipeline (Pending → Approved → Completed); query by status; deliver status email on each transition.
- **supplier-management** — Receive bulk inventory updates from supplier; use updates to trigger fulfillment of waiting orders.
- **admin-operations** — Review pending orders in batch; stage and commit approval/denial decisions; view sales reporting by category and date range.
- **customer-notifications** — Send order confirmation, approval, denial, and completion emails; queue notifications so mail outage does not block order processing.

## Screens

### Storefront

| Screen             | Purpose            | Key Elements                                                                                                           |
| ------------------ | ------------------ | ---------------------------------------------------------------------------------------------------------------------- |
| Home               | Entry point        | Category image map; pet category navigation sidebar; optional MyList and pet tips panels                               |
| Category listing   | Browse products    | Paginated product list; product names and descriptions; Add to Cart per product                                        |
| Product page       | Browse items       | Paginated item list; item names, descriptions, prices; Add to Cart per item                                            |
| Item detail        | Full item view     | Item image; list price and customer price; full description; Add to Cart                                               |
| Search results     | Keyword search     | Paginated items; item names, descriptions, prices; Add to Cart per item                                                |
| Cart               | Review items       | Line items with quantity boxes; Remove links; Update Cart button; subtotal; Checkout button                            |
| Checkout form      | Order entry        | Billing address form (pre-filled from account); Shipping address form (pre-filled); card is pre-filled, not re-entered |
| Order confirmation | Success            | Order number; confirmation email address; status email explanation                                                     |
| Sign in / sign up  | Authentication     | Sign in form (pre-filled with remembered username); Sign up form (contact, card, profile preferences)                  |
| Account            | User profile       | Read-only view of contact, card, language, profile settings                                                            |
| Edit account       | Profile management | Editable forms for contact, card, language, MyList flag, pet tips flag                                                 |

### Admin

| Screen                  | Purpose      | Key Elements                                                                                                                                                                         |
| ----------------------- | ------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Pending orders          | Batch review | Sortable table (order number, customer, date, amount, status); rows are selectable; Status cell is editable (Approved/Denied); Commit button; data loads on refresh, not auto-polled |
| Non-pending orders      | Reference    | Read-only table of already-decided and completed orders                                                                                                                              |
| Sales by category (pie) | Reporting    | Pie chart; pet categories as slices; date range inputs; Fetch button                                                                                                                 |
| Sales by category (bar) | Reporting    | Bar chart; pet categories on axis; sales volume; date range inputs; Fetch button                                                                                                     |

### Supplier

| Screen         | Purpose          | Key Elements                                                                                                                        |
| -------------- | ---------------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| Inventory list | Stock management | Table of all items with current quantity; New Quantity input; Update checkbox per row; Submit button; only checked rows are written |

## Constraints and assumptions

### Constraints

- **Approval threshold:** Default $500 per order (configurable at deploy time; see open questions).
- **Order immutability:** Once submitted, an order cannot be modified, cancelled, or refunded.
- **Language scope:** English, Japanese, Chinese only. Adding a locale requires content and localization.
- **Supplier scope:** One supplier per item; no sourcing fallback.
- **Stock reservation:** Nothing is held at order time; concurrent orders for a scarce item race to fulfillment.

### Assumptions

- Customers accept email as the only post-order communication channel.
- Recorded inventory is accurate because staff maintain it; no automated reconciliation against physical stock.
- Customers will navigate and browse on desktop browsers; mobile is not a priority.
- Administrators will work through the queue in batches, not one order at a time.
- One supplier's invoice data matches the OPC's line-item record.

## Open questions

1. **Approval rule design:** Should the approval threshold stay a single order-total rule, or become a rule engine that can also consider customer age/tenure, order destination, and item category?

2. **Back-order visibility:** Should back-ordered orders (Approved but waiting on stock) become a distinct status in the admin queue, or stay as Approved with a separate stock-wait indicator?

3. **Back-order timeout:** How long should an approved order wait on stock before escalation, cancellation, or fallback?

4. **Stock visibility:** Should customers see availability before ordering (coupling the storefront to supplier data), or keep the current design where availability is resolved post-order?

5. **Admin interface location:** Should the admin interface remain browser-based, or could a desktop application be an option?

6. **Pricing strategy:** Should prices be per-locale (e.g., different USD/JPY/CNY values) instead of one price formatted three ways?

7. **Inventory reconciliation:** Who owns reconciling recorded vs. physical inventory, and at what frequency?

8. **Card tokenization:** Which payment tokenization service should be used, and how should the stored token be managed?

9. **Cancellation window:** Should customers be able to cancel orders while Pending (before approval), and does this require a cancellation window?

10. **Supplier feedback on inventory commit:** Should the supplier app report how many waiting orders were released by each inventory update?

## Sources

- `design/sources/markdown/java-pet-store-1-3-2-product-requirements-document/extracted.md` — Goals, users, functional requirements, data model, constraints
- `design/sources/markdown/java-pet-store-1-3-2-user-manual/extracted.md` — User journeys, screen descriptions, functionality details
- `legacy-analysis/discovery/report.md` — System architecture, component structure, data flow
- `legacy-analysis/discovery/capabilities.csv` — Capability breakdown
