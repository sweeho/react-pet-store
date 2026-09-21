## ADDED Requirements

### Requirement: Email message structure

The system SHALL process email messages containing exactly three required elements in order: recipient email address (Address), message subject (Subject), and message content (Content). All three elements MUST be present for a valid email message.

#### Scenario: Send email with all required fields

- **GIVEN** an email message with address="customer@example.com", subject="Order Confirmation", and content="<html>Your order has been confirmed</html>"
- **WHEN** the message is sent
- **THEN** the system delivers the email with the specified recipient, subject line, and HTML-formatted content

#### Scenario: Missing required field

- **GIVEN** an email message missing the address element
- **WHEN** the system attempts to process the message
- **THEN** the system raises an exception and does not send the email

### Requirement: XML email format

The system SHALL accept email messages in XML format conforming to the Mail DTD schema with public identifier "-//Sun Microsystems, Inc. - J2EE Blueprints Group//DTD OPC Mail 1.0//EN". All email messages SHALL be validated against the DTD during deserialization.

#### Scenario: Parse valid XML email

- **GIVEN** an XML email message conforming to the Mail DTD schema
- **WHEN** the message is parsed
- **THEN** the system successfully deserializes it to a Mail object

#### Scenario: Parse invalid XML email

- **GIVEN** an XML email message that does not conform to the Mail DTD
- **WHEN** the message is parsed
- **THEN** the system raises an XMLDocumentException

### Requirement: JMS message dispatch

The system SHALL receive email dispatch requests from a JMS Queue via a Message-Driven Bean (MailerMDB) that implements the MessageListener interface. The MailerMDB SHALL listen on a configured Queue destination for email messages.

#### Scenario: Receive email from queue

- **GIVEN** an email message placed on the JMS queue
- **WHEN** the MailerMDB onMessage() method is invoked with the message
- **THEN** the system processes the message and sends the email

### Requirement: Email sending via JavaMail

The system SHALL send emails to the specified recipient email address with the provided subject line and HTML-formatted message content using the J2EE Mail Session resource. Email content SHALL always be sent as HTML format via MIME message.

#### Scenario: Send email successfully

- **GIVEN** a Mail object with valid address, subject, and HTML content
- **WHEN** the system calls sendMail()
- **THEN** the email is delivered to the recipient with subject and content intact

#### Scenario: Set email properties

- **GIVEN** an email ready to send
- **WHEN** the system constructs the MimeMessage
- **THEN** the system sets the recipient via InternetAddress.parse(), subject line, and content type as "text/html"

### Requirement: Mail Session JNDI lookup

The system SHALL look up a JavaMail Session from JNDI with resource name "mail/MailSession" as declared in the EJB resource-ref element, with container-provided authentication. The mail session binding SHALL be configured at deployment time.

#### Scenario: JNDI lookup succeeds

- **GIVEN** the application server has a mail session bound to "java:comp/env/mail/MailSession"
- **WHEN** the MailHelper looks up the mail session
- **THEN** the system retrieves a valid javax.mail.Session object

#### Scenario: JNDI lookup fails

- **GIVEN** the application server does not have a mail session configured
- **WHEN** the MailHelper attempts the JNDI lookup
- **THEN** the system throws a NamingException

### Requirement: Container-managed transactions for message processing

The system SHALL use container-managed transactions with the "Required" transaction attribute for the MailerMDB.onMessage() method, ensuring email message processing occurs within a transaction boundary. All message processing and email sending MUST be transactional.

#### Scenario: Message processing within transaction

- **GIVEN** an email message on the queue
- **WHEN** the MailerMDB processes the message
- **THEN** the entire operation from message receipt to email sending occurs within a single container-managed transaction

#### Scenario: Transaction rollback on error

- **GIVEN** a transaction is processing an email message
- **WHEN** an error occurs during email sending
- **THEN** the transaction is rolled back by the container

### Requirement: Exception handling for mail server unavailability

When the MailHelper encounters an exception during mail creation or sending, the system SHALL catch the exception, log it to System.err, and throw a MailerAppException with the message "Failure while sending mail". When MailerMDB catches a MailerAppException, it SHALL suppress the exception without rethrowing, allowing the application to continue gracefully if the mail server is unavailable.

#### Scenario: Mail server connection fails

- **GIVEN** the mail server is unavailable or misconfigured
- **WHEN** the system attempts to send an email
- **THEN** a MailerAppException is thrown and logged, but not propagated to the container

#### Scenario: Mail server missing in development

- **GIVEN** a development environment where the mail server is not configured
- **WHEN** an email dispatch request is received
- **THEN** the system logs the error and continues without propagating the exception

### Requirement: XML parsing exception propagation

When the MailerMDB.onMessage() method encounters an XMLDocumentException during XML email message parsing, the system SHALL rethrow the exception as an EJBException, propagating the XML parsing error to the container for transaction management and error handling.

#### Scenario: Malformed XML email received

- **GIVEN** a malformed XML message on the queue
- **WHEN** the MailerMDB attempts to parse it via Mail.fromXML()
- **THEN** an XMLDocumentException is caught and rethrown as EJBException

### Requirement: JMS exception propagation

When the MailerMDB.onMessage() method encounters a JMSException during message processing, the system SHALL rethrow the exception as an EJBException, ensuring JMS-level errors are properly propagated to the container.

#### Scenario: JMS message error occurs

- **GIVEN** a JMS error during message receipt or processing
- **WHEN** the MailerMDB encounters the JMSException
- **THEN** it rethrows as EJBException for container handling

### Requirement: Asynchronous message processing

The system SHALL support asynchronous email dispatch through a message-driven bean architecture, allowing email sending to be decoupled from the main application flow. Email requests placed on the JMS queue SHALL be processed asynchronously by the message listener.

#### Scenario: Email sent asynchronously

- **GIVEN** an application that sends an email request to the JMS queue
- **WHEN** the request is enqueued
- **THEN** the requesting process continues without waiting for the email to be sent, and the MailerMDB processes it asynchronously

### Requirement: Email message content format

Email message content SHALL be sent in HTML format via MIME message. The system SHALL set the content type as "text/html" and wrap message content in an appropriate MIME data handler.

#### Scenario: Send HTML-formatted email

- **GIVEN** email content with HTML markup: "<html><body>Order confirmation</body></html>"
- **WHEN** the system sends the email
- **THEN** the content is delivered as HTML with proper MIME content type

### Requirement: Message locale support

The system SHALL support locale-specific email processing, allowing the mail sender to specify a Locale for email formatting and localization purposes. The MailHelper.createAndSendMail() method SHALL accept a Locale parameter.

#### Scenario: Send email in specific locale

- **GIVEN** an email request with Locale set to Locale.GERMAN
- **WHEN** the system processes the email
- **THEN** the email formatting respects the specified locale

### Requirement: Email from address configuration

The system SHALL set a "From" address for outgoing emails using the mail session configuration. The email sender address is configured at the mail server level through the container's mail session resource.

#### Scenario: Email sent from configured address

- **GIVEN** a mail session configured with a default sender address
- **WHEN** an email is sent
- **THEN** the message includes the configured "From" address

### Requirement: Email header metadata

The system SHALL set the "X-Mailer" header to "JavaMailer" and the "Sent Date" header to the current system date/time for all outgoing emails. These headers provide metadata about the email origin and sending time.

#### Scenario: Email includes metadata headers

- **GIVEN** an email being sent
- **WHEN** the system constructs the MimeMessage
- **THEN** the X-Mailer and Sent Date headers are set on the message
