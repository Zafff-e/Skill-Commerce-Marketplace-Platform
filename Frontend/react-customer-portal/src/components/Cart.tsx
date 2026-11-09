import { useState, type FormEvent } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import {
  Minus,
  Plus,
  Trash2,
  ArrowRight,
  ShoppingBag,
  CheckCircle2,
  ShieldCheck,
} from 'lucide-react';
import { allTasks, zones, demoPros, categories, money } from '@kaarigor/shared/catalog';
import { validUpload } from '@kaarigor/shared/booking';
import { useApp } from '../state/AppState';
import { Dialog } from './Dialog';
const tomorrow = () => {
  const d = new Date();
  d.setDate(d.getDate() + 1);
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
};
export function Cart() {
  const app = useApp();
  const {
    L,
    lang,
    cart,
    qty,
    setCart,
    cartOpen,
    setCartOpen,
    summary,
    urgent,
    setUrgent,
    selectedPro,
    setSelectedPro,
    zone,
    setZone,
    setBookings,
  } = app;
  const [stage, setStage] = useState(0),
    [error, setError] = useState(''),
    [done, setDone] = useState(''),
    [document, setDocument] = useState<File>(),
    [date, setDate] = useState(tomorrow),
    [time, setTime] = useState('10:00');
  const navigate = useNavigate();
  if (!cartOpen) return null;
  const categoryIds = [
    ...new Set(cart.map((l) => allTasks.find((t) => t.id === l.taskId)!.categoryId)),
  ];
  const compatiblePro =
    selectedPro &&
    categoryIds.length === 1 &&
    categoryIds[0] === selectedPro.categoryId &&
    selectedPro.zoneId === zone
      ? selectedPro
      : undefined;
  const legal = categoryIds.includes('legal');
  const proOptions =
    categoryIds.length === 1
      ? demoPros.filter((p) => p.categoryId === categoryIds[0] && p.zoneId === zone)
      : [];
  const close = () => {
    setCartOpen(false);
    setStage(0);
    setDone('');
    setError('');
    setDocument(undefined);
  };
  const submit = (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setError('');
    const f = new FormData(e.currentTarget);
    if (!cart.length) {
      setError(L('Add at least one service.', 'অন্তত একটি সেবা যোগ করুন।'));
      return;
    }
    if (new Date(`${date}T${time}`) <= new Date()) {
      setError(L('Choose a future date and time.', 'ভবিষ্যতের তারিখ ও সময় বেছে নিন।'));
      return;
    }
    if (String(f.get('address') || '').trim().length < 8) {
      setError(L('Please enter a complete service address.', 'সেবার পূর্ণ ঠিকানা লিখুন।'));
      return;
    }
    const id = `DEMO-${crypto.randomUUID().slice(0, 8).toUpperCase()}`;
    setBookings((old) => [
      {
        id,
        lines: cart.map((l) => ({ ...l })),
        total: summary.total,
        zone,
        pro: compatiblePro,
        legal,
        createdAt: new Date().toISOString(),
      },
      ...old,
    ]);
    setDone(id);
    setCart([]);
    setSelectedPro(undefined);
    setDocument(undefined);
    setStage(2);
  };
  return (
    <Dialog
      title={
        stage === 2
          ? L('You’re all set.', 'সব প্রস্তুত।')
          : L('Your service bag', 'আপনার সার্ভিস ব্যাগ')
      }
      onClose={close}
      drawer
    >
      {stage === 2 ? (
        <div className="booking-success">
          <CheckCircle2 size={54} />
          <span className="eyebrow">{L('DEMO REQUEST CREATED', 'ডেমো অনুরোধ তৈরি হয়েছে')}</span>
          <h2>
            {L('One less thing', 'আরেকটি কাজ')}
            <br />
            <em>{L('on your mind.', 'চিন্তার বাইরে।')}</em>
          </h2>
          <p>
            {L(
              'Your sample booking is ready to review. No professional has been contacted and no payment has been collected.',
              'আপনার নমুনা বুকিং দেখার জন্য প্রস্তুত। কোনো দক্ষ কর্মীর সঙ্গে যোগাযোগ বা অর্থ গ্রহণ করা হয়নি।',
            )}
          </p>
          <code>{done}</code>
          <button
            className="btn full"
            onClick={() => {
              close();
              navigate('/bookings');
            }}
          >
            {L('See my bookings', 'আমার বুকিং দেখুন')}
            <ArrowRight size={17} />
          </button>
        </div>
      ) : !cart.length ? (
        <div className="empty">
          <ShoppingBag size={38} />
          <h3>{L('A little help starts here.', 'সহায়তার শুরু এখানেই।')}</h3>
          <p>
            {L(
              'Choose a task and we’ll keep it in your bag.',
              'একটি কাজ বেছে নিন, ব্যাগে যোগ হয়ে যাবে।',
            )}
          </p>
          <Link to="/services" onClick={close} className="btn">
            {L('Explore services', 'সেবা দেখুন')}
          </Link>
        </div>
      ) : (
        <>
          <div className="checkout-steps">
            <span className={stage === 0 ? 'active' : ''}>
              01 {L('Your services', 'আপনার সেবা')}
            </span>
            <span className={stage === 1 ? 'active' : ''}>02 {L('The details', 'বিস্তারিত')}</span>
          </div>
          {stage === 0 ? (
            <>
              <div className="cart-lines">
                {cart.map((line) => {
                  const task = allTasks.find((t) => t.id === line.taskId)!,
                    cat = categories.find((c) => c.id === task.categoryId)!;
                  return (
                    <div className="cart-line" key={task.id}>
                      <img
                        src={`/assets/${cat.avatar}.svg`}
                        alt=""
                        style={{ background: cat.color }}
                      />
                      <div>
                        <b>{task.name[lang]}</b>
                        <small>
                          {money(task.price, lang)} · {L('per task', 'প্রতি কাজ')}
                        </small>
                        <div className="quantity">
                          <button
                            onClick={() => qty(task.id, -1)}
                            aria-label={L('Decrease quantity', 'পরিমাণ কমান')}
                          >
                            <Minus size={13} />
                          </button>
                          <span>{line.quantity}</span>
                          <button
                            onClick={() => qty(task.id, 1)}
                            disabled={line.quantity >= 20}
                            aria-label={L('Increase quantity', 'পরিমাণ বাড়ান')}
                          >
                            <Plus size={13} />
                          </button>
                        </div>
                      </div>
                      <div>
                        <b>{money(task.price * line.quantity, lang)}</b>
                        <button
                          className="remove"
                          onClick={() => setCart((old) => old.filter((l) => l.taskId !== task.id))}
                          aria-label={L('Remove service', 'সেবা সরান')}
                        >
                          <Trash2 size={15} />
                        </button>
                      </div>
                    </div>
                  );
                })}
              </div>
              <label className="urgency">
                <div>
                  <b>{L('Need urgent help?', 'জরুরি সহায়তা প্রয়োজন?')}</b>
                  <small>
                    {L(
                      'Add ৳300 for urgent dispatch. Subject to availability.',
                      'জরুরি সহায়তায় অতিরিক্ত ৩০০ টাকা। কর্মীর প্রাপ্যতা সাপেক্ষে।',
                    )}
                  </small>
                </div>
                <input
                  type="checkbox"
                  checked={urgent}
                  onChange={(e) => setUrgent(e.target.checked)}
                />
              </label>
              <div className="cost-summary hallmark-receipt-slip">
                <div className="receipt-header-row">
                  <span className="receipt-title-tag">
                    {L('OFFICIAL RECEIPT SLIP', 'অফিসিয়াল সার্ভিস স্লিপ')}
                  </span>
                  <span className="receipt-code">#SC-2026</span>
                </div>
                <div className="receipt-tear-line" />
                <div className="receipt-line">
                  <span>{L('Labour subtotal', 'মোট শ্রমমূল্য')}</span>
                  <b className="tabular-num">{money(summary.labor, lang)}</b>
                </div>
                {urgent && (
                  <div className="receipt-line">
                    <span>{L('Urgency dispatch fee', 'জরুরি ডিসপ্যাচ ফি')}</span>
                    <b className="tabular-num">{money(summary.urgency, lang)}</b>
                  </div>
                )}
                <div className="receipt-line-dashed" />
                <div className="total receipt-total">
                  <span>{L('Estimated Total Payable', 'সর্বমোট প্রদেয়')}</span>
                  <b className="tabular-num">{money(summary.total, lang)}</b>
                </div>
                {/* Hallmark Verified Stamp */}
                <div className="hallmark-stamp-seal">
                  <div className="stamp-inner">
                    <span className="stamp-text">✓ DOKKHO VERIFIED</span>
                    <span className="stamp-sub">0% COMMISSION ON PARTS</span>
                  </div>
                </div>
              </div>
              <div className="notice">
                <ShieldCheck size={15} />
                {L(
                  'Replacement parts and official charges are extra, at cost, with your approval. The platform commission is included in labour; there is no commission on parts.',
                  'যন্ত্রাংশ ও সরকারি ফি আপনার অনুমোদনে প্রকৃত মূল্যে আলাদা। প্ল্যাটফর্ম কমিশন শ্রমমূল্যের অন্তর্ভুক্ত; যন্ত্রাংশে কমিশন নেই।',
                )}
              </div>
              <button
                className="btn full"
                onClick={() => {
                  setStage(1);
                  setError('');
                }}
              >
                {L('Continue to details', 'বিস্তারিত দিন')}
                <ArrowRight size={16} />
              </button>
            </>
          ) : (
            <form onSubmit={submit} className="stack">
              <div className="notice">
                {L(
                  'Demo only. Please use sample information. Addresses and documents are held only in memory and are not uploaded.',
                  'শুধু ডেমো। নমুনা তথ্য ব্যবহার করুন। ঠিকানা ও নথি সাময়িক মেমরিতে থাকবে, আপলোড হবে না।',
                )}
              </div>
              <label>
                {L('Neighbourhood', 'এলাকা')}
                <select value={zone} onChange={(e) => setZone(e.target.value)}>
                  {zones.map((z) => (
                    <option key={z.id} value={z.id}>
                      {z.name[lang]}
                    </option>
                  ))}
                </select>
              </label>
              <label>
                {L('Who should help?', 'কে সহায়তা করবেন?')}
                <select
                  value={compatiblePro?.id || 'auto'}
                  onChange={(e) => setSelectedPro(proOptions.find((p) => p.id === e.target.value))}
                >
                  <option value="auto">
                    {L(
                      categoryIds.length > 1
                        ? 'Auto-assign a professional for each trade'
                        : 'Find a suitable available professional',
                      'উপযুক্ত দক্ষ কর্মী স্বয়ংক্রিয়ভাবে নির্বাচন',
                    )}
                  </option>
                  {proOptions.map((p) => (
                    <option key={p.id} value={p.id}>
                      {lang === 'en' ? p.name : p.bn}
                    </option>
                  ))}
                </select>
              </label>
              <div className="field-grid">
                <label>
                  {L('Date', 'তারিখ')}
                  <input
                    required
                    type="date"
                    value={date}
                    min={new Date().toLocaleDateString('en-CA')}
                    onChange={(e) => setDate(e.target.value)}
                  />
                </label>
                <label>
                  {L('Time', 'সময়')}
                  <select value={time} onChange={(e) => setTime(e.target.value)}>
                    {['09:00', '10:00', '12:00', '14:00', '16:00', '18:00'].map((t) => (
                      <option key={t}>{t}</option>
                    ))}
                  </select>
                </label>
              </div>
              <label>
                {L('Service address', 'সেবার ঠিকানা')}
                <textarea
                  name="address"
                  autoComplete="off"
                  required
                  minLength={8}
                  maxLength={400}
                  rows={2}
                  placeholder={L('House, road, building and floor', 'বাসা, রাস্তা, ভবন ও তলা')}
                />
              </label>
              <label>
                {L('Tell us a little about the job', 'কাজের সংক্ষিপ্ত বিবরণ')}
                <textarea name="notes" rows={2} maxLength={1500} />
              </label>
              {legal && (
                <fieldset className="legal-fields">
                  <legend>{L('Court errand details', 'আদালতের কাজের বিবরণ')}</legend>
                  <div className="stack">
                    <label>
                      {L('Court premises', 'আদালত')}
                      <select name="court" required>
                        <option value="">{L('Choose court', 'আদালত বেছে নিন')}</option>
                        <option>{L('Dhaka Judge Court', 'ঢাকা জজ আদালত')}</option>
                        <option>{L('Supreme Court premises', 'সুপ্রিম কোর্ট প্রাঙ্গণ')}</option>
                      </select>
                    </label>
                    <label>
                      {L('Case number / document reference', 'মামলা নম্বর / নথির সূত্র')}
                      <input name="caseNumber" required maxLength={150} />
                    </label>
                    <label>
                      {L(
                        'Supporting document (optional, PDF/JPG/PNG · 5 MB)',
                        'সহায়ক নথি (ঐচ্ছিক, PDF/JPG/PNG · ৫ এমবি)',
                      )}
                      <input
                        type="file"
                        accept=".pdf,.jpg,.jpeg,.png"
                        onChange={(e) => {
                          const file = e.target.files?.[0];
                          if (file && !validUpload(file)) {
                            setError(
                              L(
                                'Choose PDF, JPG or PNG up to 5 MB.',
                                'সর্বোচ্চ ৫ এমবি PDF, JPG বা PNG দিন।',
                              ),
                            );
                            e.target.value = '';
                            setDocument(undefined);
                          } else {
                            setError('');
                            setDocument(file);
                          }
                        }}
                      />
                    </label>
                    {document && <small>{document.name}</small>}
                  </div>
                </fieldset>
              )}
              <div className="notice">
                {L(
                  'Payment: cash after service. Online payment is not connected in this preview.',
                  'পেমেন্ট: কাজ শেষে নগদ। এই প্রিভিউতে অনলাইন পেমেন্ট সংযুক্ত নয়।',
                )}
              </div>
              <div className="cost-summary hallmark-receipt-slip">
                <div className="receipt-header-row">
                  <span className="receipt-title-tag">
                    {L('FINAL CONFIRMATION', 'চূড়ান্ত সারসংক্ষেপ')}
                  </span>
                  <span className="receipt-code">#SC-2026</span>
                </div>
                <div className="receipt-tear-line" />
                <div className="total receipt-total">
                  <span>{L('Estimated total', 'আনুমানিক মোট')}</span>
                  <b className="tabular-num">{money(summary.total, lang)}</b>
                </div>
              </div>
              {error && (
                <p role="alert" className="error">
                  {error}
                </p>
              )}
              <label className="check-label">
                <input required type="checkbox" />
                {L(
                  'I understand this creates a sample booking only.',
                  'আমি বুঝেছি, এটি শুধু নমুনা বুকিং তৈরি করবে।',
                )}
              </label>
              <button className="btn full" type="submit">
                {L('Create demo request', 'ডেমো অনুরোধ তৈরি করুন')}
                <ArrowRight size={17} />
              </button>
              <button className="text-link" type="button" onClick={() => setStage(0)}>
                {L('Back to services', 'সেবার তালিকায় ফিরুন')}
              </button>
            </form>
          )}
        </>
      )}
    </Dialog>
  );
}
