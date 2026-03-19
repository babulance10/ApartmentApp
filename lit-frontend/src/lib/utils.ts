export function formatCurrency(amount: number) {
  return `\u20B9${amount.toLocaleString('en-IN')}`;
}

export const MONTHS = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

export function monthName(m: number) {
  return MONTHS[m - 1] ?? '';
}

export function currentMonthYear() {
  const d = new Date();
  return { month: d.getMonth() + 1, year: d.getFullYear() };
}

export function billStatusColor(status: string) {
  if (status === 'PAID') return 'text-green-600 bg-green-50';
  if (status === 'PARTIAL') return 'text-yellow-600 bg-yellow-50';
  return 'text-red-600 bg-red-50';
}

export function priorityColor(p: string) {
  if (p === 'HIGH') return 'text-red-600 bg-red-50';
  if (p === 'MEDIUM') return 'text-yellow-600 bg-yellow-50';
  return 'text-blue-600 bg-blue-50';
}

export function statusColor(s: string) {
  if (s === 'RESOLVED') return 'text-green-600 bg-green-50';
  if (s === 'IN_PROGRESS') return 'text-yellow-600 bg-yellow-50';
  return 'text-red-600 bg-red-50';
}
