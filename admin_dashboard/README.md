# Amoura Admin Dashboard

## Mô tả
Dashboard quản trị cho ứng dụng Amoura - giao diện quản lý người dùng, báo cáo, và các tính năng admin.

## Yêu cầu hệ thống
- Node.js 18+ 
- npm hoặc yarn

## Cài đặt và Chạy

### 1. Cài đặt dependencies
```bash
npm install
```

### 2. Chạy development server
```bash
npm run dev
```
*Mặc định chạy trên port 3000*

### 3. Build production
```bash
npm run build
npm start
```

## Scripts có sẵn
- `npm run dev` - Chạy development server
- `npm run build` - Build production
- `npm start` - Chạy production server  
- `npm run lint` - Kiểm tra code linting

## Tech Stack
- **Framework**: Next.js 15.2.4
- **UI Library**: React 19
- **Language**: TypeScript 5
- **Styling**: Tailwind CSS
- **UI Components**: Radix UI
- **Form Handling**: React Hook Form với Zod validation
- **Charts**: Recharts
- **Icons**: Lucide React
- **Date**: date-fns

## Cấu trúc thư mục
```
admin_dashboard/
├── app/                 # Next.js App Router
├── components/          # React components
├── hooks/              # Custom React hooks
├── lib/                # Utility functions
├── public/             # Static assets
└── src/                # Source code
```

## Tính năng chính
- Quản lý người dùng
- Dashboard analytics
- Hệ thống báo cáo
- Quản lý moderators
- Cài đặt hệ thống
- Đa ngôn ngữ (i18n)
- Theme switching (dark/light mode)
