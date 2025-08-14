

// Use dashboard layout for add-account page for full UI consistency
import DashboardLayout from "../dashboard/layout";

export default function AddAccountLayout({ children }: { children: React.ReactNode }) {
  return <DashboardLayout>{children}</DashboardLayout>;
}
