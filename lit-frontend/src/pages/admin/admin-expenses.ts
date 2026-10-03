import { LitElement, html } from 'lit';
import { customElement, state } from 'lit/decorators.js';
import { iconPlus, iconTrash2, iconEdit2 } from '../../lib/icons.js';
import { formatCurrency, monthName, currentMonthYear, MONTHS } from '../../lib/utils.js';
import api from '../../lib/api.js';

const APARTMENT_ID = 'psa-main';
const CATEGORIES = ['Security', 'Cleaning', 'Electricity', 'Water', 'Maintenance', 'Lift', 'Plumbing', 'Painting', 'Other'];

type TemplateItem = { id: string; category: string; description: string; amount: number };
type TemplateSet = { id: string; name: string; items: TemplateItem[] };

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

  @state() private templates: TemplateItem[] = [];
  @state() private templateSets: TemplateSet[] = [];
  @state() private showTemplateList = false;
  @state() private applyModal = false;
  @state() private applyingId: string | null = null;
  @state() private expandedSetId: string | null = null;
  @state() private selectedItems: Record<string, string[]> = {};
  @state() private savingSet = false;

  createRenderRoot() { return this; }

  connectedCallback() {
    super.connectedCallback();
    this._load();
    this._loadTemplates();
  }

  private async _load() {
    this.loading = true;
    try {
      const { data } = await api.get(`/expenses?apartmentId=${APARTMENT_ID}&month=${this.month}&year=${this.year}`);
      this.expenses = data;
    } catch { this.expenses = []; }
    this.loading = false;
  }

  private async _loadTemplates() {
    try {
      const [single, sets] = await Promise.all([
        api.get(`/expense-templates?apartmentId=${APARTMENT_ID}`),
        api.get(`/expense-template-sets?apartmentId=${APARTMENT_ID}`),
      ]);
      this.templates = single.data;
      this.templateSets = sets.data;
    } catch { this.templates = []; this.templateSets = []; }
  }

  updated(changed: Map<string, any>) {
    if ((changed.has('month') && changed.get('month') !== undefined) || (changed.has('year') && changed.get('year') !== undefined)) this._load();
  }

  private _openCreate() {
    this.editExp = null;
    this.form = { category: 'Security', description: '', amount: '', expenseDate: new Date().toISOString().split('T')[0] };
    this.showTemplateList = false;
    this.modal = true;
  }

  private _openEdit(e: any) {
    this.editExp = e;
    this.form = { category: e.category, description: e.description, amount: String(e.amount), expenseDate: e.expenseDate?.split('T')[0] ?? '' };
    this.showTemplateList = false;
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

  private async _saveTemplate() {
    if (!this.form.description || !this.form.amount) return;
    try {
      await api.post('/expense-templates', { apartmentId: APARTMENT_ID, category: this.form.category, description: this.form.description, amount: parseFloat(this.form.amount) });
      await this._loadTemplates();
      alert(`Template "${this.form.description}" saved!`);
    } catch (e: any) { alert(e.response?.data?.message || 'Could not save template'); }
  }

  private _loadTemplate(t: TemplateItem) {
    this.form = { ...this.form, category: t.category, description: t.description, amount: String(t.amount) };
    this.showTemplateList = false;
  }

  private async _deleteTemplate(id: string) {
    if (!confirm('Delete this template?')) return;
    await api.delete(`/expense-templates/${id}`);
    await this._loadTemplates();
  }

  /** Applies a single standalone template into the month currently on screen. */
  private async _applyTemplate(t: TemplateItem) {
    this.applyingId = t.id;
    const expenseDate = this._targetDate();
    try {
      await api.post('/expenses', { apartmentId: APARTMENT_ID, month: this.month, year: this.year, category: t.category, description: t.description, amount: t.amount, expenseDate });
      await this._load();
    } catch (e: any) { alert(e.response?.data?.message || 'Could not apply template'); }
    this.applyingId = null;
  }

  private _targetDate() {
    const cur = currentMonthYear();
    const isCurrentPeriod = this.month === cur.month && this.year === cur.year;
    return isCurrentPeriod
      ? new Date().toISOString().split('T')[0]
      : new Date(this.year, this.month - 1, 1).toISOString().split('T')[0];
  }

  /** Saves every expense in the month on screen as one reusable multi-row template. */
  private async _saveMonthAsSet() {
    if (this.expenses.length === 0) { alert('There are no expenses in this month to save.'); return; }
    const suggested = `${monthName(this.month)} ${this.year} expenses`;
    const name = prompt('Name this template (it will contain all ' + this.expenses.length + ' expenses of this month):', suggested);
    if (!name) return;
    this.savingSet = true;
    try {
      await api.post('/expense-template-sets/from-month', { apartmentId: APARTMENT_ID, name, month: this.month, year: this.year });
      await this._loadTemplates();
      alert(`Template "${name}" saved with ${this.expenses.length} items.`);
    } catch (e: any) { alert(e.response?.data?.message || 'Could not save template'); }
    this.savingSet = false;
  }

  private _toggleSet(setId: string) {
    if (this.expandedSetId === setId) { this.expandedSetId = null; return; }
    this.expandedSetId = setId;
    if (!this.selectedItems[setId]) {
      const set = this.templateSets.find(s => s.id === setId);
      this.selectedItems = { ...this.selectedItems, [setId]: set ? set.items.map(i => i.id) : [] };
    }
  }

  private _toggleItem(setId: string, itemId: string) {
    const current = this.selectedItems[setId] ?? [];
    const next = current.includes(itemId) ? current.filter(i => i !== itemId) : [...current, itemId];
    this.selectedItems = { ...this.selectedItems, [setId]: next };
  }

  private _selectedCount(set: TemplateSet) {
    return (this.selectedItems[set.id] ?? set.items.map(i => i.id)).length;
  }

  private async _applySet(set: TemplateSet) {
    const itemIds = this.selectedItems[set.id] ?? set.items.map(i => i.id);
    if (itemIds.length === 0) { alert('Select at least one item to apply.'); return; }
    this.applyingId = set.id;
    try {
      await api.post(`/expense-template-sets/${set.id}/apply`, { month: this.month, year: this.year, itemIds });
      await this._load();
      this.applyModal = false;
    } catch (e: any) { alert(e.response?.data?.message || 'Could not apply template'); }
    this.applyingId = null;
  }

  private async _deleteSet(set: TemplateSet) {
    if (!confirm(`Delete template "${set.name}" and its ${set.items.length} items?`)) return;
    await api.delete(`/expense-template-sets/${set.id}`);
    await this._loadTemplates();
  }

  render() {
    const total = this.expenses.reduce((s, e) => s + e.amount, 0);
    const byCategory = this.expenses.reduce((acc: Record<string, number>, e) => { acc[e.category] = (acc[e.category] || 0) + e.amount; return acc; }, {});
    const templateCount = this.templateSets.length + this.templates.length;

    return html`
      <div>
        <div class="flex items-center justify-between mb-6">
          <div>
            <h1 class="text-2xl font-bold text-gray-900">Expenses</h1>
            <p class="text-gray-500 text-sm mt-1">${monthName(this.month)} ${this.year} — Total: ${formatCurrency(total)}</p>
          </div>
          <div class="flex gap-2">
            <psa-button variant="secondary" .loading=${this.savingSet} @click=${this._saveMonthAsSet}>💾 Save Month as Template</psa-button>
            <psa-button variant="secondary" @click=${() => this.applyModal = true}>📋 Apply Template${templateCount ? ` (${templateCount})` : ''}</psa-button>
            <psa-button @click=${this._openCreate}>${iconPlus('w-4 h-4')} Add Expense</psa-button>
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

        <psa-modal ?open=${this.applyModal} modalTitle="Apply Template" size="md" @close=${() => this.applyModal = false}>
          <div class="space-y-4">
            <p class="text-sm text-gray-500">
              Adds expenses straight into <span class="font-medium text-gray-700">${monthName(this.month)} ${this.year}</span>.
            </p>

            ${this.templateSets.length === 0 && this.templates.length === 0 ? html`
              <p class="text-sm text-gray-400">
                No templates yet. Use "Save Month as Template" to turn this month's expenses into a reusable set,
                or tick "Save as Template" while adding a single expense.
              </p>
            ` : ''}

            ${this.templateSets.length > 0 ? html`
              <div>
                <p class="text-xs font-semibold text-gray-400 uppercase tracking-wide mb-2">Multi-expense templates</p>
                <div class="space-y-2">
                  ${this.templateSets.map(set => {
                    const selected = this.selectedItems[set.id] ?? set.items.map(i => i.id);
                    const setTotal = set.items.filter(i => selected.includes(i.id)).reduce((s, i) => s + i.amount, 0);
                    const open = this.expandedSetId === set.id;
                    return html`
                      <div class="border border-gray-200 rounded-lg overflow-hidden">
                        <div class="flex items-center gap-2 px-3 py-2 bg-gray-50">
                          <button @click=${() => this._toggleSet(set.id)} class="flex-1 min-w-0 text-left bg-transparent border-none cursor-pointer">
                            <p class="text-sm font-medium text-gray-800 truncate">${set.name}</p>
                            <p class="text-xs text-gray-500">${this._selectedCount(set)}/${set.items.length} items · ${formatCurrency(setTotal)} ${open ? '▲' : '▼'}</p>
                          </button>
                          <psa-button .loading=${this.applyingId === set.id} .disabled=${this.applyingId !== null} @click=${() => this._applySet(set)}>
                            Apply ${this._selectedCount(set)}
                          </psa-button>
                          <button @click=${() => this._deleteSet(set)} class="text-red-400 hover:text-red-600 bg-transparent border-none cursor-pointer text-sm px-1">✕</button>
                        </div>
                        ${open ? html`
                          <div class="divide-y divide-gray-100">
                            ${set.items.map(i => html`
                              <label class="flex items-center gap-3 px-3 py-2 hover:bg-gray-50 cursor-pointer">
                                <input type="checkbox" .checked=${selected.includes(i.id)} @change=${() => this._toggleItem(set.id, i.id)} />
                                <span class="text-xs font-medium bg-blue-100 text-blue-700 px-2 py-0.5 rounded-full">${i.category}</span>
                                <span class="flex-1 min-w-0 text-sm text-gray-700 truncate">${i.description}</span>
                                <span class="text-sm font-semibold text-gray-900">${formatCurrency(i.amount)}</span>
                              </label>
                            `)}
                          </div>
                        ` : ''}
                      </div>
                    `;
                  })}
                </div>
              </div>
            ` : ''}

            ${this.templates.length > 0 ? html`
              <div>
                <p class="text-xs font-semibold text-gray-400 uppercase tracking-wide mb-2">Single-expense templates</p>
                <div class="space-y-2">
                  ${this.templates.map(t => html`
                    <div class="flex items-center gap-2 px-3 py-2 border border-gray-200 rounded-lg">
                      <div class="flex-1 min-w-0">
                        <p class="text-sm font-medium text-gray-800 truncate">${t.description}</p>
                        <p class="text-xs text-gray-500">${t.category} · ${formatCurrency(t.amount)}</p>
                      </div>
                      <psa-button .loading=${this.applyingId === t.id} .disabled=${this.applyingId !== null} @click=${() => this._applyTemplate(t)}>Apply</psa-button>
                      <button @click=${() => this._deleteTemplate(t.id)} class="text-red-400 hover:text-red-600 bg-transparent border-none cursor-pointer text-sm px-1">✕</button>
                    </div>
                  `)}
                </div>
              </div>
            ` : ''}
          </div>
        </psa-modal>

        <psa-modal ?open=${this.modal} modalTitle=${this.editExp ? 'Edit Expense' : 'Add Expense'} size="sm" @close=${() => this.modal = false}>
          <div class="space-y-4">
            ${this.templates.length > 0 ? html`
              <div class="relative">
                <button @click=${() => this.showTemplateList = !this.showTemplateList}
                  class="w-full flex items-center justify-between px-3 py-2 text-sm bg-indigo-50 border border-indigo-200 rounded-lg text-indigo-700 hover:bg-indigo-100 cursor-pointer border-solid">
                  <span>📋 Load from Template (${this.templates.length})</span>
                  <span>${this.showTemplateList ? '▲' : '▼'}</span>
                </button>
                ${this.showTemplateList ? html`
                  <div class="mt-1 border border-gray-200 rounded-lg bg-white shadow-lg max-h-48 overflow-y-auto">
                    ${this.templates.map((t) => html`
                      <div class="flex items-center gap-2 px-3 py-2 hover:bg-gray-50 border-b border-gray-100 last:border-0">
                        <div class="flex-1 min-w-0 cursor-pointer" @click=${() => this._loadTemplate(t)}>
                          <p class="text-sm font-medium text-gray-800 truncate">${t.description}</p>
                          <p class="text-xs text-gray-500">${t.category} · ${formatCurrency(t.amount)}</p>
                        </div>
                        <button @click=${() => this._deleteTemplate(t.id)} class="text-red-400 hover:text-red-600 bg-transparent border-none cursor-pointer text-xs px-1">✕</button>
                      </div>
                    `)}
                  </div>
                ` : ''}
              </div>
            ` : ''}
            <psa-select label="Category" .value=${this.form.category} @value-changed=${(e: CustomEvent) => this._uf('category', e.detail)}>
              ${CATEGORIES.map(c => html`<option value=${c}>${c}</option>`)}
            </psa-select>
            <psa-input label="Description" .value=${this.form.description} @value-changed=${(e: CustomEvent) => this._uf('description', e.detail)} placeholder="e.g. Security guard salary"></psa-input>
            <psa-input label="Amount (₹)" type="number" .value=${this.form.amount} @value-changed=${(e: CustomEvent) => this._uf('amount', e.detail)}></psa-input>
            <psa-input label="Date" type="date" .value=${this.form.expenseDate} @value-changed=${(e: CustomEvent) => this._uf('expenseDate', e.detail)}></psa-input>
            <div class="flex items-center justify-between pt-2">
              <button @click=${this._saveTemplate} ?disabled=${!this.form.description || !this.form.amount}
                class="text-xs px-3 py-1.5 bg-gray-100 hover:bg-gray-200 text-gray-600 rounded-lg cursor-pointer border-none disabled:opacity-50">
                📋 Save as Template
              </button>
              <div class="flex gap-2">
                <psa-button variant="secondary" @click=${() => this.modal = false}>Cancel</psa-button>
                <psa-button .loading=${this.saving} .disabled=${!this.form.description || !this.form.amount} @click=${this._handleSave}>Save</psa-button>
              </div>
            </div>
          </div>
        </psa-modal>
      </div>
    `;
  }
}
