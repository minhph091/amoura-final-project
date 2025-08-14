# Amoura Landing Page

## Mô tả
Trang landing chính thức của ứng dụng Amoura - giới thiệu tính năng, download links và thông tin về sản phẩm.

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
*Chạy trên port 3002*

### 3. Build production
```bash
npm run build
npm start
```

## Scripts có sẵn
- `npm run dev` - Chạy development server (port 3002)
- `npm run build` - Build production
- `npm start` - Chạy production server (port 3002)
- `npm run lint` - Kiểm tra code linting

## Tech Stack
- **Framework**: Next.js 15.2.4
- **UI Library**: React 19
- **Language**: TypeScript 5
- **Styling**: Tailwind CSS
- **UI Components**: Radix UI
- **Icons**: Lucide React
- **QR Code**: qrcode library
- **Theme**: next-themes (dark/light mode)

## Tính năng chính
- Landing page responsive
- Download links cho mobile app
- QR code generation
- Dark/Light theme switching
- SEO optimized
- Fast loading với Next.js optimization

## Cấu trúc thư mục
```
landing_page/
├── app/                # Next.js App Router
├── components/         # React components
├── lib/               # Utility functions  
├── public/            # Static assets
└── styles/            # Global styles
```
