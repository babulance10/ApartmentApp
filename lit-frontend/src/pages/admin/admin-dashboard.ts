import { LitElement, html, nothing } from 'lit';
import { customElement, state } from 'lit/decorators.js';
import { iconReceipt, iconTrendingUp, iconTrendingDown, iconAlertCircle, iconCheckCircle, iconWallet, iconPiggyBank } from '../../lib/icons.js';
import { formatCurrency, monthName, currentMonthYear } from '../../lib/utils.js';
import api from '../../lib/api.js';

const APARTMENT_ID = 'psa-main';

@customElement('admin-dashboard')
export class AdminDashboard extends LitElement {
  @state() private summary: any = null;
  @state() private expenses: any[] = [];
  @state() private maintenance: any[] = [];
  @state() private allTimeTotals: any = null;
  @state() private loading = true;

  createRenderRoot() { return this; }

  connectedCallback() {
    super.connectedCallback();
    this._load();
  }

  private async _load() {
    const { month, year } = currentMonthYear();
    try {
      const [s, e, m, allTime] = await Promise.all([
        api.get(`/bills/summary?apartmentId=${APARTMENT_ID}&month=${month}&year=${year}`),
        api.get(`/expenses?apartmentId=${APARTMENT_ID}&month=${month}&year=${year}`),
        api.get(`/maintenance?status=OPEN`),
        api.get(`/bills/all-time-totals?apartmentId=${APARTMENT_ID}`),
      ]);
      this.summary = s.data;
      this.expenses = e.data;
      this.maintenance = m.data;
      this.allTimeTotals = allTime.data;
    } catch {}
    this.loading = false;
  }

  render() {
    const { month, year } = currentMonthYear();
    const totalExpenses = this.expenses.reduce((s: number, e: any) => s + e.amount, 0);
    const collected = this.summary?.totalCollected ?? 0;
    const due = this.summary?.totalDue ?? 0;
    const pending = this.summary?.pending ?? 0;
    const paidFlats = this.summary?.bills?.filter((b: any) => b.status === 'PAID').length ?? 0;
    const totalFlats = this.summary?.bills?.length ?? 15;
    const totalReceived = this.allTimeTotals?.totalReceived ?? 0;
    const totalExpensesAllTime = this.allTimeTotals?.totalExpenses ?? 0;
    const remaining = totalReceived - totalExpensesAllTime;

    const stats = [
      { label: 'Total Due', value: formatCurrency(due), icon: iconReceipt, color: 'bg-blue-500', sub: `${monthName(month)} ${year}` },
      { label: 'Collected', value: formatCurrency(collected), icon: iconTrendingUp, color: 'bg-green-500', sub: `${paidFlats}/${totalFlats} flats paid` },
      { label: 'Pending', value: formatCurrency(pending), icon: iconTrendingDown, color: 'bg-red-500', sub: `${totalFlats - paidFlats} flats pending` },
      { label: 'Expenses', value: formatCurrency(totalExpenses), icon: iconTrendingDown, color: 'bg-orange-500', sub: `${this.expenses.length} entries` },
    ];

    return html`
      <div>
        <div class="mb-6">
          <h1 class="text-2xl font-bold text-gray-900">Dashboard</h1>
          <p class="text-gray-500 text-sm mt-1">${monthName(month)} ${year} Overview</p>
        </div>

        <div class="grid grid-cols-1 sm:grid-cols-2 gap-4 mb-4">
          <div class="flex items-center gap-4 bg-gradient-to-r from-indigo-50 to-blue-50 border border-indigo-100 rounded-xl px-5 py-4">
            <div class="w-11 h-11 bg-indigo-500 rounded-xl flex items-center justify-center flex-shrink-0">
              ${iconWallet('w-5 h-5 text-white')}
            </div>
            <div>
              <p class="text-xs font-semibold text-indigo-400 uppercase tracking-wide">Total Received (All Time)</p>
              <p class="text-2xl font-bold text-indigo-700">${this.loading ? '...' : formatCurrency(totalReceived)}</p>
              <p class="text-xs text-indigo-400">Since inception</p>
            </div>
          </div>
          <div class="flex items-center gap-4 bg-gradient-to-r from-emerald-50 to-green-50 border border-emerald-100 rounded-xl px-5 py-4">
            <div class="w-11 h-11 bg-emerald-500 rounded-xl flex items-center justify-center flex-shrink-0">
              ${iconPiggyBank('w-5 h-5 text-white')}
            </div>
            <div>
              <p class="text-xs font-semibold text-emerald-400 uppercase tracking-wide">Remaining Balance</p>
              <p class="text-2xl font-bold text-emerald-700">${this.loading ? '...' : formatCurrency(remaining)}</p>
              <p class="text-xs text-emerald-400">After all expenses</p>
            </div>
          </div>
        </div>

        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
          ${stats.map(({ label, value, icon, color, sub }) => html`
            <div class="bg-white rounded-xl border border-gray-200 shadow-sm">
              <div class="px-6 py-4 flex items-center gap-4">
                <div class="w-12 h-12 ${color} rounded-xl flex items-center justify-center flex-shrink-0">
                  ${icon('w-6 h-6 text-white')}
                </div>
                <div>
                  <p class="text-2xl font-bold text-gray-900">${this.loading ? '...' : value}</p>
                  <p class="text-sm font-medium text-gray-600">${label}</p>
                  <p class="text-xs text-gray-400">${sub}</p>
                </div>
              </div>
            </div>
          `)}
        </div>

        <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <div class="bg-white rounded-xl border border-gray-200 shadow-sm">
            <div class="px-6 py-4 border-b border-gray-100">
              <h2 class="font-semibold text-gray-900">Payment Status — ${monthName(month)} ${year}</h2>
            </div>
            <div>
              ${this.loading ? html`<p class="px-6 py-4 text-gray-500 text-sm">Loading...</p>` :
                !this.summary?.bills?.length ? html`<p class="px-6 py-4 text-gray-400 text-sm">No bills generated yet.</p>` :
                html`<div class="divide-y divide-gray-50">
                  ${this.summary.bills.map((bill: any) => html`
                    <div class="flex items-center justify-between px-6 py-3">
                      <div class="flex items-center gap-3">
                        ${bill.status === 'PAID'
                          ? iconCheckCircle('w-4 h-4 text-green-500')
                          : iconAlertCircle('w-4 h-4 text-red-400')}
                        <span class="text-sm font-medium text-gray-700">Flat ${bill.flat?.flatNumber}</span>
                      </div>
                      <div class="text-right">
                        <span class="text-xs font-medium px-2 py-0.5 rounded-full ${
                          bill.status === 'PAID' ? 'bg-green-100 text-green-700' :
                          bill.status === 'PARTIAL' ? 'bg-yellow-100 text-yellow-700' :
                          'bg-orange-100 text-orange-700'
                        }">${bill.status}</span>
                        <p class="text-xs text-gray-400 mt-0.5">${formatCurrency(bill.totalAmount)}</p>
                      </div>
                    </div>
                  `)}
                </div>`}
            </div>
          </div>

          <div class="bg-white rounded-xl border border-gray-200 shadow-sm">
            <div class="px-6 py-4 border-b border-gray-100">
              <h2 class="font-semibold text-gray-900">Open Maintenance Requests</h2>
            </div>
            <div>
              ${this.loading ? html`<p class="px-6 py-4 text-gray-500 text-sm">Loading...</p>` :
                this.maintenance.length === 0 ? html`<p class="px-6 py-4 text-gray-400 text-sm">No open requests.</p>` :
                html`<div class="divide-y divide-gray-50">
                  ${this.maintenance.slice(0, 8).map((req: any) => html`
                    <div class="flex items-center justify-between px-6 py-3">
                      <div>
                        <p class="text-sm font-medium text-gray-700">${req.title}</p>
                        <p class="text-xs text-gray-400">Flat ${req.flat?.flatNumber} · ${req.user?.name}</p>
                      </div>
                      <span class="text-xs font-medium px-2 py-0.5 rounded-full ${
                        req.priority === 'HIGH' ? 'bg-red-100 text-red-700' :
                        req.priority === 'MEDIUM' ? 'bg-yellow-100 text-yellow-700' :
                        'bg-blue-100 text-blue-700'
                      }">${req.priority}</span>
                    </div>
                  `)}
                </div>`}
            </div>
          </div>
        </div>
      </div>
    `;
  }
}
