export interface ApiConfig {
  mode: 'demo' | 'live';
  baseUrl: string;
}
export class ApiError extends Error {
  constructor(
    message: string,
    public status: number,
  ) {
    super(message);
  }
}
export async function request<T>(
  config: ApiConfig,
  path: string,
  init: RequestInit = {},
  token?: string,
): Promise<T> {
  if (config.mode !== 'live') throw new ApiError('This action needs a connected API.', 503);
  const abort = new AbortController();
  const timeout = setTimeout(() => abort.abort(), 15000);
  try {
    const response = await fetch(`${config.baseUrl.replace(/\/$/, '')}${path}`, {
      ...init,
      credentials: 'include',
      headers: {
        ...(init.body instanceof FormData ? {} : { 'Content-Type': 'application/json' }),
        ...(token ? { Authorization: `Bearer ${token}` } : {}),
        ...init.headers,
      },
      signal: abort.signal,
    });
    if (!response.ok) {
      let detail = 'The request could not be completed.';
      try {
        const problem = await response.json();
        detail = problem.detail || problem.title || detail;
      } catch {}
      throw new ApiError(detail, response.status);
    }
    return response.status === 204 ? (undefined as T) : await response.json();
  } finally {
    clearTimeout(timeout);
  }
}
