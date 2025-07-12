import { NextResponse } from "next/server";
import type { NextRequest } from "next/server";

export function middleware(request: NextRequest) {
  // DISABLED FOR TESTING - Allow all requests to pass through
  return NextResponse.next();

  // Check if user is trying to access protected routes
  // const protectedPaths = [
  //   "/dashboard",
  //   "/users",
  //   "/moderators",
  //   "/reports",
  //   "/messages",
  //   "/matches",
  // ];
  // const isProtectedPath = protectedPaths.some((path) =>
  //   request.nextUrl.pathname.startsWith(path)
  // );

  // if (isProtectedPath) {
  //   // Check for auth token in cookies or headers
  //   const token = request.cookies.get("auth_token")?.value;

  //   if (!token) {
  //     // Redirect to login if no token
  //     return NextResponse.redirect(new URL("/login", request.url));
  //   }
  // }

  // // Allow access to login page and public routes
  // return NextResponse.next();
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
    "/((?!api|_next/static|_next/image|favicon.ico|public).*)",
  ],
};
