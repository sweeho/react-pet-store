# Customer Notifications Specification Extraction

## Summary

This specification documents the customer notifications capability of the legacy Java Pet Store application. The notifications system provides asynchronous email delivery for customer notifications including order confirmations and status updates through a message-driven bean architecture.

## Scope

The notifications capability encompasses:

1. **Email Messaging**: Sending customer emails with subject and HTML-formatted content
2. **JMS Integration**: Asynchronous email dispatch through message queues
3. **Message Format**: XML-based email messages with DTD schema validation
4. **Message Processing**: Message-driven bean processing of email requests
5. **JavaMail Integration**: SMTP email sending via J2EE Mail Session
6. **Transaction Management**: Container-managed transactions for message reliability
7. **Exception Handling**: Graceful degradation when mail server is unavailable
8. **Email Metadata**: Headers and formatting for sent emails

## Extracted from Legacy Application

Source: Java Pet Store 1.3.2 reference application (30 records across multiple modules)

### Key Components

- **Mailer Component** (`components/mailer`): Core email sending and formatting logic
- **AsyncSender Component** (`components/asyncsender`): JMS message queue integration
- **XML Documents Component** (`components/xmldocuments`): Email message XML serialization
- **OPC and Petstore Applications**: Integration points for email dispatch

### Key Classes

- `MailerMDB`: Message-driven bean receiving email requests from JMS queue
- `MailHelper`: Utility class for sending emails via JavaMail
- `Mail`: Data object representing an email message with address, subject, content
- `AsyncSender`: EJB for enqueueing messages to the notification queue

## Design Decisions

1. **Message-Driven Bean Pattern**: Email delivery is asynchronous through MDB listener
2. **XML Message Format**: Email requests use XML with DTD schema validation
3. **JavaMail API**: Standard J2EE JavaMail for SMTP integration
4. **JNDI Resource Binding**: Mail session configured via deployment-time resource binding
5. **Graceful Degradation**: Missing mail server silently ignored for robustness
6. **Container Transactions**: Required semantics ensure message processing atomicity
7. **Error Categorization**: Different exception handling for mail server vs XML parsing errors
8. **HTML Email Format**: All emails sent in HTML format for rich content support

## Known Ambiguities

1. **Mail Server Configuration**: Exact mail server connection parameters not specified in code
2. **Locale Usage**: How locale is used in email formatting/localization is not documented
3. **Message Ordering**: Whether JMS messages are processed in order is not specified
4. **Retry Behavior**: No retry logic visible for failed email sends
5. **Large Message Handling**: Size limits for email messages are not documented
6. **Character Encoding**: Email encoding handling is not explicitly documented

## Implementation Considerations

- JMS queue must be configured in application server for email dispatch
- Mail session must be bound to JNDI name "java:comp/env/mail/MailSession"
- SMTP server configuration is external to application (server-specific)
- DTD validation is enabled by default for all incoming email XML
- Exceptions during mail server connection are silently ignored to prevent cascading failures
- All email sending is HTML-formatted; plain text is not supported
- Transaction support depends on container's transaction manager
