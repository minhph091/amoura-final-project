"use client";

import { useState, useEffect } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { toast } from "@/hooks/use-toast";
import { authService } from "@/src/services/auth.service";
import { useLanguage } from "@/src/contexts/LanguageContext";
import type { User } from "@/src/types/user.types";
import { API_ENDPOINTS } from "@/src/constants/api.constants";
import { apiClient } from "@/src/services/api.service";

export function AdminProfile() {
  const { t } = useLanguage();
  const [user, setUser] = useState<User | null>(null);
  const [edit, setEdit] = useState(false);
  // Only allow editing fields present in UpdateUserRequest
  const [form, setForm] = useState({
    username: "",
    firstName: "",
    lastName: "",
    phoneNumber: ""
  });
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    const u = authService.getCurrentUser();
    setUser(u);
    if (u) {
      setForm({
        username: u.username || "",
        firstName: u.firstName || "",
        lastName: u.lastName || "",
        phoneNumber: u.phoneNumber || ""
      });
    }
  }, []);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setForm({ ...form, [e.target.name]: e.target.value });
  };

  const handleSave = async () => {
    setLoading(true);
    try {
      // Check if user is authenticated
      const currentUser = authService.getCurrentUser();
      const token = localStorage.getItem("auth_token");
      
      if (!currentUser || !token) {
        toast({ title: t.errorTitle, description: "Authentication required. Please login again." });
        return;
      }

      // Validate token before proceeding
      const currentToken = localStorage.getItem("auth_token");
      if (!currentToken) {
        toast({ title: t.errorTitle, description: "Session expired. Please login again." });
        return;
      }

      // Refresh the token in apiClient
      apiClient.setToken(currentToken);

      // Validate form data before sending
      const updatePayload: any = {};

      // Only include fields that have actually changed
      if (form.username?.trim() !== user?.username) {
        updatePayload.username = form.username?.trim();
      }
      
      if (form.firstName?.trim() !== user?.firstName) {
        updatePayload.firstName = form.firstName?.trim();
      }
      
      if (form.lastName?.trim() !== user?.lastName) {
        updatePayload.lastName = form.lastName?.trim();
      }
      
      if (form.phoneNumber?.trim() !== user?.phoneNumber) {
        updatePayload.phoneNumber = form.phoneNumber?.trim();
      }

      // Check if there are any changes
      if (Object.keys(updatePayload).length === 0) {
        toast({ title: t.success, description: "No changes detected." });
        setEdit(false);
        setLoading(false);
        return;
      }

      // Basic validation for changed fields only
      if (updatePayload.username && updatePayload.username.length < 3) {
        toast({ title: t.errorTitle, description: "Username must be at least 3 characters" });
        setLoading(false);
        return;
      }

      if (updatePayload.firstName && updatePayload.firstName.length < 2) {
        toast({ title: t.errorTitle, description: "First name must be at least 2 characters" });
        setLoading(false);
        return;
      }

      if (updatePayload.lastName && updatePayload.lastName.length < 2) {
        toast({ title: t.errorTitle, description: "Last name must be at least 2 characters" });
        setLoading(false);
        return;
      }

      // Phone number validation
      if (updatePayload.phoneNumber && !/^\+?[0-9]{10,15}$/.test(updatePayload.phoneNumber)) {
        toast({ title: t.errorTitle, description: "Invalid phone number format" });
        setLoading(false);
        return;
      }
      
      // Try custom API route first
      let res;
      try {
        const customResponse = await fetch("/api/user-update", {
          method: "PATCH",
          headers: {
            "Authorization": `Bearer ${currentToken}`,
            "Content-Type": "application/json",
          },
          body: JSON.stringify(updatePayload)
        });

        if (customResponse.ok) {
          const data = await customResponse.json();
          res = { success: true, data };
        } else {
          const errorData = await customResponse.json();
          
          // Handle specific error codes
          let errorMessage = errorData.message || `HTTP Error: ${customResponse.status}`;
          if (errorData.errorCode === "USERNAME_EXISTS") {
            errorMessage = "Username already exists. Please choose a different username.";
          } else if (errorData.errorCode === "PHONE_EXISTS") {
            errorMessage = "Phone number already exists. Please use a different phone number.";
          }
          
          res = { success: false, error: errorMessage };
        }
      } catch (customError) {
        // Fallback to standard proxy
        res = await apiClient.patch("/user", updatePayload);
      }
      
      if (res.success) {
        toast({ title: t.success, description: t.accountUpdatedSuccessfully });
        
        // Merge updated data with existing user data
        const updatedUserData = { ...user, ...updatePayload };
        
        // If backend returns updated user data, use that instead
        if (res.data) {
          Object.assign(updatedUserData, res.data);
        }
        
        setUser(updatedUserData as User);
        setEdit(false);
        
        // Update localStorage with new user data
        localStorage.setItem("user_data", JSON.stringify(updatedUserData));
      } else {
        
        // Handle specific error messages
        let errorMessage = res.error || t.failed;
        if (res.error?.includes("USERNAME_EXISTS")) {
          errorMessage = "Username already exists. Please choose a different username.";
        } else if (res.error?.includes("PHONE_EXISTS")) {
          errorMessage = "Phone number already exists. Please use a different phone number.";
        } else if (res.error?.includes("403")) {
          errorMessage = "Access denied. Please check your permissions or try logging in again.";
        } else if (res.error?.includes("CORS")) {
          errorMessage = "Connection issue. Please try again or contact support.";
        }
        
        toast({ title: t.errorTitle, description: errorMessage });
      }
    } catch (err) {
      let errorMessage: string = t.failed;
      if (err instanceof Error) {
        if (err.message.includes('fetch')) {
          errorMessage = "Network connection failed. Please check your internet connection.";
        } else {
          errorMessage = err.message;
        }
      }
      toast({ title: t.errorTitle, description: errorMessage });
    }
    setLoading(false);
  };

  if (!user) return <div>Loading...</div>;

  return (
    <div className="space-y-6">
      <Card className="bg-gradient-to-br from-white to-gray-50 border-0 shadow-lg">
        <CardHeader className="flex flex-row items-center justify-between bg-gradient-to-r from-pink-50 to-blue-50 rounded-t-lg">
          <Badge className="bg-gradient-to-r from-pink-500 to-blue-500 text-white text-sm px-3 py-1">
            {user.roleName}
          </Badge>
        </CardHeader>
        <CardContent>
          <form className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <Label>{t.email}</Label>
              <Input value={user.email || ""} readOnly disabled />
            </div>
            <div>
              <Label>{t.username}</Label>
              <Input name="username" value={form.username} onChange={handleChange} readOnly={!edit} />
            </div>
            <div>
              <Label>{t.firstName}</Label>
              <Input name="firstName" value={form.firstName} onChange={handleChange} readOnly={!edit} />
            </div>
            <div>
              <Label>{t.lastName}</Label>
              <Input name="lastName" value={form.lastName} onChange={handleChange} readOnly={!edit} />
            </div>
            <div>
              <Label>{t.phoneNumber}</Label>
              <Input name="phoneNumber" value={form.phoneNumber} onChange={handleChange} readOnly={!edit} />
            </div>
            <div>
              <Label>{t.status}</Label>
              <Input value={user.status || ""} readOnly disabled />
            </div>
            <div>
              <Label>{t.role}</Label>
              <Input value={user.roleName || ""} readOnly disabled />
            </div>
            <div>
              <Label>{t.lastLogin}</Label>
              <Input value={user.lastLogin || ""} readOnly disabled />
            </div>
            <div>
              <Label>{t.createdAt}</Label>
              <Input value={user.createdAt || ""} readOnly disabled />
            </div>
            <div>
              <Label>{t.updatedAt}</Label>
              <Input value={user.updatedAt || ""} readOnly disabled />
            </div>
          </form>
          <div className="flex gap-2 mt-6">
            {!edit ? (
              <>
                <Button onClick={() => setEdit(true)} type="button" variant="edit">{t.edit}</Button>
              </>
            ) : (
              <>
                <Button onClick={handleSave} type="button" disabled={loading} variant="save">{t.save}</Button>
                <Button onClick={() => {
                  setEdit(false);
                  if (user) {
                    setForm({
                      username: user.username || "",
                      firstName: user.firstName || "",
                      lastName: user.lastName || "",
                      phoneNumber: user.phoneNumber || ""
                    });
                  }
                }} type="button" variant="cancel">{t.cancel}</Button>
              </>
            )}
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
