import { LitElement, html } from 'lit';
import { customElement, state } from 'lit/decorators.js';
import { iconPlus, iconEdit2, iconKeyRound } from '../../lib/icons.js';
import api from '../../lib/api.js';

@customElement('admin-users')
export class AdminUsers extends LitElement {
  @state() private users: any[] = [];
  @state() private loading = true;
  @state() private modal = false;
  @state() private editUser: any = null;
  @state() private form = { name: '', email: '', phone: '', password: '', role: 'TENANT' };
  @state() private saving = false;
  @state() private resetModal: any = null;
  @state() private newPw = '';
  @state() private resetting = false;

  createRenderRoot() { return this; }
  connectedCallback() { super.connectedCallback(); this._load(); }

  private async _load() { const { data } = await api.get('/users'); this.users = data; this.loading = false; }

  private _openCreate() { this.editUser = null; this.form = { name: '', email: '', phone: '', password: '', role: 'TENANT' }; this.modal = true; }
  private _openEdit(u: any) { this.editUser = u; this.form = { name: u.name, email: u.email, phone: u.phone || '', password: '', role: u.role }; this.modal = true; }

  private async _handleSave() {
    this.saving = true;
    try {
      if (this.editUser) {
        await api.patch(`/users/${this.editUser.id}`, { name: this.form.name, phone: this.form.phone, role: this.form.role });
        if (this.form.password) await api.patch(`/users/${this.editUser.id}/password`, { password: this.form.password });
      } else { await api.post('/users', this.form); }
      await this._load(); this.modal = false;
    } catch (e: any) { alert(e.response?.data?.message || 'Error saving user'); }
    this.saving = false;
  }

  private async _handleToggleOwnerTenant(u: any) {
    await api.patch(`/users/${u.id}/owner-tenant`, { isOwnerTenant: !u.isOwnerTenant }); await this._load();
  }

  private async _handleAdminReset() {
    if (!this.resetModal || !this.newPw) return;
    this.resetting = true;
    try {
      await api.patch(`/users/${this.resetModal.user.id}/password`, { password: this.newPw });
      alert('Password reset successfully.'); this.resetModal = null; this.newPw = '';
    } catch (e: any) { alert(e.response?.data?.message || 'Error resetting password'); }
    this.resetting = false;
  }

  private _uf(key: string, val: string) { this.form = { ...this.form, [key]: val }; }

  private _roleColor(role: string) {
    return role === 'ADMIN' ? 'bg-purple-100 text-purple-700' : role === 'OWNER' ? 'bg-blue-100 text-blue-700' : 'bg-green-100 text-green-700';
  }

  render() {
    return html`
      <div>
        <div class="flex items-center justify-between mb-6">
          <div>
            <h1 class="text-2xl font-bold text-gray-900">Users</h1>
            <p class="text-gray-500 text-sm mt-1">${this.users.length} registered users</p>
          </div>
          <psa-button @click=${this._openCreate}>${iconPlus('w-4 h-4')} Add User</psa-button>
        </div>
        <div class="bg-white rounded-xl border border-gray-200 shadow-sm">
          <div class="overflow-x-auto">
            <table class="w-full text-sm">
              <thead class="bg-gray-50 border-b border-gray-100">
                <tr>
                  <th class="text-left px-6 py-3 font-medium text-gray-500">Name</th>
                  <th class="text-left px-6 py-3 font-medium text-gray-500">Email</th>
                  <th class="text-left px-6 py-3 font-medium text-gray-500">Phone</th>
                  <th class="text-left px-6 py-3 font-medium text-gray-500">Role</th>
                  <th class="text-left px-6 py-3 font-medium text-gray-500">Owner+Tenant</th>
                  <th class="text-left px-6 py-3 font-medium text-gray-500">Actions</th>
                </tr>
              </thead>
              <tbody class="divide-y divide-gray-50">
                ${this.loading ? html`<tr><td colspan="6" class="px-6 py-4 text-gray-400">Loading...</td></tr>` :
                  this.users.map(u => html`
                    <tr class="hover:bg-gray-50">
                      <td class="px-6 py-3 font-medium text-gray-900">${u.name}</td>
                      <td class="px-6 py-3 text-gray-600">${u.email}</td>
                      <td class="px-6 py-3 text-gray-600">${u.phone || '—'}</td>
                      <td class="px-6 py-3"><span class="text-xs font-medium px-2 py-0.5 rounded-full ${this._roleColor(u.role)}">${u.role}</span></td>
                      <td class="px-6 py-3">
                        ${u.role === 'OWNER' ? html`
                          <button @click=${() => this._handleToggleOwnerTenant(u)}
                            class="text-xs font-medium px-2 py-0.5 rounded-full cursor-pointer transition border-none ${u.isOwnerTenant ? 'bg-green-100 text-green-700' : 'bg-gray-100 text-gray-500'}">
                            ${u.isOwnerTenant ? 'Yes' : 'No'}
                          </button>
                        ` : html`<span class="text-gray-300">—</span>`}
                      </td>
                      <td class="px-6 py-3">
                        <div class="flex items-center gap-2">
                          <button @click=${() => this._openEdit(u)} class="text-blue-600 hover:text-blue-700 cursor-pointer bg-transparent border-none">${iconEdit2('w-4 h-4')}</button>
                          <button @click=${() => { this.resetModal = { open: true, user: u }; this.newPw = ''; }}
                            class="text-orange-500 hover:text-orange-700 cursor-pointer bg-transparent border-none">${iconKeyRound('w-4 h-4')}</button>
                        </div>
                      </td>
                    </tr>
                  `)}
              </tbody>
            </table>
          </div>
        </div>

        <psa-modal ?open=${this.modal} modalTitle=${this.editUser ? 'Edit User' : 'Add User'} size="sm" @close=${() => this.modal = false}>
          <div class="space-y-4">
            <psa-input label="Full Name" .value=${this.form.name} @value-changed=${(e: CustomEvent) => this._uf('name', e.detail)}></psa-input>
            ${!this.editUser ? html`<psa-input label="Email" type="email" .value=${this.form.email} @value-changed=${(e: CustomEvent) => this._uf('email', e.detail)}></psa-input>` : ''}
            <psa-input label="Phone" .value=${this.form.phone} @value-changed=${(e: CustomEvent) => this._uf('phone', e.detail)}></psa-input>
            <psa-input label=${this.editUser ? 'New Password (leave blank to keep)' : 'Password'} type="password" .value=${this.form.password} @value-changed=${(e: CustomEvent) => this._uf('password', e.detail)}></psa-input>
            <psa-select label="Role" .value=${this.form.role} @value-changed=${(e: CustomEvent) => this._uf('role', e.detail)}>
              <option value="TENANT">Tenant</option><option value="OWNER">Owner</option><option value="ADMIN">Admin</option>
            </psa-select>
            <div class="flex gap-2 justify-end pt-2">
              <psa-button variant="secondary" @click=${() => this.modal = false}>Cancel</psa-button>
              <psa-button .loading=${this.saving} @click=${this._handleSave}>Save</psa-button>
            </div>
          </div>
        </psa-modal>

        <psa-modal ?open=${!!this.resetModal?.open} modalTitle="Reset Password — ${this.resetModal?.user?.name || ''}" size="sm" @close=${() => this.resetModal = null}>
          <div class="space-y-4">
            <p class="text-xs text-gray-500">Set a new password for this user.</p>
            <psa-input label="New Password" type="password" .value=${this.newPw} @value-changed=${(e: CustomEvent) => this.newPw = e.detail} placeholder="Min 6 characters"></psa-input>
            <div class="flex gap-2 justify-end pt-2">
              <psa-button variant="secondary" @click=${() => this.resetModal = null}>Cancel</psa-button>
              <psa-button .loading=${this.resetting} .disabled=${this.newPw.length < 6} @click=${this._handleAdminReset}>Reset Password</psa-button>
            </div>
          </div>
        </psa-modal>
      </div>
    `;
  }
}
