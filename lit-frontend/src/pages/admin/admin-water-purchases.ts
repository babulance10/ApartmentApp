import { LitElement, html } from 'lit';
import { customElement, state } from 'lit/decorators.js';
import { iconPlus, iconTrash2, iconEdit2, iconTruck } from '../../lib/icons.js';
import { formatCurrency, monthName, currentMonthYear, MONTHS } from '../../lib/utils.js';
import api from '../../lib/api.js';

const APARTMENT_ID = 'psa-main';
const emptyForm = { srNo: '', capacityLiters: '10000', tokenNo: '', bookedOn: '', deliveredOn: '', amountPaid: '', vehicleNo: '' };

@customElement('admin-water-purchases')
export class AdminWaterPurchases extends LitElement {
  @state() private month = currentMonthYear().month;
  @state() private year = currentMonthYear().year;
  @state() private purchases: any[] = [];
  @state() private loading = true;
  @state() private modal = false;
  @state() private editItem: any = null;
  @state() private form = { ...emptyForm };
  @state() private saving = false;

  createRenderRoot() { return this; }
  connectedCallback() { super.connectedCallback(); this._load(); }

  private async _load() {
    this.loading = true;
    try { const { data } = await api.get(`/water-purchases?apartmentId=${APARTMENT_ID}&month=${this.month}&year=${this.year}`); this.purchases = data; }
    catch { this.purchases = []; }
    this.loading = false;
  }

  updated(changed: Map<string, any>) {
    if ((changed.has('month') && changed.get('month') !== undefined) || (changed.has('year') && changed.get('year') !== undefined)) this._load();
  }

  private _openCreate() {
    this.editItem = null;
    const today = new Date().toISOString().split('T')[0];
    const nextSr = this.purchases.length > 0 ? Math.max(...this.purchases.map((p: any) => p.srNo)) + 1 : 1;
    this.form = { ...emptyForm, srNo: String(nextSr), bookedOn: today, deliveredOn: today };
    this.modal = true;
  }

  private _openEdit(item: any) {
    this.editItem = item;
    this.form = { srNo: String(item.srNo), capacityLiters: String(item.capacityLiters), tokenNo: item.tokenNo, bookedOn: item.bookedOn?.split('T')[0] ?? '', deliveredOn: item.deliveredOn?.split('T')[0] ?? '', amountPaid: String(item.amountPaid), vehicleNo: item.vehicleNo };
    this.modal = true;
  }

  private async _handleSave() {
    this.saving = true;
    try {
      const payload = { apartmentId: APARTMENT_ID, month: this.month, year: this.year, srNo: +this.form.srNo, capacityLiters: +this.form.capacityLiters, tokenNo: this.form.tokenNo, bookedOn: this.form.bookedOn, deliveredOn: this.form.deliveredOn, amountPaid: +this.form.amountPaid, vehicleNo: this.form.vehicleNo };
      if (this.editItem) await api.patch(`/water-purchases/${this.editItem.id}`, payload);
      else await api.post('/water-purchases', payload);
      await this._load(); this.modal = false;
    } catch (e: any) { alert(e.response?.data?.message || 'Error saving'); }
    this.saving = false;
  }

  private async _handleDelete(id: string) {
    if (!confirm('Delete this purchase entry?')) return;
    await api.delete(`/water-purchases/${id}`); await this._load();
  }

  private _uf(key: string, val: string) { this.form = { ...this.form, [key]: val }; }
  private _years = [2024, 2025, 2026, 2027];

  render() {
    const totalAmount = this.purchases.reduce((s, p) => s + p.amountPaid, 0);
    const totalLiters = this.purchases.reduce((s, p) => s + p.capacityLiters, 0);
    const isFormValid = this.form.bookedOn && this.form.deliveredOn && this.form.amountPaid && this.form.srNo;

    return html`
      <div>
        <div class="flex items-center justify-between mb-6">
          <div>
            <h1 class="text-2xl font-bold text-gray-900">Water Tanker Purchases</h1>
            <p class="text-gray-500 text-sm mt-1">${monthName(this.month)} ${this.year} — ${this.purchases.length} deliveries · ${totalLiters.toLocaleString('en-IN')} L · ${formatCurrency(totalAmount)}</p>
          </div>
          <psa-button @click=${this._openCreate}>${iconPlus('w-4 h-4')} Add Entry</psa-button>
        </div>
        <div class="flex gap-3 mb-6">
          <psa-select .value=${String(this.month)} @value-changed=${(e: CustomEvent) => this.month = +e.detail}>
            ${MONTHS.map((m, i) => html`<option value=${i + 1}>${m}</option>`)}
          </psa-select>
          <psa-select .value=${String(this.year)} @value-changed=${(e: CustomEvent) => this.year = +e.detail}>
            ${this._years.map(y => html`<option value=${y}>${y}</option>`)}
          </psa-select>
        </div>

        ${this.purchases.length > 0 ? html`
          <div class="grid grid-cols-3 gap-4 mb-6">
            <div class="bg-blue-50 border border-blue-100 rounded-xl p-4">
              <p class="text-xs font-medium text-blue-600">Total Deliveries</p>
              <p class="text-2xl font-bold text-blue-900 mt-1">${this.purchases.length}</p>
            </div>
            <div class="bg-cyan-50 border border-cyan-100 rounded-xl p-4">
              <p class="text-xs font-medium text-cyan-600">Total Water</p>
              <p class="text-2xl font-bold text-cyan-900 mt-1">${(totalLiters / 1000).toFixed(0)}K L</p>
            </div>
            <div class="bg-green-50 border border-green-100 rounded-xl p-4">
              <p class="text-xs font-medium text-green-600">Total Spent</p>
              <p class="text-2xl font-bold text-green-900 mt-1">${formatCurrency(totalAmount)}</p>
            </div>
          </div>
        ` : ''}

        <div class="bg-white rounded-xl border border-gray-200 shadow-sm">
          <div class="overflow-x-auto">
            <table class="w-full text-sm">
              <thead class="bg-gray-50 border-b border-gray-100">
                <tr>${['Sr.','Capacity','Token No','Booked On','Delivered On','Amount Paid','Vehicle No','Actions'].map(h => html`<th class="text-left px-4 py-3 font-medium text-gray-500">${h}</th>`)}</tr>
              </thead>
              <tbody class="divide-y divide-gray-50">
                ${this.loading ? html`<tr><td colspan="8" class="px-4 py-4 text-gray-400">Loading...</td></tr>` :
                  this.purchases.length === 0 ? html`
                    <tr><td colspan="8" class="px-4 py-12 text-center">
                      ${iconTruck('w-10 h-10 mx-auto text-gray-300 mb-2')}
                      <p class="text-gray-400">No water purchases for ${monthName(this.month)} ${this.year}.</p>
                    </td></tr>
                  ` : this.purchases.map(p => html`
                    <tr class="hover:bg-gray-50">
                      <td class="px-4 py-3 font-medium text-gray-700">${p.srNo}</td>
                      <td class="px-4 py-3 text-gray-700">${p.capacityLiters.toLocaleString('en-IN')} L</td>
                      <td class="px-4 py-3 font-mono text-gray-800 text-xs font-semibold">${p.tokenNo}</td>
                      <td class="px-4 py-3 text-gray-600 text-xs">${new Date(p.bookedOn).toLocaleDateString('en-IN')}</td>
                      <td class="px-4 py-3 text-gray-600 text-xs">${new Date(p.deliveredOn).toLocaleDateString('en-IN')}</td>
                      <td class="px-4 py-3 font-semibold text-gray-900">${formatCurrency(p.amountPaid)}</td>
                      <td class="px-4 py-3 font-mono text-xs text-gray-700">${p.vehicleNo}</td>
                      <td class="px-4 py-3 flex gap-2">
                        <button @click=${() => this._openEdit(p)} class="text-blue-400 hover:text-blue-600 cursor-pointer bg-transparent border-none">${iconEdit2('w-4 h-4')}</button>
                        <button @click=${() => this._handleDelete(p.id)} class="text-red-400 hover:text-red-600 cursor-pointer bg-transparent border-none">${iconTrash2('w-4 h-4')}</button>
                      </td>
                    </tr>
                  `)}
              </tbody>
            </table>
          </div>
        </div>

        <psa-modal ?open=${this.modal} modalTitle=${this.editItem ? 'Edit Purchase Entry' : 'Add Water Purchase'} size="md" @close=${() => this.modal = false}>
          <div class="grid grid-cols-2 gap-4">
            <psa-input label="Sr. No" type="number" .value=${this.form.srNo} @value-changed=${(e: CustomEvent) => this._uf('srNo', e.detail)}></psa-input>
            <psa-input label="Capacity (Liters)" type="number" .value=${this.form.capacityLiters} @value-changed=${(e: CustomEvent) => this._uf('capacityLiters', e.detail)}></psa-input>
            <psa-input label="Token No" .value=${this.form.tokenNo} @value-changed=${(e: CustomEvent) => this._uf('tokenNo', e.detail)} placeholder="e.g. 3583"></psa-input>
            <psa-input label="Amount Paid (₹)" type="number" .value=${this.form.amountPaid} @value-changed=${(e: CustomEvent) => this._uf('amountPaid', e.detail)} placeholder="e.g. 1100"></psa-input>
            <psa-input label="Booked On" type="date" .value=${this.form.bookedOn} @value-changed=${(e: CustomEvent) => this._uf('bookedOn', e.detail)}></psa-input>
            <psa-input label="Delivered On" type="date" .value=${this.form.deliveredOn} @value-changed=${(e: CustomEvent) => this._uf('deliveredOn', e.detail)}></psa-input>
            <div class="col-span-2">
              <psa-input label="Vehicle No" .value=${this.form.vehicleNo} @value-changed=${(e: CustomEvent) => this._uf('vehicleNo', e.detail)} placeholder="e.g. TS12UC2432"></psa-input>
            </div>
          </div>
          <div class="flex gap-2 justify-end pt-4">
            <psa-button variant="secondary" @click=${() => this.modal = false}>Cancel</psa-button>
            <psa-button .loading=${this.saving} .disabled=${!isFormValid} @click=${this._handleSave}>Save</psa-button>
          </div>
        </psa-modal>
      </div>
    `;
  }
}
