import { AmouraLogo } from "@/components/ui/AmouraLogo";
import Link from "next/link";

export default function HelpPage() {
  return (
    <div className="min-h-screen bg-gradient-elegant flex flex-col relative overflow-hidden">
      {/* Animated background elements */}
      <div className="absolute inset-0 bg-grid-pattern opacity-5"></div>
      <div className="absolute top-10 left-10 w-72 h-72 bg-gradient-to-r from-pink-400/20 to-purple-600/20 rounded-full blur-3xl animate-pulse-slow"></div>
      <div className="absolute bottom-10 right-10 w-96 h-96 bg-gradient-to-r from-rose-400/20 to-pink-600/20 rounded-full blur-3xl animate-pulse-slow"></div>

      {/* Header */}
      <header className="flex items-center justify-between p-6 lg:p-8 relative z-10">
        <Link href="/" className="transition-transform hover:scale-105">
          <AmouraLogo size="default" />
        </Link>
        <Link
          href="/"
          className="px-6 py-3 text-sm font-medium text-gray-700 hover:text-gray-900 bg-white/80 backdrop-blur-sm rounded-full shadow-lg transition-all hover:shadow-xl hover:scale-105"
        >
          Back to Home
        </Link>
      </header>

      {/* Main Content */}
      <main className="flex-1 container mx-auto px-6 lg:px-8 py-12 relative z-10">
        <div className="max-w-4xl mx-auto">
          <div className="bg-white/90 backdrop-blur-lg rounded-3xl shadow-2xl border border-white/30 p-8 lg:p-12 relative overflow-hidden">
            {/* Decorative gradient overlay */}
            <div className="absolute top-0 left-0 right-0 h-1 bg-gradient-to-r from-pink-500 via-purple-500 to-rose-500"></div>

            <h1 className="font-heading text-4xl lg:text-6xl font-bold text-gradient-primary mb-8 text-center">
              Help Center
            </h1>

            <div className="prose prose-lg max-w-none">
              <p className="text-gray-600 text-lg mb-8 text-center">
                Last updated: {new Date().toLocaleDateString()}
              </p>

              <section className="mb-10">
                <h2 className="font-heading text-2xl font-semibold text-gradient-rose mb-4">
                  Getting Started
                </h2>
                <div className="text-gray-700 leading-relaxed space-y-4">
                  <h3 className="font-heading text-xl font-medium text-gray-800">
                    Admin Dashboard Overview
                  </h3>
                  <p>
                    The Amoura Admin Dashboard provides you with comprehensive
                    tools to manage your dating platform. From user management
                    to content moderation, you have full control over your
                    platform's operations.
                  </p>
                  <ul className="list-disc pl-6 space-y-2">
                    <li>View real-time statistics and analytics</li>
                    <li>Manage user accounts and profiles</li>
                    <li>Handle reports and content moderation</li>
                    <li>Monitor matches and messaging activities</li>
                    <li>Manage subscription and billing</li>
                  </ul>
                </div>
              </section>

              <section className="mb-10">
                <h2 className="font-heading text-2xl font-semibold text-gradient-purple mb-4">
                  User Management
                </h2>
                <div className="text-gray-700 leading-relaxed space-y-4">
                  <h3 className="font-heading text-xl font-medium text-gray-800">
                    Managing User Accounts
                  </h3>
                  <p>
                    Learn how to effectively manage user accounts on your platform:
                  </p>
                  <ul className="list-disc pl-6 space-y-2">
                    <li>
                      <strong>View User Details:</strong> Access comprehensive
                      user profiles including personal information, photos, and
                      activity history
                    </li>
                    <li>
                      <strong>Account Status:</strong> Update user account
                      status (Active, Inactive, Suspended) based on your
                      platform policies
                    </li>
                    <li>
                      <strong>Search and Filter:</strong> Use advanced search
                      and filtering options to find specific users quickly
                    </li>
                    <li>
                      <strong>Bulk Actions:</strong> Perform actions on multiple
                      users simultaneously for efficient management
                    </li>
                  </ul>

                  <h3 className="font-heading text-xl font-medium text-gray-800 mt-6">
                    Adding New Accounts
                  </h3>
                  <p>
                    To create new user accounts or admin accounts:
                  </p>
                  <ol className="list-decimal pl-6 space-y-2">
                    <li>Navigate to "Add Account" in the sidebar</li>
                    <li>Fill in the required information (name, email, role)</li>
                    <li>Set appropriate permissions and access levels</li>
                    <li>Send invitation or create account directly</li>
                  </ol>
                </div>
              </section>

              <section className="mb-10">
                <h2 className="font-heading text-2xl font-semibold text-gray-900 mb-4">
                  Content Moderation
                </h2>
                <div className="text-gray-700 leading-relaxed space-y-4">
                  <h3 className="font-heading text-xl font-medium text-gray-800">
                    Handling Reports
                  </h3>
                  <p>
                    When users report inappropriate content or behavior:
                  </p>
                  <ul className="list-disc pl-6 space-y-2">
                    <li>
                      Review reported content in the Reports section
                    </li>
                    <li>
                      Investigate the context and severity of the issue
                    </li>
                    <li>
                      Take appropriate action (warning, suspension, ban)
                    </li>
                    <li>
                      Communicate decisions to involved parties
                    </li>
                    <li>
                      Document actions for future reference
                    </li>
                  </ul>

                  <h3 className="font-heading text-xl font-medium text-gray-800 mt-6">
                    Content Guidelines
                  </h3>
                  <p>
                    Ensure your platform maintains high content standards:
                  </p>
                  <ul className="list-disc pl-6 space-y-2">
                    <li>Review profile photos for appropriateness</li>
                    <li>Monitor messaging for harassment or spam</li>
                    <li>Check for fake profiles and catfishing</li>
                    <li>Enforce community guidelines consistently</li>
                  </ul>
                </div>
              </section>

              <section className="mb-10">
                <h2 className="font-heading text-2xl font-semibold text-gray-900 mb-4">
                  Analytics and Insights
                </h2>
                <div className="text-gray-700 leading-relaxed space-y-4">
                  <h3 className="font-heading text-xl font-medium text-gray-800">
                    Understanding Your Data
                  </h3>
                  <p>
                    The dashboard provides valuable insights into your platform's
                    performance:
                  </p>
                  <ul className="list-disc pl-6 space-y-2">
                    <li>
                      <strong>User Growth:</strong> Track new registrations and
                      user retention rates
                    </li>
                    <li>
                      <strong>Matching Success:</strong> Monitor match rates and
                      compatibility scores
                    </li>
                    <li>
                      <strong>Activity Metrics:</strong> View messaging frequency
                      and user engagement
                    </li>
                    <li>
                      <strong>Revenue Tracking:</strong> Monitor subscription
                      revenue and premium features usage
                    </li>
                  </ul>

                  <h3 className="font-heading text-xl font-medium text-gray-800 mt-6">
                    Using Analytics for Growth
                  </h3>
                  <p>
                    Leverage data insights to improve your platform:
                  </p>
                  <ul className="list-disc pl-6 space-y-2">
                    <li>Identify peak usage times for better resource allocation</li>
                    <li>Analyze user behavior patterns to enhance features</li>
                    <li>Track conversion rates from free to premium users</li>
                    <li>Monitor churn rates and implement retention strategies</li>
                  </ul>
                </div>
              </section>

              <section className="mb-10">
                <h2 className="font-heading text-2xl font-semibold text-gray-900 mb-4">
                  Security and Privacy
                </h2>
                <div className="text-gray-700 leading-relaxed space-y-4">
                  <h3 className="font-heading text-xl font-medium text-gray-800">
                    Protecting User Data
                  </h3>
                  <p>
                    Best practices for maintaining user privacy and security:
                  </p>
                  <ul className="list-disc pl-6 space-y-2">
                    <li>Regularly update passwords and enable 2FA</li>
                    <li>Limit admin access to essential personnel only</li>
                    <li>Monitor for suspicious login activities</li>
                    <li>Ensure compliance with data protection regulations</li>
                    <li>Regularly backup user data and system configurations</li>
                  </ul>

                  <h3 className="font-heading text-xl font-medium text-gray-800 mt-6">
                    Admin Account Security
                  </h3>
                  <p>
                    Keep your admin account secure:
                  </p>
                  <ul className="list-disc pl-6 space-y-2">
                    <li>Use strong, unique passwords</li>
                    <li>Enable two-factor authentication</li>
                    <li>Log out when not actively using the dashboard</li>
                    <li>Don't share admin credentials</li>
                    <li>Report any suspicious activities immediately</li>
                  </ul>
                </div>
              </section>

              <section className="mb-10">
                <h2 className="font-heading text-2xl font-semibold text-gray-900 mb-4">
                  Troubleshooting
                </h2>
                <div className="text-gray-700 leading-relaxed space-y-4">
                  <h3 className="font-heading text-xl font-medium text-gray-800">
                    Common Issues
                  </h3>
                  <div className="space-y-4">
                    <div>
                      <p className="font-medium">Dashboard not loading properly</p>
                      <ul className="list-disc pl-6 space-y-1 text-sm">
                        <li>Clear your browser cache and cookies</li>
                        <li>Try using a different browser or incognito mode</li>
                        <li>Check your internet connection</li>
                        <li>Contact support if the issue persists</li>
                      </ul>
                    </div>
                    <div>
                      <p className="font-medium">Cannot access certain features</p>
                      <ul className="list-disc pl-6 space-y-1 text-sm">
                        <li>Verify your admin permissions</li>
                        <li>Check if your account is properly activated</li>
                        <li>Contact your system administrator</li>
                      </ul>
                    </div>
                    <div>
                      <p className="font-medium">Data not updating in real-time</p>
                      <ul className="list-disc pl-6 space-y-1 text-sm">
                        <li>Refresh the page manually</li>
                        <li>Check system status for any ongoing issues</li>
                        <li>Report persistent data sync issues to support</li>
                      </ul>
                    </div>
                  </div>
                </div>
              </section>

              <section className="mb-10">
                <h2 className="font-heading text-2xl font-semibold text-gray-900 mb-4">
                  Contact Support
                </h2>
                <div className="text-gray-700 leading-relaxed space-y-4">
                  <p>
                    Need additional help? Our support team is here to assist you:
                  </p>
                  <div className="bg-gray-50 rounded-lg p-6 space-y-4">
                    <div>
                      <p className="font-medium text-gray-800">Email Support</p>
                      <p className="text-gray-600">
                        <a href="mailto:admin-support@amoura.space" className="text-pink-600 underline">
                          admin-support@amoura.space
                        </a>
                      </p>
                      <p className="text-sm text-gray-500">Response time: 24-48 hours</p>
                    </div>
                    <div>
                      <p className="font-medium text-gray-800">Emergency Support</p>
                      <p className="text-gray-600">
                        <a href="mailto:urgent@amoura.space" className="text-red-600 underline">
                          urgent@amoura.space
                        </a>
                      </p>
                      <p className="text-sm text-gray-500">For security issues or critical bugs</p>
                    </div>
                    <div>
                      <p className="font-medium text-gray-800">Documentation</p>
                      <p className="text-gray-600">
                        <a href="https://docs.amoura.space" className="text-blue-600 underline">
                          docs.amoura.space
                        </a>
                      </p>
                      <p className="text-sm text-gray-500">Comprehensive API and admin guides</p>
                    </div>
                  </div>
                  <p className="text-sm text-gray-600">
                    When contacting support, please include your admin email,
                    a detailed description of the issue, and any relevant
                    screenshots or error messages.
                  </p>
                </div>
              </section>
            </div>
          </div>
        </div>
      </main>
    </div>
  );
}
