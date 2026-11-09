import { Component, inject, signal, computed } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators, AbstractControl } from '@angular/forms';
import { RouterLink } from '@angular/router';
import { Workspace } from '../core/workspace';
import { validBangladeshPhone, validUpload } from '@kaarigor/shared/booking';
@Component({
  selector: 'provider-register',
  standalone: true,
  imports: [ReactiveFormsModule, RouterLink],
  templateUrl: './register.html',
})
export class Register {
  w = inject(Workspace);
  fb = inject(FormBuilder);
  step = signal(0);
  showPassword = signal(false);
  error = signal('');
  complete = signal(false);
  selectedTasks = signal<string[]>([]);
  zone = signal('dhanmondi');
  radius = signal(5);
  files: Record<string, File | undefined> = {};
  account = this.fb.nonNullable.group({
    firstName: ['', [Validators.required, Validators.maxLength(60)]],
    lastName: ['', [Validators.required, Validators.maxLength(60)]],
    phone: [
      '',
      [
        Validators.required,
        (c: AbstractControl) => (validBangladeshPhone(c.value) ? null : { phone: true }),
      ],
    ],
    email: ['', [Validators.required, Validators.email]],
    password: ['', [Validators.required, Validators.minLength(10)]],
    confirm: ['', Validators.required],
    acknowledge: [false, Validators.requiredTrue],
  });
  skill = this.fb.nonNullable.group({
    trade: ['electrician', Validators.required],
    experience: [0, [Validators.required, Validators.min(0), Validators.max(60)]],
    bio: ['', Validators.maxLength(1200)],
  });
  identity = this.fb.nonNullable.group({
    nid: ['', [Validators.required, Validators.pattern(/^(\d{10}|\d{13}|\d{17})$/)]],
    consent: [false, Validators.requiredTrue],
  });
  filename(key: string) {
    return this.files[key]?.name || '';
  }
  currentCategory() {
    return this.w.categories.find((c) => c.id === this.skill.controls.trade.value)!;
  }
  L(en: string, bn: string) {
    return this.w.L(en, bn);
  }
  invalid(name: string) {
    const c = this.account.get(name);
    return !!c?.invalid && c.touched;
  }
  next() {
    this.error.set('');
    if (this.step() === 0) {
      this.account.markAllAsTouched();
      if (this.account.invalid) {
        this.error.set(
          this.L(
            'Please check the highlighted fields. Password must have at least 10 characters.',
            'চিহ্নিত ঘরগুলো দেখুন। পাসওয়ার্ড অন্তত ১০ অক্ষরের হতে হবে।',
          ),
        );
        return;
      }
      if (this.account.controls.password.value !== this.account.controls.confirm.value) {
        this.error.set(this.L('The passwords do not match.', 'পাসওয়ার্ড দুটি মেলেনি।'));
        return;
      }
    }
    if (this.step() === 1) {
      this.skill.markAllAsTouched();
      if (this.skill.invalid || !this.selectedTasks().length) {
        this.error.set(
          this.L(
            'Choose at least one task and check your experience.',
            'অন্তত একটি কাজ বেছে নিন ও অভিজ্ঞতা সঠিক দিন।',
          ),
        );
        return;
      }
    }
    this.step.update((s) => Math.min(3, s + 1));
    window.scrollTo({ top: 0, behavior: 'smooth' });
  }
  changeTrade() {
    this.selectedTasks.set([]);
  }
  toggleTask(id: string) {
    this.selectedTasks.update((old) =>
      old.includes(id) ? old.filter((v) => v !== id) : [...old, id],
    );
  }
  pickFile(event: Event, key: string) {
    const input = event.target as HTMLInputElement;
    const file = input.files?.[0];
    this.error.set('');
    if (file && !validUpload(file)) {
      input.value = '';
      delete this.files[key];
      this.error.set(
        this.L('Choose a JPG, PNG or PDF file up to 5 MB.', 'সর্বোচ্চ ৫ এমবি JPG, PNG বা PDF দিন।'),
      );
      return;
    }
    this.files[key] = file;
  }
  submit() {
    this.identity.markAllAsTouched();
    this.error.set('');
    if (
      this.identity.invalid ||
      !this.files['front'] ||
      !this.files['back'] ||
      (this.skill.controls.trade.value === 'legal' && !this.files['credential'])
    ) {
      this.error.set(
        this.L(
          'Add a valid sample NID number, both sides of the card, any required trade credential and the acknowledgement.',
          'সঠিক নমুনা এনআইডি নম্বর, উভয় পাশ, প্রয়োজনীয় পেশাগত পরিচয়পত্র ও সম্মতি দিন।',
        ),
      );
      return;
    }
    this.w.name.set(
      `${this.account.controls.firstName.value} ${this.account.controls.lastName.value}`,
    );
    this.w.onboarded.set(true);
    this.files = {};
    this.account.reset();
    this.identity.reset();
    this.complete.set(true);
    window.scrollTo(0, 0);
  }
}
