import { Component, inject, signal, computed } from '@angular/core';
import { RouterLink } from '@angular/router';
import { FormsModule } from '@angular/forms';
import { Workspace } from '../core/workspace';
import { money } from '@kaarigor/shared/catalog';
@Component({
  selector: 'provider-dashboard',
  standalone: true,
  imports: [RouterLink, FormsModule],
  template: `
    <div class="workspace-shell">
      <aside class="workspace-sidebar">
        <span class="eyebrow">{{ L('YOUR WORK, YOUR WAY', 'নিজের কাজে নিজের পথ') }}</span>
        <div class="provider-mini">
          <img src="assets/electrician.svg" alt="" />
          <div>
            <b>{{ w.name() || L('Sample professional', 'নমুনা দক্ষ কর্মী') }}</b
            ><small>{{
              w.onboarded()
                ? L('Pending verification', 'যাচাইয়ের অপেক্ষায়')
                : L('Demo workspace', 'ডেমো কর্মক্ষেত্র')
            }}</small>
          </div>
        </div>
        <nav>
          @for (tab of tabs; track tab.id) {
            <button [class.active]="active() === tab.id" (click)="active.set(tab.id)">
              <span>{{ tab.icon }}</span
              >{{ L(tab.en, tab.bn) }}<i>↗</i>
            </button>
          }
        </nav>
        <div class="sidebar-bottom">
          <span class="eyebrow">{{ L('A LITTLE GOOD TO KNOW', 'জেনে রাখা ভালো') }}</span>
          <p>
            {{
              L(
                'Your reputation grows with every job done well.',
                'প্রতিটি ভালো কাজ আপনার সুনাম বাড়ায়।'
              )
            }}
          </p>
          <a routerLink="/register">{{ L('Complete your profile', 'প্রোফাইল সম্পূর্ণ করুন') }} ↗</a
          ><a routerLink="/admin">{{ L('Demo verification desk', 'ডেমো যাচাই ডেস্ক') }} ↗</a>
        </div>
      </aside>
      <main class="workspace-main">
        <header class="workspace-heading">
          <div>
            <span class="eyebrow">{{ L('PROVIDER WORKSPACE', 'দক্ষ কর্মীর কর্মক্ষেত্র') }}</span>
            <h1>
              {{
                active() === 'overview'
                  ? L('Make today good work.', 'আজ হোক সুন্দর কাজের দিন।')
                  : active() === 'jobs'
                    ? L('Your work, in one place.', 'সব কাজ এক জায়গায়।')
                    : active() === 'earnings'
                      ? L('Every job adds up.', 'প্রতিটি কাজের হিসাব।')
                      : L('Work around your life.', 'নিজের মতো কাজ করুন।')
              }}
            </h1>
            <p>
              {{
                L(
                  'A clear view of the day ahead. Sample data only.',
                  'সামনের দিনের কাজের স্পষ্ট চিত্র। শুধু নমুনা তথ্য।'
                )
              }}
            </p>
          </div>
          <label class="online-toggle"
            ><span
              ><b>{{ w.online() ? L('Online', 'অনলাইন') : L('Offline', 'অফলাইন') }}</b
              ><small>{{ L('Demo availability', 'ডেমো প্রাপ্যতা') }}</small></span
            ><input
              type="checkbox"
              [checked]="w.online()"
              (change)="w.online.set($any($event.target).checked)"
          /></label>
        </header>
        <div class="notice workspace-notice">
          {{
            L(
              'Demo workspace. Job status, earnings and verification changes are local to this session. No real customers are contacted.',
              'ডেমো কর্মক্ষেত্র। কাজের অবস্থা, আয় ও যাচাইয়ের পরিবর্তন এই সেশনে থাকবে। বাস্তব গ্রাহকের সঙ্গে যোগাযোগ হবে না।'
            )
          }}
        </div>
        @if (active() === 'overview' || active() === 'earnings') {
          <section class="metric-grid">
            <article>
              <span>{{ L('Sample jobs', 'নমুনা কাজ') }}</span
              ><strong>{{ w.jobs().length }}</strong
              ><small>{{ L('In your demo workspace', 'আপনার ডেমো কর্মক্ষেত্রে') }}</small>
            </article>
            <article>
              <span>{{ L('Completed labour', 'সম্পন্ন কাজের শ্রমমূল্য') }}</span
              ><strong>{{ format(completedLabor()) }}</strong
              ><small>{{ L('Before platform commission', 'প্ল্যাটফর্ম কমিশনের আগে') }}</small>
            </article>
            <article>
              <span>{{ L('Estimated net earnings', 'আনুমানিক নিট আয়') }}</span
              ><strong>{{ format(Math.round(completedLabor() * 0.9)) }}</strong
              ><small>{{ L('10% demo labour commission', 'শ্রমমূল্যে ১০% ডেমো কমিশন') }}</small>
            </article>
          </section>
        }
        @if (active() === 'overview' || active() === 'jobs') {
          <section>
            <div class="workspace-section-heading">
              <h2>{{ L('On your workbench', 'আপনার কাজের তালিকা') }}</h2>
              <span class="pill">{{ w.jobs().length }} {{ L('sample jobs', 'নমুনা কাজ') }}</span>
            </div>
            <div class="job-cards">
              @for (job of w.jobs(); track job.id) {
                <article class="job-card">
                  <div class="job-heading">
                    <span class="eyebrow">{{ job.id }}</span
                    ><span class="badge">{{ statusLabel(job.status) }}</span>
                  </div>
                  <h3>{{ L(job.service, job.bn) }}</h3>
                  <div class="job-meta">
                    <span>{{ zoneName(job.zone) }}</span
                    ><span
                      >{{ job.time }} ·
                      {{ L('Sample appointment', 'নমুনা অ্যাপয়েন্টমেন্ট') }}</span
                    >
                  </div>
                  <div class="job-progress">
                    @for (s of states; track s; let i = $index) {
                      <span [class.done]="states.indexOf(job.status) >= i">{{ i + 1 }}</span>
                    }
                  </div>
                  <div class="job-price">
                    <span
                      >{{ L('Labour', 'শ্রমমূল্য') }}<b>{{ format(job.labor) }}</b></span
                    ><span
                      >{{ L('Estimated net', 'আনুমানিক নিট')
                      }}<b>{{ format(Math.round(job.labor * 0.9)) }}</b></span
                    >
                  </div>
                  @if (job.part) {
                    <div class="notice">
                      {{ job.part.name }} · {{ format(job.part.amount) }} ·
                      {{
                        L(
                          'Awaiting customer approval; excluded from earnings.',
                          'গ্রাহকের অনুমোদনের অপেক্ষায়; আয়ের হিসাবে নেই।'
                        )
                      }}
                    </div>
                  }
                  <div class="job-actions">
                    @if (job.status !== 'Completed') {
                      <button class="btn small" (click)="w.advance(job.id)">
                        {{ nextLabel(job.status) }} →
                      </button>
                    } @else {
                      <span class="completed-note"
                        >✓ {{ L('Sample job completed', 'নমুনা কাজ সম্পন্ন') }}</span
                      >
                    }
                    @if (job.status === 'InProgress' && !job.part) {
                      <button class="btn small secondary" (click)="partJob.set(job.id)">
                        {{ L('Request a part', 'যন্ত্রাংশের অনুরোধ') }}
                      </button>
                    }
                  </div>
                </article>
              }
            </div>
          </section>
        } @else if (active() === 'earnings') {
          <section class="workspace-panel">
            <div class="workspace-section-heading">
              <h2>{{ L('A transparent ledger', 'স্বচ্ছ হিসাব') }}</h2>
            </div>
            <div class="table-wrap">
              <table>
                <thead>
                  <tr>
                    <th>{{ L('Job', 'কাজ') }}</th>
                    <th>{{ L('Labour', 'শ্রমমূল্য') }}</th>
                    <th>{{ L('Commission', 'কমিশন') }}</th>
                    <th>{{ L('Net labour', 'নিট শ্রমমূল্য') }}</th>
                    <th>{{ L('Status', 'অবস্থা') }}</th>
                  </tr>
                </thead>
                <tbody>
                  @for (job of w.jobs(); track job.id) {
                    <tr>
                      <td>{{ job.id }}</td>
                      <td>{{ format(job.labor) }}</td>
                      <td>{{ format(Math.round(job.labor * 0.1)) }}</td>
                      <td>{{ format(Math.round(job.labor * 0.9)) }}</td>
                      <td>{{ statusLabel(job.status) }}</td>
                    </tr>
                  }
                </tbody>
              </table>
            </div>
            <div class="notice">
              {{
                L(
                  'Only completed jobs count towards the earnings summary. Parts reimbursements are separate and have no commission. Payouts are not connected.',
                  'শুধু সম্পন্ন কাজ আয়ের সারাংশে গণনা হয়। যন্ত্রাংশের মূল্য ফেরত আলাদা, কমিশন নেই। পেআউট সংযুক্ত নয়।'
                )
              }}
            </div>
          </section>
        } @else {
          <section class="workspace-panel schedule-panel">
            <h2>{{ L('Your weekly availability', 'সাপ্তাহিক সময়সূচি') }}</h2>
            <p>
              {{
                L(
                  'Choose the days you usually work. This demo schedule stays in memory.',
                  'সাধারণত যেদিন কাজ করেন বেছে নিন। ডেমো সময়সূচি মেমরিতে থাকবে।'
                )
              }}
            </p>
            <div class="day-buttons">
              @for (day of days; track day.en) {
                <button
                  class="pill"
                  [class.active]="selectedDays().includes(day.en)"
                  [attr.aria-pressed]="selectedDays().includes(day.en)"
                  (click)="toggleDay(day.en)"
                >
                  {{ L(day.en, day.bn) }}
                </button>
              }
            </div>
            <div class="field-grid">
              <label
                >{{ L('Start time', 'শুরুর সময়') }}<input type="time" [(ngModel)]="start" /></label
              ><label>{{ L('End time', 'শেষ সময়') }}<input type="time" [(ngModel)]="end" /></label>
            </div>
            <button class="btn" (click)="saveSchedule()">
              {{ L('Save sample availability', 'নমুনা সময়সূচি রাখুন') }}
            </button>
            @if (scheduleMessage()) {
              <div class="notice" role="status">{{ scheduleMessage() }}</div>
            }
          </section>
        }
      </main>
    </div>
    @if (partJob()) {
      <div class="provider-modal-backdrop">
        <section
          class="provider-modal"
          role="dialog"
          aria-modal="true"
          aria-labelledby="parts-title"
        >
          <div class="workspace-section-heading">
            <h2 id="parts-title">{{ L('Request a part', 'যন্ত্রাংশের অনুরোধ') }}</h2>
            <button
              class="icon-btn"
              (click)="partJob.set('')"
              [attr.aria-label]="L('Close', 'বন্ধ করুন')"
            >
              ×
            </button>
          </div>
          <form (ngSubmit)="addPart()" class="stack">
            <label
              >{{ L('Part name', 'যন্ত্রাংশের নাম')
              }}<input name="partName" [(ngModel)]="partName" required maxlength="100" /></label
            ><label
              >{{ L('Actual cost (BDT)', 'প্রকৃত মূল্য (টাকা)')
              }}<input
                name="partCost"
                type="number"
                [(ngModel)]="partCost"
                required
                min="1"
                max="100000"
            /></label>
            <div class="notice">
              {{
                L(
                  'This creates a local pending request. It does not approve the cost or charge the customer.',
                  'শুধু স্থানীয় অনুরোধ তৈরি হবে। মূল্য অনুমোদন বা গ্রাহকের কাছ থেকে অর্থ নেওয়া হবে না।'
                )
              }}
            </div>
            <button class="btn" type="submit">
              {{ L('Create sample request', 'নমুনা অনুরোধ তৈরি') }}
            </button>
          </form>
        </section>
      </div>
    }
  `,
})
export class Dashboard {
  w = inject(Workspace);
  active = signal('overview');
  Math = Math;
  states = ['Accepted', 'OnTheWay', 'Arrived', 'InProgress', 'Completed'];
  tabs = [
    { id: 'overview', en: 'Overview', bn: 'সারাংশ', icon: '◫' },
    { id: 'jobs', en: 'My jobs', bn: 'আমার কাজ', icon: '▤' },
    { id: 'earnings', en: 'Earnings', bn: 'আয়', icon: '◷' },
    { id: 'schedule', en: 'Availability', bn: 'সময়সূচি', icon: '▦' },
  ];
  days = [
    { en: 'Sun', bn: 'রবি' },
    { en: 'Mon', bn: 'সোম' },
    { en: 'Tue', bn: 'মঙ্গল' },
    { en: 'Wed', bn: 'বুধ' },
    { en: 'Thu', bn: 'বৃহস্পতি' },
    { en: 'Fri', bn: 'শুক্র' },
    { en: 'Sat', bn: 'শনি' },
  ];
  selectedDays = signal(['Sun', 'Mon', 'Tue', 'Wed', 'Thu']);
  start = '09:00';
  end = '18:00';
  scheduleMessage = signal('');
  partJob = signal('');
  partName = '';
  partCost = 0;
  completedLabor = computed(() =>
    this.w
      .jobs()
      .filter((j) => j.status === 'Completed')
      .reduce((s, j) => s + j.labor, 0),
  );
  L(en: string, bn: string) {
    return this.w.L(en, bn);
  }
  format(n: number) {
    return money(n, this.w.lang());
  }
  zoneName(id: string) {
    return this.w.zones.find((z) => z.id === id)?.name[this.w.lang()];
  }
  statusLabel(s: string) {
    const en: Record<string, string> = {
      Accepted: 'Accepted',
      OnTheWay: 'On the way',
      Arrived: 'Arrived',
      InProgress: 'Working',
      Completed: 'Completed',
    };
    const bn: Record<string, string> = {
      Accepted: 'গৃহীত',
      OnTheWay: 'পথে',
      Arrived: 'পৌঁছেছেন',
      InProgress: 'কাজ চলছে',
      Completed: 'সম্পন্ন',
    };
    return this.w.lang() === 'en' ? en[s] : bn[s];
  }
  nextLabel(s: string) {
    return (
      {
        Accepted: this.L('Start journey', 'রওনা দিন'),
        OnTheWay: this.L('Mark arrived', 'উপস্থিতি জানান'),
        Arrived: this.L('Start work', 'কাজ শুরু'),
        InProgress: this.L('Complete demo job', 'ডেমো কাজ সম্পন্ন'),
      }[s] || ''
    );
  }
  toggleDay(day: string) {
    this.selectedDays.update((old) =>
      old.includes(day) ? old.filter((d) => d !== day) : [...old, day],
    );
  }
  saveSchedule() {
    this.scheduleMessage.set(
      this.selectedDays().length && this.start < this.end
        ? this.L(
            'Sample availability saved for this session.',
            'এই সেশনে নমুনা সময়সূচি রাখা হয়েছে।',
          )
        : this.L(
            'Choose at least one day and an end time after the start.',
            'অন্তত একটি দিন ও শুরুর পরের শেষ সময় বেছে নিন।',
          ),
    );
  }
  addPart() {
    if (!this.partName.trim() || this.partCost <= 0 || this.partCost > 100000) return;
    this.w.jobs.update((jobs) =>
      jobs.map((j) =>
        j.id === this.partJob()
          ? { ...j, part: { name: this.partName.trim(), amount: this.partCost, approved: false } }
          : j,
      ),
    );
    this.partJob.set('');
    this.partName = '';
    this.partCost = 0;
  }
}
