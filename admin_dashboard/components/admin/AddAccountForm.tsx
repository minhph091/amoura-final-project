"use client";
import { useState } from "react";

// This form matches backend UserDTO and registration requirements

import { authService } from "@/src/services/auth.service";
import { Button } from "@/components/ui/button";

export default function AddAccountForm() {
  // Defensive: Only allow ADMIN to render this form
  const user = typeof window !== "undefined" ? authService.getCurrentUser() : null;
  if (!user || user.roleName !== "ADMIN") return null;

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
      setSuccess("Account creation initiated. Check email for further steps.");
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
      setError(err.message || "Error");
    }
    setLoading(false);
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-6 p-0 animate-fade-in">
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div>
          <label className="block text-base font-semibold mb-1">Email</label>
          <input name="email" type="email" className="input input-bordered w-full h-11 px-3 text-base rounded-md" value={form.email} onChange={handleChange} required placeholder="Enter email" title="Email" />
        </div>
        <div>
          <label className="block text-base font-semibold mb-1">Username</label>
          <input name="username" className="input input-bordered w-full h-11 px-3 text-base rounded-md" value={form.username} onChange={handleChange} placeholder="Enter username" title="Username" />
        </div>
        <div>
          <label className="block text-base font-semibold mb-1">First Name</label>
          <input name="firstName" className="input input-bordered w-full h-11 px-3 text-base rounded-md" value={form.firstName} onChange={handleChange} placeholder="Enter first name" title="First Name" />
        </div>
        <div>
          <label className="block text-base font-semibold mb-1">Last Name</label>
          <input name="lastName" className="input input-bordered w-full h-11 px-3 text-base rounded-md" value={form.lastName} onChange={handleChange} placeholder="Enter last name" title="Last Name" />
        </div>
        <div>
          <label className="block text-base font-semibold mb-1">Phone Number</label>
          <input name="phoneNumber" className="input input-bordered w-full h-11 px-3 text-base rounded-md" value={form.phoneNumber} onChange={handleChange} placeholder="Enter phone number" title="Phone Number" />
        </div>
        <div>
          <label className="block text-base font-semibold mb-1">Role</label>
          <select name="roleName" className="select select-bordered w-full h-11 px-3 text-base rounded-md" value={form.roleName} onChange={handleChange} required title="Role">
            <option value="ADMIN">Admin</option>
            <option value="MODERATOR">Moderator</option>
          </select>
        </div>
        <div className="md:col-span-2">
          <label className="block text-base font-semibold mb-1">Temporary Password</label>
          <input name="password" type="text" className="input input-bordered w-full h-11 px-3 text-base rounded-md text-green-700 font-mono" value={form.password} onChange={handleChange} required placeholder="Temporary password" title="Temporary Password" />
          <span className="text-xs text-muted-foreground">Default: Amoura123@</span>
        </div>
      </div>
      <div className="flex justify-end mt-4">
        <Button
          type="submit"
          className="w-full text-lg py-3 rounded-lg"
          variant="success"
          disabled={loading}
        >
          {loading ? "Adding..." : "Add Account"}
        </Button>
      </div>
      {error && <div className="text-red-500 text-base font-semibold mt-2">{error}</div>}
      {success && <div className="text-green-600 text-base font-semibold mt-2">{success}</div>}
    </form>
  );
}
