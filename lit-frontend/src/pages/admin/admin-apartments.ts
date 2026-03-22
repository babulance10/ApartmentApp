import { LitElement, html, nothing } from 'lit';
import { customElement, state } from 'lit/decorators.js';
import { iconBuilding2, iconEdit2 } from '../../lib/icons.js';
import api from '../../lib/api.js';

@customElement('admin-apartments')
export class AdminApartments extends LitElement {
  @state() private apartment: any = null;
  @state() private loading = true;
  @state() private modal = false;
  @state() private form = { name: '', address: '', city: '', upiNumber: '', upiName: '', maintenanceAmount: '2000' };
  @state() private saving = false;

  createRenderRoot() { return this; }

  connectedCallback() { super.connectedCallback(); this._load(); }

  private async _load() {
    try {
      const { data } = await api.get('/apartments');
      if (data.length) this.apartment = data[0];
    } catch {}
    this.loading = false;
  }

  private _openEdit() {
    if (!this.apartment) return;
    this.form = {
      name: this.apartment.name,
      address: this.apartment.address || '',
      city: this.apartment.city || '',
      upiNumber: this.apartment.upiNumber || '',
      upiName: this.apartment.upiName || '',
      maintenanceAmount: String(this.apartment.maintenanceAmount ?? 2000),
    };
    this.modal = true;
  }

  private async _handleSave() {
    this.saving = true;
    try {
      await api.patch(`/apartments/${this.apartment.id}`, { ...this.form, maintenanceAmount: parseFloat(this.form.maintenanceAmount) || 2000 });
      await this._load();
      this.modal = false;
    } catch (e: any) {
      alert(e.response?.data?.message || 'Error saving');
    }
    this.saving = false;
  }

  private _updateForm(key: string, val: string) {
    this.form = { ...this.form, [key]: val };
  }

  render() {
    return html`
      <div>
        <div class="flex items-center justify-between mb-6">
          <div>
            <h1 class="text-2xl font-bold text-gray-900">Apartment</h1>
            <p class="text-gray-500 text-sm mt-1">Building information and payment details</p>
          </div>
        </div>

        ${this.loading ? html`<p class="text-gray-500">Loading...</p>` :
          this.apartment ? html`
            <div class="max-w-2xl">
              <div class="bg-white rounded-xl border border-gray-200 shadow-sm">
                <div class="px-6 py-4 border-b border-gray-100 flex items-center justify-between">
                  <div class="flex items-center gap-3">
                    <div class="w-10 h-10 bg-blue-600 rounded-xl flex items-center justify-center">
                      ${iconBuilding2('w-6 h-6 text-white')}
                    </div>
                    <div>
                      <h2 class="font-bold text-gray-900 text-lg">${this.apartment.name}</h2>
                      <p class="text-sm text-gray-500">${this.apartment.city}</p>
                    </div>
                  </div>
                  <button @click=${this._openEdit} class="inline-flex items-center gap-2 px-3 py-1.5 text-sm font-medium bg-white hover:bg-gray-50 text-gray-700 border border-gray-300 rounded-lg cursor-pointer">
                    ${iconEdit2('w-4 h-4')} Edit
                  </button>
                </div>
                <div class="px-6 py-4 space-y-4">
                  <div class="grid grid-cols-2 gap-4">
                    <div>
                      <p class="text-xs font-medium text-gray-500 uppercase tracking-wide mb-1">Address</p>
                      <p class="text-sm text-gray-800">${this.apartment.address || '—'}</p>
                    </div>
                    <div>
                      <p class="text-xs font-medium text-gray-500 uppercase tracking-wide mb-1">City</p>
                      <p class="text-sm text-gray-800">${this.apartment.city || '—'}</p>
                    </div>
                  </div>
                  <div class="border-t border-gray-100 pt-4">
                    <p class="text-xs font-medium text-gray-500 uppercase tracking-wide mb-3">Billing Configuration</p>
                    <div class="bg-amber-50 border border-amber-100 rounded-xl p-4 mb-4">
                      <div class="flex items-center justify-between">
                        <span class="text-sm text-gray-600">Monthly Maintenance</span>
                        <span class="text-sm font-bold text-amber-700">₹${(this.apartment.maintenanceAmount ?? 2000).toLocaleString('en-IN')}</span>
                      </div>
                    </div>
                  </div>
                  <div class="border-t border-gray-100 pt-4">
                    <p class="text-xs font-medium text-gray-500 uppercase tracking-wide mb-3">UPI Payment Details</p>
                    <div class="bg-blue-50 border border-blue-100 rounded-xl p-4 space-y-2">
                      <div class="flex items-center justify-between">
                        <span class="text-sm text-gray-600">UPI Number</span>
                        <span class="text-sm font-bold text-blue-700">${this.apartment.upiNumber || '—'}</span>
                      </div>
                      <div class="flex items-center justify-between">
                        <span class="text-sm text-gray-600">Account Name</span>
                        <span class="text-sm font-medium text-gray-800">${this.apartment.upiName || '—'}</span>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          ` : html`<p class="text-gray-400">No apartment found.</p>`}

        <psa-modal ?open=${this.modal} modalTitle="Edit Apartment" size="md" @close=${() => this.modal = false}>
          <div class="space-y-4">
            <psa-input label="Apartment Name" .value=${this.form.name} @value-changed=${(e: CustomEvent) => this._updateForm('name', e.detail)}></psa-input>
            <psa-input label="Address" .value=${this.form.address} @value-changed=${(e: CustomEvent) => this._updateForm('address', e.detail)}></psa-input>
            <psa-input label="City" .value=${this.form.city} @value-changed=${(e: CustomEvent) => this._updateForm('city', e.detail)}></psa-input>
            <psa-input label="UPI Number / Phone" .value=${this.form.upiNumber} @value-changed=${(e: CustomEvent) => this._updateForm('upiNumber', e.detail)}></psa-input>
            <psa-input label="UPI Account Name" .value=${this.form.upiName} @value-changed=${(e: CustomEvent) => this._updateForm('upiName', e.detail)}></psa-input>
            <div class="border-t border-gray-100 pt-4">
              <p class="text-xs font-medium text-gray-500 uppercase tracking-wide mb-3">Billing Configuration</p>
              <psa-input label="Monthly Maintenance Amount (₹)" type="number" .value=${this.form.maintenanceAmount} @value-changed=${(e: CustomEvent) => this._updateForm('maintenanceAmount', e.detail)}></psa-input>
              <p class="text-xs text-gray-400 mt-1">This amount will be used when generating new monthly bills.</p>
            </div>
            <div class="flex gap-2 justify-end pt-2">
              <psa-button variant="secondary" @click=${() => this.modal = false}>Cancel</psa-button>
              <psa-button .loading=${this.saving} @click=${this._handleSave}>Save</psa-button>
            </div>
          </div>
        </psa-modal>
      </div>
    `;
  }
}
