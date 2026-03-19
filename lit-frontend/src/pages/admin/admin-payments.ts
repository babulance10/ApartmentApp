import { LitElement, html } from 'lit';
import { customElement, state } from 'lit/decorators.js';
import { iconTrash2 } from '../../lib/icons.js';
import { formatCurrency, monthName, currentMonthYear, MONTHS } from '../../lib/utils.js';
import api from '../../lib/api.js';

const APARTMENT_ID = 'psa-main';

@customElement('admin-payments')
export class AdminPayments extends LitElement {
  @state() private month = currentMonthYear().month;
  @state() private year = currentMonthYear().year;
  @state() private bills: any[] = [];
  @state() private payments: any[] = [];
  @state() private loading = true;

  createRenderRoot() { return this; }
  connectedCallback() { super.connectedCallback(); this._load(); }

  private async _load() {
    this.loading = true;
    try {
      const { data } = await api.get(`/bills/summary?apartmentId=${APARTMENT_ID}&month=${this.month}&year=${this.year}`);
      this.bills = data.bills || [];
      const billIds = (data.bills || []).map((b: any) => b.id);
      if (billIds.length) {
        const allPayments = await Promise.all(billIds.map((id: string) => api.get(`/payments?billId=${id}`).then(r => r.data)));
        this.payments = allPayments.flat();
      } else { this.payments = []; }
    } catch { this.payments = []; }
    this.loading = false;
  }

  updated(changed: Map<string, any>) {
    if ((changed.has('month') && changed.get('month') !== undefined) || (changed.has('year') && changed.get('year') !== undefined)) this._load();
  }

  private async _deletePayment(id: string) {
    if (!confirm('Delete this payment?')) return;
    await api.delete(`/payments/${id}`); await this._load();
  }

  private _methodColor(m: string) {
    return m === 'UPI' ? 'bg-blue-100 text-blue-700' : m === 'CASH' ? 'bg-green-100 text-green-700' : m === 'BANK_TRANSFER' ? 'bg-purple-100 text-purple-700' : 'bg-orange-100 text-orange-700';
  }

  private _years = [2024, 2025, 2026, 2027];

  render() {
    const totalCollected = this.payments.reduce((s, p) => s + p.amount, 0);
    return html`
      <div>
        <div class="flex items-center justify-between mb-6">
          <div>
            <h1 class="text-2xl font-bold text-gray-900">Payments</h1>
            <p class="text-gray-500 text-sm mt-1">${monthName(this.month)} ${this.year} — ${this.payments.length} payments · ${formatCurrency(totalCollected)} collected</p>
          </div>
        </div>
        <div class="flex gap-3 mb-6">
          <psa-select .value=${String(this.month)} @value-changed=${(e: CustomEvent) => this.month = +e.detail}>
            ${MONTHS.map((m, i) => html`<option value=${i + 1}>${m}</option>`)}
          </psa-select>
          <psa-select .value=${String(this.year)} @value-changed=${(e: CustomEvent) => this.year = +e.detail}>
            ${this._years.map(y => html`<option value=${y}>${y}</option>`)}
          </psa-select>
        </div>
        <div class="bg-white rounded-xl border border-gray-200 shadow-sm">
          <div class="overflow-x-auto">
            <table class="w-full text-sm">
              <thead class="bg-gray-50 border-b border-gray-100">
                <tr>
                  ${['Flat','Amount','Method','Transaction Ref','Date','Action'].map(h => html`<th class="text-left px-4 py-3 font-medium text-gray-500">${h}</th>`)}
                </tr>
              </thead>
              <tbody class="divide-y divide-gray-50">
                ${this.loading ? html`<tr><td colspan="6" class="px-4 py-4 text-gray-400">Loading...</td></tr>` :
                  this.payments.length === 0 ? html`<tr><td colspan="6" class="px-4 py-8 text-center text-gray-400">No payments recorded for this month.</td></tr>` :
                  this.payments.map(p => {
                    const bill = this.bills.find(b => b.id === p.billId);
                    return html`
                      <tr class="hover:bg-gray-50">
                        <td class="px-4 py-3 font-medium text-gray-900">Flat ${bill?.flat?.flatNumber ?? '—'}</td>
                        <td class="px-4 py-3 font-semibold text-green-600">${formatCurrency(p.amount)}</td>
                        <td class="px-4 py-3"><span class="text-xs font-medium px-2 py-0.5 rounded-full ${this._methodColor(p.paymentMethod)}">${p.paymentMethod ?? '—'}</span></td>
                        <td class="px-4 py-3 text-gray-500 font-mono text-xs">${p.transactionRef || '—'}</td>
                        <td class="px-4 py-3 text-gray-500">${new Date(p.paymentDate).toLocaleDateString('en-IN')}</td>
                        <td class="px-4 py-3"><button @click=${() => this._deletePayment(p.id)} class="text-red-400 hover:text-red-600 cursor-pointer bg-transparent border-none">${iconTrash2('w-4 h-4')}</button></td>
                      </tr>
                    `;
                  })}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    `;
  }
}
