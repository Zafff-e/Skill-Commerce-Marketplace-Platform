import { createContext, useContext, useEffect, useState, type ReactNode } from 'react';
import { categories, allTasks, type Lang, type Pro } from '@kaarigor/shared/catalog';
import { totals, type CartLine } from '@kaarigor/shared/booking';
import { applyTheme, storedTheme, type Theme } from '@kaarigor/shared/theme';
export interface Booking {
  id: string;
  lines: CartLine[];
  total: number;
  zone: string;
  pro?: Pro;
  legal: boolean;
  createdAt: string;
}
function useAppStore() {
  const [lang, setLang] = useState<Lang>(() => {
    try {
      return localStorage.getItem('kaarigor-lang') === 'bn' ? 'bn' : 'en';
    } catch {
      return 'en';
    }
  });
  const [theme, setTheme] = useState<Theme>(storedTheme);
  const [cart, setCart] = useState<CartLine[]>(() => {
    try {
      const lines = JSON.parse(localStorage.getItem('kaarigor-cart') || '[]');
      if (Array.isArray(lines))
        return lines.filter(
          (l: CartLine) =>
            allTasks.some((t) => t.id === l.taskId) &&
            Number.isInteger(l.quantity) &&
            l.quantity >= 1 &&
            l.quantity <= 20,
        );
      return [];
    } catch {
      return [];
    }
  });
  const [cartOpen, setCartOpen] = useState(false),
    [urgent, setUrgent] = useState(false),
    [selectedPro, setSelectedPro] = useState<Pro>(),
    [zone, setZone] = useState('dhanmondi'),
    [bookings, setBookings] = useState<Booking[]>([]),
    [saved, setSaved] = useState<string[]>([]),
    [toast, setToast] = useState('');
  useEffect(() => {
    document.documentElement.lang = lang;
    try {
      localStorage.setItem('kaarigor-lang', lang);
    } catch {}
  }, [lang]);
  useEffect(() => {
    applyTheme(theme);
    const id = setInterval(() => applyTheme(theme), 300000);
    return () => clearInterval(id);
  }, [theme]);
  useEffect(() => {
    try {
      localStorage.setItem('kaarigor-cart', JSON.stringify(cart));
    } catch {}
  }, [cart]);
  useEffect(() => {
    if (!toast) return;
    const id = setTimeout(() => setToast(''), 4000);
    return () => clearTimeout(id);
  }, [toast]);
  function L(en: string, bn: string) {
    return lang === 'bn' ? bn : en;
  }
  function add(taskId: string) {
    setCart((old) =>
      old.some((l) => l.taskId === taskId) ? old : [...old, { taskId, quantity: 1 }],
    );
    setToast(L('Added to your service bag.', 'সার্ভিস ব্যাগে যোগ হয়েছে।'));
  }
  function qty(taskId: string, delta: number) {
    setCart((old) =>
      old
        .map((l) =>
          l.taskId === taskId ? { ...l, quantity: Math.min(20, l.quantity + delta) } : l,
        )
        .filter((l) => l.quantity > 0),
    );
  }
  function save(id: string) {
    setSaved((old) => (old.includes(id) ? old.filter((v) => v !== id) : [...old, id]));
  }
  return {
    lang,
    setLang,
    L,
    theme,
    setTheme,
    cart,
    setCart,
    cartOpen,
    setCartOpen,
    urgent,
    setUrgent,
    selectedPro,
    setSelectedPro,
    zone,
    setZone,
    bookings,
    setBookings,
    saved,
    save,
    toast,
    setToast,
    add,
    qty,
    summary: totals(cart, urgent),
    categories,
  };
}
const Context = createContext<ReturnType<typeof useAppStore> | null>(null);
export function AppProvider({ children }: { children: ReactNode }) {
  return <Context.Provider value={useAppStore()}>{children}</Context.Provider>;
}
export function useApp() {
  const value = useContext(Context);
  if (!value) throw new Error('AppProvider missing');
  return value;
}
