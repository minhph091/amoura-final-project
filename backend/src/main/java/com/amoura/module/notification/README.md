# Notification Module - Complete Documentation

## 📋 Overview
The Notification module provides a comprehensive real-time notification system for the Amoura dating application, featuring WebSocket integration, cursor-based pagination, and multiple notification types.

## 🚀 Features

### ✅ Real-time Notifications via WebSocket
- Instant delivery of notifications to connected clients
- User-specific notification channels
- JWT authentication for secure connections
- Support for multiple WebSocket protocols (SockJS, native WebSocket)

### ✅ Cursor-Based Pagination
- High-performance pagination without offset issues
- Consistent results even with concurrent updates
- Bidirectional navigation (next/previous pages)

### ✅ Multiple Notification Types
- **MATCH**: New match notifications
- **MESSAGE**: New message notifications  
- **SYSTEM**: System announcements
- **MARKETING**: Promotional content
- **PROFILE_UPDATE**: Profile change notifications
- **SECURITY_ALERT**: Security-related notifications

### ✅ Read/Unread Management
- Individual notification read status
- Bulk mark as read functionality
- Unread count tracking

## 🔌 WebSocket Integration

### Connection URLs
```
Development:
- ws://localhost:8080/ws
- ws://localhost:8080/websocket
- http://localhost:8080/ws (SockJS)

Production:
- wss://your-domain.com/ws
- wss://your-domain.com/websocket
- https://your-domain.com/ws (SockJS)
```

### Authentication Methods

#### Method 1: JWT Token in Headers (Recommended)
```javascript
// Using SockJS + STOMP
const socket = new SockJS('http://localhost:8080/ws');
const stompClient = Stomp.over(socket);

stompClient.connect({
  'Authorization': 'Bearer ' + jwtToken
}, onConnect, onError);

// Using native WebSocket
const ws = new WebSocket('ws://localhost:8080/ws');
ws.onopen = function() {
  ws.send(JSON.stringify({
    type: 'AUTH',
    token: jwtToken
  }));
};
```

#### Method 2: JWT Token in Query Parameters
```javascript
// For clients that don't support custom headers
const socket = new SockJS('http://localhost:8080/ws?token=' + jwtToken);
const stompClient = Stomp.over(socket);

stompClient.connect({}, onConnect, onError);
```

### Subscription Topics

#### User-Specific Notifications
```javascript
// Each user subscribes to their personal notification queue
stompClient.subscribe('/user/queue/notification', function(message) {
  const notification = JSON.parse(message.body);
  console.log('New notification:', notification);
  displayNotification(notification);
});
```

#### Public System Notifications (Future)
```javascript
// For system-wide announcements
stompClient.subscribe('/topic/system', function(message) {
  const systemNotification = JSON.parse(message.body);
  console.log('System notification:', systemNotification);
});
```

### Message Format

#### Incoming Notification Message
```json
{
  "id": "123",
  "type": "MATCH",
  "title": "New Match!",
  "content": "You and Sarah have matched! Start chatting now!",
  "relatedEntityId": 456,
  "relatedEntityType": "MATCH",
  "timestamp": "2024-01-15T10:30:00Z",
  "action": "CREATE",
  "isRead": false
}
```

#### Message Types and Actions
- **CREATE**: New notification created
- **UPDATE**: Notification updated (e.g., marked as read)
- **DELETE**: Notification deleted

### Complete WebSocket Implementation Examples

#### Vanilla JavaScript
```javascript
class NotificationWebSocket {
  constructor(token) {
    this.token = token;
    this.socket = null;
    this.stompClient = null;
    this.reconnectAttempts = 0;
    this.maxReconnectAttempts = 5;
  }

  connect() {
    try {
      // Create SockJS connection
      this.socket = new SockJS('http://localhost:8080/ws');
      this.stompClient = Stomp.over(this.socket);

      // Configure STOMP client
      this.stompClient.reconnect_delay = 5000;
      this.stompClient.debug = null; // Disable debug logs

      // Connect with authentication
      this.stompClient.connect({
        'Authorization': 'Bearer ' + this.token
      }, 
      // Success callback
      (frame) => {
        console.log('WebSocket connected:', frame);
        this.reconnectAttempts = 0;
        this.subscribeToNotifications();
      },
      // Error callback
      (error) => {
        console.error('WebSocket connection error:', error);
        this.handleReconnect();
      });
    } catch (error) {
      console.error('Failed to create WebSocket connection:', error);
    }
  }

  subscribeToNotifications() {
    this.stompClient.subscribe('/user/queue/notification', (message) => {
      try {
        const notification = JSON.parse(message.body);
        this.handleNotification(notification);
      } catch (error) {
        console.error('Error parsing notification:', error);
      }
    });
  }

  handleNotification(notification) {
    console.log('Received notification:', notification);
    
    // Handle different notification types
    switch (notification.type) {
      case 'MATCH':
        this.showMatchNotification(notification);
        break;
      case 'MESSAGE':
        this.showMessageNotification(notification);
        break;
      case 'SYSTEM':
        this.showSystemNotification(notification);
        break;
      default:
        this.showGenericNotification(notification);
    }
  }

  showMatchNotification(notification) {
    // Show match notification with special styling
    this.showToast(notification.title, notification.content, 'success');
  }

  showMessageNotification(notification) {
    // Show message notification
    this.showToast(notification.title, notification.content, 'info');
  }

  showSystemNotification(notification) {
    // Show system notification
    this.showToast(notification.title, notification.content, 'warning');
  }

  showGenericNotification(notification) {
    // Show generic notification
    this.showToast(notification.title, notification.content, 'default');
  }

  showToast(title, content, type) {
    // Implementation depends on your UI framework
    // Example with a simple toast library
    if (window.toast) {
      window.toast.show({
        title: title,
        message: content,
        type: type,
        duration: 5000
      });
    }
  }

  handleReconnect() {
    if (this.reconnectAttempts < this.maxReconnectAttempts) {
      this.reconnectAttempts++;
      console.log(`Reconnecting... Attempt ${this.reconnectAttempts}`);
      
      setTimeout(() => {
        this.connect();
      }, 5000 * this.reconnectAttempts); // Exponential backoff
    } else {
      console.error('Max reconnection attempts reached');
    }
  }

  disconnect() {
    if (this.stompClient) {
      this.stompClient.disconnect();
    }
    if (this.socket) {
      this.socket.close();
    }
  }
}

// Usage
const notificationWS = new NotificationWebSocket(jwtToken);
notificationWS.connect();

// Cleanup on page unload
window.addEventListener('beforeunload', () => {
  notificationWS.disconnect();
});
```

#### React Hook
```javascript
import { useEffect, useRef, useState } from 'react';
import SockJS from 'sockjs-client';
import Stomp from 'stompjs';

export const useNotificationWebSocket = (token) => {
  const [isConnected, setIsConnected] = useState(false);
  const [notifications, setNotifications] = useState([]);
  const stompClientRef = useRef(null);
  const reconnectTimeoutRef = useRef(null);

  const connect = () => {
    try {
      const socket = new SockJS('http://localhost:8080/ws');
      const stompClient = Stomp.over(socket);
      
      stompClient.reconnect_delay = 5000;
      stompClient.debug = null;

      stompClient.connect({
        'Authorization': `Bearer ${token}`
      }, 
      () => {
        setIsConnected(true);
        console.log('WebSocket connected');
        
        // Subscribe to notifications
        stompClient.subscribe('/user/queue/notification', (message) => {
          const notification = JSON.parse(message.body);
          setNotifications(prev => [notification, ...prev]);
        });
      },
      (error) => {
        setIsConnected(false);
        console.error('WebSocket error:', error);
        
        // Attempt reconnection
        if (reconnectTimeoutRef.current) {
          clearTimeout(reconnectTimeoutRef.current);
        }
        reconnectTimeoutRef.current = setTimeout(connect, 5000);
      });

      stompClientRef.current = stompClient;
    } catch (error) {
      console.error('Failed to connect:', error);
    }
  };

  const disconnect = () => {
    if (stompClientRef.current) {
      stompClientRef.current.disconnect();
    }
    if (reconnectTimeoutRef.current) {
      clearTimeout(reconnectTimeoutRef.current);
    }
    setIsConnected(false);
  };

  useEffect(() => {
    if (token) {
      connect();
    }

    return () => {
      disconnect();
    };
  }, [token]);

  return { isConnected, notifications, disconnect };
};
```

#### Angular Service
```typescript
import { Injectable } from '@angular/core';
import { BehaviorSubject, Observable } from 'rxjs';
import * as SockJS from 'sockjs-client';
import * as Stomp from 'stompjs';

export interface Notification {
  id: string;
  type: string;
  title: string;
  content: string;
  relatedEntityId?: number;
  relatedEntityType?: string;
  timestamp: string;
  action: string;
  isRead: boolean;
}

@Injectable({
  providedIn: 'root'
})
export class NotificationWebSocketService {
  private stompClient: Stomp.Client | null = null;
  private notificationsSubject = new BehaviorSubject<Notification[]>([]);
  public notifications$ = this.notificationsSubject.asObservable();
  private isConnectedSubject = new BehaviorSubject<boolean>(false);
  public isConnected$ = this.isConnectedSubject.asObservable();

  connect(token: string): void {
    const socket = new SockJS('http://localhost:8080/ws');
    this.stompClient = Stomp.over(socket);
    
    this.stompClient.reconnect_delay = 5000;
    this.stompClient.debug = null;

    this.stompClient.connect({
      'Authorization': `Bearer ${token}`
    }, 
    () => {
      this.isConnectedSubject.next(true);
      console.log('WebSocket connected');
      
      this.stompClient!.subscribe('/user/queue/notification', (message) => {
        const notification: Notification = JSON.parse(message.body);
        const currentNotifications = this.notificationsSubject.value;
        this.notificationsSubject.next([notification, ...currentNotifications]);
      });
    },
    (error) => {
      this.isConnectedSubject.next(false);
      console.error('WebSocket error:', error);
      
      // Reconnect after 5 seconds
      setTimeout(() => this.connect(token), 5000);
    });
  }

  disconnect(): void {
    if (this.stompClient) {
      this.stompClient.disconnect();
      this.stompClient = null;
    }
    this.isConnectedSubject.next(false);
  }

  getNotifications(): Observable<Notification[]> {
    return this.notifications$;
  }

  getConnectionStatus(): Observable<boolean> {
    return this.isConnected$;
  }
}
```

## 📡 REST API Endpoints

### Cursor-Based Pagination (Recommended)

#### GET /api/notifications
Get user notifications with cursor-based pagination.

**Parameters:**
- `cursor` (optional): ID of the last item from previous page
- `limit` (optional): Number of items per page (default: 20, max: 100)
- `direction` (optional): Pagination direction - "NEXT" or "PREVIOUS" (default: "NEXT")

**Request Examples:**
```bash
# First page
GET /api/notifications?limit=10

# Next page
GET /api/notifications?cursor=123&limit=10&direction=NEXT

# Previous page
GET /api/notifications?cursor=123&limit=10&direction=PREVIOUS
```

**Response:**
```json
{
  "data": [
    {
      "id": 123,
      "userId": 456,
      "type": "MATCH",
      "title": "New Match!",
      "content": "You and Sarah have matched!",
      "relatedEntityId": 789,
      "relatedEntityType": "MATCH",
      "isRead": false,
      "readAt": null,
      "createdAt": "2024-01-15T10:30:00Z",
      "updatedAt": "2024-01-15T10:30:00Z"
    }
  ],
  "nextCursor": 122,
  "previousCursor": 124,
  "hasNext": true,
  "hasPrevious": false,
  "count": 10
}
```

### Read Status Management

#### GET /api/notifications/unread
Get all unread notifications for the current user.

**Response:**
```json
[
  {
    "id": 123,
    "type": "MATCH",
    "title": "New Match!",
    "content": "You and Sarah have matched!",
    "isRead": false,
    "createdAt": "2024-01-15T10:30:00Z"
  }
]
```

#### GET /api/notifications/unread/count
Get the count of unread notifications.

**Response:**
```json
{
  "count": 5
}
```

#### PUT /api/notifications/{id}/read
Mark a specific notification as read.

**Request:**
```bash
PUT /api/notifications/123/read
```

**Response:**
```json
{
  "message": "Notification marked as read",
  "notificationId": 123
}
```

#### PUT /api/notifications/read-all
Mark all notifications as read for the current user.

**Request:**
```bash
PUT /api/notifications/read-all
```

**Response:**
```json
{
  "message": "All notifications marked as read",
  "updatedCount": 10
}
```

## 🔧 Service Integration

### Sending Notifications from Other Services

#### Match Notifications
```java
@Service
public class MatchingService {
    
    @Autowired
    private NotificationService notificationService;
    
    public void createMatch(Long user1Id, Long user2Id, Long matchId) {
        // Create match logic...
        
        // Send notifications to both users
        User user1 = userRepository.findById(user1Id).orElseThrow();
        User user2 = userRepository.findById(user2Id).orElseThrow();
        
        notificationService.createNotification(
            user1Id,
            NotificationType.MATCH,
            "New Match!",
            "You and " + user2.getFirstName() + " have matched! Start chatting now!",
            matchId,
            "MATCH"
        );
        
        notificationService.createNotification(
            user2Id,
            NotificationType.MATCH,
            "New Match!",
            "You and " + user1.getFirstName() + " have matched! Start chatting now!",
            matchId,
            "MATCH"
        );
    }
}
```

#### Message Notifications
```java
@Service
public class MessageService {
    
    @Autowired
    private NotificationService notificationService;
    
    public void sendMessage(Long senderId, Long receiverId, String message) {
        // Send message logic...
        
        User sender = userRepository.findById(senderId).orElseThrow();
        
        notificationService.createNotification(
            receiverId,
            NotificationType.MESSAGE,
            "New Message",
            sender.getFirstName() + " sent you a message",
            messageId,
            "MESSAGE"
        );
    }
}
```

#### System Notifications
```java
@Service
public class SystemService {
    
    @Autowired
    private NotificationService notificationService;
    
    public void sendSystemNotification(Long userId, String title, String content) {
        notificationService.createNotification(
            userId,
            NotificationType.SYSTEM,
            title,
            content,
            null,
            "SYSTEM"
        );
    }
    
    public void sendSystemNotificationToAllUsers(String title, String content) {
        List<User> allUsers = userRepository.findAll();
        
        for (User user : allUsers) {
            notificationService.createNotification(
                user.getId(),
                NotificationType.SYSTEM,
                title,
                content,
                null,
                "SYSTEM"
            );
        }
    }
}
```

## 🛠️ Configuration

### WebSocket Configuration
```java
@Configuration
@EnableWebSocketMessageBroker
public class WebSocketConfig implements WebSocketMessageBrokerConfigurer {
    
    @Override
    public void registerStompEndpoints(StompEndpointRegistry registry) {
        registry.addEndpoint("/ws", "/websocket")
                .setAllowedOrigins("*") // Configure for production
                .withSockJS();
    }
    
    @Override
    public void configureMessageBroker(MessageBrokerRegistry config) {
        config.enableSimpleBroker("/user", "/topic");
        config.setApplicationDestinationPrefixes("/app");
        config.setUserDestinationPrefix("/user");
    }
}
```

### Security Configuration
```java
@Configuration
@EnableWebSecurity
public class SecurityConfig {
    
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .cors(cors -> cors.configurationSource(corsConfigurationSource()))
            .authorizeHttpRequests(authz -> authz
                .requestMatchers("/ws/**", "/websocket/**").permitAll()
                .anyRequest().authenticated()
            );
        return http.build();
    }
    
    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        configuration.setAllowedOrigins(Arrays.asList("*"));
        configuration.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "DELETE", "OPTIONS"));
        configuration.setAllowedHeaders(Arrays.asList("*"));
        configuration.setAllowCredentials(true);
        
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }
}
```

## 🚨 Troubleshooting

### Common WebSocket Issues

#### Connection Refused (403/401)
**Problem:** WebSocket connection fails with authentication error.

**Solutions:**
1. Check JWT token validity
2. Ensure token is properly formatted: `Bearer <token>`
3. Verify CORS configuration
4. Check WebSocket endpoint permissions in security config

```javascript
// Debug authentication
console.log('Token:', jwtToken);
console.log('Token format:', 'Bearer ' + jwtToken);
```

#### Connection Timeout
**Problem:** WebSocket connection times out.

**Solutions:**
1. Check network connectivity
2. Verify WebSocket endpoint URL
3. Check server firewall settings
4. Implement reconnection logic

```javascript
// Add timeout handling
const socket = new SockJS('http://localhost:8080/ws');
socket.onclose = function() {
  console.log('Connection closed, attempting to reconnect...');
  setTimeout(connect, 5000);
};
```

#### Messages Not Received
**Problem:** WebSocket connects but no notifications received.

**Solutions:**
1. Verify subscription topic: `/user/queue/notification`
2. Check if notifications are being sent from backend
3. Verify user authentication
4. Check browser console for errors

```javascript
// Debug subscription
stompClient.subscribe('/user/queue/notification', (message) => {
  console.log('Raw message:', message);
  console.log('Message body:', message.body);
  const notification = JSON.parse(message.body);
  console.log('Parsed notification:', notification);
});
```

### Performance Optimization

#### Connection Pooling
```javascript
// Reuse WebSocket connections
class WebSocketManager {
  constructor() {
    this.connections = new Map();
  }
  
  getConnection(userId, token) {
    if (!this.connections.has(userId)) {
      const connection = new NotificationWebSocket(token);
      this.connections.set(userId, connection);
    }
    return this.connections.get(userId);
  }
}
```

#### Message Batching
```javascript
// Batch multiple notifications
class NotificationBatcher {
  constructor() {
    this.batch = [];
    this.batchTimeout = null;
  }
  
  addNotification(notification) {
    this.batch.push(notification);
    
    if (this.batchTimeout) {
      clearTimeout(this.batchTimeout);
    }
    
    this.batchTimeout = setTimeout(() => {
      this.processBatch();
    }, 100);
  }
  
  processBatch() {
    // Process all notifications in batch
    this.batch.forEach(notification => {
      this.displayNotification(notification);
    });
    this.batch = [];
  }
}
```

## 📊 Monitoring and Logging

### WebSocket Connection Monitoring
```javascript
// Monitor connection health
class WebSocketMonitor {
  constructor(wsService) {
    this.wsService = wsService;
    this.healthCheckInterval = null;
  }
  
  startMonitoring() {
    this.healthCheckInterval = setInterval(() => {
      if (!this.wsService.isConnected()) {
        console.warn('WebSocket disconnected, attempting reconnection...');
        this.wsService.reconnect();
      }
    }, 30000); // Check every 30 seconds
  }
  
  stopMonitoring() {
    if (this.healthCheckInterval) {
      clearInterval(this.healthCheckInterval);
    }
  }
}
```

### Error Logging
```javascript
// Comprehensive error logging
class NotificationLogger {
  static logError(error, context) {
    console.error('Notification Error:', {
      timestamp: new Date().toISOString(),
      error: error.message,
      stack: error.stack,
      context: context
    });
    
    // Send to error tracking service
    if (window.errorTracker) {
      window.errorTracker.captureException(error, {
        extra: context
      });
    }
  }
}
```

## 🔒 Security Considerations

### JWT Token Security
- Store tokens securely (HttpOnly cookies, secure storage)
- Implement token refresh mechanism
- Validate token expiration
- Use HTTPS in production

### WebSocket Security
- Validate user permissions for each notification
- Implement rate limiting
- Monitor for suspicious activity
- Use secure WebSocket (WSS) in production

### Data Privacy
- Sanitize notification content
- Implement user consent for marketing notifications
- Provide opt-out mechanisms
- Comply with data protection regulations

## 📈 Performance Metrics

### Key Performance Indicators
- WebSocket connection success rate
- Notification delivery latency
- API response times
- Database query performance
- Memory usage

### Monitoring Dashboard
```javascript
// Performance monitoring
class PerformanceMonitor {
  static trackMetric(name, value) {
    // Send to monitoring service
    if (window.analytics) {
      window.analytics.track('performance_metric', {
        name: name,
        value: value,
        timestamp: Date.now()
      });
    }
  }
  
  static trackNotificationDelivery(notificationId, deliveryTime) {
    this.trackMetric('notification_delivery_time', deliveryTime);
  }
}
```

## 🎯 Best Practices

### Frontend Implementation
1. **Implement reconnection logic** with exponential backoff
2. **Handle connection errors** gracefully
3. **Batch notifications** for better performance
4. **Provide user feedback** for connection status
5. **Implement proper cleanup** on component unmount

### Backend Implementation
1. **Validate all inputs** before processing
2. **Use proper error handling** and logging
3. **Implement rate limiting** for notification sending
4. **Optimize database queries** with proper indexing
5. **Monitor system resources** and performance

### Testing
1. **Unit tests** for notification logic
2. **Integration tests** for WebSocket functionality
3. **Load testing** for high-volume scenarios
4. **Security testing** for authentication and authorization
5. **End-to-end tests** for complete user workflows

## 📚 Additional Resources

### Documentation Links
- [Spring WebSocket Documentation](https://docs.spring.io/spring-framework/reference/web/websocket.html)
- [STOMP Protocol Specification](https://stomp.github.io/stomp-specification-1.2.html)
- [SockJS Documentation](https://github.com/sockjs/sockjs-client)

### Related Modules
- [User Module](../user/README.md) - User management and authentication
- [Matching Module](../matching/README.md) - Match creation and management
- [Profile Module](../profile/README.md) - User profile management

### Support
For technical support or questions about the Notification module, please refer to the project documentation or contact the development team. 