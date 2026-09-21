# Notifications Design Notes

## Legacy Implementation

### Message-Driven Bean Processing

**MailerMDB** - Message-driven bean consuming notification requests:

- Implements MessageDrivenBean and MessageListener
- Consumes messages from JMS Queue via onMessage(Message)
- Processes mail messages containing Address, Subject, Content
- Container-managed transaction handling (Required)

### Mail Message Structure

**Mail.dtd** - XML schema for email messages:

```
<!ELEMENT Mail (Address, Subject, Content)>
<!ELEMENT Address (#PCDATA)>
<!ELEMENT Subject (#PCDATA)>
<!ELEMENT Content (#PCDATA)>
```

Mail class parses and extracts these three mandatory elements in sequence.

### Notification Triggering

Order status transitions trigger notification messages posted to JMS queue:

- Order confirmation on creation
- Status update notifications (APPROVED, DENIED, COMPLETED)
- Shipment notifications on fulfillment
- Delivery notifications when orders are shipped

### Multi-Locale Support

Notification templates support multiple locales; content localized based on customer's preferred language.
