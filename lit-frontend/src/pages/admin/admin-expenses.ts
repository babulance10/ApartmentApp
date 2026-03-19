import { LitElement, html } from 'lit';
import { customElement, state } from 'lit/decorators.js';
import { iconPlus, iconTrash2, iconEdit2 } from '../../lib/icons.js';
import { formatCurrency, monthName, currentMonthYear, MONTHS } from '../../lib/utils.js';
import api from '../../lib/api.js';

const APARTMENT_ID = 'psa-main';
const CATEGORIES = ['Security', 'Cleaning', 'Electricity', 'Water', 'Maintenance', 'Lift', 'Plumbing', 'Painting', 'Other'];

@customElement('admin-expenses')
export class AdminExpenses extends LitElement {
  @state() private month = currentMonthYear().month;
  @state() private year = currentMonthYear().year;
  @state() private expenses: any[] = [];
  @state() private loading = true;
  @state() private modal = false;
  @state() private editExp: any = null;
  @state() private form = { category: 'Security', description: '', amount: '', expenseDate: '' };
  @state() private saving = false;

  createRenderRoot() { return this; }
  connectedCallback() { super.connectedCallback(); this._load(); }

  private async _load() {
    this.loading = true;
    try { const { data } = await api.get(`/expenses?apartmentId=${APARTMENT_ID}&month=${this.month}&year=${this.year}`); this.expenses = data; }
    catch { this.expenses = []; }
    this.loading = false;
  }

  updated(changed: Map<string, any>) {
    if ((changed.has('month') && changed.get('month') !== undefined) || (changed.has('year') && changed.get('year') !== undefined)) this._load();
  }

  private _openCreate() {
    this.editExp = null;
    this.form = { category: 'Security', description: '', amount: '', expenseDate: new Date().toISOString().split('T')[0] };
    this.modal = true;
  }

  private _openEdit(e: any) {
    this.editExp = e;
    this.form = { category: e.category, description: e.description, amount: String(e.amount), expenseDate: e.expenseDate?.split('T')[0] ?? '' };
    this.modal = true;
  }

  private async _handleSave() {
    this.saving = true;
    try {
      if (this.editExp) {
        await api.patch(`/expenses/${this.editExp.id}`, { category: this.form.category, description: this.form.description, amount: parseFloat(this.form.amount), expenseDate: this.form.expenseDate });
      } else {
        await api.post('/expenses', { apartmentId: APARTMENT_ID, month: this.month, year: this.year, category: this.form.category, description: this.form.description, amount: parseFloat(this.form.amount), expenseDate: this.form.expenseDate });
      }
      await this._load(); this.modal = false;
    } catch (e: any) { alert(e.response?.data?.message || 'Error'); }
    this.saving = false;
  }

  private async _handleDelete(id: string) {
    if (!confirm('Delete this expense?')) return;
    await api.delete(`/expenses/${id}`); await this._load();
  }

  private _uf(key: string, val: string) { this.form = { ...this.form, [key]: val }; }
  private _years = [2024, 2025, 2026, 2027];

  render() {
    const total = this.expenses.reduce((s, e) => s + e.amount, 0);
    const byCategory = this.expenses.reduce((acc: Record<string, number>, e) => { acc[e.category] = (acc[e.category] || 0) + e.amount; return acc; }, {});

    return html`
      <div>
        <div class="flex items-center justify-between mb-6">
          <div>
            <h1 class="text-2xl font-bold text-gray-900">Expenses</h1>
            <p class="text-gray-500 text-sm mt-1">${monthName(this.month)} ${this.year} — Total: ${formatCurrency(total)}</p>
          </div>
          <psa-button @click=${this._openCreate}>${iconPlus('w-4 h-4')} Add Expense</psa-button>
        </div>
        <div class="flex gap-3 mb-6">
          <psa-select .value=${String(this.month)} @value-changed=${(e: CustomEvent) => this.month = +e.detail}>
            ${MONTHS.map((m, i) => html`<option value=${i + 1}>${m}</option>`)}
          </psa-select>
          <psa-select .value=${String(this.year)} @value-changed=${(e: CustomEvent) => this.year = +e.detail}>
            ${this._years.map(y => html`<option value=${y}>${y}</option>`)}
          </psa-select>
        </div>

        ${Object.keys(byCategory).length > 0 ? html`
          <div class="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-3 mb-6">
            ${Object.entries(byCategory).map(([cat, amt]) => html`
              <div class="bg-white border border-gray-200 rounded-xl p-4">
                <p class="text-xs text-gray-500 font-medium">${cat}</p>
                <p class="text-lg font-bold text-gray-900 mt-1">${formatCurrency(amt as number)}</p>
              </div>
            `)}
          </div>
        ` : ''}

        <div class="bg-white rounded-xl border border-gray-200 shadow-sm">
          <div class="overflow-x-auto">
            <table class="w-full text-sm">
              <thead class="bg-gray-50 border-b border-gray-100">
                <tr>${['Category','Description','Amount','Date','Actions'].map(h => html`<th class="text-left px-4 py-3 font-medium text-gray-500">${h}</th>`)}</tr>
              </thead>
              <tbody class="divide-y divide-gray-50">
                ${this.loading ? html`<tr><td colspan="5" class="px-4 py-4 text-gray-400">Loading...</td></tr>` :
                  this.expenses.length === 0 ? html`<tr><td colspan="5" class="px-4 py-8 text-center text-gray-400">No expenses for this month.</td></tr>` :
                  this.expenses.map(e => html`
                    <tr class="hover:bg-gray-50">
                      <td class="px-4 py-3"><span class="text-xs font-medium bg-blue-100 text-blue-700 px-2 py-0.5 rounded-full">${e.category}</span></td>
                      <td class="px-4 py-3 text-gray-700">${e.description}</td>
                      <td class="px-4 py-3 font-semibold text-gray-900">${formatCurrency(e.amount)}</td>
                      <td class="px-4 py-3 text-gray-500">${new Date(e.expenseDate).toLocaleDateString('en-IN')}</td>
                      <td class="px-4 py-3 flex gap-2">
                        <button @click=${() => this._openEdit(e)} class="text-blue-500 hover:text-blue-700 cursor-pointer bg-transparent border-none">${iconEdit2('w-4 h-4')}</button>
                        <button @click=${() => this._handleDelete(e.id)} class="text-red-400 hover:text-red-600 cursor-pointer bg-transparent border-none">${iconTrash2('w-4 h-4')}</button>
                      </td>
                    </tr>
                  `)}
              </tbody>
            </table>
          </div>
        </div>

        <psa-modal ?open=${this.modal} modalTitle=${this.editExp ? 'Edit Expense' : 'Add Expense'} size="sm" @close=${() => this.modal = false}>
          <div class="space-y-4">
            <psa-select label="Category" .value=${this.form.category} @value-changed=${(e: CustomEvent) => this._uf('category', e.detail)}>
              ${CATEGORIES.map(c => html`<option value=${c}>${c}</option>`)}
            </psa-select>
            <psa-input label="Description" .value=${this.form.description} @value-changed=${(e: CustomEvent) => this._uf('description', e.detail)} placeholder="e.g. Security guard salary"></psa-input>
            <psa-input label="Amount (₹)" type="number" .value=${this.form.amount} @value-changed=${(e: CustomEvent) => this._uf('amount', e.detail)}></psa-input>
            <psa-input label="Date" type="date" .value=${this.form.expenseDate} @value-changed=${(e: CustomEvent) => this._uf('expenseDate', e.detail)}></psa-input>
            <div class="flex gap-2 justify-end pt-2">
              <psa-button variant="secondary" @click=${() => this.modal = false}>Cancel</psa-button>
              <psa-button .loading=${this.saving} .disabled=${!this.form.description || !this.form.amount} @click=${this._handleSave}>Save</psa-button>
            </div>
          </div>
        </psa-modal>
      </div>
    `;
  }
}
