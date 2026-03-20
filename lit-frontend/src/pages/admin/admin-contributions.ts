import { LitElement, html } from 'lit';
import { customElement, state } from 'lit/decorators.js';
import { iconPlus, iconTrash2 } from '../../lib/icons.js';
import { formatCurrency, monthName, currentMonthYear, MONTHS } from '../../lib/utils.js';
import api from '../../lib/api.js';

const APARTMENT_ID = 'psa-main';

@customElement('admin-contributions')
export class AdminContributions extends LitElement {
  @state() private month = currentMonthYear().month;
  @state() private year = currentMonthYear().year;
  @state() private contributions: any[] = [];
  @state() private flats: any[] = [];
  @state() private users: any[] = [];
  @state() private loading = true;
  @state() private modal = false;
  @state() private saving = false;
  @state() private form: any = { flatId: '', userId: '', month: currentMonthYear().month, year: currentMonthYear().year, type: 'WATER', amount: '', description: '' };

  createRenderRoot() { return this; }
  connectedCallback() {
    super.connectedCallback();
    api.get(`/flats?apartmentId=${APARTMENT_ID}`).then(r => this.flats = r.data).catch(() => {});
    api.get('/users').then(r => this.users = r.data).catch(() => {});
    this._load();
  }

  private async _load() {
    this.loading = true;
    try { const { data } = await api.get(`/contributions/summary?apartmentId=${APARTMENT_ID}&month=${this.month}&year=${this.year}`); this.contributions = data; }
    catch { this.contributions = []; }
    this.loading = false;
  }

  updated(changed: Map<string, any>) {
    if ((changed.has('month') && changed.get('month') !== undefined) || (changed.has('year') && changed.get('year') !== undefined)) this._load();
  }

  private async _handleSave() {
    if (!this.form.flatId || !this.form.userId || !this.form.amount) return;
    this.saving = true;
    try {
      await api.post('/contributions', { ...this.form, month: +this.form.month, year: +this.form.year, amount: +this.form.amount });
      await this._load(); this.modal = false;
      this.form = { flatId: '', userId: '', month: this.month, year: this.year, type: 'WATER', amount: '', description: '' };
    } catch (e: any) { alert(e.response?.data?.message || 'Error saving contribution'); }
    this.saving = false;
  }

  private async _handleDelete(id: string) {
    if (!confirm('Delete this contribution?')) return;
    await api.delete(`/contributions/${id}`); await this._load();
  }

  private _uf(key: string, val: any) { this.form = { ...this.form, [key]: val }; }
  private _years = [2022, 2023, 2024, 2025, 2026, 2027];
  private _typeColors: Record<string, string> = { WATER: 'bg-blue-100 text-blue-700', MAINTENANCE: 'bg-green-100 text-green-700', OTHER: 'bg-gray-100 text-gray-700' };

  render() {
    const totalAmount = this.contributions.reduce((s, c) => s + c.amount, 0);
    return html`
      <div>
        <div class="flex items-center justify-between mb-6">
          <div>
            <h1 class="text-2xl font-bold text-gray-900">Resident Contributions</h1>
            <p class="text-gray-500 text-sm mt-1">${monthName(this.month)} ${this.year} — ${this.contributions.length} entries · ${formatCurrency(totalAmount)} total</p>
            <p class="text-xs text-gray-400 mt-0.5">Credits are automatically deducted from the resident's next bill.</p>
          </div>
          <div class="flex items-center gap-3">
            <psa-select .value=${String(this.month)} @value-changed=${(e: CustomEvent) => this.month = +e.detail}>
              ${MONTHS.map((m, i) => html`<option value=${i + 1}>${m}</option>`)}
            </psa-select>
            <psa-select .value=${String(this.year)} @value-changed=${(e: CustomEvent) => this.year = +e.detail}>
              ${this._years.map(y => html`<option value=${y}>${y}</option>`)}
            </psa-select>
            <psa-button @click=${() => this.modal = true}>${iconPlus('w-4 h-4')} Add Contribution</psa-button>
          </div>
        </div>
        <div class="bg-white rounded-xl border border-gray-200 shadow-sm">
          <div class="overflow-x-auto">
            <table class="w-full text-sm">
              <thead class="bg-gray-50 border-b border-gray-100">
                <tr>${['Flat','Resident','Month/Year','Type','Amount','Description','Applied','Action'].map(h => html`<th class="text-left px-4 py-3 font-medium text-gray-500">${h}</th>`)}</tr>
              </thead>
              <tbody class="divide-y divide-gray-50">
                ${this.loading ? html`<tr><td colspan="8" class="px-4 py-4 text-gray-400">Loading...</td></tr>` :
                  this.contributions.length === 0 ? html`<tr><td colspan="8" class="px-4 py-8 text-center text-gray-400">No contributions for ${monthName(this.month)} ${this.year}.</td></tr>` :
                  this.contributions.map(c => html`
                    <tr class="hover:bg-gray-50">
                      <td class="px-4 py-3 font-medium text-gray-900">Flat ${c.flat?.flatNumber}</td>
                      <td class="px-4 py-3 text-gray-700">${c.user?.name}</td>
                      <td class="px-4 py-3 text-gray-500">${monthName(c.month)} ${c.year}</td>
                      <td class="px-4 py-3"><span class="text-xs font-medium px-2 py-0.5 rounded-full ${this._typeColors[c.type] ?? this._typeColors.OTHER}">${c.type}</span></td>
                      <td class="px-4 py-3 font-semibold text-green-700">${formatCurrency(c.amount)}</td>
                      <td class="px-4 py-3 text-gray-500 max-w-xs truncate">${c.description || '—'}</td>
                      <td class="px-4 py-3">${c.appliedToBillId ? html`<span class="text-xs text-green-600 font-medium">✓ Applied</span>` : html`<span class="text-xs text-orange-500">Pending</span>`}</td>
                      <td class="px-4 py-3">${!c.appliedToBillId ? html`<button @click=${() => this._handleDelete(c.id)} class="p-1 text-red-400 hover:text-red-600 cursor-pointer bg-transparent border-none">${iconTrash2('w-4 h-4')}</button>` : ''}</td>
                    </tr>
                  `)}
              </tbody>
            </table>
          </div>
        </div>

        <psa-modal ?open=${this.modal} modalTitle="Add Contribution" size="sm" @close=${() => this.modal = false}>
          <div class="space-y-4">
            <p class="text-xs text-gray-500 bg-blue-50 rounded-lg px-3 py-2">Record a water/maintenance amount paid by a resident. It will be automatically deducted from their next bill.</p>
            <psa-select label="Flat" .value=${this.form.flatId} @value-changed=${(e: CustomEvent) => {
              const flat = this.flats.find(f => f.id === e.detail);
              const tenant = flat?.tenancies?.[0]?.user;
              this.form = { ...this.form, flatId: e.detail, userId: tenant?.id || '' };
            }}>
              <option value="">Select flat...</option>
              ${this.flats.map(f => html`<option value=${f.id}>Flat ${f.flatNumber}</option>`)}
            </psa-select>
            <psa-select label="Resident" .value=${this.form.userId} @value-changed=${(e: CustomEvent) => this._uf('userId', e.detail)}>
              <option value="">Select resident...</option>
              ${this.users.filter(u => !(u.roles || []).includes('ADMIN')).map(u => html`<option value=${u.id}>${u.name} (${u.email})</option>`)}
            </psa-select>
            <div class="grid grid-cols-2 gap-3">
              <psa-select label="Month" .value=${String(this.form.month)} @value-changed=${(e: CustomEvent) => this._uf('month', +e.detail)}>
                ${MONTHS.map((m, i) => html`<option value=${i + 1}>${m}</option>`)}
              </psa-select>
              <psa-select label="Year" .value=${String(this.form.year)} @value-changed=${(e: CustomEvent) => this._uf('year', +e.detail)}>
                ${this._years.map(y => html`<option value=${y}>${y}</option>`)}
              </psa-select>
            </div>
            <psa-select label="Type" .value=${this.form.type} @value-changed=${(e: CustomEvent) => this._uf('type', e.detail)}>
              <option value="WATER">Water</option><option value="MAINTENANCE">Maintenance</option><option value="OTHER">Other</option>
            </psa-select>
            <psa-input label="Amount (₹)" type="number" .value=${this.form.amount} @value-changed=${(e: CustomEvent) => this._uf('amount', e.detail)}></psa-input>
            <psa-input label="Description (optional)" .value=${this.form.description} @value-changed=${(e: CustomEvent) => this._uf('description', e.detail)} placeholder="e.g. Paid water tanker bill share"></psa-input>
            <div class="flex gap-2 justify-end pt-2">
              <psa-button variant="secondary" @click=${() => this.modal = false}>Cancel</psa-button>
              <psa-button .loading=${this.saving} .disabled=${!this.form.flatId || !this.form.userId || !this.form.amount} @click=${this._handleSave}>Save</psa-button>
            </div>
          </div>
        </psa-modal>
      </div>
    `;
  }
}
