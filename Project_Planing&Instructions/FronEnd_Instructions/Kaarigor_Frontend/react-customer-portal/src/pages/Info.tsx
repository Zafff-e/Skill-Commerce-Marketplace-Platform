import { Link, useLocation } from 'react-router-dom';
import { ArrowRight } from 'lucide-react';
import { useApp } from '../state/AppState';
export function Info() {
  const { L } = useApp();
  const policy = useLocation().pathname === '/policies';
  return (
    <section className="wrap prose-page">
      <span className="eyebrow">KAARIGOR</span>
      <h1>
        {policy
          ? L('Your trust matters.', 'আপনার আস্থাই গুরুত্বপূর্ণ।')
          : L('Good help, simply.', 'সহজ পথে দক্ষ সহায়তা।')}
      </h1>
      {policy ? (
        <>
          <h2>{L('About this preview', 'এই প্রিভিউ সম্পর্কে')}</h2>
          <p>
            {L(
              'This is an interactive frontend demonstration. All professionals, reviews, availability and prices are illustrative. It does not create real accounts, dispatch workers, perform identity verification or collect payments.',
              'এটি ইন্টারঅ্যাকটিভ ফ্রন্টএন্ড ডেমো। কর্মী, রিভিউ, সময় ও মূল্য নমুনা। বাস্তব অ্যাকাউন্ট, কর্মী প্রেরণ, পরিচয় যাচাই বা অর্থ গ্রহণ হয় না।',
            )}
          </p>
          <h2>{L('What stays in your browser', 'ব্রাউজারে যে তথ্য থাকে')}</h2>
          <p>
            {L(
              'Your language, theme and service bag are stored on this device. Demo bookings, addresses, document selections and signup form values stay in memory only and clear on reload. Credentials and identity documents are never written to local storage.',
              'ভাষা, থিম ও সার্ভিস ব্যাগ এই ডিভাইসে থাকে। ডেমো বুকিং, ঠিকানা, নথি ও নিবন্ধনের তথ্য সাময়িক মেমরিতে থাকে এবং রিলোডে মুছে যায়। পাসওয়ার্ড ও পরিচয়পত্র লোকাল স্টোরেজে রাখা হয় না।',
            )}
          </p>
          <h2>{L('Before a public launch', 'প্রকাশের আগে')}</h2>
          <p>
            {L(
              'Production privacy notices, service terms, retention periods, verification policies and payment/refund rules must be approved by the operator before real data is collected. The checkboxes in the demo acknowledge the preview only.',
              'বাস্তব তথ্য সংগ্রহের আগে পরিচালনাকারীকে গোপনীয়তা নীতি, সেবার শর্ত, তথ্য সংরক্ষণকাল, যাচাই ও পেমেন্ট/রিফান্ড নীতি অনুমোদন করতে হবে। ডেমোর চেকবক্স শুধু প্রিভিউ বোঝায়।',
            )}
          </p>
        </>
      ) : (
        <>
          {[
            [
              L('01 · Choose the job', '০১ · কাজ বেছে নিন'),
              L(
                'Browse fixed tasks, add the work you need, and select a neighbourhood by tapping the map.',
                'কাজ বেছে ব্যাগে যোগ করুন এবং ম্যাপে এলাকা নির্বাচন করুন।',
              ),
            ],
            [
              L('02 · Choose the person', '০২ · দক্ষ কর্মী বেছে নিন'),
              L(
                'Review a professional’s skills and task prices. For multiple trades, choose automatic assignment for each trade.',
                'দক্ষতা ও কাজের মূল্য দেখুন। বিভিন্ন পেশার কাজ হলে প্রতিটি পেশায় স্বয়ংক্রিয় নির্বাচন করুন।',
              ),
            ],
            [
              L('03 · Choose the time', '০৩ · সময় বেছে নিন'),
              L(
                'Review the labour cost, optional urgency fee and service details. Parts and official charges are separate and need approval.',
                'শ্রমমূল্য, ঐচ্ছিক জরুরি ফি ও কাজের বিবরণ দেখুন। যন্ত্রাংশ ও সরকারি ফি আলাদা এবং অনুমোদন প্রয়োজন।',
              ),
            ],
            [
              L('04 · Follow the progress', '০৪ · অগ্রগতি জানুন'),
              L(
                'Track the request in My bookings. In production, later steps come from the assigned worker and booking server.',
                'আমার বুকিং থেকে অনুরোধ দেখুন। বাস্তব ব্যবস্থায় পরবর্তী ধাপ কর্মী ও বুকিং সার্ভার থেকে আসবে।',
              ),
            ],
          ].map(([title, body]) => (
            <div key={title}>
              <h2>{title}</h2>
              <p>{body}</p>
            </div>
          ))}
          <Link className="btn" to="/discover">
            {L('Find your helping hand', 'দক্ষ সহায়তা খুঁজুন')}
            <ArrowRight size={17} />
          </Link>
        </>
      )}
    </section>
  );
}
export function NotFound() {
  const { L } = useApp();
  return (
    <section className="wrap empty inner-page">
      <h1>404</h1>
      <h3>{L('This path doesn’t lead home.', 'এই পৃষ্ঠাটি পাওয়া যায়নি।')}</h3>
      <Link className="btn" to="/">
        {L('Back to home', 'হোমে ফিরুন')}
      </Link>
    </section>
  );
}
