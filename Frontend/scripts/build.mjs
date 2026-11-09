import { execSync } from 'node:child_process';
import { cpSync, rmSync } from 'node:fs';

cpSync('shared-design/assets', 'react-customer-portal/public/assets', { recursive: true });
execSync('npm run build -w @kaarigor/customer', { stdio: 'inherit', shell: true });
execSync('npm run build -w @kaarigor/provider', {
  stdio: 'inherit',
  shell: true,
  env: { ...process.env, NG_BUILD_MAX_WORKERS: '2' },
});
cpSync('provider-build/browser', 'dist/provider', { recursive: true });
cpSync('shared-design/assets', 'dist/assets', { recursive: true });
rmSync('provider-build', { recursive: true, force: true });
