import React, { useState } from 'react';
import { Smartphone, Download, QrCode, X, Check, Apple, ExternalLink } from 'lucide-react';

interface MobileAppDownloadModalProps {
  isOpen: boolean;
  onClose: () => void;
  lang?: 'en' | 'bn';
}

export const MobileAppDownloadModal: React.FC<MobileAppDownloadModalProps> = ({
  isOpen,
  onClose,
  lang = 'bn',
}) => {
  const [platform, setPlatform] = useState<'android' | 'ios'>('android');
  const [copied, setCopied] = useState(false);
  const [downloadMode, setDownloadMode] = useState<'github' | 'lan'>('github');

  if (!isOpen) return null;

  const GITHUB_MOBILE_REPO = 'https://github.com/Zafff-e/Skill-Commerce-Marketplace-Platform/tree/main/mobile_app';
  const GITHUB_SDK_ZIP = 'https://github.com/Zafff-e/Skill-Commerce-Marketplace-Platform/raw/main/Frontend/react-customer-portal/public/downloads/SkillCommerce_Mobile_SDK_v1.0.0.zip';
  const LAN_HOST = 'http://192.168.8.162:5173';

  const isLocal = typeof window !== 'undefined' && (window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1');
  const currentHost = typeof window !== 'undefined' ? window.location.origin : 'http://localhost:5173';

  // If local, phone scanning localhost would fail. Use GitHub or Local LAN IP.
  const activeQrUrl = downloadMode === 'github' 
    ? GITHUB_MOBILE_REPO 
    : (isLocal ? `${LAN_HOST}/downloads/mobile_app.html` : `${currentHost}/downloads/mobile_app.html`);

  const downloadUrl = isLocal ? `${LAN_HOST}/downloads/mobile_app.html` : `${currentHost}/downloads/mobile_app.html`;
  const sdkZipUrl = GITHUB_SDK_ZIP;

  // Dynamic QR Code SVG generator link
  const qrSvgUrl = `https://api.qrserver.com/v1/create-qr-code/?size=240x240&data=${encodeURIComponent(
    activeQrUrl
  )}&bgcolor=ffffff&color=064e3b&margin=6`;

  const copyLink = () => {
    navigator.clipboard.writeText(activeQrUrl);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  return (
    <div
      role="dialog"
      aria-modal="true"
      style={{
        position: 'fixed',
        inset: 0,
        zIndex: 100,
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        padding: '20px',
        background: 'rgba(2, 24, 20, 0.8)',
        backdropFilter: 'blur(12px)',
      }}
      onClick={onClose}
    >
      <div
        style={{
          width: '100%',
          maxWidth: 580,
          background: 'rgba(6, 44, 34, 0.95)',
          border: '1px solid rgba(52, 211, 153, 0.4)',
          borderRadius: 24,
          padding: '28px',
          boxShadow: '0 25px 60px rgba(0, 0, 0, 0.6), 0 0 40px rgba(16, 185, 129, 0.25)',
          color: '#ffffff',
          position: 'relative',
          fontFamily: 'system-ui, -apple-system, sans-serif',
        }}
        onClick={(e) => e.stopPropagation()}
      >
        {/* Close Button */}
        <button
          type="button"
          onClick={onClose}
          style={{
            position: 'absolute',
            top: 20,
            right: 20,
            background: 'rgba(255, 255, 255, 0.1)',
            border: 'none',
            borderRadius: '50%',
            width: 36,
            height: 36,
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            color: '#ecfdf5',
            cursor: 'pointer',
          }}
          aria-label="Close"
        >
          <X size={20} />
        </button>

        {/* Modal Header */}
        <div style={{ textAlign: 'center', marginBottom: 20 }}>
          <div
            style={{
              display: 'inline-flex',
              alignItems: 'center',
              gap: 8,
              padding: '6px 16px',
              borderRadius: 30,
              background: 'rgba(16, 185, 129, 0.2)',
              border: '1px solid #10b981',
              color: '#34d399',
              fontSize: 13,
              fontWeight: 800,
              marginBottom: 10,
            }}
          >
            <Smartphone size={16} />
            {lang === 'bn' ? 'মোবাইল অ্যাপ ও রেডিমেড SDK' : 'Mobile App & Ready SDK'}
          </div>
          <h2 style={{ fontSize: 26, fontWeight: 800, margin: '4px 0', color: '#f0fdf4' }}>
            {lang === 'bn' ? 'মোবাইলে ইনস্টল করুন' : 'Scan to Install on Mobile'}
          </h2>
          <p style={{ fontSize: 14, color: '#a7f3d0', margin: 0 }}>
            {lang === 'bn'
              ? 'QR কোড স্ক্যান করে সরাসরি ইনস্টল করুন • Android ও iOS উভয় ডিভাইসে সম্পূর্ণ কার্যকর'
              : 'Scan the QR code with your phone camera to download & install on Android or iOS'}
          </p>
        </div>

        {/* Download Source Selector */}
        <div style={{ display: 'flex', justifyContent: 'center', gap: 10, marginBottom: 16 }}>
          <button
            type="button"
            onClick={() => setDownloadMode('github')}
            style={{
              padding: '6px 14px',
              borderRadius: 20,
              border: downloadMode === 'github' ? '1px solid #10b981' : '1px solid rgba(255,255,255,0.15)',
              background: downloadMode === 'github' ? 'rgba(16, 185, 129, 0.25)' : 'transparent',
              color: downloadMode === 'github' ? '#34d399' : '#94a3b8',
              fontSize: 12,
              fontWeight: 700,
              cursor: 'pointer',
              display: 'flex',
              alignItems: 'center',
              gap: 6,
            }}
          >
            🌐 {lang === 'bn' ? 'গিটহাব ক্লাউড (সরাসরি ফোনে ডাউনলোড)' : 'GitHub Cloud (Universal)'}
          </button>
          <button
            type="button"
            onClick={() => setDownloadMode('lan')}
            style={{
              padding: '6px 14px',
              borderRadius: 20,
              border: downloadMode === 'lan' ? '1px solid #10b981' : '1px solid rgba(255,255,255,0.15)',
              background: downloadMode === 'lan' ? 'rgba(16, 185, 129, 0.25)' : 'transparent',
              color: downloadMode === 'lan' ? '#34d399' : '#94a3b8',
              fontSize: 12,
              fontWeight: 700,
              cursor: 'pointer',
              display: 'flex',
              alignItems: 'center',
              gap: 6,
            }}
          >
            📶 {lang === 'bn' ? 'লোকাল ওয়াই-ফাই নেটওয়ার্ক' : 'Local Wi-Fi Network'}
          </button>
        </div>

        {/* Platform Selector Tabs */}
        <div
          style={{
            display: 'flex',
            gap: 12,
            background: 'rgba(0, 0, 0, 0.35)',
            padding: 6,
            borderRadius: 14,
            marginBottom: 20,
          }}
        >
          <button
            type="button"
            onClick={() => setPlatform('android')}
            style={{
              flex: 1,
              padding: '10px',
              borderRadius: 10,
              border: 'none',
              background: platform === 'android' ? '#10b981' : 'transparent',
              color: platform === 'android' ? '#022c22' : '#cbd5e1',
              fontWeight: 800,
              fontSize: 14,
              cursor: 'pointer',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              gap: 8,
              transition: 'all 0.2s',
            }}
          >
            <Smartphone size={16} />
            Android (.APK / PWA)
          </button>
          <button
            type="button"
            onClick={() => setPlatform('ios')}
            style={{
              flex: 1,
              padding: '10px',
              borderRadius: 10,
              border: 'none',
              background: platform === 'ios' ? '#10b981' : 'transparent',
              color: platform === 'ios' ? '#022c22' : '#cbd5e1',
              fontWeight: 800,
              fontSize: 14,
              cursor: 'pointer',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              gap: 8,
              transition: 'all 0.2s',
            }}
          >
            <Apple size={16} />
            iOS / iPhone (Safari / PWA)
          </button>
        </div>

        {/* QR Code and Instructions Section */}
        <div
          style={{
            display: 'flex',
            gap: 24,
            alignItems: 'center',
            background: 'rgba(15, 30, 26, 0.7)',
            border: '1px solid rgba(52, 211, 153, 0.2)',
            borderRadius: 18,
            padding: 20,
            marginBottom: 20,
          }}
        >
          {/* QR Code Box */}
          <div
            style={{
              width: 170,
              background: '#ffffff',
              borderRadius: 14,
              padding: 10,
              boxShadow: '0 8px 25px rgba(0,0,0,0.4)',
              flexShrink: 0,
              display: 'flex',
              flexDirection: 'column',
              alignItems: 'center',
              gap: 6,
            }}
          >
            <img
              src={qrSvgUrl}
              alt="Scan to Install SkillCommerce App"
              style={{ width: 150, height: 150, borderRadius: 8, display: 'block' }}
            />
            <span style={{ fontSize: 10, color: '#064e3b', textAlign: 'center', fontWeight: 700 }}>
              {downloadMode === 'github' ? 'গিটহাব ক্লাউড ডাউনলোড' : 'লোকাল ওয়াই-ফাই (LAN)'}
            </span>
          </div>

          {/* Quick Steps */}
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: 15, fontWeight: 700, color: '#ecfdf5', marginBottom: 8 }}>
              {platform === 'android' ? 'Android ইনস্টল নির্দেশিকা:' : 'iOS ইনস্টল নির্দেশিকা:'}
            </div>
            <ol
              style={{
                fontSize: 13,
                color: '#cbd5e1',
                paddingLeft: 18,
                margin: 0,
                lineHeight: 1.6,
              }}
            >
              <li>ফোনের ক্যামেরা বা Google Lens দিয়ে QR কোডটি স্ক্যান করুন।</li>
              <li>
                {platform === 'android'
                  ? 'লিংকে গিয়ে "ইনস্টল করুন" বা "Add to Home Screen" চাপুন।'
                  : 'Safari ব্রাউজারে Share আইকন চাপুন এবং "Add to Home Screen" নির্বাচন করুন।'}
              </li>
              <li>তাত্ক্ষণিক আপনার মোবাইলের হোম স্ক্রিনে অ্যাপটি চালু হয়ে যাবে।</li>
            </ol>
          </div>
        </div>

        {/* Direct Action Buttons */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
          <div style={{ display: 'flex', gap: 10 }}>
            {/* Open Mobile Version in New Tab / GitHub */}
            <a
              href={downloadMode === 'github' ? GITHUB_MOBILE_REPO : downloadUrl}
              target="_blank"
              rel="noopener noreferrer"
              style={{
                flex: 1.2,
                padding: '12px 18px',
                borderRadius: 12,
                background: 'linear-gradient(135deg, #10b981 0%, #059669 100%)',
                color: '#ffffff',
                fontWeight: 800,
                fontSize: 14,
                textDecoration: 'none',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                gap: 8,
                boxShadow: '0 6px 20px rgba(16, 185, 129, 0.4)',
              }}
            >
              <ExternalLink size={16} />
              {downloadMode === 'github'
                ? (lang === 'bn' ? 'গিটহাবে অ্যাপটি দেখুন' : 'Open on GitHub')
                : (lang === 'bn' ? 'সরাসরি মোবাইলে ওপেন করুন' : 'Launch Mobile App')}
            </a>

            {/* Copy Link Button */}
            <button
              type="button"
              onClick={copyLink}
              style={{
                flex: 0.8,
                padding: '12px 16px',
                borderRadius: 12,
                background: 'rgba(255, 255, 255, 0.08)',
                border: '1px solid rgba(255, 255, 255, 0.2)',
                color: '#ecfdf5',
                fontWeight: 700,
                fontSize: 13,
                cursor: 'pointer',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                gap: 6,
              }}
            >
              {copied ? <Check size={16} color="#34d399" /> : <QrCode size={16} />}
              {copied ? (lang === 'bn' ? 'কপি হয়েছে!' : 'Copied!') : (lang === 'bn' ? 'লিংক কপি' : 'Copy Link')}
            </button>
          </div>

          {/* Full Ready-made SDK Download (ZIP) */}
          <a
            href={sdkZipUrl}
            download="SkillCommerce_Mobile_SDK_v1.0.0.zip"
            style={{
              width: '100%',
              padding: '10px 16px',
              borderRadius: 12,
              background: 'rgba(6, 78, 59, 0.4)',
              border: '1px dashed rgba(52, 211, 153, 0.35)',
              color: '#a7f3d0',
              fontWeight: 600,
              fontSize: 13,
              textDecoration: 'none',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              gap: 8,
              textAlign: 'center',
            }}
          >
            <Download size={15} />
            {lang === 'bn'
              ? 'সম্পূর্ণ মোবাইল অ্যাপ সোর্স ও SDK ডাউনলোড করুন (.ZIP • 60 MB)'
              : 'Download Full Mobile SDK & Source (.ZIP • 60 MB)'}
          </a>
        </div>
      </div>
    </div>
  );
};

