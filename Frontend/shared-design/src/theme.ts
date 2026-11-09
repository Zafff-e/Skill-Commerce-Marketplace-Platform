export type Theme = 'auto' | 'light' | 'dark';
export function daypart(date = new Date()) {
  const hour = date.getHours() + date.getMinutes() / 60;
  return hour < 5
    ? 'night'
    : hour < 7
      ? 'dawn'
      : hour < 16
        ? 'day'
        : hour < 18
          ? 'golden'
          : hour < 19.5
            ? 'dusk'
            : 'night';
}
export function applyTheme(theme: Theme) {
  const part = daypart();
  document.documentElement.dataset.daypart = part;
  document.documentElement.dataset.theme =
    theme === 'auto' ? (part === 'night' || part === 'dusk' ? 'dark' : 'light') : theme;
  try {
    localStorage.setItem('kaarigor-theme', theme);
  } catch {}
}
export function storedTheme(): Theme {
  try {
    const value = localStorage.getItem('kaarigor-theme');
    return value === 'light' || value === 'dark' ? value : 'auto';
  } catch {
    return 'auto';
  }
}
