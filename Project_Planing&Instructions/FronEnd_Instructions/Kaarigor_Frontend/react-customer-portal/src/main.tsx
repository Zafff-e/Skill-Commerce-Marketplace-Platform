import React from 'react';
import { createRoot } from 'react-dom/client';
import { HashRouter, Routes, Route } from 'react-router-dom';
import '@kaarigor/shared/styles.css';
import './styles.css';
import { AppProvider } from './state/AppState';
import { Shell } from './components/Shell';
import { Home } from './pages/Home';
import { Discover } from './pages/Discover';
import { Services } from './pages/Services';
import { Bookings } from './pages/Bookings';
import { Account } from './pages/Account';
import { Info, NotFound } from './pages/Info';
createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <AppProvider>
      <HashRouter>
        <Routes>
          <Route element={<Shell />}>
            <Route index element={<Home />} />
            <Route path="discover" element={<Discover />} />
            <Route path="services" element={<Services />} />
            <Route path="bookings" element={<Bookings />} />
            <Route path="account" element={<Account />} />
            <Route path="how-it-works" element={<Info />} />
            <Route path="policies" element={<Info />} />
            <Route path="*" element={<NotFound />} />
          </Route>
        </Routes>
      </HashRouter>
    </AppProvider>
  </React.StrictMode>,
);
