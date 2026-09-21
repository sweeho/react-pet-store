## 1. Email Message Model

- [ ] 1.1 Create Mail entity class with address, subject, and content fields
- [ ] 1.2 Implement Mail.getAddress(), getSubject(), getContent() getter methods
- [ ] 1.3 Create Mail.dtd schema file with proper DOCTYPE declarations
- [ ] 1.4 Implement Mail.fromXML() method for XML deserialization with validation
- [ ] 1.5 Add DTD PUBLIC and SYSTEM ID constants to Mail class
- [ ] 1.6 Implement XML validation error handling in Mail parsing

## 2. JavaMail Integration

- [ ] 2.1 Create MailHelper utility class for email sending
- [ ] 2.2 Implement JNDI lookup for mail/MailSession resource
- [ ] 2.3 Implement MimeMessage creation with recipient and subject
- [ ] 2.4 Set content type to "text/html" for email messages
- [ ] 2.5 Implement InternetAddress.parse() for recipient email parsing
- [ ] 2.6 Implement Transport.send() for SMTP delivery
- [ ] 2.7 Set X-Mailer header to "JavaMailer"
- [ ] 2.8 Set Sent Date header to current system date/time

## 3. Message-Driven Bean

- [ ] 3.1 Create MailerMDB implementing MessageDrivenBean and MessageListener
- [ ] 3.2 Implement onMessage(Message msg) method for queue message processing
- [ ] 3.3 Implement Mail.fromXML() deserialization in onMessage()
- [ ] 3.4 Call MailHelper.createAndSendMail() with parsed Mail data
- [ ] 3.5 Implement MailerAppException catch and suppress for graceful degradation
- [ ] 3.6 Implement XMLDocumentException catch and rethrow as EJBException
- [ ] 3.7 Implement JMSException catch and rethrow as EJBException
- [ ] 3.8 Add log output for mail server unavailability scenarios

## 4. Exception Handling

- [ ] 4.1 Create MailerAppException custom exception class
- [ ] 4.2 Implement exception logging to System.err in MailHelper
- [ ] 4.3 Throw MailerAppException with message "Failure while sending mail"
- [ ] 4.4 Implement EJBException wrapping for XML parsing errors
- [ ] 4.5 Implement EJBException wrapping for JMS errors
- [ ] 4.6 Add graceful degradation when mail server is unavailable

## 5. JMS Integration

- [ ] 5.1 Configure message-driven bean in ejb-jar.xml
- [ ] 5.2 Define message-driven-destination with Queue type
- [ ] 5.3 Configure queue destination in application server
- [ ] 5.4 Set up JMS queue listener for email dispatch
- [ ] 5.5 Implement async message processing flow
- [ ] 5.6 Test queue message reception and processing

## 6. Transaction Management

- [ ] 6.1 Declare container-managed transactions in ejb-jar.xml
- [ ] 6.2 Set transaction-type to "Container" for MailerMDB
- [ ] 6.3 Set trans-attribute to "Required" for onMessage() method
- [ ] 6.4 Verify transaction commits on successful email send
- [ ] 6.5 Verify transaction rollback on XML parsing errors
- [ ] 6.6 Verify graceful transaction handling with suppressed exceptions

## 7. JNDI Resource Configuration

- [ ] 7.1 Declare mail/MailSession resource-ref in ejb-jar.xml
- [ ] 7.2 Set res-ref-name to "mail/MailSession"
- [ ] 7.3 Set res-type to "javax.mail.Session"
- [ ] 7.4 Set res-auth to "Container"
- [ ] 7.5 Set res-sharing-scope to "Shareable"
- [ ] 7.6 Configure mail session in application server
- [ ] 7.7 Test JNDI lookup and mail session retrieval

## 8. Locale Support

- [ ] 8.1 Add Locale parameter to MailHelper.createAndSendMail()
- [ ] 8.2 Pass Locale through email sending chain
- [ ] 8.3 Document locale usage in email formatting
- [ ] 8.4 Test email sending with different locales

## 9. Email Headers and Metadata

- [ ] 9.1 Implement setFrom() for configured From address
- [ ] 9.2 Set X-Mailer header to "JavaMailer"
- [ ] 9.3 Set Sent Date header with current Date
- [ ] 9.4 Test email headers in delivered message

## 10. XML Message Format

- [ ] 10.1 Define Mail DTD schema with element structure
- [ ] 10.2 Implement XML validation with DTD
- [ ] 10.3 Support CDATA sections for HTML content
- [ ] 10.4 Test XML parsing and validation
- [ ] 10.5 Test with various XML encodings (UTF-8, ISO-8859-1)

## 11. Async Message Dispatch

- [ ] 11.1 Create AsyncSender for enqueueing email requests
- [ ] 11.2 Implement message serialization to XML format
- [ ] 11.3 Enqueue messages to notification queue
- [ ] 11.4 Verify async processing from application
- [ ] 11.5 Test decoupling of email send from application flow

## 12. Error Cases and Edge Cases

- [ ] 12.1 Test mail server unavailable scenario
- [ ] 12.2 Test invalid XML email message handling
- [ ] 12.3 Test missing required email fields
- [ ] 12.4 Test JMS queue errors
- [ ] 12.5 Test large email messages
- [ ] 12.6 Test special characters in email content
- [ ] 12.7 Test invalid recipient email addresses

## 13. Configuration and Deployment

- [ ] 13.1 Configure JMS queue in application server
- [ ] 13.2 Configure mail session in application server
- [ ] 13.3 Verify SMTP server connectivity
- [ ] 13.4 Deploy MailerMDB to container
- [ ] 13.5 Configure transaction manager
- [ ] 13.6 Deploy DTD schema to classpath

## 14. Testing and Validation

- [ ] 14.1 Write unit tests for Mail class XML parsing
- [ ] 14.2 Write integration tests for MailHelper.createAndSendMail()
- [ ] 14.3 Write tests for MailerMDB message processing
- [ ] 14.4 Write tests for JMS queue integration
- [ ] 14.5 Write tests for transaction behavior
- [ ] 14.6 Write tests for exception handling
- [ ] 14.7 Write smoke tests for end-to-end email flow
- [ ] 14.8 Test with mail server unavailable
- [ ] 14.9 Test with invalid XML messages
- [ ] 14.10 Load test with high message volume
