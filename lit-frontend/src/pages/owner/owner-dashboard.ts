import { LitElement, html } from 'lit';
import { customElement, state } from 'lit/decorators.js';
import { iconHome, iconUser, iconPhone, iconMail, iconCheckCircle, iconAlertCircle, iconClock, iconPlus, iconHandCoins } from '../../lib/icons.js';
import { formatCurrency, monthName, currentMonthYear, MONTHS } from '../../lib/utils.js';
import { getUser } from '../../lib/auth.js';
import api from '../../lib/api.js';

@customElement('owner-dashboard')
export class OwnerDashboard extends LitElement {
  @state() private month = currentMonthYear().month;
  @state() private year = currentMonthYear().year;
  @state() private profile: any = null;
  @state() private bills: any[] = [];
  @state() private contributions: any[] = [];
  @state() private loading = true;
  @state() private pocketModal = false;
  @state() private pocketSaving = false;
  @state() private pocketForm: any = { flatId: '', month: currentMonthYear().month, year: currentMonthYear().year, type: 'MAINTENANCE', amount: '', description: '' };
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
    const [billResults, contribResults] = await Promise.all([
      Promise.all(flatIds.map((id: string) => api.get(`/bills?flatId=${id}&month=${this.month}&year=${this.year}`).then(r => r.data).catch(() => []))),
      Promise.all(flatIds.map((id: string) => api.get(`/contributions?flatId=${id}`).then(r => r.data).catch(() => []))),
    ]);
    this.bills = billResults.flat();
    this.contributions = contribResults.flat();
  }

  updated(changed: Map<string, any>) {
    if (changed.has('profile') && this.profile) this._loadBills();
    if ((changed.has('month') && changed.get('month') !== undefined) || (changed.has('year') && changed.get('year') !== undefined)) this._loadBills();
  }

  private async _savePocketPayment() {
    if (!this.pocketForm.flatId || !this.pocketForm.amount) return;
    this.pocketSaving = true;
    try {
      await api.post('/contributions', {
        flatId: this.pocketForm.flatId,
        userId: this.user.id,
        month: +this.pocketForm.month,
        year: +this.pocketForm.year,
        type: this.pocketForm.type,
        amount: +this.pocketForm.amount,
        description: this.pocketForm.description || `Owner pocket payment`,
      });
      await this._loadBills();
      this.pocketModal = false;
      this.pocketForm = { flatId: '', month: this.month, year: this.year, type: 'MAINTENANCE', amount: '', description: '' };
      alert('Payment recorded! It will be auto-deducted from the next maintenance bill.');
    } catch (e: any) { alert(e.response?.data?.message || 'Error saving payment'); }
    this.pocketSaving = false;
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
    const pendingContribs = this.contributions.filter((c: any) => !c.appliedToBillId);
    const totalCredit = pendingContribs.reduce((s: number, c: any) => s + c.amount, 0);

    return html`
      <div class="animate-fadeIn">
        <!-- Header -->
        <div class="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4 mb-6">
          <div>
            <h1 class="text-2xl font-bold text-gray-900">Owner Dashboard</h1>
            <p class="text-gray-500 text-sm mt-1">Welcome, ${this.user?.name}</p>
          </div>
          ${ownedFlats.length > 0 ? html`
            <button @click=${() => { this.pocketForm = { ...this.pocketForm, flatId: ownedFlats[0]?.flatId || '' }; this.pocketModal = true; }}
              class="inline-flex items-center gap-2 px-4 py-2.5 bg-gradient-to-r from-emerald-600 to-teal-600 hover:from-emerald-700 hover:to-teal-700 text-white text-sm font-semibold rounded-xl shadow-md cursor-pointer border-none transition-all">
              ${iconPlus('w-4 h-4')} Record Pocket Payment
            </button>
          ` : ''}
        </div>

        <!-- Pocket Payment Credit Banner -->
        ${totalCredit > 0 ? html`
          <div class="bg-gradient-to-r from-emerald-50 to-teal-50 border border-emerald-200 rounded-2xl p-4 mb-6 flex items-center gap-4">
            <div class="w-10 h-10 bg-emerald-100 rounded-xl flex items-center justify-center flex-shrink-0">
              ${iconHandCoins('w-5 h-5 text-emerald-600')}
            </div>
            <div class="flex-1">
              <p class="font-semibold text-emerald-800">Pending Credit: ${formatCurrency(totalCredit)}</p>
              <p class="text-xs text-emerald-600 mt-0.5">You have ${pendingContribs.length} unapplied pocket payment(s). These will be auto-deducted from the next maintenance bill.</p>
            </div>
          </div>
        ` : ''}

        <!-- My Flats -->
        <h2 class="text-base font-semibold text-gray-700 mb-3">My Flats</h2>
        ${ownedFlats.length === 0 ? html`<p class="text-gray-400 mb-8">No flats assigned to you yet.</p>` : html`
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-8">
            ${ownedFlats.map((o: any) => {
              const flat = o.flat;
              const tenant = flat?.tenancies?.[0]?.user;
              const flatCredits = pendingContribs.filter((c: any) => c.flatId === o.flatId);
              return html`
                <div class="bg-white rounded-xl border border-gray-200 shadow-sm">
                  <div class="px-5 py-4 border-b border-gray-100 flex items-center gap-3">
                    <div class="w-9 h-9 bg-blue-100 rounded-xl flex items-center justify-center">${iconHome('w-5 h-5 text-blue-600')}</div>
                    <div class="flex-1">
                      <p class="font-bold text-gray-900">Flat ${flat?.flatNumber}</p>
                      <p class="text-xs text-gray-500">Floor ${flat?.floor}</p>
                    </div>
                    ${flatCredits.length > 0 ? html`
                      <span class="text-xs font-semibold px-2 py-1 bg-emerald-100 text-emerald-700 rounded-full">
                        CR ${formatCurrency(flatCredits.reduce((s: number, c: any) => s + c.amount, 0))}
                      </span>
                    ` : ''}
                  </div>
                  <div class="px-5 py-4">
                    <p class="text-xs font-medium text-gray-500 uppercase tracking-wide mb-2">Current Tenant</p>
                    ${tenant ? html`
                      <div class="space-y-1.5">
                        <div class="flex items-center gap-2 text-sm text-gray-800">${iconUser('w-3.5 h-3.5 text-gray-400')} <span class="font-medium">${tenant.name}</span></div>
                        ${tenant.phone ? html`<div class="flex items-center gap-2 text-sm text-gray-600">${iconPhone('w-3.5 h-3.5 text-gray-400')} <a href="tel:${tenant.phone}" class="hover:text-blue-600">${tenant.phone}</a></div>` : ''}
                        <div class="flex items-center gap-2 text-sm text-gray-600">${iconMail('w-3.5 h-3.5 text-gray-400')} <span class="truncate">${tenant.email}</span></div>
                      </div>
                    ` : html`<p class="text-sm text-gray-400 italic">No tenant assigned</p>`}
                  </div>
                </div>
              `;
            })}
          </div>
        `}

        <!-- Bills section -->
        ${ownedFlats.length > 0 ? html`
          <div class="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3 mb-3">
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
            <div class="space-y-3 mb-8">
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

        <!-- Pocket Payment History -->
        ${this.contributions.length > 0 ? html`
          <h2 class="text-base font-semibold text-gray-700 mb-3">My Pocket Payments</h2>
          <div class="bg-white rounded-xl border border-gray-200 shadow-sm overflow-hidden mb-6">
            <div class="overflow-x-auto">
              <table class="w-full text-sm">
                <thead class="bg-gray-50 border-b border-gray-100">
                  <tr>
                    <th class="text-left px-4 py-3 font-medium text-gray-500">Flat</th>
                    <th class="text-left px-4 py-3 font-medium text-gray-500">Period</th>
                    <th class="text-left px-4 py-3 font-medium text-gray-500">Type</th>
                    <th class="text-right px-4 py-3 font-medium text-gray-500">Amount</th>
                    <th class="text-left px-4 py-3 font-medium text-gray-500">Description</th>
                    <th class="text-left px-4 py-3 font-medium text-gray-500">Status</th>
                  </tr>
                </thead>
                <tbody class="divide-y divide-gray-50">
                  ${this.contributions.slice(0, 10).map((c: any) => html`
                    <tr class="hover:bg-gray-50">
                      <td class="px-4 py-3 font-medium text-gray-900">Flat ${c.flat?.flatNumber}</td>
                      <td class="px-4 py-3 text-gray-500">${monthName(c.month)} ${c.year}</td>
                      <td class="px-4 py-3"><span class="text-xs font-medium px-2 py-0.5 rounded-full bg-emerald-100 text-emerald-700">${c.type}</span></td>
                      <td class="px-4 py-3 text-right font-semibold text-emerald-700">${formatCurrency(c.amount)}</td>
                      <td class="px-4 py-3 text-gray-500 max-w-xs truncate">${c.description || '—'}</td>
                      <td class="px-4 py-3">
                        ${c.appliedToBillId
                          ? html`<span class="text-xs text-green-600 font-medium">✓ Applied to bill</span>`
                          : html`<span class="text-xs text-amber-600 font-medium">⏳ Pending next bill</span>`}
                      </td>
                    </tr>
                  `)}
                </tbody>
              </table>
            </div>
          </div>
        ` : ''}

        <!-- Pocket Payment Modal -->
        <psa-modal ?open=${this.pocketModal} modalTitle="Record Pocket Payment" size="sm" @close=${() => this.pocketModal = false}>
          <div class="space-y-4">
            <div class="bg-emerald-50 rounded-xl px-4 py-3 text-sm text-emerald-800 border border-emerald-200">
              ${iconHandCoins('w-4 h-4 inline mr-1')}
              This amount will be automatically deducted from the next maintenance bill for this flat.
            </div>
            <psa-select label="Flat" .value=${this.pocketForm.flatId} @value-changed=${(e: CustomEvent) => this.pocketForm = { ...this.pocketForm, flatId: e.detail }}>
              <option value="">Select flat...</option>
              ${ownedFlats.map((o: any) => html`<option value=${o.flatId}>Flat ${o.flat?.flatNumber}</option>`)}
            </psa-select>
            <div class="grid grid-cols-2 gap-3">
              <psa-select label="Month" .value=${String(this.pocketForm.month)} @value-changed=${(e: CustomEvent) => this.pocketForm = { ...this.pocketForm, month: +e.detail }}>
                ${MONTHS.map((m, i) => html`<option value=${i + 1}>${m}</option>`)}
              </psa-select>
              <psa-select label="Year" .value=${String(this.pocketForm.year)} @value-changed=${(e: CustomEvent) => this.pocketForm = { ...this.pocketForm, year: +e.detail }}>
                ${this._years.map(y => html`<option value=${y}>${y}</option>`)}
              </psa-select>
            </div>
            <psa-select label="Payment Type" .value=${this.pocketForm.type} @value-changed=${(e: CustomEvent) => this.pocketForm = { ...this.pocketForm, type: e.detail }}>
              <option value="MAINTENANCE">Maintenance (adjusts next bill)</option>
              <option value="WATER">Water (adjusts next bill)</option>
              <option value="OTHER">Other expense</option>
            </psa-select>
            <psa-input label="Amount (₹)" type="number" .value=${this.pocketForm.amount}
              @value-changed=${(e: CustomEvent) => this.pocketForm = { ...this.pocketForm, amount: e.detail }}></psa-input>
            <psa-input label="Description (optional)" .value=${this.pocketForm.description}
              @value-changed=${(e: CustomEvent) => this.pocketForm = { ...this.pocketForm, description: e.detail }}
              placeholder="e.g. Paid plumber from pocket"></psa-input>
            <div class="flex gap-2 justify-end pt-2">
              <psa-button variant="secondary" @click=${() => this.pocketModal = false}>Cancel</psa-button>
              <psa-button .loading=${this.pocketSaving} .disabled=${!this.pocketForm.flatId || !this.pocketForm.amount} @click=${this._savePocketPayment}>Save Payment</psa-button>
            </div>
          </div>
        </psa-modal>
      </div>
    `;
  }
}
