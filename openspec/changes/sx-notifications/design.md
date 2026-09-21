# Customer Notifications Design Notes

## User Interface

No screen records were extracted for this capability; its user interface is unspecified.

## Legacy Implementation Architecture

### Message-Driven Bean Layer

**MailerMDB** (`components/mailer/src/com/sun/j2ee/blueprints/mailer/ejb/MailerMDB.java`)

- Message-driven bean implementing MessageDrivenBean and MessageListener
- Receives messages from JMS Queue
- Method: `onMessage(Message msg)` processes incoming email requests
- Transaction attribute: Required (container-managed)
- Exception handling:
  - MailerAppException: silently ignored (mail server unavailable)
  - XMLDocumentException: rethrown as EJBException
  - JMSException: rethrown as EJBException

### Email Sending

**MailHelper** (`components/mailer/src/com/sun/j2ee/blueprints/mailer/ejb/MailHelper.java`)

- Utility class for email sending
- Method: `createAndSendMail(String emailAddress, String subject, String mailContent, Locale locale)`
- JNDI lookup: obtains JavaMail Session from "java:comp/env/mail/MailSession"
- Uses javax.mail APIs:
  - MimeMessage for message construction
  - InternetAddress.parse() for recipient parsing
  - Transport.send() for SMTP delivery
- Sets content type to "text/html"
- Creates DataHandler with ByteArrayDataSource
- Sets X-Mailer header to "JavaMailer"
- Sets Sent Date header to current system date
- Exception handling: catches all exceptions, logs to System.err, throws MailerAppException

### Email Message Model

**Mail** (`components/mailer/src/com/sun/j2ee/blueprints/mailer/ejb/Mail.java`)

- Data object representing an email message
- Fields:
  - `address`: recipient email address (String)
  - `subject`: email subject line (String)
  - `content`: email message body (String)
- Public getter methods: getAddress(), getSubject(), getContent()
- Static method: `fromXML(String buffer)` deserializes XML to Mail object
- XML validation: enabled by default (VALIDATING = true)
- DTD identifiers:
  - PUBLIC ID: "-//Sun Microsystems, Inc. - J2EE Blueprints Group//DTD OPC Mail 1.0//EN"
  - SYSTEM ID: "/com/sun/j2ee/blueprints/mailer/rsrc/schemas/Mail.dtd"

### Message Format

**Mail.dtd** (`components/mailer/src/com/sun/j2ee/blueprints/mailer/rsrc/schemas/Mail.dtd`)

```xml
<!ELEMENT Mail (Address, Subject, Content)>
<!ELEMENT Address (#PCDATA)>
<!ELEMENT Subject (#PCDATA)>
<!ELEMENT Content (#PCDATA)>
```

Example valid email message:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Mail PUBLIC "-//Sun Microsystems, Inc. - J2EE Blueprints Group//DTD OPC Mail 1.0//EN"
  "http://example.com/schemas/Mail.dtd">
<Mail>
  <Address>customer@example.com</Address>
  <Subject>Order Confirmation</Subject>
  <Content><![CDATA[<html><body>Your order has been confirmed</body></html>]]></Content>
</Mail>
```

### Configuration and Deployment

**ejb-jar.xml** Configuration

Message-driven bean declaration:

```xml
<message-driven>
  <ejb-name>MailerMDB</ejb-name>
  <ejb-class>com.sun.j2ee.blueprints.mailer.ejb.MailerMDB</ejb-class>
  <transaction-type>Container</transaction-type>
  <message-driven-destination>
    <destination-type>javax.jms.Queue</destination-type>
  </message-driven-destination>
</message-driven>
```

Resource reference for mail session:

```xml
<resource-ref>
  <res-ref-name>mail/MailSession</res-ref-name>
  <res-type>javax.mail.Session</res-type>
  <res-auth>Container</res-auth>
  <res-sharing-scope>Shareable</res-sharing-scope>
</resource-ref>
```

Container transaction declaration:

```xml
<assembly-descriptor>
  <container-transaction>
    <method>
      <ejb-name>MailerMDB</ejb-name>
      <method-name>onMessage</method-name>
      <method-params>
        <method-param>javax.jms.Message</method-param>
      </method-params>
    </method>
    <trans-attribute>Required</trans-attribute>
  </container-transaction>
</assembly-descriptor>
```

### JMS Integration

**Queue Destination**

- Message queue for email dispatch requests
- Configured in application server (implementation-dependent)
- MailerMDB listens on this queue for incoming email requests

**AsyncSender** (Separate component)

- Enqueues email requests to the notification queue
- Makes email dispatch asynchronous from main application flow

### Exception Hierarchy

**MailerAppException**

- Custom exception for mail sending failures
- Thrown by MailHelper when email cannot be sent
- Silently suppressed by MailerMDB (graceful degradation)
- Indicates mail server unavailability or configuration issues

**XMLDocumentException**

- Thrown during XML parsing/validation failures
- Propagated as EJBException by MailerMDB
- Indicates malformed or invalid email message format

**JMSException**

- Thrown for JMS queue/message processing errors
- Propagated as EJBException by MailerMDB
- Indicates queue/messaging infrastructure problems

### Email Sending Flow

1. Application enqueues email request as XML message to JMS queue
2. MailerMDB receives message via onMessage() callback
3. MailerMDB parses XML to Mail object via Mail.fromXML()
4. MailerMDB calls MailHelper.createAndSendMail() with Mail data
5. MailHelper looks up JavaMail Session from JNDI
6. MailHelper creates MimeMessage with recipient, subject, HTML content
7. MailHelper sends message via Transport.send()
8. Transaction commits if successful, rolls back on exception

### Error Handling Flow

**Mail Server Unavailable:**

1. MailHelper.createAndSendMail() throws MailerAppException
2. MailerMDB catches MailerAppException
3. Exception is silently suppressed with comment about mail server setup
4. Message is processed but email not sent
5. Transaction commits (degraded mode)

**Invalid Email XML:**

1. Mail.fromXML() throws XMLDocumentException
2. MailerMDB catches XMLDocumentException
3. Exception is rethrown as EJBException
4. Container rolls back transaction
5. Message may be redelivered by JMS

**JMS Error:**

1. MailerMDB receives JMSException from JMS APIs
2. Exception is caught and rethrown as EJBException
3. Container rolls back transaction
4. JMS provider handles redelivery

### JNDI Bindings

**Mail Session** (Required)

- JNDI name: `java:comp/env/mail/MailSession`
- Type: `javax.mail.Session`
- Auth: Container-managed
- Scope: Shareable
- Configuration: Application server-specific

### Locale Support

The MailHelper.createAndSendMail() method accepts a Locale parameter, though its usage in email formatting is not explicitly documented in the code. The Locale is passed through the call chain but actual localization behavior depends on implementation details not visible in the extracted records.

### Known Implementation Details

1. **Email Content Type**: Always "text/html" - no plain text option
2. **Exception Logging**: Errors printed to System.err, not a logging framework
3. **From Address**: Set via mail session configuration, not specified per email
4. **Character Encoding**: Handled by MIME/JavaMail defaults, not explicitly set
5. **Message Size**: No documented limits on email size
6. **Queue Semantics**: Point-to-point queue (not publish-subscribe topic)
7. **Delivery Guarantee**: At-least-once semantics via container transactions
8. **Redelivery**: Container/JMS-managed; retry count and delays configurable at server level

## Integration Points

- **Order Processing Component (OPC)**: Sends order confirmation emails
- **Process Manager**: Triggers emails for order status changes
- **Async Sender**: Enqueues email requests to notification queue
- **Application Server**: Provides JMS queue and mail session resources
- **SMTP Server**: Receives email from Transport.send() for delivery

## Performance Considerations

- No caching of email metadata
- Each email creates new MimeMessage (not pooled)
- JNDI lookup performed for each email (typically cached by server)
- No batch sending; emails sent one-at-a-time
- No documented rate limiting or throttling

## Known Limitations

1. HTML format only - no plain text alternative
2. No built-in retry mechanism for failed sends
3. Mail server misconfiguration silently ignored (no alerting)
4. No email templating engine visible
5. Locale parameter accepted but localization mechanism unclear
6. No support for attachments
7. Single recipient per email (no CC/BCC)
8. No email tracking or delivery confirmation
