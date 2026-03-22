import { LitElement, html } from 'lit';
import { customElement, state } from 'lit/decorators.js';
import { iconPlus, iconEdit2, iconTrash2 } from '../../lib/icons.js';
import { getUser } from '../../lib/auth.js';
import api from '../../lib/api.js';

@customElement('admin-events')
export class AdminEvents extends LitElement {
  @state() private events: any[] = [];
  @state() private flats: any[] = [];
  @state() private loading = true;
  @state() private selectedEvent: any = null;
  @state() private eventModal = false;
  @state() private collectionModal = false;
  @state() private expenseModal = false;
  @state() private eventForm = { name: '', description: '', targetAmount: 0, startDate: '', endDate: '' };
  @state() private collForm = { flatId: '', amount: 0, notes: '' };
  @state() private expForm = { category: '', description: '', amount: 0, expenseDate: '' };
  @state() private saving = false;
  @state() private editEvent: any = null;

  private get _isReadOnly() {
    const roles: string[] = getUser()?.roles || [];
    return roles.includes('VIEWER') && !roles.includes('ADMIN');
  }

  createRenderRoot() { return this; }

  connectedCallback() {
    super.connectedCallback();
    this._load();
    this._loadFlats();
  }

  private async _load() {
    try {
      const { data } = await api.get('/events?apartmentId=psa-main');
      this.events = data;
    } catch (e) { console.error(e); }
    this.loading = false;
  }

  private async _loadFlats() {
    try {
      const { data } = await api.get('/flats?apartmentId=psa-main');
      this.flats = data;
    } catch (e) { console.error(e); }
  }

  private _openCreateEvent() {
    this.editEvent = null;
    this.eventForm = { name: '', description: '', targetAmount: 0, startDate: '', endDate: '' };
    this.eventModal = true;
  }

  private _openEditEvent(ev: any) {
    this.editEvent = ev;
    this.eventForm = {
      name: ev.name,
      description: ev.description || '',
      targetAmount: ev.targetAmount || 0,
      startDate: ev.startDate ? ev.startDate.slice(0, 10) : '',
      endDate: ev.endDate ? ev.endDate.slice(0, 10) : '',
    };
    this.eventModal = true;
  }

  private async _saveEvent() {
    this.saving = true;
    try {
      if (this.editEvent) {
        await api.patch(`/events/${this.editEvent.id}`, this.eventForm);
      } else {
        await api.post('/events', { ...this.eventForm, apartmentId: 'psa-main' });
      }
      await this._load();
      this.eventModal = false;
      if (this.selectedEvent && this.editEvent) {
        const { data } = await api.get(`/events/${this.selectedEvent.id}`);
        this.selectedEvent = data;
      }
    } catch (e: any) { alert(e.response?.data?.message || 'Error'); }
    this.saving = false;
  }

  private async _deleteEvent(id: string) {
    if (!confirm('Delete this event and all its collections/expenses?')) return;
    await api.delete(`/events/${id}`);
    if (this.selectedEvent?.id === id) this.selectedEvent = null;
    await this._load();
  }

  private async _updateStatus(id: string, status: string) {
    await api.patch(`/events/${id}`, { status });
    await this._load();
    if (this.selectedEvent?.id === id) {
      const { data } = await api.get(`/events/${id}`);
      this.selectedEvent = data;
    }
  }

  private async _selectEvent(ev: any) {
    const { data } = await api.get(`/events/${ev.id}`);
    this.selectedEvent = data;
  }

  private _openAddCollection() {
    this.collForm = { flatId: this.flats[0]?.id || '', amount: 0, notes: '' };
    this.collectionModal = true;
  }

  private async _saveCollection() {
    this.saving = true;
    try {
      await api.post(`/events/${this.selectedEvent.id}/collections`, this.collForm);
      const { data } = await api.get(`/events/${this.selectedEvent.id}`);
      this.selectedEvent = data;
      await this._load();
      this.collectionModal = false;
    } catch (e: any) { alert(e.response?.data?.message || 'Error'); }
    this.saving = false;
  }

  private async _removeCollection(id: string) {
    if (!confirm('Remove this collection entry?')) return;
    await api.delete(`/events/collections/${id}`);
    const { data } = await api.get(`/events/${this.selectedEvent.id}`);
    this.selectedEvent = data;
    await this._load();
  }

  private _openAddExpense() {
    this.expForm = { category: '', description: '', amount: 0, expenseDate: new Date().toISOString().slice(0, 10) };
    this.expenseModal = true;
  }

  private async _saveExpense() {
    this.saving = true;
    try {
      await api.post(`/events/${this.selectedEvent.id}/expenses`, this.expForm);
      const { data } = await api.get(`/events/${this.selectedEvent.id}`);
      this.selectedEvent = data;
      await this._load();
      this.expenseModal = false;
    } catch (e: any) { alert(e.response?.data?.message || 'Error'); }
    this.saving = false;
  }

  private async _removeExpense(id: string) {
    if (!confirm('Remove this expense?')) return;
    await api.delete(`/events/expenses/${id}`);
    const { data } = await api.get(`/events/${this.selectedEvent.id}`);
    this.selectedEvent = data;
    await this._load();
  }

  private _statusColor(s: string) {
    return s === 'ACTIVE' ? 'bg-green-100 text-green-700' : s === 'COMPLETED' ? 'bg-blue-100 text-blue-700' : s === 'CANCELLED' ? 'bg-red-100 text-red-700' : 'bg-yellow-100 text-yellow-700';
  }

  private _fmt(n: number) { return '₹' + n.toLocaleString('en-IN'); }

  render() {
    const ev = this.selectedEvent;
    const totalCollected = ev ? ev.collections.reduce((s: number, c: any) => s + c.amount, 0) : 0;
    const totalSpent = ev ? ev.expenses.reduce((s: number, e: any) => s + e.amount, 0) : 0;

    return html`
      <div>
        <div class="flex items-center justify-between mb-6">
          <div>
            <h1 class="text-2xl font-bold text-gray-900">Events</h1>
            <p class="text-gray-500 text-sm mt-1">Manage event collections & expenses (Ganesh Chaturthi, Annual Day, etc.)</p>
          </div>
          ${!this._isReadOnly ? html`<psa-button @click=${this._openCreateEvent}>${iconPlus('w-4 h-4')} New Event</psa-button>` : ''}
        </div>

        <!-- Event Cards Grid -->
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 mb-6">
          ${this.loading ? html`<p class="text-gray-400">Loading...</p>` :
            this.events.length === 0 ? html`<p class="text-gray-400 col-span-3">No events yet. Create one to get started.</p>` :
            this.events.map(e => {
              const collected = e.collections.reduce((s: number, c: any) => s + c.amount, 0);
              const spent = e.expenses.reduce((s: number, x: any) => s + x.amount, 0);
              const isSelected = ev?.id === e.id;
              return html`
                <div class="bg-white rounded-xl border-2 ${isSelected ? 'border-blue-500 shadow-lg' : 'border-gray-200'} p-4 cursor-pointer hover:shadow-md transition"
                  @click=${() => this._selectEvent(e)}>
                  <div class="flex items-center justify-between mb-2">
                    <h3 class="font-semibold text-gray-900 text-base truncate">${e.name}</h3>
                    <span class="text-xs font-medium px-2 py-0.5 rounded-full ${this._statusColor(e.status)}">${e.status}</span>
                  </div>
                  ${e.description ? html`<p class="text-xs text-gray-500 mb-3 line-clamp-2">${e.description}</p>` : ''}
                  <div class="grid grid-cols-3 gap-2 text-center">
                    <div>
                      <p class="text-xs text-gray-400">Target</p>
                      <p class="text-sm font-bold text-gray-800">${this._fmt(e.targetAmount)}</p>
                    </div>
                    <div>
                      <p class="text-xs text-green-500">Collected</p>
                      <p class="text-sm font-bold text-green-700">${this._fmt(collected)}</p>
                    </div>
                    <div>
                      <p class="text-xs text-red-500">Spent</p>
                      <p class="text-sm font-bold text-red-700">${this._fmt(spent)}</p>
                    </div>
                  </div>
                  ${!this._isReadOnly ? html`
                  <div class="flex items-center gap-2 mt-3 pt-3 border-t border-gray-100">
                    <button @click=${(evt: Event) => { evt.stopPropagation(); this._openEditEvent(e); }} class="text-blue-600 text-xs cursor-pointer bg-transparent border-none hover:underline">Edit</button>
                    <select class="text-xs border border-gray-200 rounded px-1 py-0.5 cursor-pointer" @change=${(evt: Event) => { evt.stopPropagation(); this._updateStatus(e.id, (evt.target as HTMLSelectElement).value); }} .value=${e.status}>
                      <option value="PLANNING">Planning</option>
                      <option value="ACTIVE">Active</option>
                      <option value="COMPLETED">Completed</option>
                      <option value="CANCELLED">Cancelled</option>
                    </select>
                    <button @click=${(evt: Event) => { evt.stopPropagation(); this._deleteEvent(e.id); }} class="text-red-500 text-xs cursor-pointer bg-transparent border-none hover:underline ml-auto">Delete</button>
                  </div>` : html`<div class="mt-3 pt-3 border-t border-gray-100"><span class="text-xs px-2 py-0.5 rounded-full bg-gray-100 text-gray-500">${e.status}</span></div>`}
                </div>
              `;
            })}
        </div>

        <!-- Selected Event Detail -->
        ${ev ? html`
          <div class="bg-white rounded-xl border border-gray-200 shadow-sm p-5">
            <div class="flex items-center justify-between mb-4">
              <h2 class="text-lg font-bold text-gray-900">${ev.name}</h2>
              <div class="flex gap-2 text-sm">
                <span class="px-3 py-1 rounded-full bg-green-50 text-green-700 font-semibold">Collected: ${this._fmt(totalCollected)}</span>
                <span class="px-3 py-1 rounded-full bg-red-50 text-red-700 font-semibold">Spent: ${this._fmt(totalSpent)}</span>
                <span class="px-3 py-1 rounded-full bg-blue-50 text-blue-700 font-semibold">Balance: ${this._fmt(totalCollected - totalSpent)}</span>
              </div>
            </div>

            <!-- Collections -->
            <div class="mb-6">
              <div class="flex items-center justify-between mb-3">
                <h3 class="text-sm font-semibold text-gray-700">Collections (${ev.collections.length})</h3>
                ${!this._isReadOnly ? html`<button @click=${this._openAddCollection} class="text-xs text-blue-600 hover:underline cursor-pointer bg-transparent border-none flex items-center gap-1">${iconPlus('w-3 h-3')} Add Collection</button>` : ''}
              </div>
              <div class="overflow-x-auto">
                <table class="w-full text-sm">
                  <thead class="bg-gray-50">
                    <tr>
                      <th class="text-left px-4 py-2 text-xs font-medium text-gray-500">Flat</th>
                      <th class="text-left px-4 py-2 text-xs font-medium text-gray-500">Amount</th>
                      <th class="text-left px-4 py-2 text-xs font-medium text-gray-500">Date</th>
                      <th class="text-left px-4 py-2 text-xs font-medium text-gray-500">Notes</th>
                      <th class="text-left px-4 py-2 text-xs font-medium text-gray-500"></th>
                    </tr>
                  </thead>
                  <tbody class="divide-y divide-gray-50">
                    ${ev.collections.length === 0 ? html`<tr><td colspan="5" class="px-4 py-3 text-gray-400 text-xs">No collections yet.</td></tr>` :
                      ev.collections.map((c: any) => html`
                        <tr>
                          <td class="px-4 py-2 font-medium">Flat ${c.flat?.flatNumber}</td>
                          <td class="px-4 py-2 text-green-700 font-semibold">${this._fmt(c.amount)}</td>
                          <td class="px-4 py-2 text-gray-500">${c.paidDate ? new Date(c.paidDate).toLocaleDateString() : '—'}</td>
                          <td class="px-4 py-2 text-gray-500">${c.notes || '—'}</td>
                          <td class="px-4 py-2">${!this._isReadOnly ? html`<button @click=${() => this._removeCollection(c.id)} class="text-red-400 hover:text-red-600 cursor-pointer bg-transparent border-none">${iconTrash2('w-3.5 h-3.5')}</button>` : ''}</td>
                        </tr>
                      `)}
                  </tbody>
                </table>
              </div>
            </div>

            <!-- Expenses -->
            <div>
              <div class="flex items-center justify-between mb-3">
                <h3 class="text-sm font-semibold text-gray-700">Expenses (${ev.expenses.length})</h3>
                ${!this._isReadOnly ? html`<button @click=${this._openAddExpense} class="text-xs text-blue-600 hover:underline cursor-pointer bg-transparent border-none flex items-center gap-1">${iconPlus('w-3 h-3')} Add Expense</button>` : ''}
              </div>
              <div class="overflow-x-auto">
                <table class="w-full text-sm">
                  <thead class="bg-gray-50">
                    <tr>
                      <th class="text-left px-4 py-2 text-xs font-medium text-gray-500">Category</th>
                      <th class="text-left px-4 py-2 text-xs font-medium text-gray-500">Description</th>
                      <th class="text-left px-4 py-2 text-xs font-medium text-gray-500">Amount</th>
                      <th class="text-left px-4 py-2 text-xs font-medium text-gray-500">Date</th>
                      <th class="text-left px-4 py-2 text-xs font-medium text-gray-500"></th>
                    </tr>
                  </thead>
                  <tbody class="divide-y divide-gray-50">
                    ${ev.expenses.length === 0 ? html`<tr><td colspan="5" class="px-4 py-3 text-gray-400 text-xs">No expenses yet.</td></tr>` :
                      ev.expenses.map((e: any) => html`
                        <tr>
                          <td class="px-4 py-2"><span class="text-xs font-medium px-2 py-0.5 rounded-full bg-gray-100 text-gray-700">${e.category}</span></td>
                          <td class="px-4 py-2">${e.description}</td>
                          <td class="px-4 py-2 text-red-700 font-semibold">${this._fmt(e.amount)}</td>
                          <td class="px-4 py-2 text-gray-500">${new Date(e.expenseDate).toLocaleDateString()}</td>
                          <td class="px-4 py-2">${!this._isReadOnly ? html`<button @click=${() => this._removeExpense(e.id)} class="text-red-400 hover:text-red-600 cursor-pointer bg-transparent border-none">${iconTrash2('w-3.5 h-3.5')}</button>` : ''}</td>
                        </tr>
                      `)}
                  </tbody>
                </table>
              </div>
            </div>
          </div>
        ` : ''}

        <!-- Event Modal -->
        <psa-modal ?open=${this.eventModal} modalTitle=${this.editEvent ? 'Edit Event' : 'New Event'} size="sm" @close=${() => this.eventModal = false}>
          <div class="space-y-4">
            <psa-input label="Event Name" .value=${this.eventForm.name} @value-changed=${(e: CustomEvent) => this.eventForm = { ...this.eventForm, name: e.detail }}></psa-input>
            <psa-input label="Description" .value=${this.eventForm.description} @value-changed=${(e: CustomEvent) => this.eventForm = { ...this.eventForm, description: e.detail }}></psa-input>
            <psa-input label="Target Amount (₹)" type="number" .value=${String(this.eventForm.targetAmount)} @value-changed=${(e: CustomEvent) => this.eventForm = { ...this.eventForm, targetAmount: Number(e.detail) }}></psa-input>
            <div class="grid grid-cols-2 gap-3">
              <psa-input label="Start Date" type="date" .value=${this.eventForm.startDate} @value-changed=${(e: CustomEvent) => this.eventForm = { ...this.eventForm, startDate: e.detail }}></psa-input>
              <psa-input label="End Date" type="date" .value=${this.eventForm.endDate} @value-changed=${(e: CustomEvent) => this.eventForm = { ...this.eventForm, endDate: e.detail }}></psa-input>
            </div>
            <div class="flex gap-2 justify-end pt-2">
              <psa-button variant="secondary" @click=${() => this.eventModal = false}>Cancel</psa-button>
              <psa-button .loading=${this.saving} @click=${this._saveEvent}>Save</psa-button>
            </div>
          </div>
        </psa-modal>

        <!-- Collection Modal -->
        <psa-modal ?open=${this.collectionModal} modalTitle="Add Collection" size="sm" @close=${() => this.collectionModal = false}>
          <div class="space-y-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Flat</label>
              <select class="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm" @change=${(e: Event) => this.collForm = { ...this.collForm, flatId: (e.target as HTMLSelectElement).value }}>
                ${this.flats.map(f => html`<option value=${f.id} ?selected=${f.id === this.collForm.flatId}>Flat ${f.flatNumber}</option>`)}
              </select>
            </div>
            <psa-input label="Amount (₹)" type="number" .value=${String(this.collForm.amount)} @value-changed=${(e: CustomEvent) => this.collForm = { ...this.collForm, amount: Number(e.detail) }}></psa-input>
            <psa-input label="Notes" .value=${this.collForm.notes} @value-changed=${(e: CustomEvent) => this.collForm = { ...this.collForm, notes: e.detail }}></psa-input>
            <div class="flex gap-2 justify-end pt-2">
              <psa-button variant="secondary" @click=${() => this.collectionModal = false}>Cancel</psa-button>
              <psa-button .loading=${this.saving} @click=${this._saveCollection}>Add</psa-button>
            </div>
          </div>
        </psa-modal>

        <!-- Expense Modal -->
        <psa-modal ?open=${this.expenseModal} modalTitle="Add Expense" size="sm" @close=${() => this.expenseModal = false}>
          <div class="space-y-4">
            <psa-input label="Category" .value=${this.expForm.category} @value-changed=${(e: CustomEvent) => this.expForm = { ...this.expForm, category: e.detail }} placeholder="e.g. Decorations, Food, Tent"></psa-input>
            <psa-input label="Description" .value=${this.expForm.description} @value-changed=${(e: CustomEvent) => this.expForm = { ...this.expForm, description: e.detail }}></psa-input>
            <psa-input label="Amount (₹)" type="number" .value=${String(this.expForm.amount)} @value-changed=${(e: CustomEvent) => this.expForm = { ...this.expForm, amount: Number(e.detail) }}></psa-input>
            <psa-input label="Expense Date" type="date" .value=${this.expForm.expenseDate} @value-changed=${(e: CustomEvent) => this.expForm = { ...this.expForm, expenseDate: e.detail }}></psa-input>
            <div class="flex gap-2 justify-end pt-2">
              <psa-button variant="secondary" @click=${() => this.expenseModal = false}>Cancel</psa-button>
              <psa-button .loading=${this.saving} @click=${this._saveExpense}>Add</psa-button>
            </div>
          </div>
        </psa-modal>
      </div>
    `;
  }
}
