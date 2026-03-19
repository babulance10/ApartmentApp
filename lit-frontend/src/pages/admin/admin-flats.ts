import { LitElement, html } from 'lit';
import { customElement, state } from 'lit/decorators.js';
import { iconHome, iconUserPlus, iconUserMinus, iconPlus, iconEdit2 } from '../../lib/icons.js';
import api from '../../lib/api.js';

const APARTMENT_ID = 'psa-main';

@customElement('admin-flats')
export class AdminFlats extends LitElement {
  @state() private flats: any[] = [];
  @state() private users: any[] = [];
  @state() private loading = true;
  @state() private assignModal: any = null;
  @state() private selectedUser = '';
  @state() private saving = false;
  @state() private addModal = false;
  @state() private addForm = { flatNumber: '', floor: '' };
  @state() private editModal: any = null;
  @state() private editForm = { flatNumber: '', floor: '' };

  createRenderRoot() { return this; }
  connectedCallback() { super.connectedCallback(); this._load(); }

  private async _load() {
    const [f, u] = await Promise.all([api.get(`/flats?apartmentId=${APARTMENT_ID}`), api.get('/users')]);
    this.flats = f.data; this.users = u.data; this.loading = false;
  }

  private async _handleAssign() {
    if (!this.assignModal || !this.selectedUser) return;
    this.saving = true;
    try {
      const endpoint = this.assignModal.type === 'owner' ? 'assign-owner' : 'assign-tenant';
      await api.post(`/flats/${this.assignModal.flat.id}/${endpoint}`, { userId: this.selectedUser, fromDate: new Date().toISOString() });
      await this._load(); this.assignModal = null; this.selectedUser = '';
    } catch (e: any) { alert(e.response?.data?.message || 'Error'); }
    this.saving = false;
  }

  private async _handleRemove(flatId: string, type: string) {
    if (!confirm(`Remove ${type} from this flat?`)) return;
    await api.post(`/flats/${flatId}/remove-${type}`); await this._load();
  }

  private async _handleAddFlat() {
    this.saving = true;
    try {
      await api.post('/flats', { flatNumber: this.addForm.flatNumber, floor: +this.addForm.floor, apartmentId: APARTMENT_ID });
      await this._load(); this.addModal = false; this.addForm = { flatNumber: '', floor: '' };
    } catch (e: any) { alert(e.response?.data?.message || 'Error adding flat'); }
    this.saving = false;
  }

  private async _handleEditFlat() {
    if (!this.editModal) return;
    this.saving = true;
    try {
      await api.patch(`/flats/${this.editModal.flat.id}`, { flatNumber: this.editForm.flatNumber, floor: +this.editForm.floor });
      await this._load(); this.editModal = null;
    } catch (e: any) { alert(e.response?.data?.message || 'Error updating flat'); }
    this.saving = false;
  }

  render() {
    return html`
      <div>
        <div class="flex items-center justify-between mb-6">
          <div>
            <h1 class="text-2xl font-bold text-gray-900">Flats</h1>
            <p class="text-gray-500 text-sm mt-1">${this.flats.length} flats in the building</p>
          </div>
          <psa-button @click=${() => { this.addForm = { flatNumber: '', floor: '' }; this.addModal = true; }}>
            ${iconPlus('w-4 h-4')} Add Flat
          </psa-button>
        </div>

        ${this.loading ? html`<p class="text-gray-500">Loading...</p>` : html`
          <div class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4">
            ${this.flats.map((flat) => {
              const owner = flat.ownerships?.[0]?.user;
              const tenant = flat.tenancies?.[0]?.user;
              return html`
                <div class="bg-white rounded-xl border border-gray-200 shadow-sm">
                  <div class="px-6 py-4 border-b border-gray-100 flex items-center justify-between">
                    <div class="flex items-center gap-2">
                      <div class="w-8 h-8 bg-blue-100 rounded-lg flex items-center justify-center">
                        ${iconHome('w-4 h-4 text-blue-600')}
                      </div>
                      <span class="font-semibold text-gray-900">Flat ${flat.flatNumber}</span>
                    </div>
                    <div class="flex items-center gap-2">
                      <span class="text-xs text-gray-400 bg-gray-100 px-2 py-0.5 rounded-full">Floor ${flat.floor}</span>
                      <button @click=${() => { this.editForm = { flatNumber: flat.flatNumber, floor: String(flat.floor) }; this.editModal = { open: true, flat }; }}
                        class="p-1 text-gray-400 hover:text-blue-600 cursor-pointer bg-transparent border-none">${iconEdit2('w-3.5 h-3.5')}</button>
                    </div>
                  </div>
                  <div class="px-6 py-4 space-y-3">
                    <div>
                      <p class="text-xs font-medium text-gray-500 mb-1">OWNER</p>
                      ${owner ? html`
                        <div class="flex items-center justify-between">
                          <div>
                            <p class="text-sm font-medium text-gray-800">${owner.name}</p>
                            <p class="text-xs text-gray-400">${owner.email}</p>
                            ${owner.phone ? html`<p class="text-xs text-gray-400">${owner.phone}</p>` : ''}
                          </div>
                          <div class="flex gap-1">
                            <button @click=${() => { this.assignModal = { open: true, flat, type: 'owner' }; this.selectedUser = ''; }} class="p-1 text-blue-400 hover:text-blue-600 cursor-pointer bg-transparent border-none">${iconUserPlus('w-4 h-4')}</button>
                            <button @click=${() => this._handleRemove(flat.id, 'owner')} class="p-1 text-red-400 hover:text-red-600 cursor-pointer bg-transparent border-none">${iconUserMinus('w-4 h-4')}</button>
                          </div>
                        </div>
                      ` : html`
                        <button @click=${() => { this.assignModal = { open: true, flat, type: 'owner' }; this.selectedUser = ''; }}
                          class="flex items-center gap-1 text-xs text-blue-600 hover:text-blue-700 font-medium cursor-pointer bg-transparent border-none">
                          ${iconUserPlus('w-3.5 h-3.5')} Assign Owner
                        </button>
                      `}
                    </div>
                    <div>
                      <p class="text-xs font-medium text-gray-500 mb-1">TENANT</p>
                      ${tenant ? html`
                        <div class="flex items-center justify-between">
                          <div>
                            <p class="text-sm font-medium text-gray-800">${tenant.name}</p>
                            <p class="text-xs text-gray-400">${tenant.email}</p>
                            ${tenant.phone ? html`<p class="text-xs text-gray-400">${tenant.phone}</p>` : ''}
                          </div>
                          <div class="flex gap-1">
                            <button @click=${() => { this.assignModal = { open: true, flat, type: 'tenant' }; this.selectedUser = ''; }} class="p-1 text-blue-400 hover:text-blue-600 cursor-pointer bg-transparent border-none">${iconUserPlus('w-4 h-4')}</button>
                            <button @click=${() => this._handleRemove(flat.id, 'tenant')} class="p-1 text-red-400 hover:text-red-600 cursor-pointer bg-transparent border-none">${iconUserMinus('w-4 h-4')}</button>
                          </div>
                        </div>
                      ` : html`
                        <button @click=${() => { this.assignModal = { open: true, flat, type: 'tenant' }; this.selectedUser = ''; }}
                          class="flex items-center gap-1 text-xs text-blue-600 hover:text-blue-700 font-medium cursor-pointer bg-transparent border-none">
                          ${iconUserPlus('w-3.5 h-3.5')} Assign Tenant
                        </button>
                      `}
                    </div>
                  </div>
                </div>
              `;
            })}
          </div>
        `}

        <psa-modal ?open=${this.addModal} modalTitle="Add New Flat" size="sm" @close=${() => this.addModal = false}>
          <div class="space-y-4">
            <psa-input label="Flat Number" .value=${this.addForm.flatNumber} @value-changed=${(e: CustomEvent) => this.addForm = { ...this.addForm, flatNumber: e.detail }} placeholder="e.g. 601"></psa-input>
            <psa-input label="Floor" type="number" .value=${this.addForm.floor} @value-changed=${(e: CustomEvent) => this.addForm = { ...this.addForm, floor: e.detail }} placeholder="e.g. 6"></psa-input>
            <div class="flex gap-2 justify-end pt-2">
              <psa-button variant="secondary" @click=${() => this.addModal = false}>Cancel</psa-button>
              <psa-button .loading=${this.saving} .disabled=${!this.addForm.flatNumber || !this.addForm.floor} @click=${this._handleAddFlat}>Add Flat</psa-button>
            </div>
          </div>
        </psa-modal>

        <psa-modal ?open=${!!this.editModal?.open} modalTitle="Edit Flat ${this.editModal?.flat?.flatNumber || ''}" size="sm" @close=${() => this.editModal = null}>
          <div class="space-y-4">
            <psa-input label="Flat Number" .value=${this.editForm.flatNumber} @value-changed=${(e: CustomEvent) => this.editForm = { ...this.editForm, flatNumber: e.detail }}></psa-input>
            <psa-input label="Floor" type="number" .value=${this.editForm.floor} @value-changed=${(e: CustomEvent) => this.editForm = { ...this.editForm, floor: e.detail }}></psa-input>
            <div class="flex gap-2 justify-end pt-2">
              <psa-button variant="secondary" @click=${() => this.editModal = null}>Cancel</psa-button>
              <psa-button .loading=${this.saving} .disabled=${!this.editForm.flatNumber || !this.editForm.floor} @click=${this._handleEditFlat}>Save Changes</psa-button>
            </div>
          </div>
        </psa-modal>

        <psa-modal ?open=${!!this.assignModal?.open} modalTitle="Assign ${this.assignModal?.type === 'owner' ? 'Owner' : 'Tenant'} — Flat ${this.assignModal?.flat?.flatNumber || ''}" size="sm" @close=${() => this.assignModal = null}>
          <div class="space-y-4">
            <psa-select label="Select User" .value=${this.selectedUser} @value-changed=${(e: CustomEvent) => this.selectedUser = e.detail}>
              <option value="">-- Select --</option>
              ${this.users.map((u: any) => html`<option value=${u.id}>${u.name} (${u.email})</option>`)}
            </psa-select>
            <div class="flex gap-2 justify-end">
              <psa-button variant="secondary" @click=${() => this.assignModal = null}>Cancel</psa-button>
              <psa-button .loading=${this.saving} .disabled=${!this.selectedUser} @click=${this._handleAssign}>Assign</psa-button>
            </div>
          </div>
        </psa-modal>
      </div>
    `;
  }
}
