import { useState } from 'react';
import { X, ArrowUpRight, MessageCircle } from 'lucide-react';
import { Link } from 'react-router-dom';
import { useApp } from '../state/AppState';
export function Assistant() {
  const { L } = useApp();
  const [open, setOpen] = useState(false),
    [text, setText] = useState(''),
    [answer, setAnswer] = useState('');
  const suggestions = [
    { en: 'My AC is dripping', bn: 'এসি থেকে পানি পড়ছে', category: 'ac' },
    { en: 'I need a certified copy', bn: 'সার্টিফায়েড কপি প্রয়োজন', category: 'legal' },
    { en: 'A tap is leaking', bn: 'কলের পানি পড়ছে', category: 'plumber' },
  ];
  function match(value: string) {
    setText(value);
    const q = value.toLowerCase();
    setAnswer(
      /court|copy|case|মামলা|কপি|আদালত/.test(q)
        ? 'legal'
        : /ac|cool|এসি/.test(q)
          ? 'ac'
          : /tap|leak|pipe|কল|পানি|পাইপ/.test(q)
            ? 'plumber'
            : /clean|পরিষ্কার/.test(q)
              ? 'cleaner'
              : 'electrician',
    );
  }
  return (
    <div className="assistant">
      {open && (
        <section
          className="assistant-panel"
          aria-label={L('Jontu service helper', 'যন্তু সার্ভিস সহায়ক')}
        >
          <header>
            <div
              className="robot mini"
              data-mood={text ? 'listening' : 'greeting'}
              aria-hidden="true"
            >
              <i />
              <b>••</b>
              <em />
            </div>
            <div>
              <b>{L('A little help from Jontu', 'যন্তুর একটু সহায়তা')}</b>
              <small>
                {L('Offline service guide · not live AI', 'অফলাইন সেবা নির্দেশিকা · লাইভ এআই নয়')}
              </small>
            </div>
            <button
              className="icon-btn"
              aria-label={L('Close helper', 'সহায়ক বন্ধ করুন')}
              onClick={() => setOpen(false)}
            >
              <X size={16} />
            </button>
          </header>
          <div className="assistant-content">
            <p>
              {L(
                'What’s on your to-do list? Pick a problem, and I’ll point you in the right direction.',
                'কোন কাজে সহায়তা প্রয়োজন? সমস্যা বেছে নিন, সঠিক সেবা খুঁজে দেব।',
              )}
            </p>
            {suggestions.map((s) => (
              <button
                key={s.category}
                className="assistant-suggestion"
                onClick={() => match(L(s.en, s.bn))}
              >
                {L(s.en, s.bn)}
                <ArrowUpRight size={14} />
              </button>
            ))}
            <form
              onSubmit={(e) => {
                e.preventDefault();
                if (text.trim()) match(text);
              }}
            >
              <label>
                {L('Or describe it', 'অথবা সমস্যাটি লিখুন')}
                <input value={text} onChange={(e) => setText(e.target.value)} maxLength={300} />
              </label>
              <button className="btn small" disabled={!text.trim()}>
                {L('Suggest a service', 'সেবা খুঁজে দিন')}
              </button>
            </form>
            {answer && (
              <div className="notice" role="status">
                {L(
                  'This category could help. Check the task details before booking.',
                  'এই সেবাটি কাজে আসতে পারে। বুকিংয়ের আগে কাজের বিবরণ দেখুন।',
                )}
                <Link
                  to={`/services?category=${answer}`}
                  className="text-link"
                  onClick={() => setOpen(false)}
                >
                  {L('Explore suggested service', 'প্রস্তাবিত সেবা দেখুন')}
                  <ArrowUpRight size={14} />
                </Link>
              </div>
            )}
          </div>
        </section>
      )}
      <button
        className="assistant-trigger"
        onClick={() => setOpen(!open)}
        aria-expanded={open}
        aria-label={L('Ask Jontu for service help', 'যন্তুর কাছে সহায়তা চান')}
      >
        <div className="robot" data-mood="idle" aria-hidden="true">
          <i />
          <b>••</b>
          <em />
        </div>
        <span>{L('Need a hand?', 'সহায়তা চান?')}</span>
        {open ? <X size={17} /> : <MessageCircle size={17} />}
      </button>
    </div>
  );
}
