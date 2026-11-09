import { providerUrl } from '../provider';
import { Link, useNavigate } from 'react-router-dom';
import { HeroVideoCard } from '../components/video/HeroVideoCard';
import {
  ArrowRight,
  ArrowUpRight,
  MapPin,
  Check,
  ShieldCheck,
  MoveUpRight,
  ChevronLeft,
  ChevronRight,
  Clock3,
  FileCheck2,
  HeartHandshake,
  PackageCheck,
  Search,
  Play,
  Images,
  Video,
} from 'lucide-react';
import { useRef, useState } from 'react';
import { categories, zones } from '@kaarigor/shared/catalog';
import { useApp } from '../state/AppState';

const showcaseGallery = [
  {
    src: '/assets/avatars/electrician.jpg',
    title: { en: 'Expert Electricians', bn: 'দক্ষ ইলেকট্রিশিয়ান' },
    desc: { en: 'Safe home wiring & appliances', bn: 'নিরাপদ ওয়্যারিং ও হোম অ্যাপ্লায়েন্স' },
  },
  {
    src: '/assets/avatars/plumber.jpg',
    title: { en: 'Certified Plumbers', bn: 'অভিজ্ঞ প্লাম্বার' },
    desc: { en: 'Piping & sanitation solutions', bn: 'পাইপ ও স্যানিটেশন সমাধান' },
  },
  {
    src: '/assets/avatars/court-companion.jpg',
    title: { en: 'Court Companions', bn: 'আদালত সহায়ক' },
    desc: { en: 'Paperwork & procedural support', bn: 'কাগজপত্র ও পদ্ধতিগত সহায়তা' },
  },
  {
    src: '/assets/avatars/care.jpg',
    title: { en: 'Caregivers & Healthcare Escorts', bn: 'স্বাস্থ্যসেবা ও হাসপাতাল সহায়ক' },
    desc: { en: 'Patient accompaniment & support', bn: 'রোগী সেবা ও হাসপাতালে সঙ্গ' },
  },
  {
    src: '/assets/avatars/carpenter.jpg',
    title: { en: 'Master Carpenters', bn: 'দক্ষ কাঠমিস্ত্রি' },
    desc: { en: 'Furniture assembly & woodcraft', bn: 'আসবাবপত্র তৈরি ও মেরামত' },
  },
];

export function Home() {
  const { L, lang, zone, setZone } = useApp();
  const [category, setCategory] = useState('electrician');
  const [activePhoto, setActivePhoto] = useState(0);
  const [isPlayingVideo, setIsPlayingVideo] = useState(false);
  const navigate = useNavigate(),
    dock = useRef<HTMLDivElement>(null);
  return (
    <>
      {/* Top-of-Page Hero Video Playing Card (Programmatic Remotion Explainer) */}
      <section className="hero-explainer-section wrap" style={{ paddingTop: '24px', paddingBottom: '12px' }}>
        <HeroVideoCard lang={lang} />
      </section>

      {/* Showcase Twin Cards: Left PhotoCard & Right VideoCard */}
      <section className="showcase-twin-section wrap">
        <div className="showcase-twin-grid">
          {/* LEFT: PhotoCard */}
          <div className="showcase-card photocard">
            <div className="showcase-card-header">
              <div>
                <span className="showcase-badge-pill">
                  <Images size={13} />
                  {L('Photo Showcase', 'ছবিতে আমাদের দক্ষ মানুষ')}
                </span>
                <h3>{L('Verified Skilled Professionals', 'যাচাইকৃত দক্ষ পেশাজীবী')}</h3>
                <p>
                  {L(
                    'Explore trusted faces serving your community across Dhaka.',
                    'ঢাকাজুড়ে আপনার এলাকায় সেবায় নিয়োজিত নির্ভরযোগ্য মুখগুলো দেখুন।',
                  )}
                </p>
              </div>
            </div>
            <div className="showcase-card-body">
              <div className="photocard-featured">
                <img
                  src={showcaseGallery[activePhoto].src}
                  alt={showcaseGallery[activePhoto].title[lang]}
                />
                <div className="photocard-overlay">
                  <div className="photocard-caption-title">
                    {showcaseGallery[activePhoto].title[lang]}
                  </div>
                  <div className="photocard-caption-sub">
                    {showcaseGallery[activePhoto].desc[lang]}
                  </div>
                </div>
              </div>
              <div className="photocard-thumbs" role="tablist" aria-label="Photo thumbnails">
                {showcaseGallery.map((item, idx) => (
                  <button
                    key={idx}
                    type="button"
                    className={`photocard-thumb-btn ${activePhoto === idx ? 'active' : ''}`}
                    onClick={() => setActivePhoto(idx)}
                    aria-label={item.title[lang]}
                  >
                    <img src={item.src} alt="" />
                  </button>
                ))}
              </div>
            </div>
          </div>

          {/* RIGHT: VideoCard */}
          <div className="showcase-card videocard">
            <div className="showcase-card-header">
              <div>
                <span className="showcase-badge-pill video">
                  <Video size={13} />
                  {L('Platform Overview', 'প্ল্যাটফর্ম পরিচিতি ভিডিও')}
                </span>
                <h3>{L('How It Works', 'কীভাবে কাজ করে')}</h3>
                <p>
                  {L(
                    'Quick guide on local booking, transparent pricing & service.',
                    'সহজ বুকিং, স্পষ্ট মূল্য ও সেবা গ্রহণের সম্পূর্ণ প্রক্রিয়া দেখুন।',
                  )}
                </p>
              </div>
            </div>
            <div className="showcase-card-body">
              <div className="videocard-screen">
                {isPlayingVideo ? (
                  <iframe
                    title="How It Works"
                    src="https://www.youtube.com/embed/dQw4w9WgXcQ?autoplay=1"
                    allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                    allowFullScreen
                  />
                ) : (
                  <div
                    className="videocard-poster"
                    onClick={() => setIsPlayingVideo(true)}
                    role="button"
                    tabIndex={0}
                    aria-label={L('Play platform walkthrough video', 'ভিডিও চালু করুন')}
                    onKeyDown={(e) => {
                      if (e.key === 'Enter' || e.key === ' ') setIsPlayingVideo(true);
                    }}
                  >
                    <img src="/assets/ai-chatbot.jpg" alt={L('Kaarigor video preview', 'ভিডিও প্রিভিউ')} />
                    <span className="videocard-badge-live">
                      <span className="live-dot" />
                      {L('Platform Walkthrough Video', 'ভিডিও ডিরেক্টরি')}
                    </span>
                    <div className="videocard-play-btn">
                      <Play size={20} fill="currentColor" />
                    </div>
                  </div>
                )}
              </div>
              <div className="videocard-features">
                <div className="videocard-feature-item">
                  <b>{L('1. Select Task', '১. সেবা নির্বাচন')}</b>
                  <small>{L('Transparent rates', 'স্পষ্ট মূল্যতালিকা')}</small>
                </div>
                <div className="videocard-feature-item">
                  <b>{L('2. Nearby Match', '২. কাছের দক্ষ মানুষ')}</b>
                  <small>{L('Local verification', 'বিশ্বস্ত যাচাই')}</small>
                </div>
                <div className="videocard-feature-item">
                  <b>{L('3. Job Done', '৩. নিশ্চিত সমাধান')}</b>
                  <small>{L('Pay upon delight', 'কাজের পর পরিশোধ')}</small>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      <section className="home-hero wrap">
        <div className="hero-main">
          <div className="eyebrow">
            {L('YOUR NEIGHBOURHOOD. YOUR PEOPLE.', 'আপনার এলাকা। আপনার মানুষ।')}
          </div>
          <h1>
            {L('Good help.', 'দক্ষ সহায়তা।')}
            <br />
            <em>{L('Closer to home.', 'আপনার কাছেই।')}</em>
          </h1>
          <p className="hero-copy">
            {L(
              'From a dripping tap to a day at court, find the right skilled person for the things that matter.',
              'কলের লিক থেকে আদালতের কাজ—প্রয়োজনীয় প্রতিটি কাজে সঠিক দক্ষ মানুষ খুঁজে নিন।',
            )}
          </p>
          <form
            className="hero-search"
            onSubmit={(e) => {
              e.preventDefault();
              navigate(`/discover?category=${category}&zone=${zone}`);
            }}
          >
            <label>
              <span>
                <Search size={14} />
                {L('What do you need?', 'কোন সেবা প্রয়োজন?')}
              </span>
              <select value={category} onChange={(e) => setCategory(e.target.value)}>
                {categories.map((c) => (
                  <option value={c.id} key={c.id}>
                    {c.name[lang]}
                  </option>
                ))}
              </select>
            </label>
            <label>
              <span>
                <MapPin size={14} />
                {L('Your neighbourhood', 'আপনার এলাকা')}
              </span>
              <select value={zone} onChange={(e) => setZone(e.target.value)}>
                {zones.map((z) => (
                  <option value={z.id} key={z.id}>
                    {z.name[lang]}
                  </option>
                ))}
              </select>
            </label>
            <button className="btn" type="submit" aria-label={L('Find a pro', 'দক্ষ লোক খুঁজুন')}>
              <ArrowRight size={22} />
            </button>
          </form>
          <div className="hero-reassurance">
            <span>
              <ShieldCheck size={15} />
              {L('Know who’s coming', 'কে আসছেন জেনে নিন')}
            </span>
            <span>
              <Check size={15} />
              {L('See prices first', 'আগেই মূল্য জানুন')}
            </span>
            <span>
              <Clock3 size={15} />
              {L('Choose your time', 'সময় বেছে নিন')}
            </span>
          </div>
          <img className="hero-landscape" src="/assets/landscape.svg" alt="" aria-hidden="true" />
          <span className="hero-caption">
            {L('A little peace of mind, delivered.', 'একটু নিশ্চিন্ত থাকার ব্যবস্থা।')}
          </span>
        </div>
        <aside className="join-card">
          <div className="eyebrow">{L('GOOD AT WHAT YOU DO?', 'নিজের কাজে দক্ষ?')}</div>
          <h2>
            {L('Your skills.', 'আপনার দক্ষতা।')}
            <br />
            {L('Your next chapter.', 'নতুন পথচলা।')}
          </h2>
          <p>
            {L(
              'Meet customers nearby. Build a name doing what you do best.',
              'কাছের গ্রাহকদের সঙ্গে যুক্ত হোন। নিজের দক্ষতায় পরিচিতি গড়ুন।',
            )}
          </p>
          <a href={providerUrl()} className="btn white">
            {L('Join as a professional', 'দক্ষ কর্মী হিসেবে যোগ দিন')}
            <ArrowUpRight size={18} />
          </a>
          <div className="join-portrait">
            <div className="portrait-halo" />
            <img
              src="/assets/avatars/electrician.jpg"
              alt={L('Portrait of a skilled electrician', 'একজন দক্ষ ইলেকট্রিশিয়ানের ছবি')}
            />
            <div className="floating-note">
              <ShieldCheck size={17} />
              <div>
                <b>{L('Let your work speak.', 'আপনার কাজই পরিচয়।')}</b>
                <small>
                  {L('Register. Get verified. Get discovered.', 'নিবন্ধন। যাচাই। পরিচিতি।')}
                </small>
              </div>
            </div>
            <span className="portrait-scribble">
              {L('Made of skill.', 'দক্ষতায় গড়া।')}
              <br />
              {L('Built on trust.', 'আস্থায় ভরা।')}
            </span>
          </div>
        </aside>
      </section>

      <section className="trust-strip wrap">
        <span>{L('A better way to get things done', 'কাজ সম্পন্ন করার সহজ পথ')}</span>
        <div>
          <ShieldCheck size={19} />
          {L('Credential checks', 'পরিচয় ও যোগ্যতা যাচাই')}
        </div>
        <div>
          <FileCheck2 size={19} />
          {L('Clear task pricing', 'কাজের স্পষ্ট মূল্য')}
        </div>
        <div>
          <HeartHandshake size={19} />
          {L('People, not listings', 'মানুষের সঙ্গে সংযোগ')}
        </div>
      </section>
      <section className="section wrap" id="trades">
        <div className="section-heading">
          <div>
            <span className="eyebrow">{L('A PERSON FOR EVERY JOB', 'প্রতিটি কাজে দক্ষ একজন')}</span>
            <h2>{L('Who can lend a hand?', 'কোন কাজে সহায়তা চান?')}</h2>
          </div>
          <div className="dock-controls">
            <button
              className="icon-btn"
              aria-label={L('Previous trades', 'আগের পেশা')}
              onClick={() => dock.current?.scrollBy({ left: -400, behavior: 'smooth' })}
            >
              <ChevronLeft size={18} />
            </button>
            <button
              className="icon-btn"
              aria-label={L('Next trades', 'পরের পেশা')}
              onClick={() => dock.current?.scrollBy({ left: 400, behavior: 'smooth' })}
            >
              <ChevronRight size={18} />
            </button>
          </div>
        </div>
        <div className="avatar-dock" ref={dock}>
          {categories.slice(0, 8).map((c, i) => (
            <Link to={`/discover?category=${c.id}`} key={c.id} className="trade-card">
              <div className="avatar-frame" style={{ background: c.color }}>
                <img src={c.avatarImage || `/assets/avatars/${c.avatar}.jpg`} alt="" loading="lazy" />
                <span className="trade-arrow">
                  <MoveUpRight size={17} />
                </span>
              </div>
              <h3>{c.name[lang]}</h3>
              <span>{L('Explore services', 'সেবাসমূহ দেখুন')}</span>
              <small>0{i + 1}</small>
            </Link>
          ))}
        </div>
        <div className="section-bottom">
          <span>{L('Different skills. The same care.', 'নানা দক্ষতা। একই যত্ন।')}</span>
          <Link to="/services" className="text-link">
            {L('See every service', 'সব সেবা দেখুন')}
            <ArrowRight size={16} />
          </Link>
        </div>
      </section>
      <section className="special-section">
        <div className="wrap section">
          <div className="section-heading">
            <div>
              <span className="eyebrow">{L('BEYOND THE TOOLBOX', 'চেনা সেবার বাইরেও')}</span>
              <h2>{L('Life happens. We help.', 'প্রতিদিনের জীবনে, পাশে।')}</h2>
            </div>
            <p>
              {L(
                'For the days you need more than a repair. Thoughtful help for life’s less ordinary tasks.',
                'শুধু মেরামত নয়। জীবনের বিশেষ প্রয়োজনে চিন্তাশীল সহায়তা।',
              )}
            </p>
          </div>
          <div className="special-grid">
            <Link className="special-card court" to="/services?category=legal">
              <div className="special-top">
                <span className="pill">{L('COURT COMPANION', 'আদালত সহায়ক')}</span>
                <ArrowUpRight size={24} />
              </div>
              <h3>
                {L('The paperwork.', 'কাগজপত্রের কাজ।')}
                <br />
                <em>{L('Without the running around.', 'দৌড়ঝাঁপ ছাড়াই।')}</em>
              </h3>
              <p>
                {L(
                  'Certified copies, case status & court errands, with progress you can follow.',
                  'সার্টিফায়েড কপি, মামলার অবস্থা ও আদালতের কাজে ধাপে ধাপে অগ্রগতি জানুন।',
                )}
              </p>
              <div className="court-art" aria-hidden="true" style={{ overflow: 'hidden', borderRadius: '12px' }}>
                <img
                  src="/assets/avatars/court-companion.jpg"
                  alt=""
                  style={{ width: '100%', height: '140px', objectFit: 'cover', opacity: 0.85 }}
                />
              </div>
              <span className="text-link">
                {L('Meet your court companion', 'আদালত সহায়ক খুঁজুন')}
                <ArrowRight size={16} />
              </span>
            </Link>
            <Link className="special-card care" to="/services?category=care">
              <div className="special-top">
                <HeartHandshake size={26} />
                <ArrowUpRight size={22} />
              </div>
              <h3>
                {L('A little company.', 'পাশে একজন।')}
                <br />
                {L('A lot of comfort.', 'অনেকটা স্বস্তি।')}
              </h3>
              <p>
                {L(
                  'A companion for hospital visits and appointments.',
                  'হাসপাতাল ও অ্যাপয়েন্টমেন্টে সহায়তার জন্য একজন সঙ্গী।',
                )}
              </p>
              <img src="/assets/avatars/hospital-escort.jpg" alt="" loading="lazy" />
              <span className="pill">{L('HOSPITAL HELP', 'হাসপাতাল সহায়তা')}</span>
            </Link>
            <Link className="special-card errands" to="/services?category=errand">
              <div className="special-top">
                <PackageCheck size={26} />
                <ArrowUpRight size={22} />
              </div>
              <h3>
                {L('Your to-do list.', 'আপনার কাজের তালিকা।')}
                <br />
                {L('A little shorter.', 'হোক একটু ছোট।')}
              </h3>
              <p>
                {L(
                  'Document collection and everyday errands, taken care of.',
                  'নথি সংগ্রহ ও দৈনন্দিন ছোট কাজে সহায়তা।',
                )}
              </p>
              <img src="/assets/avatars/office-errands.jpg" alt="" loading="lazy" />
              <span className="pill">{L('EVERYDAY ERRANDS', 'দৈনন্দিন সহায়তা')}</span>
            </Link>
          </div>
        </div>
      </section>
      <section className="section wrap how-band">
        <div>
          <span className="eyebrow">{L('THREE SMALL STEPS', 'সহজ তিন ধাপ')}</span>
          <h2>
            {L('From “who do I call?”', '“কাকে ডাকব?” থেকে')}
            <br />
            <em>{L('to “all sorted.”', '“কাজ হয়ে গেছে।”')}</em>
          </h2>
          <Link to="/how-it-works" className="text-link">
            {L('A closer look', 'বিস্তারিত জানুন')}
            <ArrowRight size={17} />
          </Link>
        </div>
        <ol>
          {[
            [
              L('Tell us what you need', 'প্রয়োজন জানান'),
              L('Choose a service and tap your neighbourhood.', 'সেবা ও এলাকা বেছে নিন।'),
            ],
            [
              L('Find your kind of expert', 'আপনার বিশেষজ্ঞ খুঁজুন'),
              L(
                'Compare skills, credentials and clear task prices.',
                'দক্ষতা, পরিচয় ও কাজের মূল্য দেখুন।',
              ),
            ],
            [
              L('Make room for peace of mind', 'নিশ্চিন্ত থাকুন'),
              L(
                'Choose a time. Follow the progress. Pay after the job.',
                'সময় বেছে নিন। অগ্রগতি জানুন। কাজ শেষে মূল্য দিন।',
              ),
            ],
          ].map(([title, note], i) => (
            <li key={i}>
              <span>0{i + 1}</span>
              <div>
                <h3>{title}</h3>
                <p>{note}</p>
              </div>
            </li>
          ))}
        </ol>
      </section>
    </>
  );
}
