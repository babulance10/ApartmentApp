import { LitElement, html } from 'lit';
import { customElement, state } from 'lit/decorators.js';
import { iconWrench, iconPlus, iconCheckCircle, iconClock, iconAlertCircle } from '../../lib/icons.js';
import api from '../../lib/api.js';

@customElement('tenant-maintenance')
export class TenantMaintenance extends LitElement {
  @state() private requests: any[] = [];
  @state() private flatId = '';
  @state() private loading = true;
  @state() private modal = false;
  @state() private form = { title: '', description: '', priority: 'MEDIUM' };
  @state() private saving = false;

  createRenderRoot() { return this; }
  connectedCallback() { super.connectedCallback(); this._load(); }

  private async _load() {
    try {
      const profile = await api.get('/users/me');
      const tenancy = profile.data.tenancies?.[0];
      if (tenancy?.flat) {
        this.flatId = tenancy.flat.id;
        const { data } = await api.get(`/maintenance?flatId=${tenancy.flat.id}`);
        this.requests = data;
      }
    } catch {}
    this.loading = false;
  }

  private async _handleSubmit() {
    if (!this.flatId) return;
    this.saving = true;
    try {
      await api.post('/maintenance', { ...this.form, flatId: this.flatId });
      const { data } = await api.get(`/maintenance?flatId=${this.flatId}`);
      this.requests = data;
      this.modal = false;
      this.form = { title: '', description: '', priority: 'MEDIUM' };
    } catch (e: any) { alert(e.response?.data?.message || 'Error submitting request'); }
    this.saving = false;
  }

  private _statusIcon(s: string) {
    return s === 'OPEN' ? iconAlertCircle('w-4 h-4 text-red-500') : s === 'IN_PROGRESS' ? iconClock('w-4 h-4 text-yellow-500') : s === 'RESOLVED' ? iconCheckCircle('w-4 h-4 text-green-500') : iconCheckCircle('w-4 h-4 text-gray-400');
  }
  private _statusLabel: Record<string, string> = { OPEN: 'Open', IN_PROGRESS: 'In Progress', RESOLVED: 'Resolved', CLOSED: 'Closed' };
  private _statusBg: Record<string, string> = { OPEN: 'bg-red-50 border-red-100', IN_PROGRESS: 'bg-yellow-50 border-yellow-100', RESOLVED: 'bg-green-50 border-green-100', CLOSED: 'bg-gray-50 border-gray-100' };
  private _priorityColor: Record<string, string> = { HIGH: 'bg-red-100 text-red-700', MEDIUM: 'bg-yellow-100 text-yellow-700', LOW: 'bg-blue-100 text-blue-700' };

  render() {
    return html`
      <div>
        <div class="flex items-center justify-between mb-6">
          <div>
            <h1 class="text-2xl font-bold text-gray-900">Maintenance Requests</h1>
            <p class="text-gray-500 text-sm mt-1">${this.requests.length} requests raised</p>
          </div>
          <psa-button @click=${() => this.modal = true}>${iconPlus('w-4 h-4')} Raise Request</psa-button>
        </div>

        ${this.loading ? html`<p class="text-gray-500">Loading...</p>` :
          this.requests.length === 0 ? html`
            <div class="bg-white rounded-xl border border-gray-200 shadow-sm">
              <div class="px-6 py-12 text-center text-gray-400">
                ${iconWrench('w-10 h-10 mx-auto mb-3 opacity-30')}
                <p>No maintenance requests yet.</p>
                <p class="text-sm mt-1">Click "Raise Request" to submit an issue.</p>
              </div>
            </div>
          ` : html`
            <div class="space-y-3 max-w-2xl">
              ${this.requests.map(r => html`
                <div class="border rounded-xl p-4 ${this._statusBg[r.status]}">
                  <div class="flex items-start justify-between">
                    <div class="flex items-start gap-3">
                      <div class="mt-0.5">${this._statusIcon(r.status)}</div>
                      <div>
                        <p class="font-semibold text-gray-900">${r.title}</p>
                        ${r.description ? html`<p class="text-sm text-gray-600 mt-0.5">${r.description}</p>` : ''}
                        <p class="text-xs text-gray-400 mt-1">${new Date(r.createdAt).toLocaleDateString('en-IN')}</p>
                      </div>
                    </div>
                    <div class="flex flex-col items-end gap-1">
                      <span class="text-xs font-medium px-2 py-0.5 rounded-full ${this._priorityColor[r.priority]}">${r.priority}</span>
                      <span class="text-xs text-gray-500">${this._statusLabel[r.status]}</span>
                    </div>
                  </div>
                </div>
              `)}
            </div>
          `}

        <psa-modal ?open=${this.modal} modalTitle="Raise Maintenance Request" size="sm" @close=${() => this.modal = false}>
          <div class="space-y-4">
            <psa-input label="Issue Title" .value=${this.form.title} @value-changed=${(e: CustomEvent) => this.form = { ...this.form, title: e.detail }} placeholder="e.g. Water leakage in bathroom"></psa-input>
            <psa-textarea label="Description (optional)" .value=${this.form.description} @value-changed=${(e: CustomEvent) => this.form = { ...this.form, description: e.detail }} placeholder="Describe the issue in detail..."></psa-textarea>
            <psa-select label="Priority" .value=${this.form.priority} @value-changed=${(e: CustomEvent) => this.form = { ...this.form, priority: e.detail }}>
              <option value="LOW">Low</option><option value="MEDIUM">Medium</option><option value="HIGH">High</option>
            </psa-select>
            <div class="flex gap-2 justify-end pt-2">
              <psa-button variant="secondary" @click=${() => this.modal = false}>Cancel</psa-button>
              <psa-button .loading=${this.saving} .disabled=${!this.form.title} @click=${this._handleSubmit}>Submit</psa-button>
            </div>
          </div>
        </psa-modal>
      </div>
    `;
  }
}
