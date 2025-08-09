import { NextResponse } from "next/server";
import type { NextRequest } from "next/server";

export function middleware(request: NextRequest) {
  // Skip middleware for static files and API routes
  if (
    request.nextUrl.pathname.startsWith('/_next') ||
    request.nextUrl.pathname.startsWith('/api') ||
    request.nextUrl.pathname.includes('.') ||
    request.nextUrl.pathname === '/favicon.ico'
  ) {
    return NextResponse.next();
  }

  // Check if user is trying to access protected routes
  const protectedPaths = [
    "/dashboard",
    "/users",
    "/moderators",
    "/reports",
    "/messages",
    "/matches",
    "/subscriptions",
    "/settings",
    "/help",
    "/profile"
  ];
  
  const isProtectedPath = protectedPaths.some((path) =>
    request.nextUrl.pathname.startsWith(path)
  );

  if (isProtectedPath) {
    // Check for auth token in cookies
    const token = request.cookies.get("auth_token")?.value;
    
    if (!token) {
      // For production static exports, we need to handle this differently
      const isStaticExport = process.env.NEXT_EXPORT === 'true';
      
      if (isStaticExport) {
        // In static export mode, redirect using client-side JavaScript
        const response = NextResponse.next();
        response.headers.set('x-middleware-rewrite', '/login');
        return response;
      } else {
        // Normal redirect for server-side rendering
        return NextResponse.redirect(new URL("/login", request.url));
      }
    }
  }

  // Allow access to login page and public routes
  return NextResponse.next();
}

export const config = {
  matcher: [
    /*
     * Match all request paths except for the ones starting with:
     * - api (API routes)
     * - _next/static (static files)
     * - _next/image (image optimization files)
     * - favicon.ico (favicon file)
     * - public folder
     */
    "/((?!api|_next/static|_next/image|favicon.ico|.*\\..*|public).*)",
  ],
};
