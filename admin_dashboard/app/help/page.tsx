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
                  How can we help you?
                </h2>
                <p className="text-gray-700 leading-relaxed mb-4">
                  Welcome to the Amoura Help Center. Here you can find answers to frequently asked questions, guides, and support resources for using the admin dashboard and managing your platform.
                </p>
                <ul className="list-disc pl-6 space-y-2">
                  <li>Getting started with the admin dashboard</li>
                  <li>Managing users and moderators</li>
                  <li>Handling reports and content moderation</li>
                  <li>Subscription and billing support</li>
                  <li>Security and privacy best practices</li>
                  <li>Contacting Amoura support</li>
                </ul>
                <p className="text-gray-700 leading-relaxed mt-4">
                  For further assistance, please contact us at <a href="mailto:support@amoura.space" className="text-pink-600 underline">support@amoura.space</a>.
                </p>
              </section>
            </div>
          </div>
        </div>
      </main>
    </div>
  );
}
