import { providerUrl } from '../provider';
import { useState } from 'react';
import { Link } from 'react-router-dom';
import { ArrowRight, Eye, EyeOff, ShieldCheck } from 'lucide-react';
import { useApp } from '../state/AppState';
export function Account() {
  const { L } = useApp();
  const [register, setRegister] = useState(false),
    [visible, setVisible] = useState(false),
    [message, setMessage] = useState('');
  return (
    <section className="wrap account-page">
      <div className="account-story">
        <span className="eyebrow">
          {L('WELCOME TO YOUR NEIGHBOURHOOD', 'আপনার এলাকায় স্বাগতম')}
        </span>
        <h1>
          {L('A familiar face.', 'চেনা একজন।')}
          <br />
          <em>{L('A helping hand.', 'সহায়তার হাত।')}</em>
        </h1>
        <p>
          {L(
            'Keep your favourite professionals and everyday services a little closer.',
            'পছন্দের দক্ষ মানুষ ও প্রয়োজনীয় সেবাকে রাখুন হাতের কাছে।',
          )}
        </p>
        <img src="/assets/landscape.svg" alt="" />
      </div>
      <form
        className="account-form stack"
        onSubmit={(e) => {
          e.preventDefault();
          setMessage(
            L(
              'This is a design demo. Account creation and sign-in require your authentication API. No credentials have been sent or stored.',
              'এটি ডিজাইন ডেমো। অ্যাকাউন্ট তৈরি ও সাইন ইনের জন্য অথেনটিকেশন এপিআই প্রয়োজন। কোনো পরিচয় তথ্য পাঠানো বা সংরক্ষণ করা হয়নি।',
            ),
          );
        }}
      >
        <span className="eyebrow">{L('CUSTOMER ACCOUNT', 'গ্রাহক অ্যাকাউন্ট')}</span>
        <h2>
          {register
            ? L('Make yourself at home.', 'নিবন্ধন করুন।')
            : L('Good to see you.', 'স্বাগতম।')}
        </h2>
        {register && (
          <label>
            {L('Full name', 'পূর্ণ নাম')}
            <input autoComplete="name" required maxLength={100} />
          </label>
        )}
        <label>
          {L('Email address', 'ইমেইল')}
          <input type="email" autoComplete="email" required />
        </label>
        <label>
          {L('Password', 'পাসওয়ার্ড')}
          <div className="password-field">
            <input
              type={visible ? 'text' : 'password'}
              required
              minLength={8}
              autoComplete={register ? 'new-password' : 'current-password'}
            />
            <button
              type="button"
              onClick={() => setVisible(!visible)}
              aria-label={L(
                visible ? 'Hide password' : 'Show password',
                'পাসওয়ার্ড দেখুন বা লুকান',
              )}
            >
              {visible ? <EyeOff size={17} /> : <Eye size={17} />}
            </button>
          </div>
        </label>
        {message && (
          <div role="status" className="notice">
            {message}
          </div>
        )}
        <button className="btn full">
          {register
            ? L('Preview account creation', 'অ্যাকাউন্ট তৈরি প্রিভিউ')
            : L('Preview sign in', 'সাইন ইন প্রিভিউ')}
          <ArrowRight size={17} />
        </button>
        <button
          type="button"
          className="text-link"
          onClick={() => {
            setRegister(!register);
            setMessage('');
          }}
        >
          {register
            ? L('Already have an account? Sign in', 'অ্যাকাউন্ট আছে? সাইন ইন করুন')
            : L('New here? Create an account', 'নতুন? অ্যাকাউন্ট তৈরি করুন')}
        </button>
        <div className="rule" />
        <div className="notice">
          <ShieldCheck size={16} />{' '}
          {L('Here to offer your skills?', 'দক্ষ কর্মী হিসেবে যোগ দিতে চান?')}
          <a href={providerUrl()} className="text-link">
            {L('Join as a professional', 'দক্ষ কর্মী হিসেবে নিবন্ধন')}
            <ArrowRight size={16} />
          </a>
        </div>
        <Link to="/policies" className="muted">
          {L('Privacy & terms', 'গোপনীয়তা ও শর্তাবলি')}
        </Link>
      </form>
    </section>
  );
}
