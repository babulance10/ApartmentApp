import { LitElement, html } from 'lit';
import { customElement, state } from 'lit/decorators.js';
import { iconUser, iconLock, iconSave, iconEye, iconEyeOff } from '../lib/icons.js';
import { getUser } from '../lib/auth.js';
import api from '../lib/api.js';

@customElement('profile-page')
export class ProfilePage extends LitElement {
  @state() private user: any = null;
  @state() private profileForm = { name: '', phone: '' };
  @state() private pwForm = { oldPassword: '', newPassword: '', confirm: '' };
  @state() private savingProfile = false;
  @state() private savingPw = false;
  @state() private profileMsg = '';
  @state() private pwMsg = '';
  @state() private showOld = false;
  @state() private showNew = false;

  createRenderRoot() { return this; }
  connectedCallback() {
    super.connectedCallback();
    api.get('/users/me').then(r => {
      this.user = r.data;
      this.profileForm = { name: r.data.name, phone: r.data.phone || '' };
    });
  }

  private async _handleProfileSave() {
    this.savingProfile = true; this.profileMsg = '';
    try {
      await api.patch(`/users/${this.user.id}`, { name: this.profileForm.name, phone: this.profileForm.phone });
      this.profileMsg = 'Profile updated successfully.';
    } catch (e: any) { this.profileMsg = e.response?.data?.message || 'Error updating profile'; }
    this.savingProfile = false;
  }

  private async _handlePasswordChange() {
    if (this.pwForm.newPassword !== this.pwForm.confirm) { this.pwMsg = 'New passwords do not match.'; return; }
    if (this.pwForm.newPassword.length < 6) { this.pwMsg = 'Password must be at least 6 characters.'; return; }
    this.savingPw = true; this.pwMsg = '';
    try {
      await api.post('/users/me/change-password', { oldPassword: this.pwForm.oldPassword, newPassword: this.pwForm.newPassword });
      this.pwMsg = 'Password changed successfully.';
      this.pwForm = { oldPassword: '', newPassword: '', confirm: '' };
    } catch (e: any) { this.pwMsg = e.response?.data?.message || 'Current password is incorrect'; }
    this.savingPw = false;
  }

  private _currentUser = getUser();

  render() {
    return html`
      <div class="max-w-xl">
        <div class="mb-6">
          <h1 class="text-2xl font-bold text-gray-900">My Profile</h1>
          <p class="text-gray-500 text-sm mt-1">${this._currentUser?.email}</p>
        </div>

        <!-- Profile Info -->
        <div class="bg-white rounded-xl border border-gray-200 shadow-sm mb-5">
          <div class="px-6 py-4 border-b border-gray-100 flex items-center gap-3">
            <div class="w-9 h-9 bg-blue-100 rounded-xl flex items-center justify-center">${iconUser('w-5 h-5 text-blue-600')}</div>
            <p class="font-semibold text-gray-900">Personal Information</p>
          </div>
          <div class="px-6 py-4">
            <div class="space-y-4">
              <div class="flex items-center gap-2 text-xs font-medium px-2 py-0.5 rounded-full w-fit bg-purple-100 text-purple-700">${this.user?.role}</div>
              <psa-input label="Full Name" .value=${this.profileForm.name} @value-changed=${(e: CustomEvent) => this.profileForm = { ...this.profileForm, name: e.detail }}></psa-input>
              <psa-input label="Email" .value=${this.user?.email || ''} disabled></psa-input>
              <psa-input label="Phone Number" .value=${this.profileForm.phone} @value-changed=${(e: CustomEvent) => this.profileForm = { ...this.profileForm, phone: e.detail }} placeholder="+91 XXXXXXXXXX"></psa-input>
              ${this.profileMsg ? html`<p class="text-sm ${this.profileMsg.includes('success') ? 'text-green-600' : 'text-red-600'}">${this.profileMsg}</p>` : ''}
              <div class="flex justify-end">
                <psa-button .loading=${this.savingProfile} @click=${this._handleProfileSave}>${iconSave('w-4 h-4')} Save Profile</psa-button>
              </div>
            </div>
          </div>
        </div>

        <!-- Change Password -->
        <div class="bg-white rounded-xl border border-gray-200 shadow-sm">
          <div class="px-6 py-4 border-b border-gray-100 flex items-center gap-3">
            <div class="w-9 h-9 bg-orange-100 rounded-xl flex items-center justify-center">${iconLock('w-5 h-5 text-orange-600')}</div>
            <p class="font-semibold text-gray-900">Change Password</p>
          </div>
          <div class="px-6 py-4">
            <div class="space-y-4">
              <div class="relative">
                <psa-input label="Current Password" .type=${this.showOld ? 'text' : 'password'} .value=${this.pwForm.oldPassword}
                  @value-changed=${(e: CustomEvent) => this.pwForm = { ...this.pwForm, oldPassword: e.detail }}></psa-input>
                <button @click=${() => this.showOld = !this.showOld}
                  class="absolute right-3 top-8 text-gray-400 hover:text-gray-600 cursor-pointer bg-transparent border-none">
                  ${this.showOld ? iconEyeOff('w-4 h-4') : iconEye('w-4 h-4')}
                </button>
              </div>
              <div class="relative">
                <psa-input label="New Password" .type=${this.showNew ? 'text' : 'password'} .value=${this.pwForm.newPassword}
                  @value-changed=${(e: CustomEvent) => this.pwForm = { ...this.pwForm, newPassword: e.detail }}></psa-input>
                <button @click=${() => this.showNew = !this.showNew}
                  class="absolute right-3 top-8 text-gray-400 hover:text-gray-600 cursor-pointer bg-transparent border-none">
                  ${this.showNew ? iconEyeOff('w-4 h-4') : iconEye('w-4 h-4')}
                </button>
              </div>
              <psa-input label="Confirm New Password" type="password" .value=${this.pwForm.confirm}
                @value-changed=${(e: CustomEvent) => this.pwForm = { ...this.pwForm, confirm: e.detail }}></psa-input>
              ${this.pwMsg ? html`<p class="text-sm ${this.pwMsg.includes('success') ? 'text-green-600' : 'text-red-600'}">${this.pwMsg}</p>` : ''}
              <div class="flex justify-end">
                <psa-button .loading=${this.savingPw} .disabled=${!this.pwForm.oldPassword || !this.pwForm.newPassword || !this.pwForm.confirm}
                  @click=${this._handlePasswordChange}>${iconLock('w-4 h-4')} Change Password</psa-button>
              </div>
            </div>
          </div>
        </div>
      </div>
    `;
  }
}
