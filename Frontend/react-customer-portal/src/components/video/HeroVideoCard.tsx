import React, { useRef, useState, useEffect } from 'react';
import { Player, PlayerRef } from '@remotion/player';
import { PlatformExplainerVideo } from './PlatformExplainerVideo';
import {
  Play,
  Pause,
  RotateCcw,
  Volume2,
  VolumeX,
  Maximize2,
  Minimize2,
  Sparkles,
  CheckCircle2,
} from 'lucide-react';

interface SceneInfo {
  id: number;
  frame: number;
  title: { en: string; bn: string };
  desc: { en: string; bn: string };
  spokenBn: string;
}

const SCENES: SceneInfo[] = [
  {
    id: 1,
    frame: 0,
    title: { en: '1. Dual Role Entry', bn: '১. ভূমিকা নির্বাচন' },
    desc: { en: 'Choose Customer or Technician', bn: 'সেবাগ্রহীতা বা কারিগর নির্বাচন' },
    spokenBn: 'আসসালামু আলাইকুম। দক্ষ লোক খুঁজি বা কারিগর প্ল্যাটফর্মে আপনাকে স্বাগতম। আপনি সেবা নিতে পারেন অথবা দক্ষ কারিগর হিসেবে কাজ করতে পারেন।',
  },
  {
    id: 2,
    frame: 150,
    title: { en: '2. Voice & Photo AI', bn: '২. ভয়েস ও ফটো AI' },
    desc: { en: 'Speak or upload diagnostic photo', bn: 'ভয়েস বা ছবি দিয়ে সমস্যা চিহ্নিতকরণ' },
    spokenBn: 'আপনার সমস্যা বাংলায় বলুন অথবা ছবি তুলুন। আমাদের কৃত্রিম বুদ্ধিমত্তা তাৎক্ষণিক সমস্যা শনাক্ত করে সঠিক টেকনিশিয়ান খুঁজে দেবে।',
  },
  {
    id: 3,
    frame: 300,
    title: { en: '3. Radar & Secure OTP', bn: '৩. রাডার ও নিরাপদ OTP' },
    desc: { en: 'Live geo match with OTP handshake', bn: 'নিকটস্থ কারিগর ও ওটিপি ভেরিফিকেশন' },
    spokenBn: 'লাইভ রাডারে আপনার নিকটস্থ যাচাইকৃত কারিগর মুহূর্তেই পৌঁছে যাবে। কাজ শুরুর পূর্বে নিরাপদ ওটিপি কোড মিলিয়ে নিশ্চিত হন।',
  },
  {
    id: 4,
    frame: 450,
    title: { en: '4. Transparent Warranty', bn: '৪. স্বচ্ছ বিল ও গ্যারান্টি' },
    desc: { en: 'Itemized parts & 7-day guarantee', bn: 'স্বচ্ছ বিলিং ও ৭ দিনের ওয়ারেন্টি' },
    spokenBn: 'মজুরি ও পার্টসের স্বচ্ছ হিসাব দেখুন। কোন লুকানো চার্জ নেই এবং প্রতি সেবায় পাচ্ছেন ৭ দিনের নির্ভরযোগ্য সার্ভিস গ্যারান্টি।',
  },
];

interface HeroVideoCardProps {
  lang?: 'en' | 'bn';
}

export const HeroVideoCard: React.FC<HeroVideoCardProps> = ({ lang = 'bn' }) => {
  const playerRef = useRef<PlayerRef>(null);
  const [isPlaying, setIsPlaying] = useState(true);
  const [currentSceneIdx, setCurrentSceneIdx] = useState(0);
  const [isVoiceOverEnabled, setIsVoiceOverEnabled] = useState(false);
  const [isCinemaMode, setIsCinemaMode] = useState(false);

  // Synchronize Scene state with Player frame
  useEffect(() => {
    const interval = setInterval(() => {
      if (playerRef.current) {
        const frame = playerRef.current.getCurrentFrame();
        if (frame !== null) {
          if (frame < 150) setCurrentSceneIdx(0);
          else if (frame < 300) setCurrentSceneIdx(1);
          else if (frame < 450) setCurrentSceneIdx(2);
          else setCurrentSceneIdx(3);
        }
      }
    }, 250);
    return () => clearInterval(interval);
  }, []);

  // Web Speech API Voiceover Trigger synced with current scene
  useEffect(() => {
    if (!isVoiceOverEnabled || !('speechSynthesis' in window)) return;

    window.speechSynthesis.cancel();
    const scene = SCENES[currentSceneIdx];
    const utterance = new SpeechSynthesisUtterance(scene.spokenBn);
    utterance.lang = 'bn-BD';
    utterance.rate = 1.0;
    utterance.pitch = 1.05;

    // Fallback voice search
    const voices = window.speechSynthesis.getVoices();
    const bnVoice = voices.find((v) => v.lang.startsWith('bn'));
    if (bnVoice) utterance.voice = bnVoice;

    window.speechSynthesis.speak(utterance);

    return () => {
      if ('speechSynthesis' in window) {
        window.speechSynthesis.cancel();
      }
    };
  }, [currentSceneIdx, isVoiceOverEnabled]);

  const handleTogglePlay = () => {
    if (!playerRef.current) return;
    if (isPlaying) {
      playerRef.current.pause();
      setIsPlaying(false);
      if ('speechSynthesis' in window) window.speechSynthesis.cancel();
    } else {
      playerRef.current.play();
      setIsPlaying(true);
    }
  };

  const handleSeekScene = (frame: number, idx: number) => {
    if (!playerRef.current) return;
    playerRef.current.seekTo(frame);
    setCurrentSceneIdx(idx);
    if (!isPlaying) {
      playerRef.current.play();
      setIsPlaying(true);
    }
  };

  const handleRestart = () => {
    if (!playerRef.current) return;
    playerRef.current.seekTo(0);
    setCurrentSceneIdx(0);
    playerRef.current.play();
    setIsPlaying(true);
  };

  const toggleVoiceOver = () => {
    if (!('speechSynthesis' in window)) {
      alert('Speech synthesis is not supported in this browser.');
      return;
    }
    const nextState = !isVoiceOverEnabled;
    setIsVoiceOverEnabled(nextState);
    if (!nextState) {
      window.speechSynthesis.cancel();
    }
  };

  return (
    <div
      className={`hero-video-card-container ${isCinemaMode ? 'cinema-expanded' : ''}`}
      style={{
        width: '100%',
        maxWidth: isCinemaMode ? '1400px' : '100%',
        margin: '0 auto 36px auto',
        borderRadius: 28,
        background: 'rgba(6, 40, 32, 0.65)',
        border: '1px solid rgba(52, 211, 153, 0.35)',
        backdropFilter: 'blur(24px)',
        boxShadow: '0 20px 60px rgba(0, 0, 0, 0.45), 0 0 40px rgba(16, 185, 129, 0.15)',
        overflow: 'hidden',
        position: 'relative',
        transition: 'all 0.35s ease-in-out',
      }}
    >
      {/* Top Glass Header */}
      <div
        style={{
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: 'center',
          padding: '16px 24px',
          borderBottom: '1px solid rgba(52, 211, 153, 0.2)',
          background: 'rgba(2, 44, 34, 0.7)',
        }}
      >
        <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
          <div
            style={{
              padding: '6px 12px',
              borderRadius: 20,
              background: 'rgba(16, 185, 129, 0.2)',
              border: '1px solid #10b981',
              display: 'flex',
              alignItems: 'center',
              gap: 6,
              color: '#34d399',
              fontSize: 13,
              fontWeight: 800,
            }}
          >
            <Sparkles size={14} />
            {lang === 'bn' ? 'কীভাবে কাজ করে (ভিডিও গাইড)' : 'HOW IT WORKS'}
          </div>
          <span style={{ fontSize: 14, color: '#94a3b8' }}>
            {lang === 'bn' ? '৪-ধাপের নির্দেশিকা' : '4-Step Interactive Explainer'}
          </span>
        </div>

        {/* Header Action Tools */}
        <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
          {/* Voiceover Bangla Narration Button */}
          <button
            type="button"
            onClick={toggleVoiceOver}
            style={{
              padding: '6px 14px',
              borderRadius: 20,
              background: isVoiceOverEnabled
                ? 'linear-gradient(135deg, #10b981 0%, #059669 100%)'
                : 'rgba(255, 255, 255, 0.08)',
              border: `1px solid ${isVoiceOverEnabled ? '#34d399' : 'rgba(255, 255, 255, 0.18)'}`,
              color: isVoiceOverEnabled ? '#022c22' : '#ecfdf5',
              fontSize: 13,
              fontWeight: 700,
              display: 'flex',
              alignItems: 'center',
              gap: 8,
              cursor: 'pointer',
              transition: 'all 0.2s',
            }}
            title={lang === 'bn' ? 'ভয়েসওভার চালু/বন্ধ করুন' : 'Toggle Voiceover Narration'}
          >
            {isVoiceOverEnabled ? <Volume2 size={15} /> : <VolumeX size={15} />}
            <span>{isVoiceOverEnabled ? (lang === 'bn' ? '🔊 ভয়েস সক্রিয়' : '🔊 Voice On') : (lang === 'bn' ? '🔈 বাংলায় শুনুন' : '🔈 Listen')}</span>
          </button>

          {/* Cinema Expand Toggle */}
          <button
            type="button"
            onClick={() => setIsCinemaMode(!isCinemaMode)}
            style={{
              padding: '6px 12px',
              borderRadius: 14,
              background: 'rgba(255, 255, 255, 0.08)',
              border: '1px solid rgba(255, 255, 255, 0.15)',
              color: '#ecfdf5',
              cursor: 'pointer',
              display: 'flex',
              alignItems: 'center',
            }}
            title={isCinemaMode ? 'Standard View' : 'Cinema View'}
          >
            {isCinemaMode ? <Minimize2 size={16} /> : <Maximize2 size={16} />}
          </button>
        </div>
      </div>

      {/* Main Remotion Player Screen */}
      <div style={{ position: 'relative', width: '100%', aspectRatio: '16 / 9', background: '#021814' }}>
        <Player
          ref={playerRef}
          component={PlatformExplainerVideo}
          durationInFrames={600}
          fps={30}
          compositionWidth={1920}
          compositionHeight={1080}
          style={{ width: '100%', height: '100%' }}
          autoPlay
          loop
          controls={false}
        />

        {/* Subtle Watermark Overlay */}
        <div
          style={{
            position: 'absolute',
            bottom: 16,
            right: 20,
            padding: '4px 10px',
            borderRadius: 8,
            background: 'rgba(0, 0, 0, 0.5)',
            color: '#6ee7b7',
            fontSize: 11,
            fontWeight: 700,
            pointerEvents: 'none',
          }}
        >
          FIND SKILLED PEOPLE • DOKKHO MANUSH KHUJI
        </div>
      </div>

      {/* Bottom Interactive Glass Controls & Scene Progress Pills */}
      <div
        style={{
          padding: '16px 20px',
          background: 'rgba(2, 44, 34, 0.85)',
          borderTop: '1px solid rgba(52, 211, 153, 0.2)',
          display: 'flex',
          flexDirection: 'column',
          gap: 12,
        }}
      >
        {/* Step Jump Pills */}
        <div
          style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(4, 1fr)',
            gap: 10,
          }}
        >
          {SCENES.map((scene, idx) => {
            const isActive = currentSceneIdx === idx;
            return (
              <button
                key={scene.id}
                type="button"
                onClick={() => handleSeekScene(scene.frame, idx)}
                style={{
                  padding: '10px 14px',
                  borderRadius: 14,
                  background: isActive
                    ? 'rgba(16, 185, 129, 0.25)'
                    : 'rgba(255, 255, 255, 0.04)',
                  border: isActive
                    ? '2px solid #10b981'
                    : '1px solid rgba(255, 255, 255, 0.1)',
                  boxShadow: isActive ? '0 0 20px rgba(16, 185, 129, 0.4)' : 'none',
                  cursor: 'pointer',
                  textAlign: 'left',
                  display: 'flex',
                  alignItems: 'center',
                  gap: 10,
                  transition: 'all 0.2s',
                }}
              >
                <div
                  style={{
                    width: 22,
                    height: 22,
                    borderRadius: '50%',
                    background: isActive ? '#10b981' : '#334155',
                    color: isActive ? '#022c22' : '#94a3b8',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    fontSize: 12,
                    fontWeight: 900,
                    flexShrink: 0,
                  }}
                >
                  {isActive ? <CheckCircle2 size={14} /> : scene.id}
                </div>
                <div style={{ overflow: 'hidden' }}>
                  <div
                    style={{
                      fontSize: 13,
                      fontWeight: 800,
                      color: isActive ? '#ecfdf5' : '#cbd5e1',
                      whiteSpace: 'nowrap',
                      textOverflow: 'ellipsis',
                    }}
                  >
                    {scene.title[lang]}
                  </div>
                  <div
                    style={{
                      fontSize: 11,
                      color: isActive ? '#a7f3d0' : '#64748b',
                      whiteSpace: 'nowrap',
                      textOverflow: 'ellipsis',
                    }}
                  >
                    {scene.desc[lang]}
                  </div>
                </div>
              </button>
            );
          })}
        </div>

        {/* Playback Buttons & Live Step Bar */}
        <div
          style={{
            display: 'flex',
            justifyContent: 'space-between',
            alignItems: 'center',
            paddingTop: 4,
          }}
        >
          <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
            {/* Play/Pause */}
            <button
              type="button"
              onClick={handleTogglePlay}
              style={{
                width: 36,
                height: 36,
                borderRadius: '50%',
                background: '#10b981',
                border: 'none',
                color: '#022c22',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                cursor: 'pointer',
                boxShadow: '0 4px 15px rgba(16, 185, 129, 0.4)',
              }}
            >
              {isPlaying ? <Pause size={17} fill="currentColor" /> : <Play size={17} fill="currentColor" />}
            </button>

            {/* Restart */}
            <button
              type="button"
              onClick={handleRestart}
              style={{
                width: 36,
                height: 36,
                borderRadius: '50%',
                background: 'rgba(255, 255, 255, 0.08)',
                border: '1px solid rgba(255, 255, 255, 0.15)',
                color: '#ecfdf5',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                cursor: 'pointer',
              }}
              title="Restart Video"
            >
              <RotateCcw size={15} />
            </button>

            <span style={{ fontSize: 13, color: '#94a3b8', marginLeft: 8 }}>
              {isPlaying ? (lang === 'bn' ? 'চলছে' : 'Playing') : (lang === 'bn' ? 'থামানো আছে' : 'Paused')} • 20s Full Cycle
            </span>
          </div>

          <div style={{ fontSize: 13, color: '#34d399', fontWeight: 600 }}>
            {lang === 'bn' ? 'যেকোনো ধাপে ক্লিক করে বিস্তারিত দেখুন' : 'Click any step to inspect stage'}
          </div>
        </div>
      </div>
    </div>
  );
};

