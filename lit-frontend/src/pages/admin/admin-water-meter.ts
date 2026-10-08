import { LitElement, html } from 'lit';
import { customElement, state } from 'lit/decorators.js';
import { iconDroplets, iconSave } from '../../lib/icons.js';
import { formatCurrency, monthName, currentMonthYear, MONTHS } from '../../lib/utils.js';
import api from '../../lib/api.js';

const APARTMENT_ID = 'psa-main';

@customElement('admin-water-meter')
export class AdminWaterMeter extends LitElement {
  @state() private month = currentMonthYear().month;
  @state() private year = currentMonthYear().year;
  @state() private flats: any[] = [];
  @state() private readings: Record<string, { prev: string; curr: string }> = {};
  @state() private savedReadings: any[] = [];
  @state() private loading = true;
  @state() private saving = false;
  @state() private recalculating = false;
  @state() private creatingCommon = false;
  // Which month each flat's opening reading was carried forward from, when it
  // did not come from the month immediately before (i.e. months were skipped).
  @state() private prevSource: Record<string, { month: number; year: number }> = {};
  @state() private tankerCost = 0;

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

  private async _createCommonFlat() {
    this.creatingCommon = true;
    try {
      const { data } = await api.post('/flats', {
        flatNumber: 'Common',
        floor: 0,
        apartmentId: APARTMENT_ID,
      });
      this.flats = [...this.flats, data];
      this.readings[data.id] = { prev: '', curr: '' };
      alert('Common flat created successfully!');
    } catch (error: any) {
      alert(`Error creating Common flat: ${error.response?.data?.message || error.message}`);
    } finally {
      this.creatingCommon = false;
    }
  }

  private async _loadReadings() {
    this.loading = true;
    try {
      // Carry-forward is always fetched, not only when the month is empty:
      // after a partial save some flats have rows and some do not, and the
      // ones that do not still need an opening reading.
      const [{ data }, purchases, prevData] = await Promise.all([
        api.get(`/water-meter/apartment?apartmentId=${APARTMENT_ID}&month=${this.month}&year=${this.year}`),
        api.get(`/water-purchases?apartmentId=${APARTMENT_ID}&month=${this.month}&year=${this.year}`)
          .then(r => r.data).catch(() => []),
        api.get(`/water-meter/last-readings?apartmentId=${APARTMENT_ID}&month=${this.month}&year=${this.year}`)
          .then(r => r.data).catch(() => []),
      ]);
      this.savedReadings = data;
      this.tankerCost = (purchases || []).reduce((s: number, p: any) => s + (p.amountPaid || 0), 0);

      const init: Record<string, { prev: string; curr: string }> = {};
      const sources: Record<string, { month: number; year: number }> = {};
      let prevMonth = this.month - 1, prevYear = this.year;
      if (prevMonth === 0) { prevMonth = 12; prevYear--; }

      this.flats.forEach((f: any) => {
        const found = data.find((r: any) => r.flatId === f.id);
        if (found) { init[f.id] = { prev: String(found.previousReading), curr: String(found.currentReading) }; return; }
        const prevReading = prevData.find((r: any) => r.flatId === f.id);
        init[f.id] = { prev: prevReading ? String(prevReading.currentReading) : '', curr: '' };
        if (prevReading && !(prevReading.fromMonth === prevMonth && prevReading.fromYear === prevYear)) {
          sources[f.id] = { month: prevReading.fromMonth, year: prevReading.fromYear };
        }
      });
      this.readings = init;
      this.prevSource = sources;
    } catch {}
    this.loading = false;
  }

  /** Live preview of each flat's share before anything is saved. */
  private _previewAmounts() {
    const consumed: Record<string, number> = {};
    let total = 0;
    for (const f of this.flats) {
      const p = parseFloat(this.readings[f.id]?.prev || '') || 0;
      const c = parseFloat(this.readings[f.id]?.curr || '') || 0;
      const used = c > p ? c - p : 0;
      consumed[f.id] = used;
      total += used;
    }
    const amounts: Record<string, number> = {};
    for (const f of this.flats) {
      amounts[f.id] = this.tankerCost > 0 && total > 0
        ? Math.round((consumed[f.id] / total) * this.tankerCost)
        : Math.round(consumed[f.id] * 0.088);
    }
    return { consumed, amounts, total };
  }

  updated(changed: Map<string, any>) {
    if ((changed.has('month') && changed.get('month') !== undefined) || (changed.has('year') && changed.get('year') !== undefined)) {
      if (this.flats.length) this._loadReadings();
    }
  }

  private async _handleSave() {
    const filled = (v: any) => String(v ?? '').trim() !== '';
    const complete: any[] = [];
    const incomplete: string[] = [];
    this.flats.forEach((f: any) => {
      const r = this.readings[f.id] || { prev: '', curr: '' };
      if (filled(r.prev) && filled(r.curr)) {
        complete.push({ flatId: f.id, month: this.month, year: this.year, previousReading: parseFloat(r.prev), currentReading: parseFloat(r.curr) });
      } else if (filled(r.prev) || filled(r.curr)) {
        incomplete.push(f.flatNumber);
      }
    });

    if (complete.length === 0) {
      alert('Nothing saved.\n\nA reading needs BOTH a previous and a current value. Fill in the Curr Reading column too, then save.');
      return;
    }

    this.saving = true;
    try {
      await api.post('/water-meter/bulk', { readings: complete });
      // Reloading would otherwise overwrite half-finished rows with the
      // carried-forward value, making a correction look like it was ignored.
      const typed = { ...this.readings };
      await this._loadReadings();
      const savedIds = new Set(complete.map(c => c.flatId));
      const merged = { ...this.readings };
      this.flats.forEach((f: any) => { if (!savedIds.has(f.id)) merged[f.id] = typed[f.id]; });
      this.readings = merged;

      alert(`Saved ${complete.length} reading${complete.length === 1 ? '' : 's'}.` +
        (incomplete.length ? `\n\nNot saved — these need a Curr Reading as well:\nFlat ${incomplete.join(', Flat ')}` : ''));
    }
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
    const preview = this._previewAmounts();
    const carriedCount = Object.keys(this.prevSource).length;
    // How long a gap the carried-forward readings span. Billing one skipped
    // month is routine; billing many at once is not, so say it plainly.
    const src = Object.values(this.prevSource)[0];
    const gapMonths = src ? (this.year - src.year) * 12 + (this.month - src.month) : 0;
    return html`
      <div>
        <div class="flex items-center justify-between mb-6">
          <div>
            <h1 class="text-2xl font-bold text-gray-900">Water Meter Readings</h1>
            <p class="text-gray-500 text-sm mt-1">
              ${this.tankerCost > 0
                ? html`Rate calculated from ${formatCurrency(this.tankerCost)} of tanker purchases`
                : 'No tanker purchased this month — showing fallback rate of ₹0.088/L'}
            </p>
          </div>
          <div class="flex gap-2">
            ${!this.flats.find((f: any) => f.flatNumber === 'Common') ? html`
              <psa-button .loading=${this.creatingCommon} @click=${this._createCommonFlat} variant="secondary">+ Create Common Flat</psa-button>
            ` : ''}
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
        ${!this.loading && carriedCount > 0 ? html`
          <div class="flex items-start gap-2 bg-amber-50 border border-amber-200 rounded-xl px-4 py-3 mb-4">
            <span class="text-amber-500">⚠</span>
            <p class="text-xs text-amber-700">
              Last reading was <span class="font-semibold">${src ? monthName(src.month) + ' ' + src.year : ''}</span>,
              so these figures cover <span class="font-semibold">${gapMonths} month${gapMonths === 1 ? '' : 's'}</span>
              of water use, not one. Opening readings for ${carriedCount} flat${carriedCount === 1 ? '' : 's'}
              were carried forward from then (shown under each value).
              ${gapMonths > 1 ? html`Bills for ${monthName(this.month)} will therefore be about ${gapMonths}× a normal month.` : ''}
              Please check before saving.
            </p>
          </div>
        ` : ''}

        <div class="bg-white rounded-xl border border-gray-200 shadow-sm">
          <div class="overflow-x-auto">
            <table class="w-full text-sm">
              <thead class="bg-gray-50 border-b border-gray-100">
                <tr>${['Flat','Prev Reading (L)','Curr Reading (L)','Consumed (L)','Amount'].map(h => html`<th class="text-left px-4 py-3 font-medium text-gray-500">${h}</th>`)}</tr>
              </thead>
              <tbody class="divide-y divide-gray-50">
                ${this.loading ? html`<tr><td colspan="5" class="px-4 py-4 text-gray-400">Loading...</td></tr>` :
                  html`
                    ${this.flats.map(flat => {
                      const prev = parseFloat(this.readings[flat.id]?.prev || '0') || 0;
                      const curr = parseFloat(this.readings[flat.id]?.curr || '0') || 0;
                      const consumed = curr > prev ? curr - prev : 0;
                      const savedReading = this.savedReadings.find((r: any) => r.flatId === flat.id);
                      // Show the saved figure once stored, otherwise a live
                      // preview so the column is not a flat Rs 0 while typing.
                      const amount = savedReading ? savedReading.waterAmount : preview.amounts[flat.id] ?? 0;
                      const carried = this.prevSource[flat.id];
                      return html`
                        <tr class="hover:bg-gray-50">
                          <td class="px-4 py-3 font-medium text-gray-900">
                            <div class="flex items-center gap-2">${iconDroplets('w-4 h-4 text-blue-400')} Flat ${flat.flatNumber}</div>
                          </td>
                          <td class="px-4 py-2">
                            <input type="number" .value=${this.readings[flat.id]?.prev || ''} @input=${(e: Event) => this._updateReading(flat.id, 'prev', (e.target as HTMLInputElement).value)}
                              class="w-32 px-2 py-1.5 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500" placeholder="0" />
                            ${carried ? html`<p class="text-[11px] text-amber-600 mt-0.5">carried from ${monthName(carried.month)} ${carried.year}</p>` : ''}
                          </td>
                          <td class="px-4 py-2">
                            <input type="number" .value=${this.readings[flat.id]?.curr || ''} @input=${(e: Event) => this._updateReading(flat.id, 'curr', (e.target as HTMLInputElement).value)}
                              class="w-32 px-2 py-1.5 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500" placeholder="0" />
                          </td>
                          <td class="px-4 py-3 text-gray-700">${consumed.toLocaleString('en-IN')}</td>
                          <td class="px-4 py-3 font-medium ${savedReading ? 'text-gray-900' : 'text-gray-400'}">
                            ${formatCurrency(amount)}${savedReading ? '' : html`<span class="text-[11px] ml-1">est.</span>`}
                          </td>
                        </tr>
                      `;
                    })}
                    <tr class="bg-blue-50 border-t-2 border-blue-200">
                      <td class="px-4 py-3 font-bold text-gray-900">TOTAL</td>
                      <td colspan="3" class="px-4 py-3 text-right font-medium text-gray-700">
                        Total Consumed: ${this.savedReadings.reduce((sum: number, r: any) => sum + r.litersConsumed, 0).toLocaleString('en-IN')} L
                      </td>
                      <td class="px-4 py-3 font-bold text-lg text-blue-600">
                        ${formatCurrency(this.savedReadings.reduce((sum: number, r: any) => sum + r.waterAmount, 0))}
                      </td>
                    </tr>
                  `
                }
              </tbody>
            </table>
          </div>
        </div>
      </div>
    `;
  }
}
