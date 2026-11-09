import { providerUrl } from '../provider';
import { Link, NavLink, Outlet, useLocation } from 'react-router-dom';
import { ArrowUpRight, ShoppingBag, Sun, Moon, Menu, MapPin, ArrowUp } from 'lucide-react';
import { useEffect, useState } from 'react';
import { useApp } from '../state/AppState';
import { Cart } from './Cart';
import { Assistant } from './Assistant';
export function Shell() {
  const { L, lang, setLang, theme, setTheme, cart, setCartOpen, toast } = useApp();
  const [menu, setMenu] = useState(false);
  const location = useLocation();
  useEffect(() => {
    setMenu(false);
    window.scrollTo({ top: 0, behavior: 'instant' });
  }, [location.pathname]);
  useEffect(() => {
    const h = () => (document.documentElement.dataset.paused = String(document.hidden));
    document.addEventListener('visibilitychange', h);
    return () => document.removeEventListener('visibilitychange', h);
  }, []);
  return (
    <>
      <a
        className="skip-link"
        href="#/"
        onClick={(e) => {
          e.preventDefault();
          document.getElementById('main')?.focus();
        }}
      >
        {L('Skip to content', 'মূল অংশে যান')}
      </a>
      <div className="topline">
        <span>
          <MapPin size={12} />
          {L('Made for your neighbourhood. Starting in Dhaka.', 'আপনার এলাকার জন্য। শুরু ঢাকায়।')}
        </span>
        <span>
          {L(
            'Interactive demo · sample people & prices',
            'ইন্টারঅ্যাকটিভ ডেমো · নমুনা ব্যক্তি ও মূল্য',
          )}
        </span>
      </div>
      <header className="navbar">
        <div className="silk" aria-hidden="true" />
        <Link className="brand" to="/" aria-label="Kaarigor home">
          <span className="brand-mark">k</span>kaarigor<span className="brand-dot">.</span>
        </Link>
        <nav
          className={menu ? 'nav-links open' : 'nav-links'}
          aria-label={L('Main navigation', 'প্রধান মেনু')}
        >
          <NavLink to="/" end>
            {L('Home', 'হোম')}
          </NavLink>
          <NavLink to="/discover">{L('Find a pro', 'দক্ষ লোক খুঁজুন')}</NavLink>
          <NavLink to="/services">{L('Our services', 'সেবাসমূহ')}</NavLink>
          <NavLink to="/bookings">{L('My bookings', 'আমার বুকিং')}</NavLink>
          <button
            className="mobile-theme"
            onClick={() =>
              setTheme(theme === 'light' ? 'dark' : theme === 'dark' ? 'auto' : 'light')
            }
          >
            {L('Change theme', 'থিম পরিবর্তন')} · {theme}
          </button>
        </nav>
        <div className="nav-actions">
          <button
            onClick={() => setLang(lang === 'en' ? 'bn' : 'en')}
            className="language"
            aria-label={L('Switch to Bengali', 'ইংরেজি করুন')}
          >
            {lang === 'en' ? 'বাংলা' : 'EN'}
          </button>
          <button
            className="nav-theme"
            onClick={() =>
              setTheme(theme === 'light' ? 'dark' : theme === 'dark' ? 'auto' : 'light')
            }
            title={L(`Theme: ${theme}. Click to change.`, 'থিম পরিবর্তন করুন')}
            aria-label={L(`Theme: ${theme}`, 'থিম পরিবর্তন')}
          >
            {theme === 'dark' ? <Moon size={17} /> : <Sun size={17} />}
          </button>
          <button
            className="bag-btn"
            onClick={() => setCartOpen(true)}
            aria-label={L('Open service bag', 'সার্ভিস ব্যাগ খুলুন')}
          >
            <ShoppingBag size={20} />
            {cart.length > 0 && <span>{cart.reduce((s, l) => s + l.quantity, 0)}</span>}
          </button>
          <Link to="/account" className="nav-login">
            {L('Sign in', 'সাইন ইন')}
            <ArrowUpRight size={14} />
          </Link>
          <button
            className="mobile-menu"
            onClick={() => setMenu(!menu)}
            aria-label={L('Toggle menu', 'মেনু খুলুন')}
            aria-expanded={menu}
          >
            <Menu size={21} />
          </button>
        </div>
      </header>
      <main id="main" tabIndex={-1}>
        <Outlet />
      </main>
      <footer>
        <div className="footer-top">
          <div>
            <Link className="brand" to="/">
              <span className="brand-mark">k</span>kaarigor.
            </Link>
            <p>
              {L('Good people. Great work.', 'দক্ষ মানুষ। সুন্দর কাজ।')}
              <br />
              {L('A little closer to home.', 'আপনার বাড়ির আরও কাছে।')}
            </p>
          </div>
          <div>
            <h4>{L('Find your help', 'সেবা খুঁজুন')}</h4>
            <Link to="/discover">{L('Explore neighbourhoods', 'এলাকা দেখুন')}</Link>
            <Link to="/services">{L('All services', 'সকল সেবা')}</Link>
            <Link to="/services?category=legal">
              {L('Court & everyday errands', 'আদালত ও দৈনন্দিন সহায়তা')}
            </Link>
          </div>
          <div>
            <h4>{L('Build your business', 'আপনার কাজ বাড়ান')}</h4>
            <a href={providerUrl()}>{L('Become a Kaarigor', 'কারিগর হিসেবে যোগ দিন')}</a>
            <a href={providerUrl('dashboard')}>{L('Provider workspace', 'কারিগরের কর্মক্ষেত্র')}</a>
            <Link to="/how-it-works">{L('How it works', 'যেভাবে কাজ করে')}</Link>
          </div>
          <div className="footer-note">
            <span className="eyebrow">{L('LOCAL BY HEART', 'হৃদয়ে বাংলাদেশ')}</span>
            <p>
              {L(
                'For the people who make everyday life work.',
                'যাঁরা দৈনন্দিন জীবনকে সহজ করেন, তাঁদের জন্য।',
              )}
            </p>
            <button
              className="icon-btn"
              aria-label={L('Back to top', 'উপরে যান')}
              onClick={() => window.scrollTo({ top: 0, behavior: 'smooth' })}
            >
              <ArrowUp size={18} />
            </button>
          </div>
        </div>
        <div className="footer-bottom">
          <span>© {new Date().getFullYear()} Kaarigor</span>
          <span>
            {L(
              'Design preview. No real bookings or payments.',
              'ডিজাইন প্রিভিউ। বাস্তব বুকিং বা পেমেন্ট নয়।',
            )}
          </span>
          <Link to="/policies">{L('Privacy & terms', 'গোপনীয়তা ও শর্তাবলি')}</Link>
        </div>
      </footer>
      <Cart />
      <Assistant />
      {toast && (
        <div className="toast" role="status">
          {toast}
        </div>
      )}
    </>
  );
}
