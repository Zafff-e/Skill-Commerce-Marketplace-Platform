import { Link } from 'react-router-dom';
import { ArrowRight, CheckCircle2, Clock3 } from 'lucide-react';
import { allTasks, zones, money } from '@kaarigor/shared/catalog';
import { useApp } from '../state/AppState';
export function Bookings() {
  const { bookings, L, lang } = useApp();
  return (
    <section className="wrap inner-page">
      <div className="page-intro">
        <span className="eyebrow">
          {L('A LITTLE PEACE OF MIND', 'একটু নিশ্চিন্ত থাকার ব্যবস্থা')}
        </span>
        <h1>{L('Your bookings.', 'আপনার বুকিং।')}</h1>
        <p>
          {L(
            'Your sample requests from this session. No real professionals are dispatched.',
            'এই সেশনের নমুনা অনুরোধ। কোনো বাস্তব কর্মী পাঠানো হবে না।',
          )}
        </p>
      </div>
      {!bookings.length ? (
        <div className="empty empty-card">
          <Clock3 size={36} />
          <h3>{L('Your next helping hand starts here.', 'পরবর্তী সহায়তার শুরু এখানেই।')}</h3>
          <p className="muted">
            {L('You haven’t created a sample request yet.', 'এখনও কোনো নমুনা অনুরোধ তৈরি করেননি।')}
          </p>
          <Link className="btn" to="/services">
            {L('Find a service', 'সেবা খুঁজুন')}
            <ArrowRight size={17} />
          </Link>
        </div>
      ) : (
        <div className="booking-list">
          {bookings.map((b) => (
            <article key={b.id} className="booking-card">
              <div className="booking-card-top">
                <span className="eyebrow">{b.id}</span>
                <span className="badge">{L('Demo · requested', 'ডেমো · অনুরোধ')}</span>
              </div>
              <h3>
                {b.lines
                  .map(
                    (l) => `${allTasks.find((t) => t.id === l.taskId)?.name[lang]} × ${l.quantity}`,
                  )
                  .join(' · ')}
              </h3>
              <p className="muted">
                {zones.find((z) => z.id === b.zone)?.name[lang]} ·{' '}
                {b.pro
                  ? lang === 'bn'
                    ? b.pro.bn
                    : b.pro.name
                  : L('Automatic assignment', 'স্বয়ংক্রিয় নির্বাচন')}{' '}
                · {money(b.total, lang)}
              </p>
              <div className="milestones">
                {(b.legal
                  ? [
                      L('Requested', 'অনুরোধ'),
                      L('Verified', 'যাচাই'),
                      L('Attending', 'উপস্থিতি'),
                      L('Filed', 'দাখিল'),
                    ]
                  : [
                      L('Requested', 'অনুরোধ'),
                      L('Accepted', 'গৃহীত'),
                      L('On the way', 'পথে'),
                      L('Completed', 'সম্পন্ন'),
                    ]
                ).map((s, i) => (
                  <span key={s} className={i === 0 ? 'active' : ''}>
                    <i>{i === 0 ? <CheckCircle2 size={16} /> : i + 1}</i>
                    {s}
                  </span>
                ))}
              </div>
              <div className="notice">
                {L(
                  'Only “Requested” is recorded. Later steps require a connected provider and booking API. Your request clears when this page session is reloaded.',
                  'শুধু “অনুরোধ” ধাপ নথিভুক্ত হয়েছে। পরবর্তী ধাপের জন্য সংযুক্ত বুকিং এপিআই প্রয়োজন। পেজ রিলোড করলে অনুরোধ মুছে যাবে।',
                )}
              </div>
            </article>
          ))}
        </div>
      )}
    </section>
  );
}
