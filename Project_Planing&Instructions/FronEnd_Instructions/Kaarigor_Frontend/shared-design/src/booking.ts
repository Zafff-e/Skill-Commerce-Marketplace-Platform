import { allTasks } from './catalog';
export interface CartLine {
  taskId: string;
  quantity: number;
}
export const URGENCY_FEE = 300;
export function totals(lines: CartLine[], urgent: boolean) {
  const labor = lines.reduce((sum, line) => {
    const t = allTasks.find((t) => t.id === line.taskId);
    if (!t || !Number.isInteger(line.quantity) || line.quantity < 1 || line.quantity > 20)
      throw new Error('Invalid cart item');
    return sum + t.price * line.quantity;
  }, 0);
  const urgency = lines.length && urgent ? URGENCY_FEE : 0;
  return {
    labor,
    urgency,
    total: labor + urgency,
    platformCommission: Math.round((labor + urgency) * 0.1),
  };
}
export const workStates = ['Accepted', 'OnTheWay', 'Arrived', 'InProgress', 'Completed'] as const;
export type WorkState = (typeof workStates)[number];
export function nextWorkState(current: WorkState): WorkState {
  const index = workStates.indexOf(current);
  if (index < 0) throw new Error('Unknown work state');
  return workStates[Math.min(index + 1, workStates.length - 1)];
}
export function validBangladeshPhone(value: string) {
  return /^(?:\+?88)?01[3-9]\d{8}$/.test(value.replace(/[\s-]/g, ''));
}
export function validUpload(file: { size: number; type: string }) {
  return (
    file.size > 0 &&
    file.size <= 5 * 1024 * 1024 &&
    ['image/jpeg', 'image/png', 'application/pdf'].includes(file.type)
  );
}
