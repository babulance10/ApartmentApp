import { LitElement, html } from 'lit';
import { customElement, state } from 'lit/decorators.js';
import { iconAlertCircle, iconClock, iconCheckCircle } from '../../lib/icons.js';
import api from '../../lib/api.js';

const STATUS_OPTIONS = ['ALL', 'OPEN', 'IN_PROGRESS', 'RESOLVED', 'CLOSED'];

@customElement('admin-maintenance')
export class AdminMaintenance extends LitElement {
  @state() private requests: any[] = [];
  @state() private loading = true;
  @state() private filter = 'ALL';

  createRenderRoot() { return this; }
  connectedCallback() { super.connectedCallback(); this._load(); }

  private async _load() {
    this.loading = true;
    try {
      const params = this.filter !== 'ALL' ? `?status=${this.filter}` : '';
      const { data } = await api.get(`/maintenance${params}`);
      this.requests = data;
    } catch { this.requests = []; }
    this.loading = false;
  }

  updated(changed: Map<string, any>) {
    if (changed.has('filter') && changed.get('filter') !== undefined) this._load();
  }

  private async _updateStatus(id: string, status: string) {
    await api.patch(`/maintenance/${id}/status`, { status }); await this._load();
  }

  private _statusIcon(s: string) {
    return s === 'OPEN' ? iconAlertCircle('w-4 h-4 text-red-500') : s === 'IN_PROGRESS' ? iconClock('w-4 h-4 text-yellow-500') : s === 'RESOLVED' ? iconCheckCircle('w-4 h-4 text-green-500') : iconCheckCircle('w-4 h-4 text-gray-400');
  }
  private _priorityColor(p: string) { return p === 'HIGH' ? 'bg-red-100 text-red-700' : p === 'MEDIUM' ? 'bg-yellow-100 text-yellow-700' : 'bg-blue-100 text-blue-700'; }
  private _statusColor(s: string) { return s === 'OPEN' ? 'bg-red-100 text-red-700' : s === 'IN_PROGRESS' ? 'bg-yellow-100 text-yellow-700' : s === 'RESOLVED' ? 'bg-green-100 text-green-700' : 'bg-gray-100 text-gray-600'; }

  render() {
    return html`
      <div>
        <div class="flex items-center justify-between mb-6">
          <div>
            <h1 class="text-2xl font-bold text-gray-900">Maintenance Requests</h1>
            <p class="text-gray-500 text-sm mt-1">${this.requests.length} requests</p>
          </div>
        </div>
        <div class="flex gap-3 mb-6">
          <psa-select .value=${this.filter} @value-changed=${(e: CustomEvent) => this.filter = e.detail}>
            ${STATUS_OPTIONS.map(s => html`<option value=${s}>${s}</option>`)}
          </psa-select>
        </div>
        <div class="bg-white rounded-xl border border-gray-200 shadow-sm">
          <div class="overflow-x-auto">
            <table class="w-full text-sm">
              <thead class="bg-gray-50 border-b border-gray-100">
                <tr>${['Flat','Raised By','Title','Priority','Status','Date','Update Status'].map(h => html`<th class="text-left px-4 py-3 font-medium text-gray-500">${h}</th>`)}</tr>
              </thead>
              <tbody class="divide-y divide-gray-50">
                ${this.loading ? html`<tr><td colspan="7" class="px-4 py-4 text-gray-400">Loading...</td></tr>` :
                  this.requests.length === 0 ? html`<tr><td colspan="7" class="px-4 py-8 text-center text-gray-400">No maintenance requests.</td></tr>` :
                  this.requests.map(r => html`
                    <tr class="hover:bg-gray-50">
                      <td class="px-4 py-3 font-medium text-gray-900">Flat ${r.flat?.flatNumber}</td>
                      <td class="px-4 py-3 text-gray-600">${r.user?.name}</td>
                      <td class="px-4 py-3">
                        <div><p class="font-medium text-gray-800">${r.title}</p>${r.description ? html`<p class="text-xs text-gray-400 mt-0.5 line-clamp-1">${r.description}</p>` : ''}</div>
                      </td>
                      <td class="px-4 py-3"><span class="text-xs font-medium px-2 py-0.5 rounded-full ${this._priorityColor(r.priority)}">${r.priority}</span></td>
                      <td class="px-4 py-3"><div class="flex items-center gap-1.5">${this._statusIcon(r.status)}<span class="text-xs font-medium px-2 py-0.5 rounded-full ${this._statusColor(r.status)}">${r.status}</span></div></td>
                      <td class="px-4 py-3 text-gray-500 text-xs">${new Date(r.createdAt).toLocaleDateString('en-IN')}</td>
                      <td class="px-4 py-3">
                        <psa-select .value=${r.status} @value-changed=${(e: CustomEvent) => this._updateStatus(r.id, e.detail)} extraClass="text-xs py-1 px-2">
                          <option value="OPEN">Open</option><option value="IN_PROGRESS">In Progress</option><option value="RESOLVED">Resolved</option><option value="CLOSED">Closed</option>
                        </psa-select>
                      </td>
                    </tr>
                  `)}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    `;
  }
}
