import { bootstrapApplication } from '@angular/platform-browser';
import { provideRouter, withHashLocation } from '@angular/router';
import { App } from './app/app';
import { Register } from './app/features/register';
import { Dashboard } from './app/features/dashboard';
import { Admin } from './app/features/admin';
bootstrapApplication(App, {
  providers: [
    provideRouter(
      [
        { path: 'register', component: Register },
        { path: 'dashboard', component: Dashboard },
        { path: 'admin', component: Admin },
        { path: '', redirectTo: 'register', pathMatch: 'full' },
        { path: '**', redirectTo: 'register' },
      ],
      withHashLocation(),
    ),
  ],
}).catch(console.error);
