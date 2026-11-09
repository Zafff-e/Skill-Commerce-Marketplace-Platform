import { providerUrl } from '../provider';
import { Link, useNavigate } from 'react-router-dom';
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
} from 'lucide-react';
import { useRef, useState } from 'react';
import { categories, zones } from '@kaarigor/shared/catalog';
import { useApp } from '../state/AppState';
export function Home() {
  const { L, lang, zone, setZone } = useApp();
  const [category, setCategory] = useState('electrician');
  const navigate = useNavigate(),
    dock = useRef<HTMLDivElement>(null);
  return (
    <>
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
              src="/assets/electrician.svg"
              alt={L('Illustration of a skilled electrician', 'একজন দক্ষ ইলেকট্রিশিয়ানের চিত্র')}
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
                <img src={`/assets/${c.avatar}.svg`} alt="" loading="lazy" />
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
              <div className="court-art" aria-hidden="true">
                <svg viewBox="0 0 200 140">
                  <path
                    d="m20 45 80-35 80 35Zm12 12h136M25 127h150M15 137h170M42 62v60m35-60v60m45-60v60m35-60v60"
                    fill="none"
                    stroke="currentColor"
                    strokeWidth="3"
                  />
                  <path d="M100 23v12m-6-6h12" stroke="currentColor" strokeWidth="2" />
                </svg>
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
              <img src="/assets/care.svg" alt="" loading="lazy" />
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
