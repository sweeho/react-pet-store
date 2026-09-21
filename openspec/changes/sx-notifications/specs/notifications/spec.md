## ADDED Requirements

### Requirement: Message-Driven Bean Processing

The system SHALL receive email dispatch requests from a JMS Queue via a Message-Driven Bean (MailerMDB) implementing the MessageListener interface, invoked through the container's onMessage() method with container-managed transactions (Required).

#### Scenario: Consume message from queue

- **GIVEN** a message published to the mail queue
- **WHEN** the container delivers the message to MailerMDB.onMessage()
- **THEN** the message is consumed and processed within a Required transaction

### Requirement: Mail Message Structure Parsing

The system SHALL process mail messages containing three mandatory XML elements in sequence: Address (recipient email), Subject (message subject), and Content (message body), as defined in the Mail DTD schema.

#### Scenario: Parse valid mail message

- **GIVEN** a message with XML: `<Mail><Address>user@example.com</Address><Subject>Order Confirmation</Subject><Content>Your order...</Content></Mail>`
- **WHEN** the message is processed
- **THEN** all three elements are extracted: address, subject, and content

#### Scenario: Reject invalid message structure

- **GIVEN** a message missing required Content element
- **WHEN** the message is processed
- **THEN** parsing fails and error is logged; message is not sent

### Requirement: Email Notification on Order Creation

The system SHALL send a confirmation email when a purchase order is created, including the order ID, total price, and delivery address.

#### Scenario: Send order confirmation

- **GIVEN** a new purchase order with ID "1001", total "$50.00", address "john@example.com"
- **WHEN** the order is created
- **THEN** a confirmation email is sent to john@example.com with order details

### Requirement: Order Status Change Notifications

The system SHALL send notifications when order status transitions to APPROVED, DENIED, or COMPLETED, informing the customer of the new status and timestamp.

#### Scenario: Notify on order approval

- **GIVEN** an order in PENDING status transitions to APPROVED
- **WHEN** the status transition occurs
- **THEN** a notification email is sent with new status and timestamp

#### Scenario: Notify on order denial

- **GIVEN** an order in PENDING status transitions to DENIED
- **WHEN** the denial occurs
- **THEN** a notification email is sent with denial reason

### Requirement: Multi-Locale Notification Messages

The system SHALL support notification templates in multiple locales (en_US, ja_JP, zh_CN) and send notifications in the customer's preferred language.

#### Scenario: Send notification in customer's locale

- **GIVEN** a customer with preferred language ja_JP
- **WHEN** an order status changes
- **THEN** the notification is sent with Japanese text
