import { LitElement, html } from 'lit';
import { customElement, state } from 'lit/decorators.js';
import { iconCreditCard, iconCheckCircle } from '../../lib/icons.js';
import { formatCurrency, monthName } from '../../lib/utils.js';
import api from '../../lib/api.js';

@customElement('tenant-payments')
export class TenantPayments extends LitElement {
  @state() private payments: any[] = [];
  @state() private loading = true;

  createRenderRoot() { return this; }
  connectedCallback() { super.connectedCallback(); this._load(); }

  private async _load() {
    try {
      const profile = await api.get('/users/me');
      const tenancy = profile.data.tenancies?.[0];
      if (tenancy?.flat) {
        const now = new Date();
        const currentMonth = now.getMonth() + 1;
        const currentYear = now.getFullYear();
        const billsRes = await api.get(`/bills?flatId=${tenancy.flat.id}`);
        const bills = billsRes.data;
        // Only show bills up to current month (exclude future)
        const relevantBills = bills.filter((b: any) =>
          b.year < currentYear || (b.year === currentYear && b.month <= currentMonth)
        );
        if (relevantBills.length) {
          const allPayments = await Promise.all(
            relevantBills.map((b: any) => api.get(`/payments?billId=${b.id}`).then((r: any) => r.data.map((p: any) => ({ ...p, bill: b }))))
          );
          this.payments = allPayments.flat().sort((a: any, b: any) => new Date(b.paymentDate).getTime() - new Date(a.paymentDate).getTime());
        }
      }
    } catch {}
    this.loading = false;
  }

  private _methodColor(m: string) {
    return m === 'UPI' ? 'bg-blue-100 text-blue-700' : m === 'CASH' ? 'bg-green-100 text-green-700' : m === 'BANK_TRANSFER' ? 'bg-purple-100 text-purple-700' : 'bg-orange-100 text-orange-700';
  }

  render() {
    return html`
      <div>
        <div class="mb-6">
          <h1 class="text-2xl font-bold text-gray-900">Payment History</h1>
          <p class="text-gray-500 text-sm mt-1">${this.payments.length} payments recorded</p>
        </div>
        ${this.loading ? html`<p class="text-gray-500">Loading...</p>` :
          this.payments.length === 0 ? html`
            <div class="bg-white rounded-xl border border-gray-200 shadow-sm">
              <div class="px-6 py-12 text-center text-gray-400">
                ${iconCreditCard('w-10 h-10 mx-auto mb-3 opacity-30')}
                <p>No payment history found.</p>
              </div>
            </div>
          ` : html`
            <div class="space-y-3 max-w-2xl">
              ${this.payments.map(p => html`
                <div class="bg-white border border-gray-200 rounded-xl p-4 flex items-center justify-between">
                  <div class="flex items-center gap-3">
                    <div class="w-10 h-10 bg-green-100 rounded-xl flex items-center justify-center">${iconCheckCircle('w-5 h-5 text-green-600')}</div>
                    <div>
                      <p class="font-medium text-gray-900">${monthName(p.bill.month)} ${p.bill.year}</p>
                      <div class="flex items-center gap-2 mt-0.5">
                        <span class="text-xs font-medium px-2 py-0.5 rounded-full ${this._methodColor(p.paymentMethod)}">${p.paymentMethod ?? 'CASH'}</span>
                        ${p.transactionRef ? html`<span class="text-xs text-gray-400 font-mono">${p.transactionRef}</span>` : ''}
                      </div>
                    </div>
                  </div>
                  <div class="text-right">
                    <p class="font-bold text-green-600">${formatCurrency(p.amount)}</p>
                    <p class="text-xs text-gray-400">${new Date(p.paymentDate).toLocaleDateString('en-IN')}</p>
                  </div>
                </div>
              `)}
            </div>
          `}
      </div>
    `;
  }
}
