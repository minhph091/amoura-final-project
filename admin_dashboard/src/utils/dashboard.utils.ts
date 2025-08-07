/**
 * Utility functions for dashboard data processing and formatting
 */

export const formatNumber = (num: number): string => {
  if (num >= 1000000) {
    return (num / 1000000).toFixed(1) + 'M';
  }
  if (num >= 1000) {
    return (num / 1000).toFixed(1) + 'K';
  }
  return num.toLocaleString();
};

export const formatDate = (dateString: string): string => {
  if (!dateString) return 'Unknown';
  try {
    const date = new Date(dateString);
    return date.toLocaleDateString('en-US', {
      month: 'short',
      day: 'numeric',
      year: 'numeric'
    });
  } catch (error) {
    return 'Invalid Date';
  }
};

export const formatDateTime = (dateString: string): string => {
  if (!dateString) return 'Unknown';
  try {
    const date = new Date(dateString);
    return date.toLocaleString('en-US', {
      month: 'short',
      day: 'numeric',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });
  } catch (error) {
    return 'Invalid Date';
  }
};

export const formatTimeAgo = (dateString: string): string => {
  if (!dateString) return 'Unknown';
  try {
    const date = new Date(dateString);
    const now = new Date();
    const diffMs = now.getTime() - date.getTime();
    const diffMins = Math.floor(diffMs / (1000 * 60));
    const diffHours = Math.floor(diffMs / (1000 * 60 * 60));
    const diffDays = Math.floor(diffMs / (1000 * 60 * 60 * 24));

    if (diffMins < 1) return 'Just now';
    if (diffMins < 60) return `${diffMins} minutes ago`;
    if (diffHours < 24) return `${diffHours} hours ago`;
    if (diffDays < 7) return `${diffDays} days ago`;
    return formatDate(dateString);
  } catch (error) {
    return 'Invalid Date';
  }
};

export const getStatusColor = (status: string): string => {
  switch (status?.toUpperCase()) {
    case 'ACTIVE':
      return 'bg-green-100 text-green-800 border-green-200';
    case 'INACTIVE':
      return 'bg-gray-100 text-gray-800 border-gray-200';
    case 'SUSPEND':
    case 'SUSPENDED':
      return 'bg-red-100 text-red-800 border-red-200';
    case 'PENDING':
      return 'bg-yellow-100 text-yellow-800 border-yellow-200';
    default:
      return 'bg-gray-100 text-gray-800 border-gray-200';
  }
};

export const calculatePercentage = (value: number, total: number): number => {
  if (total === 0) return 0;
  return Math.round((value / total) * 100);
};

export const calculateGrowthRate = (current: number, previous: number): number => {
  if (previous === 0) return current > 0 ? 100 : 0;
  return Math.round(((current - previous) / previous) * 100);
};

/**
 * Check if data appears to be fallback/simulated data
 */
export const isFallbackData = (data: any[]): boolean => {
  if (!Array.isArray(data) || data.length === 0) return true;
  
  // Check if all dates are from 2025-08-01 onwards (likely fallback)
  return data.every(item => 
    item.date && new Date(item.date) >= new Date('2025-08-01')
  );
};

/**
 * Validate backend chart data
 */
export const validateChartData = (data: any[]): boolean => {
  if (!Array.isArray(data)) return false;
  return data.every(item => 
    item && 
    typeof item === 'object' && 
    item.date && 
    !isNaN(new Date(item.date).getTime())
  );
};

/**
 * Extract user info from activity description
 */
export const extractUserFromActivity = (description: string, activityType: string): {
  name: string;
  email: string;
  status: string;
} => {
  if (!description) {
    return {
      name: 'Unknown User',
      email: 'unknown@example.com',
      status: 'ACTIVE'
    };
  }

  // Handle USER_REGISTRATION: "New user John Doe (johndoe) registered"
  if (activityType === 'USER_REGISTRATION') {
    const match = description.match(/New user (.+?) \((.+?)\) registered/);
    if (match) {
      const fullName = match[1];
      const username = match[2];
      return {
        name: fullName,
        email: `${username}@example.com`,
        status: 'ACTIVE'
      };
    }
    return {
      name: 'New User',
      email: 'newuser@example.com',
      status: 'ACTIVE'
    };
  }

  // Handle USER_STATUS_UPDATE
  if (activityType === 'USER_STATUS_UPDATE') {
    const status = description.includes('ACTIVE') ? 'ACTIVE' :
                  description.includes('SUSPEND') ? 'SUSPEND' :
                  description.includes('INACTIVE') ? 'INACTIVE' : 'ACTIVE';
    return {
      name: 'User Status Updated',
      email: 'status@example.com',
      status
    };
  }

  // Default for other activity types
  return {
    name: activityType.replace(/_/g, ' ').toLowerCase().replace(/\b\w/g, l => l.toUpperCase()),
    email: 'activity@example.com',
    status: 'ACTIVE'
  };
};
