"use client";

import React, { useState } from "react";
import { ChevronDown, HelpCircle } from "lucide-react";

interface FAQSectionProps {
  language: string;
}

export function FAQSection({ language }: FAQSectionProps) {
  const [openIndex, setOpenIndex] = useState<number | null>(null);

  const faqs =
    language === "vi"
      ? [
          {
            question: "Amoura có miễn phí không?",
            answer:
              "Amoura có bản miễn phí với các tính năng cơ bản như xem hồ sơ, gửi like và chat cơ bản. Chúng tôi cũng có gói Premium với nhiều tính năng nâng cao như Super Like, Boost, và xem ai đã like bạn.",
          },
          {
            question: "Làm thế nào để xác thực hồ sơ?",
            answer:
              "Để xác thực hồ sơ, bạn cần cung cấp số điện thoại, email và ảnh chân dung rõ nét. Chúng tôi sử dụng AI để kiểm tra tính xác thực của ảnh và thông tin cá nhân.",
          },
          {
            question: "Tôi có thể thay đổi vị trí tìm kiếm không?",
            answer:
              "Có, bạn có thể thay đổi bán kính tìm kiếm từ 5km đến 100km. Với gói Premium, bạn có thể tìm kiếm ở bất kỳ thành phố nào trên thế giới.",
          },
          {
            question: "Dữ liệu cá nhân của tôi có được bảo mật không?",
            answer:
              "Chúng tôi cam kết bảo vệ thông tin cá nhân của bạn với mã hóa end-to-end và không bao giờ chia sẻ dữ liệu với bên thứ ba. Bạn có thể xóa tài khoản bất cứ lúc nào.",
          },
          {
            question: "Tôi có thể báo cáo hành vi không phù hợp không?",
            answer:
              "Có, chúng tôi có hệ thống báo cáo và chặn người dùng. Đội ngũ kiểm duyệt sẽ xử lý các báo cáo trong vòng 24 giờ.",
          },
          {
            question: "Thuật toán ghép đôi hoạt động như thế nào?",
            answer:
              "AI của chúng tôi phân tích sở thích, tính cách, và hành vi để gợi ý những người phù hợp nhất. Càng sử dụng nhiều, thuật toán càng hiểu bạn hơn.",
          },
        ]
      : [
          {
            question: "Is Amoura free to use?",
            answer:
              "Amoura has a free version with basic features like viewing profiles, sending likes, and basic chat. We also offer Premium subscription with advanced features like Super Likes, Boosts, and seeing who liked you.",
          },
          {
            question: "How do I verify my profile?",
            answer:
              "To verify your profile, you need to provide your phone number, email, and clear portrait photos. We use AI to check the authenticity of photos and personal information.",
          },
          {
            question: "Can I change my search location?",
            answer:
              "Yes, you can change your search radius from 5km to 100km. With Premium subscription, you can search in any city worldwide.",
          },
          {
            question: "Is my personal data secure?",
            answer:
              "We are committed to protecting your personal information with end-to-end encryption and never share data with third parties. You can delete your account at any time.",
          },
          {
            question: "Can I report inappropriate behavior?",
            answer:
              "Yes, we have reporting and blocking systems. Our moderation team handles reports within 24 hours.",
          },
          {
            question: "How does the matching algorithm work?",
            answer:
              "Our AI analyzes interests, personality, and behavior to suggest the most compatible matches. The more you use it, the better the algorithm understands you.",
          },
        ];

  const toggleFAQ = (index: number) => {
    setOpenIndex(openIndex === index ? null : index);
  };

  return (
    <section className="py-16 relative overflow-hidden">
      {/* Background */}
      <div className="absolute inset-0 bg-gradient-to-b from-white via-slate-50/50 to-white dark:from-slate-900 dark:via-slate-800/50 dark:to-slate-900"></div>

      {/* Decorative elements */}
      <div className="absolute top-20 right-20 w-32 h-32 bg-gradient-to-r from-pink-200/30 to-purple-200/30 rounded-full blur-3xl"></div>
      <div className="absolute bottom-20 left-20 w-40 h-40 bg-gradient-to-r from-purple-200/30 to-rose-200/30 rounded-full blur-3xl"></div>

      <div className="container mx-auto px-6 relative z-10">
        <div className="text-center mb-16">
          <div className="inline-flex items-center gap-2 bg-gradient-to-r from-pink-100 to-purple-100 dark:from-pink-900/20 dark:to-purple-900/20 text-pink-600 dark:text-pink-400 px-4 py-2 rounded-full text-sm font-semibold mb-4">
            <HelpCircle className="w-4 h-4" />
            {language === "vi"
              ? "Câu hỏi thường gặp"
              : "Frequently Asked Questions"}
          </div>
          <h2 className="text-4xl lg:text-5xl font-bold bg-gradient-to-r from-slate-800 to-slate-600 dark:from-slate-100 dark:to-slate-300 bg-clip-text text-transparent mb-6">
            {language === "vi" ? "Có thắc mắc gì không?" : "Have Questions?"}
          </h2>
          <p className="text-lg text-slate-600 dark:text-slate-300 max-w-3xl mx-auto leading-relaxed">
            {language === "vi"
              ? "Tìm câu trả lời cho những câu hỏi phổ biến nhất về Amoura"
              : "Find answers to the most common questions about Amoura"}
          </p>
        </div>

        <div className="max-w-4xl mx-auto">
          <div className="space-y-4">
            {faqs.map((faq, index) => (
              <div
                key={index}
                className="bg-white/80 dark:bg-slate-800/80 backdrop-blur-sm rounded-2xl border border-slate-200/50 dark:border-slate-700/50 overflow-hidden transition-all duration-300 hover:shadow-lg"
              >
                <button
                  onClick={() => toggleFAQ(index)}
                  className="w-full px-8 py-6 text-left flex items-center justify-between hover:bg-slate-50/50 dark:hover:bg-slate-700/50 transition-colors"
                >
                  <h3 className="text-lg font-semibold text-slate-800 dark:text-slate-100 pr-4">
                    {faq.question}
                  </h3>
                  <ChevronDown
                    className={`w-5 h-5 text-slate-500 dark:text-slate-400 transition-transform duration-300 flex-shrink-0 ${
                      openIndex === index ? "rotate-180" : ""
                    }`}
                  />
                </button>
                <div
                  className={`overflow-hidden transition-all duration-300 ${
                    openIndex === index
                      ? "max-h-96 opacity-100"
                      : "max-h-0 opacity-0"
                  }`}
                >
                  <div className="px-8 pb-6">
                    <p className="text-slate-600 dark:text-slate-300 leading-relaxed">
                      {faq.answer}
                    </p>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Contact support */}
        <div className="mt-16 text-center">
          <div className="bg-gradient-to-r from-pink-50 to-purple-50 dark:from-pink-900/20 dark:to-purple-900/20 rounded-2xl p-8 max-w-2xl mx-auto border border-pink-200/50 dark:border-pink-700/50">
            <h3 className="text-xl font-bold text-slate-800 dark:text-slate-100 mb-4">
              {language === "vi"
                ? "Vẫn còn thắc mắc?"
                : "Still have questions?"}
            </h3>
            <p className="text-slate-600 dark:text-slate-300 mb-6">
              {language === "vi"
                ? "Đội ngũ hỗ trợ của chúng tôi luôn sẵn sàng giúp đỡ bạn 24/7"
                : "Our support team is available 24/7 to help you"}
            </p>
            <a
              href="#"
              className="inline-flex items-center gap-2 bg-gradient-to-r from-pink-500 to-rose-500 text-white px-6 py-3 rounded-full font-semibold transition-all duration-300 transform hover:-translate-y-1 hover:shadow-lg"
            >
              <HelpCircle className="w-5 h-5" />
              {language === "vi" ? "Liên hệ hỗ trợ" : "Contact Support"}
            </a>
          </div>
        </div>
      </div>
    </section>
  );
}
