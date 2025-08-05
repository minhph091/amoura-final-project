# WebSocket Connection Fix

## Problem Analysis

From the logs, the WebSocket connection is failing with:

- Error: `HTTP status code: 400`
- URL shows: `https://api.amoura.space:0/api/ws#` (incorrect port 0 and fragment #)
- Backend WebSocket endpoint is `/ws` but with context-path becomes `/api/ws`
- Nginx only has location `/api/ws/` (with trailing slash) but request goes to `/api/ws`

## Root Cause

1. **Nginx Configuration Mismatch**:

   - Current: `location /api/ws/` (with trailing slash)
   - Needed: `location /api/ws` (without trailing slash)

2. **Backend Configuration**:
   - Backend endpoint: `/ws`
   - With context-path: `/api/ws`
   - But Nginx proxy_pass needs to map correctly

## Fix Required

### 1. Update Nginx Configuration

Replace the current WebSocket location block in `/etc/nginx/sites-available/api.amoura.space`:

```nginx
# Current (INCORRECT):
location /api/ws/ {
    proxy_pass         http://localhost:8080/api/ws/;
    # ... other settings
}

# New (CORRECT):
location /api/ws {
    proxy_pass         http://localhost:8080/ws;
    proxy_set_header   Host $host;
    proxy_set_header   X-Real-IP $remote_addr;
    proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header   X-Forwarded-Proto $scheme;
    proxy_set_header   Upgrade $http_upgrade;
    proxy_set_header   Connection "upgrade";
    proxy_http_version 1.1;
    proxy_read_timeout 3600;
    proxy_buffering off;
}
```

### 2. Commands to Execute on Server

```bash
# 1. Edit nginx config
sudo nano /etc/nginx/sites-available/api.amoura.space

# 2. Test nginx configuration
sudo nginx -t

# 3. Reload nginx if test passes
sudo systemctl reload nginx

# 4. Check nginx status
sudo systemctl status nginx

# 5. Check if WebSocket endpoint is accessible
curl -i -N \
  -H "Connection: Upgrade" \
  -H "Upgrade: websocket" \
  -H "Sec-WebSocket-Version: 13" \
  -H "Sec-WebSocket-Key: test" \
  https://api.amoura.space/api/ws
```

### 3. Backend Verification

Check that backend is properly configured:

```bash
# Check if Spring Boot is running on port 8080
netstat -tlnp | grep 8080

# Check backend logs for WebSocket errors
tail -f /path/to/backend/logs/application.log
```

## Key Points

1. **URL Mapping**:

   - Frontend sends: `wss://api.amoura.space/api/ws`
   - Nginx should forward to: `http://localhost:8080/ws`
   - Backend handles: `/ws` endpoint

2. **Headers**: WebSocket upgrade headers must be properly forwarded

3. **SSL**: wss:// connections must terminate at Nginx with proper SSL config

## Testing After Fix

1. Check WebSocket connection in app logs
2. Should see: `WebSocket: Connected successfully` instead of HTTP 400 error
3. Chat functionality should work in real-time

## Alternative Debug Steps

If still not working, try:

1. **Check backend logs** for WebSocket connection attempts
2. **Test direct connection** (bypassing Nginx): `ws://api.amoura.space:8080/ws`
3. **Verify SSL certificate** is properly configured
4. **Check firewall rules** for WebSocket traffic
