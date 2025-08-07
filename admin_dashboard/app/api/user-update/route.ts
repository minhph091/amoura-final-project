// API route để proxy user update requests với custom handling
import { NextRequest, NextResponse } from 'next/server';

export async function PATCH(request: NextRequest) {
  try {
    // Get auth token from request headers
    const authHeader = request.headers.get('authorization');
    if (!authHeader) {
      return NextResponse.json(
        { error: 'Authorization header required' },
        { status: 401 }
      );
    }

    // Get request body
    const body = await request.json();

    // Forward request to backend
    const backendResponse = await fetch('http://localhost:8080/api/user', {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': authHeader,
        'Accept': 'application/json',
      },
      body: JSON.stringify(body),
    });

    // Get response data
    let responseData;
    const contentType = backendResponse.headers.get('content-type');
    
    if (contentType && contentType.includes('application/json')) {
      responseData = await backendResponse.json();
    } else {
      responseData = await backendResponse.text();
    }

    // Return response with same status
    return NextResponse.json(responseData, { 
      status: backendResponse.status,
      headers: {
        'Content-Type': 'application/json',
      }
    });

  } catch (error) {
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}

export async function PUT(request: NextRequest) {
  // Same logic for PUT method
  try {
    const authHeader = request.headers.get('authorization');
    if (!authHeader) {
      return NextResponse.json(
        { error: 'Authorization header required' },
        { status: 401 }
      );
    }

    const body = await request.json();

    const backendResponse = await fetch('http://localhost:8080/api/user', {
      method: 'PATCH', // Backend expects PATCH, not PUT
      headers: {
        'Content-Type': 'application/json',
        'Authorization': authHeader,
        'Accept': 'application/json',
      },
      body: JSON.stringify(body),
    });

    let responseData;
    const contentType = backendResponse.headers.get('content-type');
    
    if (contentType && contentType.includes('application/json')) {
      responseData = await backendResponse.json();
    } else {
      responseData = await backendResponse.text();
    }

    return NextResponse.json(responseData, { 
      status: backendResponse.status,
      headers: {
        'Content-Type': 'application/json',
      }
    });

  } catch (error) {
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}
