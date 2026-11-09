import { Link, useSearchParams } from 'react-router-dom';
import { ArrowUpRight, Plus, Check, ShieldCheck, FileText } from 'lucide-react';
import { categories, money } from '@kaarigor/shared/catalog';
import { useApp } from '../state/AppState';
export function Services() {
  const { L, lang, add, cart, setCartOpen } = useApp();
  const [params, setParams] = useSearchParams();
  const id = params.get('category') || 'all';
  const chosen = categories.find((c) => c.id === id);
  return (
    <section className="wrap services-page">
      <div className="page-intro">
        <span className="eyebrow">{L('EVERYDAY EXPERTISE', 'প্রতিদিনের দক্ষ সহায়তা')}</span>
        <h1>{chosen ? chosen.name[lang] : L('What needs doing?', 'কোন কাজটি করতে চান?')}</h1>
        <p>
          {chosen
            ? chosen.note[lang]
            : L(
                'Little fixes. Bigger projects. The people who know how.',
                'ছোট মেরামত কিংবা বড় কাজ। পাশে আছে দক্ষ মানুষ।',
              )}
        </p>
      </div>
      <div className="category-tabs">
        <button className={id === 'all' ? 'pill active' : 'pill'} onClick={() => setParams({})}>
          {L('Everything', 'সব সেবা')}
        </button>
        {categories.map((c) => (
          <button
            className={id === c.id ? 'pill active' : 'pill'}
            key={c.id}
            onClick={() => setParams({ category: c.id })}
          >
            {c.name[lang]}
          </button>
        ))}
      </div>
      {id === 'legal' && (
        <div className="legal-explainer">
          <FileText size={30} />
          <div>
            <h3>
              {L('Someone to help you navigate the paperwork.', 'কাগজপত্রের কাজে একজন সহায়ক।')}
            </h3>
            <p>
              {L(
                'Certified copy collection and administrative errands. Court companions provide logistical support; legal advice and representation require a licensed lawyer. Official charges are separate.',
                'সার্টিফায়েড কপি সংগ্রহ ও প্রশাসনিক সহায়তা। আদালত সহায়ক যাতায়াত ও নথির কাজে সহায়তা করেন; আইনি পরামর্শ ও প্রতিনিধিত্বের জন্য আইনজীবী প্রয়োজন। সরকারি ফি আলাদা।',
              )}
            </p>
            <div className="milestones">
              {[
                L('Requested', 'অনুরোধ'),
                L('Verified', 'যাচাই'),
                L('Attending', 'উপস্থিতি'),
                L('Filed', 'দাখিল'),
              ].map((s, i) => (
                <span key={s}>
                  <i>{i + 1}</i>
                  {s}
                </span>
              ))}
            </div>
          </div>
        </div>
      )}
      <div className="services-grid">
        {categories
          .filter((c) => id === 'all' || c.id === id)
          .map((c) => (
            <article className="service-category" key={c.id}>
              <div className="service-banner" style={{ background: c.color }}>
                <div>
                  <span className="eyebrow">{L('GOOD HANDS, NEAR YOU', 'কাছেই দক্ষ সহায়তা')}</span>
                  <h2>{c.name[lang]}</h2>
                </div>
                <img src={c.avatarImage || `/assets/avatars/${c.avatar}.jpg`} alt="" />
              </div>
              <p>{c.note[lang]}</p>
              {c.tasks.map((t) => (
                <div className="service-task" key={t.id}>
                  <div>
                    <b>{t.name[lang]}</b>
                    <small>
                      {money(t.price, lang)} · {L('labour', 'শ্রমমূল্য')}
                    </small>
                  </div>
                  <button
                    className="icon-btn"
                    disabled={cart.some((l) => l.taskId === t.id)}
                    onClick={() => add(t.id)}
                    aria-label={L(`Add ${t.name.en}`, `${t.name.bn} যোগ করুন`)}
                  >
                    {cart.some((l) => l.taskId === t.id) ? <Check size={17} /> : <Plus size={17} />}
                  </button>
                </div>
              ))}
              <Link className="text-link" to={`/discover?category=${c.id}`}>
                {L('Find a professional', 'দক্ষ কর্মী খুঁজুন')}
                <ArrowUpRight size={16} />
              </Link>
            </article>
          ))}
      </div>
      <div className="catalog-bottom">
        <ShieldCheck size={24} />
        <p>
          {L(
            'Sample labour rates are shown upfront. Replacement parts and official fees are quoted separately, with your approval.',
            'নমুনা শ্রমমূল্য আগেই দেখানো হয়েছে। যন্ত্রাংশ ও সরকারি ফি আপনার অনুমোদন সাপেক্ষে আলাদা জানানো হবে।',
          )}
        </p>
        <button className="btn" disabled={!cart.length} onClick={() => setCartOpen(true)}>
          {L('Review service bag', 'সার্ভিস ব্যাগ দেখুন')}
        </button>
      </div>
    </section>
  );
}
