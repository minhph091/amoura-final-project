
// Backend UserDTO structure (đúng với backend)
export interface User {
  id: number;
  username?: string;
  email: string;
  phoneNumber?: string;
  firstName?: string;
  lastName?: string;
  fullName?: string;
  roleName?: string;
  status: string;
  lastLogin?: string;
  createdAt: string;
  updatedAt?: string;
}
