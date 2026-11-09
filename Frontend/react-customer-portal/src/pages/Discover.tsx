import { useSearchParams, Link } from 'react-router-dom';
import { useMemo, useState } from 'react';
import {
  Heart,
  Star,
  ShieldCheck,
  ArrowRight,
  MapPin,
  SlidersHorizontal,
  List,
  Map as MapIcon,
  Check,
} from 'lucide-react';
import { categories, zones, demoPros, money, type Pro } from '@kaarigor/shared/catalog';
import { useApp } from '../state/AppState';
import { AreaMap } from '../components/AreaMap';
import { Dialog } from '../components/Dialog';
export function Discover() {
  const { L, lang, zone, setZone, saved, save, add, setSelectedPro, setCartOpen, cart } = useApp();
  const [params, setParams] = useSearchParams();
  const catId = params.get('category') || 'electrician';
  const currentZone = params.get('zone') || zone;
  const category = categories.find((c) => c.id === catId) || categories[0];
  const [available, setAvailable] = useState(false),
    [sort, setSort] = useState('recommended'),
    [view, setView] = useState('split'),
    [profile, setProfile] = useState<Pro>();
  const onlySaved = params.get('saved') === 'true';
  const pros = useMemo(
    () =>
      demoPros
        .filter(
          (p) =>
            p.categoryId === category.id &&
            p.zoneId === currentZone &&
            (!available || p.available) &&
            (!onlySaved || saved.includes(p.id)),
        )
        .sort((a, b) =>
          sort === 'rating'
            ? b.rating - a.rating
            : sort === 'experience'
              ? b.years - a.years
              : Number(b.available) - Number(a.available),
        ),
    [category.id, currentZone, available, sort, onlySaved, saved],
  );
  const changeZone = (id: string) => {
    setZone(id);
    setParams((p) => {
      p.set('zone', id);
      return p;
    });
  };
  return (
    <section className="wrap discovery-page">
      <div className="page-intro">
        <span className="eyebrow">
          {L('GOOD HELP IS AROUND THE CORNER', 'কাছেই আছে দক্ষ সহায়তা')}
        </span>
        <h1>{L('Find your person.', 'আপনার দক্ষ মানুষ খুঁজুন।')}</h1>
        <p>
          {L(
            'Choose the work. Pick your neighbourhood. Meet the people who can help.',
            'কাজ ও এলাকা বেছে নিন। সহায়তাকারী দক্ষ মানুষের সঙ্গে পরিচিত হোন।',
          )}
        </p>
      </div>
      <div className="discover-toolbar">
        <label>
          <span>{L('I’m looking for', 'যে সেবা প্রয়োজন')}</span>
          <select
            value={category.id}
            onChange={(e) =>
              setParams((p) => {
                p.set('category', e.target.value);
                return p;
              })
            }
          >
            {categories.map((c) => (
              <option key={c.id} value={c.id}>
                {c.name[lang]}
              </option>
            ))}
          </select>
        </label>
        <label>
          <span>{L('Around', 'এলাকা')}</span>
          <select value={currentZone} onChange={(e) => changeZone(e.target.value)}>
            {zones.map((z) => (
              <option key={z.id} value={z.id}>
                {z.name[lang]}
              </option>
            ))}
          </select>
        </label>
        <div className="toolbar-options">
          <button
            className={available ? 'pill filter active' : 'pill filter'}
            onClick={() => setAvailable(!available)}
            aria-pressed={available}
          >
            <i className="live-dot" />
            {L('Available today', 'আজ সময় আছে')}
          </button>
          <Link
            className={onlySaved ? 'pill filter active' : 'pill filter'}
            to={
              onlySaved
                ? `/discover?category=${category.id}&zone=${currentZone}`
                : `/discover?category=${category.id}&zone=${currentZone}&saved=true`
            }
          >
            <Heart size={13} />
            {L('Saved', 'পছন্দের')}
          </Link>
        </div>
        <div className="view-toggle">
          <button
            onClick={() => setView('list')}
            aria-label={L('List view', 'তালিকা')}
            aria-pressed={view === 'list'}
          >
            <List size={19} />
          </button>
          <button
            onClick={() => setView('split')}
            aria-label={L('Map and list view', 'ম্যাপ ও তালিকা')}
            aria-pressed={view === 'split'}
          >
            <MapIcon size={19} />
          </button>
        </div>
      </div>
      <div className={view === 'split' ? 'discovery-grid' : 'discovery-grid list-only'}>
        <div className="result-side">
          <div className="results-heading">
            <div>
              <b>
                {pros.length} {L('sample professionals', 'নমুনা দক্ষ কর্মী')}
              </b>
              <small>{zones.find((z) => z.id === currentZone)?.name[lang]}</small>
            </div>
            <label className="sort">
              <SlidersHorizontal size={15} />
              <select
                aria-label={L('Sort results', 'ফলাফল সাজান')}
                value={sort}
                onChange={(e) => setSort(e.target.value)}
              >
                <option value="recommended">{L('Recommended', 'প্রস্তাবিত')}</option>
                <option value="rating">{L('Top rated', 'সর্বোচ্চ রেটিং')}</option>
                <option value="experience">{L('Most experienced', 'সর্বাধিক অভিজ্ঞ')}</option>
              </select>
            </label>
          </div>
          <div className="pro-list">
            {pros.map((pro) => (
              <article className="pro-card" key={pro.id}>
                <div className="pro-portrait" style={{ background: category.color }}>
                  <img src={pro.avatarImage || `/assets/avatars/${pro.avatar}.jpg`} alt="" />
                  <span className={pro.available ? 'availability available' : 'availability'}>
                    {pro.available ? L('Today', 'আজ') : L('Tomorrow', 'আগামীকাল')}
                  </span>
                </div>
                <div className="pro-details">
                  <div className="pro-name">
                    <button onClick={() => setProfile(pro)}>
                      {lang === 'en' ? pro.name : pro.bn}
                    </button>
                    <button
                      className="save-btn"
                      aria-label={
                        saved.includes(pro.id)
                          ? L('Unsave professional', 'পছন্দ থেকে সরান')
                          : L('Save professional', 'পছন্দের তালিকায় রাখুন')
                      }
                      onClick={() => save(pro.id)}
                    >
                      <Heart size={19} fill={saved.includes(pro.id) ? 'var(--orange)' : 'none'} />
                    </button>
                  </div>
                  <span className="pro-trade">
                    {category.name[lang]} · {pro.years} {L('years’ experience', 'বছরের অভিজ্ঞতা')}
                  </span>
                  <div className="pro-meta">
                    <Star size={13} fill="#c49a4f" stroke="#c49a4f" />
                    <b>{pro.rating.toFixed(1)}</b>
                    <span>
                      ({pro.jobs} {L('sample jobs', 'নমুনা কাজ')})
                    </span>
                    <span className="verification">
                      <ShieldCheck size={13} />
                      {L('Demo credential', 'ডেমো পরিচয়')}
                    </span>
                  </div>
                  <div className="pro-bottom">
                    <span>
                      <small>{L('Labour from', 'শ্রমমূল্য শুরু')}</small>
                      <b>{money(category.tasks[0].price, lang)}</b>
                    </span>
                    <button className="btn small secondary" onClick={() => setProfile(pro)}>
                      {L('View & book', 'দেখুন ও বুক করুন')}
                      <ArrowRight size={15} />
                    </button>
                  </div>
                </div>
              </article>
            ))}
            {!pros.length && (
              <div className="empty">
                <h3>{L('No matches in this view.', 'এই ফিল্টারে কেউ নেই।')}</h3>
                <p className="muted">
                  {L(
                    'Try another area, or clear your filters.',
                    'অন্য এলাকা বেছে নিন বা ফিল্টার সরান।',
                  )}
                </p>
                <button
                  className="btn secondary"
                  onClick={() => {
                    setAvailable(false);
                    setParams({ category: category.id, zone: currentZone });
                  }}
                >
                  {L('Clear filters', 'ফিল্টার সরান')}
                </button>
              </div>
            )}
          </div>
          <div className="notice">
            {L(
              'These are illustrative profiles and sample prices. Verification badges and availability here do not represent real people.',
              'এগুলো নমুনা প্রোফাইল ও মূল্য। যাচাই ও সময়ের তথ্য বাস্তব ব্যক্তির নয়।',
            )}
          </div>
        </div>
        {view === 'split' && (
          <AreaMap value={currentZone} onChange={changeZone} pros={pros} onPro={setProfile} />
        )}
      </div>
      {profile && (
        <Dialog
          title={lang === 'en' ? profile.name : profile.bn}
          onClose={() => setProfile(undefined)}
        >
          <div className="profile-head">
            <img
              src={profile.avatarImage || `/assets/avatars/${profile.avatar}.jpg`}
              alt=""
              style={{ background: category.color }}
            />
            <div>
              <span className="eyebrow">{L('SAMPLE PROFESSIONAL', 'নমুনা দক্ষ কর্মী')}</span>
              <h3>{category.name[lang]}</h3>
              <p>
                {zones.find((z) => z.id === profile.zoneId)?.name[lang]} · {profile.years}{' '}
                {L('years of experience', 'বছরের অভিজ্ঞতা')}
              </p>
              <span className="pill">
                <Star size={13} />
                {profile.rating.toFixed(1)} · {L('Illustrative rating', 'নমুনা রেটিং')}
              </span>
            </div>
          </div>
          <h3>{L('Choose the work you need', 'যে কাজ প্রয়োজন বেছে নিন')}</h3>
          <div className="task-list">
            {category.tasks.map((task) => (
              <div className="task-row" key={task.id}>
                <div>
                  <b>{task.name[lang]}</b>
                  <small>
                    {L('Labour only · parts at cost', 'শুধু শ্রম · যন্ত্রাংশ প্রকৃত মূল্যে')}
                  </small>
                </div>
                <b>{money(task.price, lang)}</b>
                <button
                  className="btn secondary small"
                  disabled={cart.some((l) => l.taskId === task.id)}
                  onClick={() => add(task.id)}
                >
                  {cart.some((l) => l.taskId === task.id) ? (
                    <Check size={16} />
                  ) : (
                    L('Add', 'যোগ করুন')
                  )}
                </button>
              </div>
            ))}
          </div>
          <button
            className="btn full"
            disabled={!cart.some((line) => category.tasks.some((t) => t.id === line.taskId))}
            onClick={() => {
              setSelectedPro(profile);
              setProfile(undefined);
              setCartOpen(true);
            }}
          >
            {L('Continue with this professional', 'এই দক্ষ কর্মীর সঙ্গে এগিয়ে যান')}
            <ArrowRight size={17} />
          </button>
        </Dialog>
      )}
    </section>
  );
}
