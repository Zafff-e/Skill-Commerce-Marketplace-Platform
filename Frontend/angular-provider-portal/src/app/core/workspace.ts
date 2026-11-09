import { Injectable, signal } from '@angular/core';
import { applyTheme, storedTheme, type Theme } from '@kaarigor/shared/theme';
import { type Lang, categories, zones } from '@kaarigor/shared/catalog';
import { nextWorkState, type WorkState } from '@kaarigor/shared/booking';
export interface Job {
  id: string;
  service: string;
  bn: string;
  zone: string;
  time: string;
  labor: number;
  status: WorkState;
  part?: { name: string; amount: number; approved: boolean };
}
@Injectable({ providedIn: 'root' })
export class Workspace {
  lang = signal<Lang>('en');
  theme = signal<Theme>(storedTheme());
  name = signal('');
  onboarded = signal(false);
  online = signal(false);
  notice = signal('');
  categories = categories;
  zones = zones;
  jobs = signal<Job[]>([
    {
      id: 'DEMO-1042',
      service: 'Ceiling fan repair',
      bn: 'সিলিং ফ্যান মেরামত',
      zone: 'dhanmondi',
      time: '10:00',
      labor: 350,
      status: 'Accepted',
    },
    {
      id: 'DEMO-1043',
      service: 'Switchboard replacement',
      bn: 'সুইচবোর্ড পরিবর্তন',
      zone: 'mirpur',
      time: '14:00',
      labor: 200,
      status: 'InProgress',
    },
  ]);
  queue = signal([
    {
      id: 'SAMPLE-01',
      name: 'Sample applicant A',
      trade: 'Electrician',
      status: 'Pending',
      reason: '',
    },
    {
      id: 'SAMPLE-02',
      name: 'Sample applicant B',
      trade: 'Court companion',
      status: 'Pending',
      reason: '',
    },
  ]);
  constructor() {
    try {
      this.lang.set(localStorage.getItem('kaarigor-lang') === 'bn' ? 'bn' : 'en');
    } catch {}
    this.setLanguage(this.lang());
    applyTheme(this.theme());
    setInterval(() => applyTheme(this.theme()), 300000);
    document.addEventListener(
      'visibilitychange',
      () => (document.documentElement.dataset['paused'] = String(document.hidden)),
    );
  }
  L(en: string, bn: string) {
    return this.lang() === 'en' ? en : bn;
  }
  setLanguage(lang: Lang) {
    this.lang.set(lang);
    document.documentElement.lang = lang;
    try {
      localStorage.setItem('kaarigor-lang', lang);
    } catch {}
  }
  toggleTheme() {
    const t = this.theme() === 'light' ? 'dark' : this.theme() === 'dark' ? 'auto' : 'light';
    this.theme.set(t);
    applyTheme(t);
  }
  advance(id: string) {
    this.jobs.update((jobs) =>
      jobs.map((j) => (j.id === id ? { ...j, status: nextWorkState(j.status) } : j)),
    );
  }
  verify(id: string, status: string, reason = '') {
    this.queue.update((items) => items.map((i) => (i.id === id ? { ...i, status, reason } : i)));
  }
}
