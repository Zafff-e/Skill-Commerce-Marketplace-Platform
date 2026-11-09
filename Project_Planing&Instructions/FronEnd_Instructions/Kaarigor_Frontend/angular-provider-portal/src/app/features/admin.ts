import { Component, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { RouterLink } from '@angular/router';
import { Workspace } from '../core/workspace';
@Component({
  selector: 'admin-demo',
  standalone: true,
  imports: [FormsModule, RouterLink],
  template: `
    <main class="admin-page">
      <header class="workspace-heading">
        <div>
          <span class="eyebrow">{{ L('DEMO VERIFICATION DESK', 'ডেমো যাচাই ডেস্ক') }}</span>
          <h1>{{ L('Trust starts with care.', 'যত্ন থেকেই আস্থার শুরু।') }}</h1>
          <p>
            {{
              L(
                'Illustrative workflow with placeholder applicants.',
                'নমুনা আবেদনকারীদের দিয়ে প্রক্রিয়া প্রদর্শন।'
              )
            }}
          </p>
        </div>
        <a class="btn secondary" routerLink="/dashboard"
          >{{ L('Back to workspace', 'কর্মক্ষেত্রে ফিরুন') }} ↗</a
        >
      </header>
      <div class="notice">
        {{
          L(
            'Demo only. No real identity documents or accounts are accessible. Production admin routes must use server-enforced authentication and role authorization.',
            'শুধু ডেমো। বাস্তব পরিচয়পত্র বা অ্যাকাউন্ট নেই। বাস্তব অ্যাডমিন রুটে সার্ভারে পরিচয় ও ভূমিকা যাচাই আবশ্যক।'
          )
        }}
      </div>
      <section class="admin-grid">
        <div class="verification-queue">
          <h2>{{ L('Review queue', 'পর্যালোচনার তালিকা') }}</h2>
          @for (item of w.queue(); track item.id) {
            <button
              class="queue-item"
              [class.active]="selected() === item.id"
              (click)="selected.set(item.id)"
            >
              <div>
                <b>{{ item.name }}</b
                ><small>{{ item.trade }} · {{ item.id }}</small>
              </div>
              <span class="badge">{{ status(item.status) }}</span>
            </button>
          }
        </div>
        <div class="verification-detail">
          @for (item of w.queue(); track item.id) {
            @if (item.id === selected()) {
              <div class="workspace-section-heading">
                <h2>{{ item.name }}</h2>
                <span class="badge">{{ status(item.status) }}</span>
              </div>
              <div class="identity-comparison">
                <div>
                  <img src="assets/electrician.svg" alt="Sample portrait" /><span>{{
                    L('Sample profile portrait', 'নমুনা প্রোফাইল ছবি')
                  }}</span>
                </div>
                <div class="document-placeholder">
                  <span>▤</span
                  ><b>{{ L('Identity document placeholder', 'পরিচয়পত্রের নমুনা স্থান') }}</b
                  ><small>{{ L('No actual NID is stored', 'কোনো বাস্তব এনআইডি নেই') }}</small>
                </div>
              </div>
              <label class="review-note"
                >{{ L('Reason / review note', 'কারণ / মন্তব্য')
                }}<textarea
                  [(ngModel)]="reason"
                  rows="3"
                  [placeholder]="
                    L(
                      'Required for rejection or resubmission',
                      'প্রত্যাখ্যান বা পুনরায় জমার জন্য আবশ্যক'
                    )
                  "
                ></textarea>
              </label>
              @if (message()) {
                <div class="error" role="alert">{{ message() }}</div>
              }
              @if (item.reason) {
                <p class="notice">{{ item.reason }}</p>
              }
              <div class="review-actions">
                <button
                  class="btn"
                  [disabled]="item.status !== 'Pending'"
                  (click)="review(item.id, 'Approved')"
                >
                  {{ L('Approve sample', 'নমুনা অনুমোদন') }}</button
                ><button
                  class="btn secondary"
                  [disabled]="item.status !== 'Pending'"
                  (click)="review(item.id, 'Resubmission')"
                >
                  {{ L('Request resubmission', 'পুনরায় জমা') }}</button
                ><button
                  class="btn secondary"
                  [disabled]="item.status !== 'Pending'"
                  (click)="review(item.id, 'Rejected')"
                >
                  {{ L('Reject with reason', 'কারণসহ প্রত্যাখ্যান') }}
                </button>
              </div>
            }
          }
        </div>
      </section>
    </main>
  `,
})
export class Admin {
  w = inject(Workspace);
  selected = signal('SAMPLE-01');
  reason = '';
  message = signal('');
  L(en: string, bn: string) {
    return this.w.L(en, bn);
  }
  status(s: string) {
    return this.w.lang() === 'en'
      ? s
      : {
          Pending: 'অপেক্ষমাণ',
          Approved: 'অনুমোদিত',
          Rejected: 'প্রত্যাখ্যাত',
          Resubmission: 'পুনরায় জমা',
        }[s] || s;
  }
  review(id: string, status: string) {
    if (status !== 'Approved' && !this.reason.trim()) {
      this.message.set(this.L('Please give a reason.', 'কারণ লিখুন।'));
      return;
    }
    this.w.verify(id, status, this.reason.trim());
    this.reason = '';
    this.message.set('');
  }
}
