import { AmouraLogo } from "@/components/ui/AmouraLogo";
import Link from "next/link";

export default function TermsOfService() {
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
              Terms of Service
            </h1>

            <div className="prose prose-lg max-w-none">
              <p className="text-gray-600 text-lg mb-8 text-center">
                Last updated: {new Date().toLocaleDateString()}
              </p>

              <section className="mb-10">
                <h2 className="font-heading text-2xl font-semibold text-gradient-rose mb-4">
                  1. Acceptance of Terms
                </h2>
                <p className="text-gray-700 leading-relaxed mb-4">
                  By accessing and using Amoura ("the App"), you accept and
                  agree to be bound by the terms and provision of this
                  agreement. These Terms of Service ("Terms") constitute a
                  legally binding agreement between you and Amoura regarding
                  your use of the App.
                </p>
                <p className="text-gray-700 leading-relaxed">
                  If you do not agree to these Terms, please do not use the App.
                  We reserve the right to modify these Terms at any time, and
                  such modifications will be effective immediately upon posting.
                </p>
              </section>

              <section className="mb-10">
                <h2 className="font-heading text-2xl font-semibold text-gradient-purple mb-4">
                  2. Description of Service
                </h2>
                <p className="text-gray-700 leading-relaxed mb-4">
                  Amoura is a dating and social networking application that
                  allows users to create profiles, connect with other users,
                  exchange messages, and engage in various social activities
                  within the platform.
                </p>
                <p className="text-gray-700 leading-relaxed">
                  The App provides features including but not limited to profile
                  creation, photo sharing, messaging, location-based matching,
                  and premium subscription services.
                </p>
              </section>

              <section className="mb-10">
                <h2 className="font-heading text-2xl font-semibold text-gradient-rose mb-4">
                  3. User Accounts and Registration
                </h2>
                <div className="text-gray-700 leading-relaxed space-y-4">
                  <p>
                    To use certain features of the App, you must create an
                    account. When creating an account, you agree to:
                  </p>
                  <ul className="list-disc pl-6 space-y-2">
                    <li>
                      Provide accurate, current, and complete information during
                      registration
                    </li>
                    <li>
                      Maintain and promptly update your account information
                    </li>
                    <li>
                      Maintain the security of your password and accept
                      responsibility for all activities under your account
                    </li>
                    <li>
                      Notify us immediately of any unauthorized use of your
                      account
                    </li>
                  </ul>
                  <p>
                    You are responsible for all activities that occur under your
                    account, whether or not you authorized such activities.
                  </p>
                </div>
              </section>

              <section className="mb-10">
                <h2 className="font-heading text-2xl font-semibold text-gray-900 mb-4">
                  4. User Conduct and Content
                </h2>
                <div className="text-gray-700 leading-relaxed space-y-4">
                  <p>You agree not to use the App to:</p>
                  <ul className="list-disc pl-6 space-y-2">
                    <li>
                      Upload, post, or transmit any content that is unlawful,
                      harmful, threatening, abusive, harassing, defamatory,
                      vulgar, obscene, or otherwise objectionable
                    </li>
                    <li>
                      Impersonate any person or entity or falsely state or
                      misrepresent your affiliation with a person or entity
                    </li>
                    <li>
                      Upload, post, or transmit any content that infringes any
                      patent, trademark, trade secret, copyright, or other
                      proprietary rights
                    </li>
                    <li>
                      Upload, post, or transmit any unsolicited or unauthorized
                      advertising, promotional materials, spam, or any other
                      form of solicitation
                    </li>
                    <li>
                      Interfere with or disrupt the App or servers or networks
                      connected to the App
                    </li>
                    <li>
                      Use any automated means to access the App or collect
                      information from the App
                    </li>
                  </ul>
                </div>
              </section>

              <section className="mb-10">
                <h2 className="font-heading text-2xl font-semibold text-gray-900 mb-4">
                  5. Privacy and Data Protection
                </h2>
                <p className="text-gray-700 leading-relaxed mb-4">
                  Your privacy is important to us. Our Privacy Policy explains
                  how we collect, use, and protect your information when you use
                  our App. By using the App, you consent to the collection and
                  use of your information as outlined in our Privacy Policy.
                </p>
                <p className="text-gray-700 leading-relaxed">
                  We implement appropriate security measures to protect your
                  personal information against unauthorized access, alteration,
                  disclosure, or destruction.
                </p>
              </section>

              <section className="mb-10">
                <h2 className="font-heading text-2xl font-semibold text-gray-900 mb-4">
                  6. Premium Services and Billing
                </h2>
                <div className="text-gray-700 leading-relaxed space-y-4">
                  <p>
                    Amoura offers premium subscription services with additional
                    features. By purchasing a premium subscription:
                  </p>
                  <ul className="list-disc pl-6 space-y-2">
                    <li>
                      You agree to pay all fees associated with your
                      subscription
                    </li>
                    <li>
                      Subscriptions automatically renew unless cancelled before
                      the renewal date
                    </li>
                    <li>
                      Refunds are subject to our refund policy and applicable
                      app store policies
                    </li>
                    <li>
                      We reserve the right to change subscription prices with
                      reasonable notice
                    </li>
                  </ul>
                </div>
              </section>

              <section className="mb-10">
                <h2 className="font-heading text-2xl font-semibold text-gray-900 mb-4">
                  7. Intellectual Property Rights
                </h2>
                <p className="text-gray-700 leading-relaxed mb-4">
                  The App and its original content, features, and functionality
                  are owned by Amoura and are protected by international
                  copyright, trademark, patent, trade secret, and other
                  intellectual property laws.
                </p>
                <p className="text-gray-700 leading-relaxed">
                  You retain ownership of content you submit to the App, but
                  grant us a worldwide, non-exclusive, royalty-free license to
                  use, reproduce, modify, and distribute such content in
                  connection with the App.
                </p>
              </section>

              <section className="mb-10">
                <h2 className="font-heading text-2xl font-semibold text-gray-900 mb-4">
                  8. Disclaimers and Limitation of Liability
                </h2>
                <div className="text-gray-700 leading-relaxed space-y-4">
                  <p>
                    THE APP IS PROVIDED "AS IS" WITHOUT WARRANTIES OF ANY KIND.
                    WE DISCLAIM ALL WARRANTIES, EXPRESS OR IMPLIED, INCLUDING
                    BUT NOT LIMITED TO:
                  </p>
                  <ul className="list-disc pl-6 space-y-2">
                    <li>
                      MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
                    </li>
                    <li>NON-INFRINGEMENT OF THIRD-PARTY RIGHTS</li>
                    <li>ACCURACY, COMPLETENESS, OR RELIABILITY OF CONTENT</li>
                  </ul>
                  <p>
                    IN NO EVENT SHALL AMOURA BE LIABLE FOR ANY INDIRECT,
                    INCIDENTAL, SPECIAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES.
                  </p>
                </div>
              </section>

              <section className="mb-10">
                <h2 className="font-heading text-2xl font-semibold text-gray-900 mb-4">
                  9. Termination
                </h2>
                <p className="text-gray-700 leading-relaxed mb-4">
                  We reserve the right to terminate or suspend your account and
                  access to the App at our sole discretion, without notice, for
                  conduct that we believe violates these Terms or is harmful to
                  other users, us, or third parties.
                </p>
                <p className="text-gray-700 leading-relaxed">
                  You may terminate your account at any time by following the
                  account deletion process in the App settings.
                </p>
              </section>

              <section className="mb-10">
                <h2 className="font-heading text-2xl font-semibold text-gray-900 mb-4">
                  10. Contact Information
                </h2>
                <p className="text-gray-700 leading-relaxed">
                  If you have any questions about these Terms of Service, please
                  contact us at:
                </p>
                <div className="bg-gray-50 rounded-lg p-6 mt-4">
                  <p className="text-gray-700 font-medium">
                    Amoura Support Team
                  </p>
                  <p className="text-gray-600">Email: legal@amoura.space</p>
                  <p className="text-gray-600">Website: https://amoura.space</p>
                </div>
              </section>
            </div>
          </div>
        </div>
      </main>
    </div>
  );
}
