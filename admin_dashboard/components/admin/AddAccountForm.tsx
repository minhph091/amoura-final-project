"use client";
import { useState } from "react";

// This form matches backend UserDTO and registration requirements

import { authService } from "@/src/services/auth.service";
import { Button } from "@/components/ui/button";
import { useLanguage } from "@/src/contexts/LanguageContext";

export default function AddAccountForm() {
  const { t } = useLanguage();
  const [form, setForm] = useState({
    email: "",
    username: "",
    firstName: "",
    lastName: "",
    phoneNumber: "",
    roleName: "MODERATOR",
    password: "Amoura123@",
  });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const [success, setSuccess] = useState("");

  // Defensive: Only allow ADMIN to render this form
  const user = typeof window !== "undefined" ? authService.getCurrentUser() : null;
  if (typeof window !== "undefined" && (!user || user.roleName !== "ADMIN")) {
    return (
      <div className="p-6 text-center">
        <p className="text-gray-500">Access denied. Admin privileges required.</p>
      </div>
    );
  }

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    setForm({ ...form, [e.target.name]: e.target.value });
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError("");
    setSuccess("");
    try {
      const res = await authService.registerInitiate(form);
      if (!res.success) throw new Error(res.error || "Failed to initiate registration");
      setSuccess(t.accountCreationInitiated);
      setForm({
        email: "",
        username: "",
        firstName: "",
        lastName: "",
        phoneNumber: "",
        roleName: "MODERATOR",
        password: "Amoura123@",
      });
    } catch (err: any) {
      setError(err.message || t.errorMessage);
    }
    setLoading(false);
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-6 p-0 animate-fade-in">
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div className="space-y-1">
          <label className="text-xs font-semibold text-green-600">{t.email}</label>
          <input 
            name="email" 
            type="email" 
            className="w-full h-11 px-3 text-sm rounded-lg border border-gray-200 focus:border-green-500 focus:ring-2 focus:ring-green-100 transition-all" 
            value={form.email} 
            onChange={handleChange} 
            required 
            placeholder={t.enterEmail} 
            title="Email" 
          />
        </div>
        <div className="space-y-1">
          <label className="text-xs font-semibold text-blue-600">{t.username}</label>
          <input 
            name="username" 
            className="w-full h-11 px-3 text-sm rounded-lg border border-gray-200 focus:border-blue-500 focus:ring-2 focus:ring-blue-100 transition-all" 
            value={form.username} 
            onChange={handleChange} 
            placeholder={t.enterUsername} 
            title="Username" 
          />
        </div>
        <div className="space-y-1">
          <label className="text-xs font-semibold text-indigo-600">{t.firstName}</label>
          <input 
            name="firstName" 
            className="w-full h-11 px-3 text-sm rounded-lg border border-gray-200 focus:border-indigo-500 focus:ring-2 focus:ring-indigo-100 transition-all" 
            value={form.firstName} 
            onChange={handleChange} 
            placeholder={t.enterFirstName} 
            title="First Name" 
          />
        </div>
        <div className="space-y-1">
          <label className="text-xs font-semibold text-teal-600">{t.lastName}</label>
          <input 
            name="lastName" 
            className="w-full h-11 px-3 text-sm rounded-lg border border-gray-200 focus:border-teal-500 focus:ring-2 focus:ring-teal-100 transition-all" 
            value={form.lastName} 
            onChange={handleChange} 
            placeholder={t.enterLastName} 
            title="Last Name" 
          />
        </div>
        <div className="space-y-1">
          <label className="text-xs font-semibold text-purple-600">{t.phoneNumber}</label>
          <input 
            name="phoneNumber" 
            className="w-full h-11 px-3 text-sm rounded-lg border border-gray-200 focus:border-purple-500 focus:ring-2 focus:ring-purple-100 transition-all" 
            value={form.phoneNumber} 
            onChange={handleChange} 
            placeholder={t.enterPhoneNumber} 
            title="Phone Number" 
          />
        </div>
        <div className="space-y-1">
          <label className="text-xs font-semibold text-orange-600">{t.role}</label>
          <select 
            name="roleName" 
            className="w-full h-11 px-3 text-sm rounded-lg border border-gray-200 focus:border-orange-500 focus:ring-2 focus:ring-orange-100 transition-all bg-white" 
            value={form.roleName} 
            onChange={handleChange} 
            required 
            title="Role"
          >
            <option value="ADMIN">{t.admin}</option>
            <option value="MODERATOR">{t.moderator}</option>
          </select>
        </div>
        <div className="md:col-span-2 space-y-1">
          <label className="text-xs font-semibold text-emerald-600">{t.temporaryPassword}</label>
          <input 
            name="password" 
            type="text" 
            className="w-full h-11 px-3 text-sm rounded-lg border border-gray-200 focus:border-emerald-500 focus:ring-2 focus:ring-emerald-100 transition-all text-emerald-700 font-mono bg-emerald-50" 
            value={form.password} 
            onChange={handleChange} 
            required 
            placeholder={t.temporaryPasswordPlaceholder} 
            title="Temporary Password" 
          />
          <span className="text-xs text-gray-500">{t.defaultPassword}</span>
        </div>
      </div>
      <div className="flex justify-end mt-6">
        <Button
          type="submit"
          className="w-full text-base py-3 rounded-lg bg-gradient-to-r from-pink-500 to-purple-600 hover:from-pink-600 hover:to-purple-700 text-white shadow-lg hover:shadow-xl transition-all duration-200"
          disabled={loading}
        >
          {loading ? t.adding : t.addAccount}
        </Button>
      </div>
      {error && (
        <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg text-sm font-medium">
          {error}
        </div>
      )}
      {success && (
        <div className="bg-green-50 border border-green-200 text-green-700 px-4 py-3 rounded-lg text-sm font-medium">
          {success}
        </div>
      )}
    </form>
  );
}
