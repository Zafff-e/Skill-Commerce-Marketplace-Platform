export function providerUrl(route = 'register') {
  const origin = (import.meta.env.VITE_PROVIDER_ORIGIN || '').replace(/\/$/, '');
  return `${origin}/provider/#/${route}`;
}
