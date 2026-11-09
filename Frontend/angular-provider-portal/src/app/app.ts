import { Component, inject } from '@angular/core';
import { RouterOutlet, RouterLink, RouterLinkActive } from '@angular/router';
import { Workspace } from './core/workspace';
@Component({
  selector: 'app-root',
  standalone: true,
  imports: [RouterOutlet, RouterLink, RouterLinkActive],
  template: `
    <header class="provider-nav">
      <a class="brand" href="/"
        ><span class="brand-mark">k</span>kaarigor<span class="brand-dot">.</span></a
      ><span class="portal-label">{{ w.L('FOR PROFESSIONALS', 'দক্ষ কর্মীদের জন্য') }}</span>
      <nav>
        <a routerLink="/dashboard" routerLinkActive="active">{{
          w.L('Workspace', 'কর্মক্ষেত্র')
        }}</a
        ><a routerLink="/register" routerLinkActive="active">{{
          w.L('Join Kaarigor', 'নিবন্ধন')
        }}</a
        ><button (click)="w.setLanguage(w.lang() === 'en' ? 'bn' : 'en')">
          {{ w.lang() === 'en' ? 'বাংলা' : 'EN' }}</button
        ><button (click)="w.toggleTheme()" [attr.aria-label]="w.L('Change theme', 'থিম পরিবর্তন')">
          {{ w.L('Theme', 'থিম') }} · {{ w.theme() }}
        </button>
      </nav>
    </header>
    <router-outlet />
    <footer class="provider-footer">
      <span
        >© {{ year }} Kaarigor ·
        {{ w.L('Good people. Great work.', 'দক্ষ মানুষ। সুন্দর কাজ।') }}</span
      ><a href="/">{{ w.L('Back to customer site', 'গ্রাহক সাইটে ফিরুন') }} ↗</a
      ><span>{{
        w.L(
          'Interactive demo · no real accounts or verification',
          'ইন্টারঅ্যাকটিভ ডেমো · বাস্তব অ্যাকাউন্ট বা যাচাই নয়'
        )
      }}</span>
    </footer>
  `,
})
export class App {
  w = inject(Workspace);
  year = new Date().getFullYear();
}
