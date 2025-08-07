import { AmouraLogo } from "@/components/ui/AmouraLogo";
import Link from "next/link";

export default function PrivacyPolicy() {
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

            <h1 className="font-heading text-4xl lg:text-6xl font-bold text-gradient-rose mb-8 text-center">
              Privacy Policy
            </h1>

            <div className="prose prose-lg max-w-none">
              <p className="text-gray-600 text-lg mb-8 text-center">
                Last updated: {new Date().toLocaleDateString()}
              </p>

              <section className="mb-10">
                <h2 className="font-heading text-2xl font-semibold text-gray-900 mb-4">
                  1. Introduction
                </h2>
                <p className="text-gray-700 leading-relaxed mb-4">
                  Welcome to Amoura ("we," "our," or "us"). We are committed to
                  protecting your privacy and ensuring the security of your
                  personal information. This Privacy Policy explains how we
                  collect, use, disclose, and safeguard your information when
                  you use our dating application.
                </p>
                <p className="text-gray-700 leading-relaxed">
                  By using Amoura, you agree to the collection and use of
                  information in accordance with this policy. If you do not
                  agree with our policies and practices, do not download,
                  register with, or use this application.
                </p>
              </section>

              <section className="mb-10">
                <h2 className="font-heading text-2xl font-semibold text-gradient-purple mb-4">
                  2. Information We Collect
                </h2>
                <div className="text-gray-700 leading-relaxed space-y-4">
                  <h3 className="font-heading text-xl font-medium text-gradient-rose">
                    Personal Information
                  </h3>
                  <p>
                    We collect information that you provide directly to us, such
                    as:
                  </p>
                  <ul className="list-disc pl-6 space-y-2">
                    <li>Name, age, gender, and sexual orientation</li>
                    <li>Email address and phone number</li>
                    <li>Profile photos and other images</li>
                    <li>Bio and personal descriptions</li>
                    <li>Preferences and interests</li>
                    <li>Messages and communications with other users</li>
                  </ul>

                  <h3 className="font-heading text-xl font-medium text-gray-800 mt-6">
                    Location Information
                  </h3>
                  <p>
                    We collect and process information about your location to
                    provide location-based features:
                  </p>
                  <ul className="list-disc pl-6 space-y-2">
                    <li>Precise geolocation data (with your consent)</li>
                    <li>
                      General location information derived from IP address
                    </li>
                    <li>Location preferences for matching</li>
                  </ul>

                  <h3 className="font-heading text-xl font-medium text-gray-800 mt-6">
                    Technical Information
                  </h3>
                  <p>We automatically collect certain technical information:</p>
                  <ul className="list-disc pl-6 space-y-2">
                    <li>
                      Device information (model, operating system, unique
                      identifiers)
                    </li>
                    <li>App usage data and interaction patterns</li>
                    <li>Log files and crash reports</li>
                    <li>Cookies and similar tracking technologies</li>
                  </ul>
                </div>
              </section>

              <section className="mb-10">
                <h2 className="font-heading text-2xl font-semibold text-gray-900 mb-4">
                  3. How We Use Your Information
                </h2>
                <div className="text-gray-700 leading-relaxed space-y-4">
                  <p>We use the information we collect to:</p>
                  <ul className="list-disc pl-6 space-y-2">
                    <li>Provide, maintain, and improve our services</li>
                    <li>Create and manage your user account</li>
                    <li>Facilitate connections and matches with other users</li>
                    <li>Enable messaging and communication features</li>
                    <li>
                      Personalize your experience and show relevant content
                    </li>
                    <li>Process payments for premium services</li>
                    <li>Send notifications and important updates</li>
                    <li>Ensure safety and prevent fraudulent activity</li>
                    <li>Comply with legal obligations and enforce our terms</li>
                    <li>
                      Conduct research and analytics to improve our services
                    </li>
                  </ul>
                </div>
              </section>

              <section className="mb-10">
                <h2 className="font-heading text-2xl font-semibold text-gray-900 mb-4">
                  4. Information Sharing and Disclosure
                </h2>
                <div className="text-gray-700 leading-relaxed space-y-4">
                  <h3 className="font-heading text-xl font-medium text-gray-800">
                    With Other Users
                  </h3>
                  <p>
                    Your profile information, photos, and activity may be
                    visible to other users of the app as part of the core
                    functionality.
                  </p>

                  <h3 className="font-heading text-xl font-medium text-gray-800 mt-6">
                    With Service Providers
                  </h3>
                  <p>
                    We may share your information with trusted third-party
                    service providers who assist us in operating the app, such
                    as:
                  </p>
                  <ul className="list-disc pl-6 space-y-2">
                    <li>Cloud storage and hosting services</li>
                    <li>Payment processing companies</li>
                    <li>Analytics and marketing platforms</li>
                    <li>Customer support tools</li>
                  </ul>

                  <h3 className="font-heading text-xl font-medium text-gray-800 mt-6">
                    Legal Requirements
                  </h3>
                  <p>
                    We may disclose your information if required by law or in
                    response to:
                  </p>
                  <ul className="list-disc pl-6 space-y-2">
                    <li>Court orders or legal process</li>
                    <li>Government or regulatory requests</li>
                    <li>Protection of our rights and safety</li>
                    <li>Prevention of fraud or illegal activities</li>
                  </ul>
                </div>
              </section>

              <section className="mb-10">
                <h2 className="font-heading text-2xl font-semibold text-gray-900 mb-4">
                  5. Data Security
                </h2>
                <p className="text-gray-700 leading-relaxed mb-4">
                  We implement appropriate technical and organizational security
                  measures to protect your personal information against
                  unauthorized access, alteration, disclosure, or destruction.
                  These measures include:
                </p>
                <ul className="list-disc pl-6 space-y-2 text-gray-700">
                  <li>Encryption of data in transit and at rest</li>
                  <li>Regular security assessments and updates</li>
                  <li>
                    Limited access to personal information on a need-to-know
                    basis
                  </li>
                  <li>Secure data centers and infrastructure</li>
                </ul>
                <p className="text-gray-700 leading-relaxed mt-4">
                  However, no method of transmission over the internet or
                  electronic storage is 100% secure. While we strive to protect
                  your information, we cannot guarantee absolute security.
                </p>
              </section>

              <section className="mb-10">
                <h2 className="font-heading text-2xl font-semibold text-gray-900 mb-4">
                  6. Your Rights and Choices
                </h2>
                <div className="text-gray-700 leading-relaxed space-y-4">
                  <p>
                    You have several rights regarding your personal information:
                  </p>
                  <ul className="list-disc pl-6 space-y-2">
                    <li>
                      <strong>Access:</strong> Request a copy of the personal
                      information we hold about you
                    </li>
                    <li>
                      <strong>Rectification:</strong> Request correction of
                      inaccurate or incomplete information
                    </li>
                    <li>
                      <strong>Erasure:</strong> Request deletion of your
                      personal information
                    </li>
                    <li>
                      <strong>Portability:</strong> Request transfer of your
                      data to another service
                    </li>
                    <li>
                      <strong>Restriction:</strong> Request limitation of
                      processing of your information
                    </li>
                    <li>
                      <strong>Objection:</strong> Object to certain processing
                      of your information
                    </li>
                  </ul>
                  <p>
                    To exercise these rights, please contact us using the
                    information provided at the end of this policy.
                  </p>
                </div>
              </section>

              <section className="mb-10">
                <h2 className="font-heading text-2xl font-semibold text-gray-900 mb-4">
                  7. Contact Us
                </h2>
                <p className="text-gray-700 leading-relaxed mb-4">
                  If you have any questions, concerns, or requests regarding
                  this Privacy Policy or our data practices, please contact us:
                </p>
                <div className="bg-gray-50 rounded-lg p-6">
                  <p className="text-gray-700 font-medium">
                    Amoura Privacy Team
                  </p>
                  <p className="text-gray-600">Email: privacy@amoura.space</p>
                  <p className="text-gray-600">Website: https://amoura.space</p>
                </div>
                <p className="text-gray-700 leading-relaxed mt-4">
                  We will respond to your inquiries within a reasonable
                  timeframe and work to resolve any privacy concerns you may
                  have.
                </p>
              </section>
            </div>
          </div>
        </div>
      </main>
    </div>
  );
}
