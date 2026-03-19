import { LitElement, html } from 'lit';
import { customElement, state } from 'lit/decorators.js';
import { iconHome, iconUser, iconPhone, iconMail, iconCheckCircle, iconAlertCircle, iconClock } from '../../lib/icons.js';
import { formatCurrency, monthName, currentMonthYear, MONTHS } from '../../lib/utils.js';
import { getUser } from '../../lib/auth.js';
import api from '../../lib/api.js';

@customElement('owner-dashboard')
export class OwnerDashboard extends LitElement {
  @state() private month = currentMonthYear().month;
  @state() private year = currentMonthYear().year;
  @state() private profile: any = null;
  @state() private bills: any[] = [];
  @state() private loading = true;
  private user = getUser();

  createRenderRoot() { return this; }
  connectedCallback() { super.connectedCallback(); this._load(); }

  private async _load() {
    try {
      const { data } = await api.get('/users/me');
      this.profile = data;
    } catch {}
    this.loading = false;
  }

  private async _loadBills() {
    if (!this.profile) return;
    const flatIds = this.profile.ownedFlats?.map((o: any) => o.flatId) ?? [];
    if (!flatIds.length) return;
    const results = await Promise.all(
      flatIds.map((id: string) => api.get(`/bills?flatId=${id}&month=${this.month}&year=${this.year}`).then(r => r.data).catch(() => []))
    );
    this.bills = results.flat();
  }

  updated(changed: Map<string, any>) {
    if (changed.has('profile') && this.profile) this._loadBills();
    if ((changed.has('month') && changed.get('month') !== undefined) || (changed.has('year') && changed.get('year') !== undefined)) this._loadBills();
  }

  private _years = [2024, 2025, 2026, 2027];

  private _statusCfg(status: string) {
    const map: Record<string, any> = {
      PAID: { label: 'Paid', icon: iconCheckCircle('w-4 h-4'), color: 'text-green-600', bg: 'bg-green-50 border-green-200' },
      PARTIAL: { label: 'Partially Paid', icon: iconClock('w-4 h-4'), color: 'text-yellow-600', bg: 'bg-yellow-50 border-yellow-200' },
      PENDING: { label: 'Pending', icon: iconAlertCircle('w-4 h-4'), color: 'text-red-600', bg: 'bg-red-50 border-red-200' },
    };
    return map[status] || map.PENDING;
  }

  render() {
    if (this.loading) return html`<p class="text-gray-500">Loading...</p>`;
    const ownedFlats = this.profile?.ownedFlats ?? [];

    return html`
      <div>
        <div class="mb-6">
          <h1 class="text-2xl font-bold text-gray-900">Owner Dashboard</h1>
          <p class="text-gray-500 text-sm mt-1">Welcome, ${this.user?.name}</p>
        </div>

        <h2 class="text-base font-semibold text-gray-700 mb-3">My Flats</h2>
        ${ownedFlats.length === 0 ? html`<p class="text-gray-400 mb-8">No flats assigned to you yet.</p>` : html`
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-8">
            ${ownedFlats.map((o: any) => {
              const flat = o.flat;
              const tenant = flat?.tenancies?.[0]?.user;
              return html`
                <div class="bg-white rounded-xl border border-gray-200 shadow-sm">
                  <div class="px-6 py-4 border-b border-gray-100 flex items-center gap-3">
                    <div class="w-9 h-9 bg-blue-100 rounded-xl flex items-center justify-center">${iconHome('w-5 h-5 text-blue-600')}</div>
                    <div>
                      <p class="font-bold text-gray-900">Flat ${flat?.flatNumber}</p>
                      <p class="text-xs text-gray-500">${flat?.apartment?.name} · Floor ${flat?.floor}</p>
                    </div>
                  </div>
                  <div class="px-6 py-4">
                    <p class="text-xs font-medium text-gray-500 uppercase tracking-wide mb-2">Current Tenant</p>
                    ${tenant ? html`
                      <div class="space-y-1.5">
                        <div class="flex items-center gap-2 text-sm text-gray-800">${iconUser('w-3.5 h-3.5 text-gray-400')} <span class="font-medium">${tenant.name}</span></div>
                        ${tenant.phone ? html`<div class="flex items-center gap-2 text-sm text-gray-600">${iconPhone('w-3.5 h-3.5 text-gray-400')} <a href="tel:${tenant.phone}" class="hover:text-blue-600">${tenant.phone}</a></div>` : ''}
                        <div class="flex items-center gap-2 text-sm text-gray-600">${iconMail('w-3.5 h-3.5 text-gray-400')} <span>${tenant.email}</span></div>
                      </div>
                    ` : html`<p class="text-sm text-gray-400 italic">No tenant assigned</p>`}
                  </div>
                </div>
              `;
            })}
          </div>
        `}

        ${ownedFlats.length > 0 ? html`
          <div class="flex items-center justify-between mb-3">
            <h2 class="text-base font-semibold text-gray-700">Bills</h2>
            <div class="flex gap-2">
              <psa-select .value=${String(this.month)} @value-changed=${(e: CustomEvent) => this.month = +e.detail}>
                ${MONTHS.map((m, i) => html`<option value=${i + 1}>${m}</option>`)}
              </psa-select>
              <psa-select .value=${String(this.year)} @value-changed=${(e: CustomEvent) => this.year = +e.detail}>
                ${this._years.map(y => html`<option value=${y}>${y}</option>`)}
              </psa-select>
            </div>
          </div>

          ${this.bills.length === 0 ? html`<p class="text-gray-400 text-sm">No bills for ${monthName(this.month)} ${this.year}.</p>` : html`
            <div class="space-y-3">
              ${this.bills.map((bill: any) => {
                const cfg = this._statusCfg(bill.status);
                return html`
                  <div class="border rounded-xl p-4 ${cfg.bg}">
                    <div class="flex items-center justify-between mb-3">
                      <div class="flex items-center gap-2">
                        <span class="${cfg.color}">${cfg.icon}</span>
                        <span class="font-semibold text-gray-900">Flat ${bill.flat?.flatNumber} — ${monthName(this.month)} ${this.year}</span>
                      </div>
                      <span class="text-xs font-semibold px-2 py-0.5 rounded-full border ${cfg.bg} ${cfg.color}">${cfg.label}</span>
                    </div>
                    <div class="grid grid-cols-2 sm:grid-cols-4 gap-3 text-sm">
                      <div><p class="text-xs text-gray-500">Maintenance</p><p class="font-medium">${formatCurrency(bill.maintenanceAmount)}</p></div>
                      ${bill.waterAmount > 0 ? html`<div><p class="text-xs text-gray-500">Water</p><p class="font-medium">${formatCurrency(bill.waterAmount)}</p></div>` : ''}
                      ${bill.previousDue > 0 ? html`<div><p class="text-xs text-gray-500">Prev Due</p><p class="font-medium text-orange-600">${formatCurrency(bill.previousDue)}</p></div>` : ''}
                      <div><p class="text-xs text-gray-500">Total</p><p class="font-bold text-gray-900">${formatCurrency(bill.totalAmount)}</p></div>
                      ${bill.paidAmount > 0 ? html`<div><p class="text-xs text-gray-500">Paid</p><p class="font-medium text-green-600">${formatCurrency(bill.paidAmount)}</p></div>` : ''}
                      ${bill.status !== 'PAID' ? html`<div><p class="text-xs text-gray-500">Balance</p><p class="font-bold text-red-600">${formatCurrency(bill.totalAmount - bill.paidAmount)}</p></div>` : ''}
                    </div>
                  </div>
                `;
              })}
            </div>
          `}
        ` : ''}
      </div>
    `;
  }
}
