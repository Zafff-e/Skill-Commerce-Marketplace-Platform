import React from 'react';
import {
  AbsoluteFill,
  Sequence,
  useCurrentFrame,
  useVideoConfig,
  spring,
  interpolate,
} from 'remotion';

// Eco-Glassmorphism Theme Palette
const THEME = {
  bgGradient: 'radial-gradient(circle at 50% 30%, #064e3b 0%, #022c22 45%, #051310 100%)',
  emerald: '#10b981',
  emeraldGlow: 'rgba(16, 185, 129, 0.45)',
  teal: '#14b8a6',
  gold: '#fbbf24',
  glassBg: 'rgba(6, 78, 59, 0.35)',
  glassBorder: 'rgba(52, 211, 153, 0.35)',
  glassCard: 'rgba(15, 30, 26, 0.72)',
  textPrimary: '#ffffff',
  textSecondary: '#a7f3d0',
};

// --- SCENE 1: Dual-Persona Entry & Dokkho-Bot (Frames 0–150 | 0–5s) ---
export const Scene1DualPersona: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  // Dokkho-Bot spring entrance
  const botEntrance = spring({
    frame,
    fps,
    config: { damping: 12, mass: 0.8 },
  });

  // Bot waving hand swing
  const wave = Math.sin(frame * 0.2) * 12;

  // Role cards spring entrance
  const cardsEntrance = spring({
    frame: frame - 25,
    fps,
    config: { damping: 14, mass: 1 },
  });

  // Glowing animated cursor trajectory & click
  const cursorProgress = interpolate(frame, [60, 110], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });
  const cursorX = interpolate(cursorProgress, [0, 1], [1300, 720]);
  const cursorY = interpolate(cursorProgress, [0, 1], [850, 680]);

  const clickScale =
    frame >= 110 && frame <= 130
      ? interpolate(frame, [110, 120, 130], [1, 0.94, 1.04])
      : 1;

  const card1BorderGlow =
    frame >= 115
      ? '0 0 40px rgba(16, 185, 129, 0.8), inset 0 0 20px rgba(52, 211, 153, 0.4)'
      : '0 8px 32px rgba(0, 0, 0, 0.4)';

  return (
    <AbsoluteFill
      style={{
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        justifyContent: 'center',
        padding: '60px 100px',
        color: THEME.textPrimary,
        fontFamily: 'system-ui, -apple-system, sans-serif',
      }}
    >
      {/* Dokkho-Bot Avatar & Floating Greeting */}
      <div
        style={{
          transform: `scale(${botEntrance}) translateY(${interpolate(
            botEntrance,
            [0, 1],
            [60, 0]
          )}px)`,
          opacity: botEntrance,
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          marginBottom: 40,
        }}
      >
        <div style={{ position: 'relative', display: 'inline-block' }}>
          <img
            src="/assets/ai-chatbot.jpg"
            alt="Dokkho-Bot"
            style={{
              width: 150,
              height: 150,
              borderRadius: '50%',
              border: `4px solid ${THEME.emerald}`,
              boxShadow: `0 0 35px ${THEME.emeraldGlow}`,
              objectFit: 'cover',
            }}
          />
          {/* Hand Wave Emoji */}
          <div
            style={{
              position: 'absolute',
              bottom: 4,
              right: 4,
              fontSize: 42,
              transform: `rotate(${wave}deg)`,
              transformOrigin: 'bottom right',
            }}
          >
            👋
          </div>
        </div>

        {/* Greeting Badge */}
        <div
          style={{
            marginTop: 18,
            padding: '12px 28px',
            background: 'rgba(6, 78, 59, 0.85)',
            border: `1px solid ${THEME.glassBorder}`,
            borderRadius: 50,
            backdropFilter: 'blur(16px)',
            boxShadow: '0 10px 30px rgba(0,0,0,0.4)',
            textAlign: 'center',
          }}
        >
          <div style={{ fontSize: 28, fontWeight: 700, color: '#ecfdf5' }}>
            আসসালামু আলাইকুম! কীভাবে সাহায্য করতে পারি?
          </div>
          <div style={{ fontSize: 18, color: THEME.textSecondary, marginTop: 4 }}>
            Welcome to Find Skilled People (দক্ষ মানুষ খুঁজি)
          </div>
        </div>
      </div>

      {/* Twin Persona Signature Box Cards */}
      <div
        style={{
          display: 'flex',
          gap: 40,
          width: '100%',
          maxWidth: 1100,
          transform: `scale(${cardsEntrance})`,
          opacity: cardsEntrance,
        }}
      >
        {/* Card 1: Need a Service (Customer) */}
        <div
          style={{
            flex: 1,
            padding: '36px 32px',
            background: THEME.glassCard,
            border: `2px solid ${frame >= 115 ? THEME.emerald : THEME.glassBorder}`,
            borderRadius: 24,
            backdropFilter: 'blur(20px)',
            boxShadow: card1BorderGlow,
            transform: `scale(${clickScale})`,
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            textAlign: 'center',
            position: 'relative',
          }}
        >
          <div
            style={{
              width: 72,
              height: 72,
              borderRadius: '50%',
              background: 'rgba(16, 185, 129, 0.2)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              fontSize: 34,
              marginBottom: 16,
              border: `1px solid ${THEME.emerald}`,
            }}
          >
            🛠️
          </div>
          <div style={{ fontSize: 30, fontWeight: 800, color: '#f0fdf4' }}>
            Need a Service
          </div>
          <div style={{ fontSize: 24, fontWeight: 600, color: THEME.textSecondary, marginTop: 6 }}>
            সেবা নিতে চাই
          </div>
          <div style={{ fontSize: 16, color: '#94a3b8', marginTop: 12 }}>
            Verified technicians • Zero hassle • 7-day guarantee
          </div>
          {frame >= 115 && (
            <div
              style={{
                position: 'absolute',
                top: 16,
                right: 18,
                padding: '4px 12px',
                background: THEME.emerald,
                color: '#022c22',
                fontWeight: 800,
                borderRadius: 12,
                fontSize: 14,
              }}
            >
              SELECTED
            </div>
          )}
        </div>

        {/* Card 2: Provide a Service (Technician) */}
        <div
          style={{
            flex: 1,
            padding: '36px 32px',
            background: THEME.glassCard,
            border: `1px solid ${THEME.glassBorder}`,
            borderRadius: 24,
            backdropFilter: 'blur(20px)',
            boxShadow: '0 8px 32px rgba(0, 0, 0, 0.35)',
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            textAlign: 'center',
            opacity: frame >= 115 ? 0.6 : 1,
          }}
        >
          <div
            style={{
              width: 72,
              height: 72,
              borderRadius: '50%',
              background: 'rgba(20, 184, 166, 0.2)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              fontSize: 34,
              marginBottom: 16,
              border: `1px solid ${THEME.teal}`,
            }}
          >
            💼
          </div>
          <div style={{ fontSize: 30, fontWeight: 800, color: '#f0fdf4' }}>
            Provide a Service
          </div>
          <div style={{ fontSize: 24, fontWeight: 600, color: THEME.textSecondary, marginTop: 6 }}>
            কাজ করতে চাই
          </div>
          <div style={{ fontSize: 16, color: '#94a3b8', marginTop: 12 }}>
            Instant jobs • Transparent earnings • Flexible zones
          </div>
        </div>
      </div>

      {/* Animated Glowing Clicking Cursor */}
      {frame >= 60 && (
        <div
          style={{
            position: 'absolute',
            left: cursorX,
            top: cursorY,
            pointerEvents: 'none',
            zIndex: 100,
            transform: 'translate(-10px, -10px)',
          }}
        >
          <svg
            width="46"
            height="46"
            viewBox="0 0 24 24"
            fill="none"
            stroke="#10b981"
            strokeWidth="2.5"
            strokeLinecap="round"
            strokeLinejoin="round"
            style={{
              filter: 'drop-shadow(0 0 14px rgba(16, 185, 129, 0.9))',
            }}
          >
            <path d="m3 3 7.07 16.97 2.51-7.39 7.39-2.51L3 3z" fill="#059669" />
            <path d="m13 13 6 6" />
          </svg>
        </div>
      )}
    </AbsoluteFill>
  );
};

// --- SCENE 2: Voice & Photo AI Intake + Avatar Ribbon (Frames 150–300 | 5–10s) ---
export const Scene2AiIntake: React.FC = () => {
  const frame = useCurrentFrame();
  const localFrame = frame - 150;
  const { fps } = useVideoConfig();

  // Waveform heights animated with sine waves
  const wave1 = 20 + Math.sin(localFrame * 0.3) * 35;
  const wave2 = 25 + Math.sin(localFrame * 0.4 + 1) * 45;
  const wave3 = 30 + Math.sin(localFrame * 0.5 + 2) * 60;
  const wave4 = 25 + Math.sin(localFrame * 0.35 + 3) * 40;
  const wave5 = 15 + Math.sin(localFrame * 0.25 + 4) * 30;

  // Laser scan across photo
  const scanY = interpolate(localFrame % 60, [0, 60], [10, 240]);

  // Sliding avatar ribbon
  const ribbonX = interpolate(localFrame, [0, 150], [0, -320]);

  // Entrance spring
  const sceneEntrance = spring({
    frame: localFrame,
    fps,
    config: { damping: 14 },
  });

  const avatars = [
    { title: 'AC Technician', bn: 'এসি টেকনিশিয়ান', file: 'ac.jpg', highlight: true },
    { title: 'Electrician', bn: 'ইলেকট্রিশিয়ান', file: 'electrician.jpg' },
    { title: 'Plumber', bn: 'প্লাম্বার', file: 'plumber.jpg' },
    { title: 'Carpenter', bn: 'কাঠমিস্ত্রি', file: 'carpenter.jpg' },
    { title: 'Cleaner', bn: 'ক্লিনার', file: 'cleaner.jpg' },
    { title: 'Court Escort', bn: 'আদালত সহায়ক', file: 'court-companion.jpg' },
    { title: 'Caregiver', bn: 'কেয়ারগিভার', file: 'care.jpg' },
  ];

  return (
    <AbsoluteFill
      style={{
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        justifyContent: 'center',
        padding: '40px 80px',
        color: THEME.textPrimary,
        fontFamily: 'system-ui, -apple-system, sans-serif',
        opacity: sceneEntrance,
      }}
    >
      {/* Top Banner: AI Intake */}
      <div
        style={{
          textAlign: 'center',
          marginBottom: 30,
        }}
      >
        <span
          style={{
            padding: '6px 18px',
            borderRadius: 50,
            background: 'rgba(16, 185, 129, 0.2)',
            border: `1px solid ${THEME.emerald}`,
            color: THEME.emerald,
            fontSize: 16,
            fontWeight: 700,
            letterSpacing: '1px',
            textTransform: 'uppercase',
          }}
        >
          Step 2 • Multimodal AI Intake
        </span>
        <h2 style={{ fontSize: 38, fontWeight: 800, marginTop: 12, color: '#f0fdf4' }}>
          ভয়েস বা ছবি দিয়ে সহজেই সমস্যা বলুন
        </h2>
        <p style={{ fontSize: 20, color: THEME.textSecondary, marginTop: 4 }}>
          Voice & Photo Problem Recognition with Instant Skill Matching
        </p>
      </div>

      {/* Center Layout: Left Voice Waveform + Right Broken AC Photo Scan */}
      <div
        style={{
          display: 'flex',
          gap: 40,
          width: '100%',
          maxWidth: 1100,
          marginBottom: 40,
        }}
      >
        {/* Left: Pulsing Voice Waveform Box */}
        <div
          style={{
            flex: 1.2,
            background: THEME.glassCard,
            border: `1px solid ${THEME.glassBorder}`,
            borderRadius: 24,
            padding: 30,
            backdropFilter: 'blur(20px)',
            display: 'flex',
            flexDirection: 'column',
            justifyContent: 'space-between',
            boxShadow: '0 8px 32px rgba(0,0,0,0.3)',
          }}
        >
          <div style={{ display: 'flex', alignItems: 'center', gap: 16 }}>
            <div
              style={{
                width: 54,
                height: 54,
                borderRadius: '50%',
                background: 'rgba(239, 68, 68, 0.2)',
                border: '2px solid #ef4444',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                fontSize: 26,
              }}
            >
              🎙️
            </div>
            <div>
              <div style={{ fontSize: 16, color: '#ef4444', fontWeight: 700 }}>LIVE RECORDING</div>
              <div style={{ fontSize: 14, color: '#94a3b8' }}>AI Speech-to-Text (Bangla)</div>
            </div>
          </div>

          {/* Voice Waveform Bars */}
          <div
            style={{
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              gap: 12,
              height: 100,
              margin: '20px 0',
            }}
          >
            {[wave1, wave2, wave3, wave4, wave5, wave4, wave2, wave3, wave1].map((h, i) => (
              <div
                key={i}
                style={{
                  width: 10,
                  height: h,
                  background: 'linear-gradient(to top, #10b981, #34d399)',
                  borderRadius: 10,
                  boxShadow: '0 0 12px rgba(16, 185, 129, 0.7)',
                }}
              />
            ))}
          </div>

          {/* Spoken Transcription Bubble */}
          <div
            style={{
              padding: '14px 20px',
              borderRadius: 16,
              background: 'rgba(6, 78, 59, 0.7)',
              border: '1px solid rgba(52, 211, 153, 0.3)',
            }}
          >
            <div style={{ fontSize: 22, fontWeight: 700, color: '#fef08a' }}>
              &ldquo;আমার এসি ঠান্ডা হচ্ছে না&rdquo;
            </div>
            <div style={{ fontSize: 16, color: '#a7f3d0', marginTop: 4 }}>
              &ldquo;My AC is not cooling properly&rdquo;
            </div>
          </div>
        </div>

        {/* Right: Broken AC Photo with Laser Scan */}
        <div
          style={{
            flex: 0.9,
            background: THEME.glassCard,
            border: `1px solid ${THEME.glassBorder}`,
            borderRadius: 24,
            padding: 24,
            backdropFilter: 'blur(20px)',
            position: 'relative',
            overflow: 'hidden',
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            boxShadow: '0 8px 32px rgba(0,0,0,0.3)',
          }}
        >
          <div style={{ position: 'relative', width: '100%', height: 200, borderRadius: 16, overflow: 'hidden' }}>
            <img
              src="/assets/avatars/ac.jpg"
              alt="Broken AC Diagnostic"
              style={{ width: '100%', height: '100%', objectFit: 'cover' }}
            />
            {/* Laser Scan Beam */}
            <div
              style={{
                position: 'absolute',
                top: scanY,
                left: 0,
                right: 0,
                height: 3,
                background: '#34d399',
                boxShadow: '0 0 18px 4px #10b981',
              }}
            />
            <div
              style={{
                position: 'absolute',
                top: 12,
                left: 12,
                padding: '4px 10px',
                background: 'rgba(0,0,0,0.7)',
                borderRadius: 8,
                fontSize: 12,
                color: THEME.emerald,
                fontWeight: 700,
              }}
            >
              DIAGNOSTIC VISION SCAN
            </div>
          </div>

          <div
            style={{
              marginTop: 16,
              width: '100%',
              display: 'flex',
              justifyContent: 'space-between',
              alignItems: 'center',
            }}
          >
            <span style={{ fontSize: 16, color: '#e2e8f0', fontWeight: 600 }}>Detected Defect:</span>
            <span
              style={{
                padding: '4px 12px',
                borderRadius: 20,
                background: 'rgba(239, 68, 68, 0.2)',
                color: '#f87171',
                fontSize: 14,
                fontWeight: 700,
                border: '1px solid rgba(239, 68, 68, 0.4)',
              }}
            >
              Capacitor / Gas Issue (98%)
            </span>
          </div>
        </div>
      </div>

      {/* Bottom Horizontal Avatar Ribbon with Auto-Selected Specialist */}
      <div
        style={{
          width: '100%',
          maxWidth: 1100,
          overflow: 'hidden',
          position: 'relative',
          padding: '10px 0',
        }}
      >
        <div
          style={{
            display: 'flex',
            gap: 24,
            transform: `translateX(${ribbonX}px)`,
          }}
        >
          {avatars.map((av, index) => {
            const isHighlight = av.highlight;
            return (
              <div
                key={index}
                style={{
                  minWidth: 170,
                  padding: '16px 12px',
                  borderRadius: 18,
                  background: isHighlight
                    ? 'rgba(16, 185, 129, 0.25)'
                    : 'rgba(15, 30, 26, 0.6)',
                  border: isHighlight
                    ? `2px solid ${THEME.emerald}`
                    : `1px solid ${THEME.glassBorder}`,
                  boxShadow: isHighlight
                    ? `0 0 25px ${THEME.emeraldGlow}`
                    : 'none',
                  display: 'flex',
                  flexDirection: 'column',
                  alignItems: 'center',
                  transform: isHighlight ? 'scale(1.08)' : 'scale(1)',
                }}
              >
                <img
                  src={`/assets/avatars/${av.file}`}
                  alt={av.title}
                  style={{
                    width: 70,
                    height: 70,
                    borderRadius: '50%',
                    objectFit: 'cover',
                    border: isHighlight ? `2px solid ${THEME.emerald}` : '1px solid #475569',
                    marginBottom: 10,
                  }}
                />
                <div style={{ fontSize: 16, fontWeight: 700, color: '#f0fdf4', textAlign: 'center' }}>
                  {av.title}
                </div>
                <div style={{ fontSize: 13, color: THEME.textSecondary, marginTop: 2 }}>
                  {av.bn}
                </div>
                {isHighlight && (
                  <span
                    style={{
                      marginTop: 8,
                      fontSize: 11,
                      fontWeight: 800,
                      background: THEME.emerald,
                      color: '#022c22',
                      padding: '2px 8px',
                      borderRadius: 10,
                    }}
                  >
                    MATCHED
                  </span>
                )}
              </div>
            );
          })}
        </div>
      </div>
    </AbsoluteFill>
  );
};

// --- SCENE 3: Live Radial Map & OTP Handshake (Frames 300–450 | 10–15s) ---
export const Scene3RadarOtp: React.FC = () => {
  const frame = useCurrentFrame();
  const localFrame = frame - 300;
  const { fps } = useVideoConfig();

  // Sonar radar rings expanding
  const sonarScale1 = ((localFrame * 0.04) % 1) * 2.5;
  const sonarOpacity1 = 1 - (localFrame * 0.04) % 1;

  const sonarScale2 = (((localFrame + 25) * 0.04) % 1) * 2.5;
  const sonarOpacity2 = 1 - ((localFrame + 25) * 0.04) % 1;

  // Technician movement along path to customer pin
  const travelProgress = interpolate(localFrame, [20, 100], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });
  const techX = interpolate(travelProgress, [0, 1], [320, 680]);
  const techY = interpolate(travelProgress, [0, 1], [480, 420]);

  // OTP handshake pop-in
  const otpEntrance = spring({
    frame: localFrame - 80,
    fps,
    config: { damping: 12 },
  });

  return (
    <AbsoluteFill
      style={{
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        justifyContent: 'center',
        padding: '40px 80px',
        color: THEME.textPrimary,
        fontFamily: 'system-ui, -apple-system, sans-serif',
      }}
    >
      {/* Title Header */}
      <div style={{ textAlign: 'center', marginBottom: 25 }}>
        <span
          style={{
            padding: '6px 18px',
            borderRadius: 50,
            background: 'rgba(16, 185, 129, 0.2)',
            border: `1px solid ${THEME.emerald}`,
            color: THEME.emerald,
            fontSize: 16,
            fontWeight: 700,
            letterSpacing: '1px',
            textTransform: 'uppercase',
          }}
        >
          Step 3 • Live Radar Match & OTP Handshake
        </span>
        <h2 style={{ fontSize: 38, fontWeight: 800, marginTop: 12, color: '#f0fdf4' }}>
          নিকটস্থ যাচাইকৃত দক্ষ মানুষ ও নিরাপদ ওটিপি
        </h2>
        <p style={{ fontSize: 20, color: THEME.textSecondary, marginTop: 4 }}>
          Live Geo-Dispatching within Mirpur / Dhanmondi & Verified Work Start
        </p>
      </div>

      {/* Radar Map Canvas Simulation */}
      <div
        style={{
          width: 1000,
          height: 480,
          background: 'radial-gradient(circle at 50% 50%, #064e3b 0%, #022c22 70%, #01140e 100%)',
          border: `2px solid ${THEME.glassBorder}`,
          borderRadius: 24,
          position: 'relative',
          overflow: 'hidden',
          boxShadow: '0 20px 50px rgba(0,0,0,0.5)',
        }}
      >
        {/* Dhaka Grid Roads & Waterway representation */}
        <svg
          width="100%"
          height="100%"
          style={{ position: 'absolute', top: 0, left: 0, opacity: 0.25 }}
        >
          <line x1="0" y1="180" x2="1000" y2="180" stroke="#34d399" strokeWidth="2" strokeDasharray="8 6" />
          <line x1="0" y1="360" x2="1000" y2="360" stroke="#34d399" strokeWidth="2" strokeDasharray="8 6" />
          <line x1="280" y1="0" x2="280" y2="480" stroke="#34d399" strokeWidth="2" strokeDasharray="8 6" />
          <line x1="720" y1="0" x2="720" y2="480" stroke="#34d399" strokeWidth="2" strokeDasharray="8 6" />
          {/* River curve */}
          <path d="M 120 0 Q 300 240 220 480" stroke="#0ea5e9" strokeWidth="12" fill="none" opacity="0.4" />
        </svg>

        {/* Sonar Expanding Rings from Customer Pin */}
        <div
          style={{
            position: 'absolute',
            left: 700,
            top: 420,
            width: 200,
            height: 200,
            marginLeft: -100,
            marginTop: -100,
            borderRadius: '50%',
            border: `2px solid ${THEME.emerald}`,
            transform: `scale(${sonarScale1})`,
            opacity: sonarOpacity1,
            pointerEvents: 'none',
          }}
        />
        <div
          style={{
            position: 'absolute',
            left: 700,
            top: 420,
            width: 200,
            height: 200,
            marginLeft: -100,
            marginTop: -100,
            borderRadius: '50%',
            border: `2px solid ${THEME.emerald}`,
            transform: `scale(${sonarScale2})`,
            opacity: sonarOpacity2,
            pointerEvents: 'none',
          }}
        />

        {/* Customer Destination Pin */}
        <div
          style={{
            position: 'absolute',
            left: 680,
            top: 400,
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
          }}
        >
          <div
            style={{
              padding: '6px 14px',
              borderRadius: 20,
              background: '#047857',
              color: '#ffffff',
              fontSize: 14,
              fontWeight: 800,
              boxShadow: '0 4px 15px rgba(0,0,0,0.5)',
              marginBottom: 6,
            }}
          >
            🏠 Dhanmondi 27 (Customer)
          </div>
          <div
            style={{
              width: 20,
              height: 20,
              borderRadius: '50%',
              background: '#34d399',
              boxShadow: '0 0 20px #10b981',
            }}
          />
        </div>

        {/* Moving Technician Card */}
        <div
          style={{
            position: 'absolute',
            left: techX - 90,
            top: techY - 70,
            padding: '10px 16px',
            background: 'rgba(6, 78, 59, 0.9)',
            border: `2px solid ${THEME.emerald}`,
            borderRadius: 16,
            backdropFilter: 'blur(12px)',
            boxShadow: `0 8px 30px ${THEME.emeraldGlow}`,
            display: 'flex',
            alignItems: 'center',
            gap: 12,
            zIndex: 10,
          }}
        >
          <img
            src="/assets/avatars/ac.jpg"
            alt="Technician"
            style={{
              width: 46,
              height: 46,
              borderRadius: '50%',
              border: `2px solid ${THEME.emerald}`,
              objectFit: 'cover',
            }}
          />
          <div>
            <div style={{ fontSize: 15, fontWeight: 800, color: '#f0fdf4' }}>
              Kabir Hasan • AC Expert
            </div>
            <div style={{ fontSize: 13, color: THEME.textSecondary, display: 'flex', gap: 8 }}>
              <span>⭐ 4.9</span>
              <span>•</span>
              <span>1.2 km away</span>
            </div>
          </div>
        </div>

        {/* Dashed Routing Path */}
        <svg
          width="100%"
          height="100%"
          style={{ position: 'absolute', top: 0, left: 0, pointerEvents: 'none' }}
        >
          <line
            x1="320"
            y1="480"
            x2="680"
            y2="420"
            stroke="#10b981"
            strokeWidth="4"
            strokeDasharray="10 8"
            opacity="0.8"
          />
        </svg>

        {/* OTP Handshake Floating Badge (When arrived) */}
        {localFrame >= 80 && (
          <div
            style={{
              position: 'absolute',
              top: 50,
              left: '50%',
              transform: `translateX(-50%) scale(${otpEntrance})`,
              background: 'rgba(15, 23, 42, 0.92)',
              border: '2px solid #fbbf24',
              borderRadius: 20,
              padding: '20px 36px',
              textAlign: 'center',
              boxShadow: '0 12px 40px rgba(251, 191, 36, 0.35)',
              zIndex: 30,
            }}
          >
            <div style={{ fontSize: 14, color: '#fbbf24', fontWeight: 800, letterSpacing: '2px' }}>
              SECURE START OTP HANDSHAKE
            </div>
            <div
              style={{
                fontSize: 48,
                fontWeight: 900,
                color: '#ffffff',
                letterSpacing: '8px',
                marginTop: 6,
              }}
            >
              ১২৩৪ <span style={{ fontSize: 32, color: '#94a3b8' }}>/ 1234</span>
            </div>
            <div
              style={{
                marginTop: 10,
                padding: '4px 16px',
                background: '#10b981',
                color: '#022c22',
                borderRadius: 20,
                fontWeight: 800,
                fontSize: 14,
                display: 'inline-block',
              }}
            >
              ✓ STATUS: IN_PROGRESS
            </div>
          </div>
        )}
      </div>
    </AbsoluteFill>
  );
};

// --- SCENE 4: Transparent Billing & 7-Day Warranty (Frames 450–600 | 15–20s) ---
export const Scene4BillingWarranty: React.FC = () => {
  const frame = useCurrentFrame();
  const localFrame = frame - 450;
  const { fps } = useVideoConfig();

  // Invoice card spring
  const invoiceEntrance = spring({
    frame: localFrame,
    fps,
    config: { damping: 14 },
  });

  // Clicking "Approve" button
  const approveClick =
    localFrame >= 60 && localFrame <= 80
      ? interpolate(localFrame, [60, 70, 80], [1, 0.95, 1])
      : 1;

  // Warranty badge spring
  const warrantyEntrance = spring({
    frame: localFrame - 75,
    fps,
    config: { damping: 10, mass: 0.8 },
  });

  return (
    <AbsoluteFill
      style={{
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        justifyContent: 'center',
        padding: '40px 80px',
        color: THEME.textPrimary,
        fontFamily: 'system-ui, -apple-system, sans-serif',
      }}
    >
      {/* Title Header */}
      <div style={{ textAlign: 'center', marginBottom: 25 }}>
        <span
          style={{
            padding: '6px 18px',
            borderRadius: 50,
            background: 'rgba(16, 185, 129, 0.2)',
            border: `1px solid ${THEME.emerald}`,
            color: THEME.emerald,
            fontSize: 16,
            fontWeight: 700,
            letterSpacing: '1px',
            textTransform: 'uppercase',
          }}
        >
          Step 4 • Transparent Bill & Warranty Shield
        </span>
        <h2 style={{ fontSize: 38, fontWeight: 800, marginTop: 12, color: '#f0fdf4' }}>
          স্বচ্ছ বিলিং ও ৭ দিনের নিশ্চিত সার্ভিস ওয়ারেন্টি
        </h2>
        <p style={{ fontSize: 20, color: THEME.textSecondary, marginTop: 4 }}>
          Zero Hidden Charges • Real-Time Parts Approval • Complete Peace of Mind
        </p>
      </div>

      <div
        style={{
          display: 'flex',
          gap: 40,
          width: '100%',
          maxWidth: 1100,
          alignItems: 'center',
        }}
      >
        {/* Split Transparent Invoice Card */}
        <div
          style={{
            flex: 1.1,
            background: THEME.glassCard,
            border: `1px solid ${THEME.glassBorder}`,
            borderRadius: 24,
            padding: 32,
            backdropFilter: 'blur(20px)',
            boxShadow: '0 20px 40px rgba(0,0,0,0.4)',
            transform: `scale(${invoiceEntrance})`,
          }}
        >
          <div style={{ display: 'flex', justifyContent: 'space-between', borderBottom: '1px solid rgba(255,255,255,0.1)', paddingBottom: 16 }}>
            <div>
              <div style={{ fontSize: 22, fontWeight: 800 }}>Invoice #BK-202611-9482</div>
              <div style={{ fontSize: 14, color: '#94a3b8' }}>Service: AC Master Servicing</div>
            </div>
            <div style={{ padding: '4px 12px', background: 'rgba(16, 185, 129, 0.2)', color: THEME.emerald, borderRadius: 12, fontWeight: 700, fontSize: 13, height: 'fit-content' }}>
              ITEMIZED BREAKDOWN
            </div>
          </div>

          <div style={{ margin: '20px 0', display: 'flex', flexDirection: 'column', gap: 14 }}>
            {/* Line 1: Labor */}
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <div>
                <div style={{ fontSize: 18, fontWeight: 700 }}>Labor (সার্ভিস মজুরি)</div>
                <div style={{ fontSize: 13, color: '#94a3b8' }}>Standard master jet wash & check</div>
              </div>
              <div style={{ fontSize: 20, fontWeight: 800, color: '#f0fdf4' }}>৳600</div>
            </div>

            {/* Line 2: Parts */}
            <div
              style={{
                display: 'flex',
                justifyContent: 'space-between',
                alignItems: 'center',
                padding: '12px 14px',
                background: 'rgba(6, 78, 59, 0.4)',
                borderRadius: 14,
                border: '1px solid rgba(52, 211, 153, 0.2)',
              }}
            >
              <div>
                <div style={{ fontSize: 18, fontWeight: 700, color: '#fef08a', display: 'flex', alignItems: 'center', gap: 8 }}>
                  <span>Capacitor 45uF (পার্টস)</span>
                  <span style={{ fontSize: 11, background: '#10b981', color: '#022c22', padding: '2px 6px', borderRadius: 6, fontWeight: 800 }}>
                    AI Market-Price Verified
                  </span>
                </div>
                <div style={{ fontSize: 13, color: '#a7f3d0' }}>Original Daikin compatible • 0% commission</div>
              </div>
              <div style={{ fontSize: 20, fontWeight: 800, color: '#fef08a' }}>৳450</div>
            </div>

            {/* Total */}
            <div
              style={{
                display: 'flex',
                justifyContent: 'space-between',
                alignItems: 'center',
                borderTop: '2px dashed rgba(255,255,255,0.2)',
                paddingTop: 16,
                marginTop: 6,
              }}
            >
              <div style={{ fontSize: 22, fontWeight: 800 }}>Total Payable (মোট প্রদেয়)</div>
              <div style={{ fontSize: 32, fontWeight: 900, color: THEME.emerald }}>৳1,050</div>
            </div>
          </div>

          {/* Approve Button */}
          <button
            type="button"
            style={{
              width: '100%',
              padding: '16px',
              background: localFrame >= 70 ? '#059669' : 'linear-gradient(135deg, #10b981 0%, #059669 100%)',
              border: 'none',
              borderRadius: 14,
              color: '#ffffff',
              fontSize: 20,
              fontWeight: 800,
              boxShadow: '0 8px 25px rgba(16, 185, 129, 0.5)',
              transform: `scale(${approveClick})`,
              cursor: 'pointer',
            }}
          >
            {localFrame >= 70 ? '✓ Approved & Paid / অনুমোদিত হয়েছে' : 'Approve & Pay / অনুমোদন করুন'}
          </button>
        </div>

        {/* Glowing 7-Day Warranty Shield */}
        <div
          style={{
            flex: 0.9,
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            textAlign: 'center',
            transform: `scale(${warrantyEntrance})`,
            opacity: warrantyEntrance,
          }}
        >
          {/* Shield Icon Graphic */}
          <div
            style={{
              width: 170,
              height: 190,
              background: 'linear-gradient(145deg, rgba(16, 185, 129, 0.3) 0%, rgba(6, 78, 59, 0.8) 100%)',
              border: `3px solid ${THEME.emerald}`,
              borderRadius: '24px 24px 90px 90px',
              display: 'flex',
              flexDirection: 'column',
              alignItems: 'center',
              justifyContent: 'center',
              boxShadow: '0 0 50px rgba(16, 185, 129, 0.6), inset 0 0 30px rgba(52, 211, 153, 0.3)',
              marginBottom: 20,
            }}
          >
            <span style={{ fontSize: 56 }}>🛡️</span>
            <div style={{ fontSize: 32, fontWeight: 900, color: '#f0fdf4', marginTop: 4 }}>
              7 DAYS
            </div>
            <div style={{ fontSize: 13, color: THEME.textSecondary, fontWeight: 700 }}>
              WARRANTY
            </div>
          </div>

          <div style={{ fontSize: 26, fontWeight: 800, color: '#ffffff' }}>
            ৭ দিনের সার্ভিস গ্যারান্টি
          </div>
          <div style={{ fontSize: 18, color: THEME.textSecondary, marginTop: 6 }}>
            Free revisit if the problem persists
          </div>

          {/* Brand Signature Pill */}
          <div
            style={{
              marginTop: 20,
              padding: '8px 20px',
              background: 'rgba(255,255,255,0.08)',
              borderRadius: 30,
              border: '1px solid rgba(255,255,255,0.15)',
              fontSize: 14,
              color: '#94a3b8',
            }}
          >
            Find Skilled People • দক্ষ মানুষ খুঁজি
          </div>
        </div>
      </div>
    </AbsoluteFill>
  );
};

// --- MAIN 4-SCENE EXPLAINER COMPOSITION ---
export const PlatformExplainerVideo: React.FC = () => {
  return (
    <AbsoluteFill
      style={{
        background: THEME.bgGradient,
        overflow: 'hidden',
      }}
    >
      {/* Background Aurora Glow Accents */}
      <div
        style={{
          position: 'absolute',
          top: -100,
          left: '20%',
          width: 600,
          height: 600,
          borderRadius: '50%',
          background: 'radial-gradient(circle, rgba(16, 185, 129, 0.25) 0%, transparent 70%)',
          filter: 'blur(60px)',
          pointerEvents: 'none',
        }}
      />
      <div
        style={{
          position: 'absolute',
          bottom: -150,
          right: '15%',
          width: 700,
          height: 700,
          borderRadius: '50%',
          background: 'radial-gradient(circle, rgba(20, 184, 166, 0.2) 0%, transparent 70%)',
          filter: 'blur(80px)',
          pointerEvents: 'none',
        }}
      />

      {/* 4 Programmatic Video Sequences */}
      <Sequence from={0} durationInFrames={150}>
        <Scene1DualPersona />
      </Sequence>

      <Sequence from={150} durationInFrames={150}>
        <Scene2AiIntake />
      </Sequence>

      <Sequence from={300} durationInFrames={150}>
        <Scene3RadarOtp />
      </Sequence>

      <Sequence from={450} durationInFrames={150}>
        <Scene4BillingWarranty />
      </Sequence>
    </AbsoluteFill>
  );
};

