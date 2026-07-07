---
name: jms-messaging
description: Load when working with JMS listeners, message queues, or asynchronous messaging.
---

# Skill: JMS Messaging

## When to Apply This Skill

Load this skill when working with JMS listeners, message queues, or asynchronous messaging.
**Project override**: Check project memory for the specific message broker (IBM MQ, ActiveMQ, etc.) and queue naming conventions.

---

## JMS Listener Pattern

```java
@Component
@RequiredArgsConstructor
@Slf4j
public class OrderRequestListener {

    private final OrderProcessor processor;

    /**
     * Processes incoming order requests from the JMS queue.
     *
     * @param message the raw message payload (typically XML or JSON)
     */
    @JmsListener(destination = "${app.queue.orders.request}")
    public void onOrderRequest(String message) {
        log.debug("Received order request message");
        try {
            var request = deserialize(message, OrderRequest.class);
            processor.process(request);
            log.info("Order request processed successfully");
        } catch (DeserializationException e) {
            log.error("Invalid message format — sending to DLQ", e);
            deadLetterSender.send(message, e.getMessage());
        } catch (Exception e) {
            log.error("Unexpected error processing order request", e);
            throw new RuntimeException("Processing failed — triggering retry", e);
        }
    }
}
```

---

## Request-Reply Pattern

```java
@JmsListener(destination = "${app.queue.request}")
@SendTo("${app.queue.response}")   // Spring routes return value to this queue
public String handleRequest(String xmlRequest) {
    try {
        var request  = xmlMapper.deserialize(xmlRequest, RequestMessage.class);
        var response = processor.process(request);
        return xmlMapper.serialize(response);
    } catch (Exception e) {
        log.error("Failed to process request", e);
        return xmlMapper.serializeError(e.getMessage());
    }
}
```

---

## JMS Configuration

```java
@Configuration
@EnableJms
public class JmsConfiguration {

    @Bean
    public JmsListenerContainerFactory<?> listenerFactory(
            ConnectionFactory connectionFactory,
            DefaultJmsListenerContainerFactoryConfigurer configurer) {
        var factory = new DefaultJmsListenerContainerFactory();
        configurer.configure(factory, connectionFactory);
        factory.setConcurrency("1-3");        // min-max concurrent listeners
        factory.setSessionTransacted(true);   // transactional — rollback on exception triggers retry
        factory.setErrorHandler(ex -> log.error("JMS error", ex));
        return factory;
    }

    @Bean
    public JmsTemplate jmsTemplate(ConnectionFactory connectionFactory) {
        var template = new JmsTemplate(connectionFactory);
        template.setDeliveryPersistent(true);
        template.setSessionTransacted(true);
        return template;
    }
}
```

---

## Sending Messages

```java
@Component
@RequiredArgsConstructor
public class NotificationSender {

    private final JmsTemplate jmsTemplate;
    private final XmlSerializer xmlSerializer;

    public void sendNotification(OrderEvent event) {
        try {
            String xml = xmlSerializer.serialize(event);
            jmsTemplate.convertAndSend("${app.queue.notifications}", xml);
            log.info("Notification sent for order {}", event.orderId());
        } catch (SerializationException | JmsException e) {
            log.error("Failed to send notification for order {}", event.orderId(), e);
            throw new NotificationException("Notification dispatch failed", e);
        }
    }
}
```

---

## JAXB XML Serialization

```java
public final class JaxbHelper {

    private JaxbHelper() {}

    public static <T> T unmarshal(String xml, Class<T> type) throws JAXBException {
        var context      = JAXBContext.newInstance(type);
        var unmarshaller = context.createUnmarshaller();
        return type.cast(unmarshaller.unmarshal(new StringReader(xml)));
    }

    public static String marshal(Object obj) throws JAXBException {
        var context    = JAXBContext.newInstance(obj.getClass());
        var marshaller = context.createMarshaller();
        marshaller.setProperty(Marshaller.JAXB_FORMATTED_OUTPUT, true);
        var writer = new StringWriter();
        marshaller.marshal(obj, writer);
        return writer.toString();
    }
}
```

---

## Error Handling Strategy

| Error Type | Action |
|-----------|--------|
| Deserialization failure | Log + send to DLQ + do not retry |
| Business validation failure | Log + send to DLQ + do not retry |
| Transient infrastructure error | Throw RuntimeException → JMS retries |
| Permanent processing failure | Log + send to DLQ after max retries |

---

## Testing JMS Listeners

```java
@ExtendWith(MockitoExtension.class)
class OrderRequestListenerTest {

    @Mock
    private OrderProcessor processor;

    @InjectMocks
    private OrderRequestListener listener;

    @Test
    void shouldDelegateToProcessorForValidMessage() throws Exception {
        // Given
        var xml = loadResource("/test/valid-order-request.xml");
        when(processor.process(any())).thenReturn(ProcessingResult.success());

        // When
        listener.onOrderRequest(xml);

        // Then
        verify(processor).process(any());
    }

    @Test
    void shouldSendToDeadLetterQueueOnInvalidMessage() {
        // Given
        var invalidXml = "not valid xml";

        // When / Then
        assertThatThrownBy(() -> listener.onOrderRequest(invalidXml))
            .isInstanceOf(RuntimeException.class);
        verify(processor, never()).process(any());
    }
}
```

