"use client";

import React, { useState, useEffect } from "react";
import QRCode from "qrcode";
import { Download, X, QrCode, Smartphone } from "lucide-react";
import { createPortal } from "react-dom";

interface QRCodeDownloadProps {
  t: any;
}

export function QRCodeDownload({ t }: QRCodeDownloadProps) {
  const [showQRModal, setShowQRModal] = useState(false);
  const [qrCodeUrl, setQrCodeUrl] = useState("");

  // GitHub Release URL trực tiếp đến file APK
  const GITHUB_APK_URL = "https://github.com/minhph091/amoura-final-project/releases/download/v1.0.0/Amoura_v1.0.0.apk";
  // QR code cũng trỏ đến GitHub Release để tải trực tiếp
  const QR_CODE_URL = GITHUB_APK_URL;

  useEffect(() => {
    // Tạo QR code trỏ đến GitHub Release để tải trực tiếp
    const generateQRCode = async () => {
      try {
        const qrString = await QRCode.toDataURL(QR_CODE_URL, {
          width: 256,
          margin: 2,
          color: {
            dark: "#1f2937", // Dark gray
            light: "#ffffff", // White
          },
        });
        setQrCodeUrl(qrString);
      } catch (error) {
        console.error("Error generating QR code:", error);
      }
    };

    generateQRCode();
  }, []);

  // Disable scroll when modal is open
  useEffect(() => {
    if (showQRModal) {
      document.body.style.overflow = 'hidden';
    } else {
      document.body.style.overflow = 'unset';
    }
    
    // Cleanup on unmount
    return () => {
      document.body.style.overflow = 'unset';
    };
  }, [showQRModal]);

  const handleDirectDownload = () => {
    // Tải trực tiếp file APK từ GitHub Release
    window.open(GITHUB_APK_URL, '_blank');
    setShowQRModal(false); // Đóng modal sau khi mở link tải
  };

  const modalContent = showQRModal ? (
    <div 
      className="fixed inset-0 bg-black/70 backdrop-blur-sm flex items-center justify-center z-[99999] p-4"
      onClick={() => setShowQRModal(false)}
    >
      <div 
        className="bg-white dark:bg-slate-800 rounded-2xl p-8 max-w-md w-full relative shadow-2xl transform scale-100 transition-all duration-300"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Close button */}
        <button
          onClick={() => setShowQRModal(false)}
          className="absolute top-4 right-4 p-2 hover:bg-gray-100 dark:hover:bg-slate-700 rounded-full transition-colors z-10 bg-white/80 dark:bg-slate-800/80"
          title="Đóng"
          aria-label="Đóng modal"
        >
          <X className="w-6 h-6 text-gray-700 dark:text-gray-300" />
        </button>

        {/* Header */}
        <div className="text-center mb-6">
          <div className="w-16 h-16 bg-gradient-to-r from-green-500 to-emerald-600 rounded-full mx-auto mb-4 flex items-center justify-center">
            <Smartphone className="w-8 h-8 text-white" />
          </div>
          <h3 className="text-2xl font-bold text-gray-900 dark:text-white mb-2">
            Tải Amoura
          </h3>
          <p className="text-gray-600 dark:text-gray-300">
            Quét mã QR hoặc tải trực tiếp
          </p>
        </div>

        {/* QR Code */}
        <div className="text-center mb-6">
          {qrCodeUrl && (
            <div className="inline-block p-4 bg-white rounded-xl shadow-lg">
              <img
                src={qrCodeUrl}
                alt="QR Code để tải Amoura"
                className="w-48 h-48 mx-auto"
              />
            </div>
          )}
          <p className="text-sm text-gray-500 dark:text-gray-400 mt-4">
            Quét mã QR để tải app trực tiếp
          </p>
          <p className="text-xs text-gray-400 dark:text-gray-500 mt-2">
            GitHub Release: v1.0.0
          </p>
        </div>

        {/* Download button */}
        <button
          onClick={handleDirectDownload}
          className="w-full bg-gradient-to-r from-green-500 to-emerald-600 text-white px-6 py-4 rounded-xl font-semibold flex items-center justify-center gap-3 hover:from-green-600 hover:to-emerald-700 transition-all duration-300 transform hover:-translate-y-1 hover:shadow-xl"
        >
          <Download className="w-6 h-6" />
          Tải trực tiếp (54MB)
        </button>
      </div>
    </div>
  ) : null;

  return (
    <>
      {/* Button tải APK với QR Code */}
      <button
        onClick={() => setShowQRModal(true)}
        className="group bg-black dark:bg-slate-900 text-white px-6 py-3 rounded-xl font-semibold flex items-center justify-center gap-3 hover:bg-gray-800 dark:hover:bg-slate-800 transition-all duration-300 transform hover:-translate-y-1 hover:shadow-xl w-full"
      >
        <div className="w-8 h-8 flex items-center justify-center">
          <svg
            className="w-8 h-8"
            fill="currentColor"
            viewBox="0 0 24 24"
          >
            <path d="M17.6 9.48l1.84-3.18c.16-.31.04-.69-.26-.85a.637.637 0 0 0-.83.22l-1.88 3.24a11.43 11.43 0 0 0-8.94 0L5.65 5.67a.637.637 0 0 0-.83-.22c-.3.16-.42.54-.26.85L6.4 9.48C3.3 11.25 1.28 14.44 1 18h22c-.28-3.56-2.3-6.75-5.4-8.52zM7 15.25a1.25 1.25 0 1 1 0-2.5 1.25 1.25 0 0 1 0 2.5zm10 0a1.25 1.25 0 1 1 0-2.5 1.25 1.25 0 0 1 0 2.5z" />
          </svg>
        </div>
        <div className="text-left">
          <p className="text-xs opacity-80">Tải cho</p>
          <p className="text-lg font-bold">Android</p>
        </div>
      </button>

      {/* Render modal using Portal */}
      {typeof window !== 'undefined' && modalContent && createPortal(modalContent, document.body)}
    </>
  );
}
