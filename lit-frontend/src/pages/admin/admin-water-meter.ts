import { LitElement, html } from 'lit';
import { customElement, state } from 'lit/decorators.js';
import { iconDroplets, iconSave } from '../../lib/icons.js';
import { formatCurrency, monthName, currentMonthYear, MONTHS } from '../../lib/utils.js';
import api from '../../lib/api.js';

const APARTMENT_ID = 'psa-main';
const PRICE_PER_LITER = 0.088;

@customElement('admin-water-meter')
export class AdminWaterMeter extends LitElement {
  @state() private month = currentMonthYear().month;
  @state() private year = currentMonthYear().year;
  @state() private flats: any[] = [];
  @state() private readings: Record<string, { prev: string; curr: string }> = {};
  @state() private loading = true;
  @state() private saving = false;
  @state() private recalculating = false;

  createRenderRoot() { return this; }
  connectedCallback() { super.connectedCallback(); this._loadFlats(); }

  private async _loadFlats() {
    const { data } = await api.get(`/flats?apartmentId=${APARTMENT_ID}`);
    this.flats = data;
    const init: Record<string, { prev: string; curr: string }> = {};
    data.forEach((f: any) => { init[f.id] = { prev: '', curr: '' }; });
    this.readings = init;
    this._loadReadings();
  }

  private async _loadReadings() {
    this.loading = true;
    try {
      const { data } = await api.get(`/water-meter/apartment?apartmentId=${APARTMENT_ID}&month=${this.month}&year=${this.year}`);
      let prevMonth = this.month - 1, prevYear = this.year;
      if (prevMonth === 0) { prevMonth = 12; prevYear--; }
      const prevData = data.length === 0
        ? await api.get(`/water-meter/apartment?apartmentId=${APARTMENT_ID}&month=${prevMonth}&year=${prevYear}`).then(r => r.data).catch(() => [])
        : [];
      const init: Record<string, { prev: string; curr: string }> = {};
      this.flats.forEach((f: any) => {
        const found = data.find((r: any) => r.flatId === f.id);
        if (found) { init[f.id] = { prev: String(found.previousReading), curr: String(found.currentReading) }; }
        else {
          const prevReading = prevData.find((r: any) => r.flatId === f.id);
          init[f.id] = { prev: prevReading ? String(prevReading.currentReading) : '', curr: '' };
        }
      });
      this.readings = init;
    } catch {}
    this.loading = false;
  }

  updated(changed: Map<string, any>) {
    if ((changed.has('month') && changed.get('month') !== undefined) || (changed.has('year') && changed.get('year') !== undefined)) {
      if (this.flats.length) this._loadReadings();
    }
  }

  private async _handleSave() {
    this.saving = true;
    const readingsList = this.flats
      .filter(f => this.readings[f.id]?.prev !== '' && this.readings[f.id]?.curr !== '')
      .map(f => ({ flatId: f.id, month: this.month, year: this.year, previousReading: parseFloat(this.readings[f.id].prev), currentReading: parseFloat(this.readings[f.id].curr), pricePerLiter: PRICE_PER_LITER }));
    try { await api.post('/water-meter/bulk', { readings: readingsList }); await this._loadReadings(); alert('Readings saved!'); }
    catch (e: any) { alert(e.response?.data?.message || 'Error saving readings'); }
    this.saving = false;
  }

  private _updateReading(flatId: string, field: 'prev' | 'curr', val: string) {
    this.readings = { ...this.readings, [flatId]: { ...this.readings[flatId], [field]: val } };
  }

  private async _handleRecalculate() {
    if (!confirm('Recalculate all water amounts based on actual tanker purchases? This will update all existing records.')) return;
    this.recalculating = true;
    try {
      const { data } = await api.post('/water-meter/recalculate', {});
      alert(`Recalculated ${data.updated} out of ${data.total} water readings`);
      await this._loadReadings();
    } catch (e: any) {
      alert(e.response?.data?.message || 'Error recalculating water amounts');
    }
    this.recalculating = false;
  }

  private _years = [2024, 2025, 2026, 2027];

  render() {
    return html`
      <div>
        <div class="flex items-center justify-between mb-6">
          <div>
            <h1 class="text-2xl font-bold text-gray-900">Water Meter Readings</h1>
            <p class="text-gray-500 text-sm mt-1">Rate: ₹${PRICE_PER_LITER}/liter</p>
          </div>
          <div class="flex gap-2">
            <psa-button .loading=${this.recalculating} @click=${this._handleRecalculate} variant="secondary">Recalculate All</psa-button>
            <psa-button .loading=${this.saving} @click=${this._handleSave}>${iconSave('w-4 h-4')} Save Readings</psa-button>
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
                <tr>${['Flat','Prev Reading (L)','Curr Reading (L)','Consumed (L)','Amount'].map(h => html`<th class="text-left px-4 py-3 font-medium text-gray-500">${h}</th>`)}</tr>
              </thead>
              <tbody class="divide-y divide-gray-50">
                ${this.loading ? html`<tr><td colspan="5" class="px-4 py-4 text-gray-400">Loading...</td></tr>` :
                  this.flats.map(flat => {
                    const prev = parseFloat(this.readings[flat.id]?.prev || '0') || 0;
                    const curr = parseFloat(this.readings[flat.id]?.curr || '0') || 0;
                    const consumed = curr > prev ? curr - prev : 0;
                    const amount = Math.round(consumed * PRICE_PER_LITER);
                    return html`
                      <tr class="hover:bg-gray-50">
                        <td class="px-4 py-3 font-medium text-gray-900">
                          <div class="flex items-center gap-2">${iconDroplets('w-4 h-4 text-blue-400')} Flat ${flat.flatNumber}</div>
                        </td>
                        <td class="px-4 py-2">
                          <input type="number" .value=${this.readings[flat.id]?.prev || ''} @input=${(e: Event) => this._updateReading(flat.id, 'prev', (e.target as HTMLInputElement).value)}
                            class="w-32 px-2 py-1.5 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500" placeholder="0" />
                        </td>
                        <td class="px-4 py-2">
                          <input type="number" .value=${this.readings[flat.id]?.curr || ''} @input=${(e: Event) => this._updateReading(flat.id, 'curr', (e.target as HTMLInputElement).value)}
                            class="w-32 px-2 py-1.5 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500" placeholder="0" />
                        </td>
                        <td class="px-4 py-3 text-gray-700">${consumed.toLocaleString('en-IN')}</td>
                        <td class="px-4 py-3 font-medium text-gray-900">${formatCurrency(amount)}</td>
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
