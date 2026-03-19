import { LitElement, html } from 'lit';
import { customElement, state } from 'lit/decorators.js';
import { iconReceipt, iconCheckCircle, iconAlertCircle, iconClock, iconBuilding2 } from '../../lib/icons.js';
import { formatCurrency, monthName, currentMonthYear, MONTHS } from '../../lib/utils.js';
import { getUser } from '../../lib/auth.js';
import api from '../../lib/api.js';

@customElement('tenant-bills')
export class TenantBills extends LitElement {
  @state() private month = currentMonthYear().month;
  @state() private year = currentMonthYear().year;
  @state() private bills: any[] = [];
  @state() private flatInfo: any = null;
  @state() private apartment: any = null;
  @state() private loading = true;
  private user = getUser();

  createRenderRoot() { return this; }
  connectedCallback() { super.connectedCallback(); this._load(); }

  private async _load() {
    this.loading = true;
    try {
      const profile = await api.get('/users/me');
      const tenancy = profile.data.tenancies?.[0];
      if (tenancy?.flat) {
        this.flatInfo = tenancy.flat;
        const [billsRes, aptRes] = await Promise.all([
          api.get(`/bills?flatId=${tenancy.flat.id}&month=${this.month}&year=${this.year}`),
          api.get('/apartments'),
        ]);
        this.bills = billsRes.data;
        if (aptRes.data.length) this.apartment = aptRes.data[0];
      }
    } catch {}
    this.loading = false;
  }

  updated(changed: Map<string, any>) {
    if ((changed.has('month') && changed.get('month') !== undefined) || (changed.has('year') && changed.get('year') !== undefined)) this._load();
  }

  private _years = [2024, 2025, 2026, 2027];

  private _statusConfig(status: string) {
    const map: Record<string, any> = {
      PAID: { icon: iconCheckCircle('w-5 h-5'), label: 'Paid', color: 'text-green-600', bg: 'bg-green-50 border-green-200' },
      PARTIAL: { icon: iconClock('w-5 h-5'), label: 'Partially Paid', color: 'text-yellow-600', bg: 'bg-yellow-50 border-yellow-200' },
      PENDING: { icon: iconAlertCircle('w-5 h-5'), label: 'Payment Due', color: 'text-red-600', bg: 'bg-red-50 border-red-200' },
    };
    return map[status] || map.PENDING;
  }

  render() {
    const bill = this.bills[0];
    return html`
      <div>
        <div class="mb-6">
          <h1 class="text-2xl font-bold text-gray-900">My Bills</h1>
          <p class="text-gray-500 text-sm mt-1">${this.flatInfo ? `Flat ${this.flatInfo.flatNumber}` : 'Loading...'} — ${this.user?.name}</p>
        </div>
        <div class="flex gap-3 mb-6">
          <psa-select .value=${String(this.month)} @value-changed=${(e: CustomEvent) => this.month = +e.detail}>
            ${MONTHS.map((m, i) => html`<option value=${i + 1}>${m}</option>`)}
          </psa-select>
          <psa-select .value=${String(this.year)} @value-changed=${(e: CustomEvent) => this.year = +e.detail}>
            ${this._years.map(y => html`<option value=${y}>${y}</option>`)}
          </psa-select>
        </div>

        ${this.loading ? html`<p class="text-gray-500">Loading...</p>` :
          !bill ? html`
            <div class="bg-white rounded-xl border border-gray-200 shadow-sm">
              <div class="px-6 py-12 text-center text-gray-400">
                ${iconReceipt('w-10 h-10 mx-auto mb-3 opacity-30')}
                <p>No bill generated for ${monthName(this.month)} ${this.year}.</p>
              </div>
            </div>
          ` : html`
            <div class="max-w-xl space-y-4">
              <div class="flex items-center gap-3 p-4 rounded-xl border ${this._statusConfig(bill.status).bg}">
                <span class="${this._statusConfig(bill.status).color}">${this._statusConfig(bill.status).icon}</span>
                <div>
                  <p class="font-semibold ${this._statusConfig(bill.status).color}">${this._statusConfig(bill.status).label}</p>
                  <p class="text-sm text-gray-500">${monthName(this.month)} ${this.year} — Flat ${this.flatInfo?.flatNumber}</p>
                </div>
              </div>

              <div class="bg-white rounded-xl border border-gray-200 shadow-sm">
                <div class="px-6 py-4 border-b border-gray-100"><h2 class="font-semibold text-gray-900">Bill Breakdown</h2></div>
                <div class="px-6 py-4 space-y-3">
                  <div class="flex justify-between text-sm"><span class="text-gray-600">Maintenance</span><span class="font-medium">${formatCurrency(bill.maintenanceAmount)}</span></div>
                  ${bill.waterAmount > 0 ? html`<div class="flex justify-between text-sm"><span class="text-gray-600">Water Charges</span><span class="font-medium">${formatCurrency(bill.waterAmount)}</span></div>` : ''}
                  ${bill.previousDue > 0 ? html`<div class="flex justify-between text-sm"><span class="text-gray-600">Previous Due</span><span class="font-medium text-orange-600">${formatCurrency(bill.previousDue)}</span></div>` : ''}
                  <div class="border-t border-gray-100 pt-3 flex justify-between">
                    <span class="font-semibold text-gray-900">Total</span>
                    <span class="font-bold text-lg text-gray-900">${formatCurrency(bill.totalAmount)}</span>
                  </div>
                  ${bill.paidAmount > 0 ? html`
                    <div class="flex justify-between text-sm"><span class="text-gray-600">Paid</span><span class="font-medium text-green-600">${formatCurrency(bill.paidAmount)}</span></div>
                    <div class="flex justify-between text-sm font-semibold"><span class="text-gray-800">Balance Due</span><span class="text-red-600">${formatCurrency(bill.totalAmount - bill.paidAmount)}</span></div>
                  ` : ''}
                </div>
              </div>

              ${bill.status !== 'PAID' && this.apartment ? html`
                <div class="bg-white rounded-xl border border-gray-200 shadow-sm">
                  <div class="px-6 py-4 border-b border-gray-100"><h2 class="font-semibold text-gray-900">Pay via UPI</h2></div>
                  <div class="px-6 py-4">
                    <div class="bg-blue-50 border border-blue-100 rounded-xl p-4 text-center space-y-2">
                      ${iconBuilding2('w-8 h-8 text-blue-600 mx-auto')}
                      <p class="text-2xl font-bold text-blue-700">${this.apartment.upiNumber}</p>
                      <p class="text-sm text-gray-600">${this.apartment.upiName}</p>
                      <p class="text-xs text-gray-400 mt-2">Please use Flat ${this.flatInfo?.flatNumber} / ${monthName(this.month)} ${this.year} as payment remarks</p>
                    </div>
                  </div>
                </div>
              ` : ''}
            </div>
          `}
      </div>
    `;
  }
}
