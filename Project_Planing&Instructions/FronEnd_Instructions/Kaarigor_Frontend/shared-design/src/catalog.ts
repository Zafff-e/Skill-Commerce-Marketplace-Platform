export type Lang = 'en' | 'bn';
export type Localized = { en: string; bn: string };
export interface Category {
  id: string;
  name: Localized;
  note: Localized;
  color: string;
  avatar: string;
  tasks: Task[];
}
export interface Task {
  id: string;
  categoryId: string;
  name: Localized;
  price: number;
}
const task = (id: string, categoryId: string, en: string, bn: string, price: number): Task => ({
  id,
  categoryId,
  name: { en, bn },
  price,
});
export const categories: Category[] = [
  {
    id: 'electrician',
    name: { en: 'Electrician', bn: 'ইলেকট্রিশিয়ান' },
    note: { en: 'A little spark of expertise.', bn: 'বিদ্যুতের সমস্যায় দক্ষ সহায়তা।' },
    color: '#ead4af',
    avatar: 'electrician',
    tasks: [
      task('fan', 'electrician', 'Ceiling fan repair', 'সিলিং ফ্যান মেরামত', 350),
      task('switch', 'electrician', 'Switchboard replacement', 'সুইচবোর্ড পরিবর্তন', 200),
    ],
  },
  {
    id: 'plumber',
    name: { en: 'Plumber', bn: 'প্লাম্বার' },
    note: { en: 'Leaks, taps & everything between.', bn: 'পাইপ ও কলের সমস্যা সমাধান।' },
    color: '#cfdfdf',
    avatar: 'plumber',
    tasks: [
      task('leak', 'plumber', 'Leaking tap repair', 'কলের লিক মেরামত', 300),
      task('pipe', 'plumber', 'Pipe inspection', 'পাইপ পরীক্ষা', 400),
    ],
  },
  {
    id: 'ac',
    name: { en: 'AC technician', bn: 'এসি টেকনিশিয়ান' },
    note: { en: 'Bring the cool back home.', bn: 'ঘরে ফিরুক শীতল স্বস্তি।' },
    color: '#d5e3cf',
    avatar: 'ac',
    tasks: [
      task('ac-clean', 'ac', 'AC deep cleaning', 'এসি ডিপ ক্লিনিং', 800),
      task('ac-check', 'ac', 'AC diagnosis', 'এসি পরীক্ষা', 450),
    ],
  },
  {
    id: 'cleaner',
    name: { en: 'Home cleaner', bn: 'পরিচ্ছন্নতাকর্মী' },
    note: { en: 'A fresh start for your space.', bn: 'ঘর হোক ঝকঝকে পরিষ্কার।' },
    color: '#e8d5c9',
    avatar: 'cleaner',
    tasks: [
      task('bath', 'cleaner', 'Bathroom deep clean', 'বাথরুম ডিপ ক্লিনিং', 650),
      task('kitchen', 'cleaner', 'Kitchen deep clean', 'রান্নাঘর ডিপ ক্লিনিং', 900),
    ],
  },
  {
    id: 'carpenter',
    name: { en: 'Carpenter', bn: 'কাঠমিস্ত্রি' },
    note: { en: 'Good hands. Beautiful work.', bn: 'দক্ষ হাতে সুন্দর কাজ।' },
    color: '#e6d6ba',
    avatar: 'carpenter',
    tasks: [
      task('door', 'carpenter', 'Door hinge repair', 'দরজার কবজা মেরামত', 350),
      task('furniture', 'carpenter', 'Furniture assembly', 'আসবাবপত্র সংযোজন', 750),
    ],
  },
  {
    id: 'painter',
    name: { en: 'Painter', bn: 'রংমিস্ত্রি' },
    note: { en: 'Make room for a new colour.', bn: 'ঘর সাজুক নতুন রঙে।' },
    color: '#dfd4e1',
    avatar: 'painter',
    tasks: [task('paint-check', 'painter', 'Painting consultation', 'রঙের কাজ পরিদর্শন', 300)],
  },
  {
    id: 'legal',
    name: { en: 'Court companion', bn: 'আদালত সহায়ক' },
    note: { en: 'A helping hand with the paperwork.', bn: 'আদালতের কাজে বিশ্বস্ত সহায়তা।' },
    color: '#d6dfd3',
    avatar: 'legal',
    tasks: [
      task('copy', 'legal', 'Certified copy assistance', 'সার্টিফায়েড কপি সংগ্রহে সহায়তা', 600),
      task('case-status', 'legal', 'Case status check', 'মামলার অবস্থা জানা', 300),
    ],
  },
  {
    id: 'care',
    name: { en: 'Hospital companion', bn: 'হাসপাতাল সহায়ক' },
    note: { en: 'Someone by your side.', bn: 'প্রয়োজনে পাশে একজন।' },
    color: '#d6e1e6',
    avatar: 'care',
    tasks: [task('escort', 'care', 'Hospital escort · 2 hours', 'হাসপাতাল সহায়তা · ২ ঘণ্টা', 700)],
  },
  {
    id: 'errand',
    name: { en: 'Everyday errands', bn: 'দৈনন্দিন সহায়তা' },
    note: { en: 'Get a little time back.', bn: 'সময় বাঁচাতে পাশে আছি।' },
    color: '#eadebf',
    avatar: 'legal',
    tasks: [task('documents', 'errand', 'Document collection', 'নথি সংগ্রহ', 400)],
  },
];
export const zones = [
  {
    id: 'mirpur',
    name: { en: 'Mirpur', bn: 'মিরপুর' },
    x: 165,
    y: 135,
    path: 'M90 50 205 50 225 165 150 215 65 160Z',
  },
  {
    id: 'uttara',
    name: { en: 'Uttara', bn: 'উত্তরা' },
    x: 305,
    y: 77,
    path: 'M230 24 365 20 400 95 310 130 225 100Z',
  },
  {
    id: 'gulshan',
    name: { en: 'Gulshan & Banani', bn: 'গুলশান ও বনানী' },
    x: 325,
    y: 185,
    path: 'M245 128 355 110 380 200 300 252 224 190Z',
  },
  {
    id: 'mohammadpur',
    name: { en: 'Mohammadpur', bn: 'মোহাম্মদপুর' },
    x: 115,
    y: 265,
    path: 'M65 180 150 224 205 202 210 295 120 323 55 277Z',
  },
  {
    id: 'dhanmondi',
    name: { en: 'Dhanmondi', bn: 'ধানমন্ডি' },
    x: 220,
    y: 310,
    path: 'M220 210 290 257 292 330 210 355 165 314 220 298Z',
  },
  {
    id: 'badda',
    name: { en: 'Badda & Rampura', bn: 'বাড্ডা ও রামপুরা' },
    x: 390,
    y: 280,
    path: 'M390 211 448 185 468 314 365 345 305 322 310 267Z',
  },
  {
    id: 'motijheel',
    name: { en: 'Motijheel', bn: 'মতিঝিল' },
    x: 335,
    y: 395,
    path: 'M300 337 365 360 430 337 427 415 325 452 280 404Z',
  },
  {
    id: 'old-dhaka',
    name: { en: 'Old Dhaka', bn: 'পুরান ঢাকা' },
    x: 200,
    y: 420,
    path: 'M130 339 210 369 275 343 265 413 309 466 207 490 133 445Z',
  },
];
export interface Pro {
  id: string;
  name: string;
  bn: string;
  categoryId: string;
  zoneId: string;
  rating: number;
  jobs: number;
  years: number;
  available: boolean;
  avatar: string;
}
const names = [
  ['Rafiq Islam', 'রফিক ইসলাম'],
  ['Nusrat Jahan', 'নুসরাত জাহান'],
  ['Hasan Mahmud', 'হাসান মাহমুদ'],
];
export const demoPros: Pro[] = categories.flatMap((cat, c) =>
  zones.flatMap((z, i) =>
    true
      ? names
          .slice(0, 2)
          .map((n, k) => ({
            id: `demo-${cat.id}-${z.id}-${k}`,
            name: n[0],
            bn: n[1],
            categoryId: cat.id,
            zoneId: z.id,
            rating: 4.8 + k * 0.1,
            jobs: 24 + c * 3 + k * 8,
            years: 3 + c + k,
            available: k === 0,
            avatar: cat.avatar,
          }))
      : [],
  ),
);
export const allTasks = categories.flatMap((c) => c.tasks);
export function money(value: number, lang: Lang = 'en') {
  const number = new Intl.NumberFormat(lang === 'bn' ? 'bn-BD' : 'en-BD', {
    maximumFractionDigits: 0,
  }).format(value);
  return lang === 'bn' ? `${number} টাকা` : `৳ ${number}`;
}
