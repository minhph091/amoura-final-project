"use client";
import { useState } from "react";

export default function AddAccountForm() {
  const [email, setEmail] = useState("");
  const [role, setRole] = useState("MODERATOR");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const handleSubmit = async (e: any) => {
    e.preventDefault();
    setLoading(true);
    setError("");
    try {
      const res = await fetch("/auth/register/initiate", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ email, role }),
      });
      if (!res.ok) throw new Error("Failed to initiate registration");
      setEmail("");
    } catch (err: any) {
      setError(err.message || "Error");
    }
    setLoading(false);
  };
  return (
    <form onSubmit={handleSubmit} className="space-y-2">
      <input type="email" placeholder="Email" className="input input-bordered w-full" value={email} onChange={e => setEmail(e.target.value)} required />
      <label htmlFor="role-select" className="block text-sm font-medium">Role</label>
      <select id="role-select" className="select select-bordered w-full" value={role} onChange={e => setRole(e.target.value)} title="Select role">
        <option value="ADMIN">Admin</option>
        <option value="MODERATOR">Moderator</option>
      </select>
      <button className="btn btn-primary w-full" disabled={loading}>
        {loading ? "Adding..." : "Add Account"}
      </button>
      {error && <div className="text-red-500">{error}</div>}
    </form>
  );
}
