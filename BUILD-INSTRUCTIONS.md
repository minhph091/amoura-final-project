# 🚀 HƯỚNG DẪN BUILD ADMIN DASHBOARD CHO PRODUCTION

## 📋 Yêu cầu Server:
- Node.js v18+
- npm hoặc pnpm

## 🔧 Commands để Deploy:

### 1. Clone repository:
```bash
git clone https://github.com/minhph091/amoura-final-project.git
cd amoura-final-project/admin_dashboard
```

### 2. Checkout branch frontend:
```bash
git checkout frontend_ui
```

### 3. Install dependencies:
```bash
npm install
# hoặc
pnpm install
```

### 4. Build production:
```bash
npm run build
# hoặc
pnpm build
```

### 5. Start production:
```bash
npm start
# hoặc
pnpm start
```

## 🌐 URLs Production:
- **Admin Dashboard (Frontend):** https://admin.amoura.space (port 3000)
- **API Backend:** https://api.amoura.space

## ⚙️ Environment Variables:
File `.env.production` đã được cấu hình:
```bash
NEXT_PUBLIC_API_URL=https://api.amoura.space/api
NEXT_PUBLIC_WS_URL=wss://api.amoura.space/ws
NODE_ENV=production
PORT=3000
```

## 🔗 Nginx Configuration:
```nginx
server {
    listen 80;
    listen 443 ssl;
    server_name admin.amoura.space;
    
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

## ✅ Checklist:
- [ ] Domain admin.amoura.space trỏ về server
- [ ] Backend API chạy trên api.amoura.space  
- [ ] SSL certificate đã cài đặt
- [ ] Commands build thành công
- [ ] App chạy trên port 3000

**🎊 Xong! Admin Dashboard sẽ accessible qua https://admin.amoura.space**
