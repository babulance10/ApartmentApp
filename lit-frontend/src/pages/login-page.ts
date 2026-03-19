import { LitElement, html, nothing } from 'lit';
import { customElement, state } from 'lit/decorators.js';
import { iconBuilding2, iconLock, iconMail } from '../lib/icons.js';
import api from '../lib/api.js';
import { setAuth } from '../lib/auth.js';

@customElement('login-page')
export class LoginPage extends LitElement {
  @state() private email = '';
  @state() private password = '';
  @state() private error = '';
  @state() private loading = false;

  createRenderRoot() { return this; }

  private async _handleSubmit(e: Event) {
    e.preventDefault();
    this.error = '';
    this.loading = true;
    try {
      const { data } = await api.post('/auth/login', { email: this.email, password: this.password });
      setAuth(data.access_token, data.user);
      if (data.user.role === 'TENANT') window.location.hash = '#/tenant';
      else if (data.user.role === 'OWNER') window.location.hash = '#/owner';
      else window.location.hash = '#/admin';
    } catch (err: any) {
      this.error = err.response?.data?.message || 'Invalid email or password';
    } finally {
      this.loading = false;
    }
  }

  render() {
    return html`
      <div class="min-h-screen flex items-center justify-center bg-gradient-to-br from-blue-50 via-white to-indigo-50 p-4">
        <div class="w-full max-w-md">
          <div class="text-center mb-8">
            <div class="inline-flex items-center justify-center w-16 h-16 bg-blue-600 rounded-2xl mb-4 shadow-lg">
              ${iconBuilding2('w-9 h-9 text-white')}
            </div>
            <h1 class="text-2xl font-bold text-gray-900">PSA Portal</h1>
            <p class="text-gray-500 mt-1 text-sm">Primark Sreenidhi Apartment Association</p>
          </div>

          <div class="bg-white rounded-2xl shadow-xl border border-gray-100 p-8">
            <h2 class="text-xl font-semibold text-gray-800 mb-6">Sign in to your account</h2>

            ${this.error ? html`
              <div class="mb-4 p-3 bg-red-50 border border-red-200 rounded-lg text-sm text-red-600">
                ${this.error}
              </div>
            ` : nothing}

            <form @submit=${this._handleSubmit} class="space-y-4">
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Email Address</label>
                <div class="relative">
                  <span class="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400">${iconMail('w-4 h-4')}</span>
                  <input
                    type="email"
                    .value=${this.email}
                    @input=${(e: Event) => this.email = (e.target as HTMLInputElement).value}
                    placeholder="you@example.com"
                    required
                    class="w-full pl-10 pr-4 py-2.5 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  />
                </div>
              </div>

              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Password</label>
                <div class="relative">
                  <span class="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400">${iconLock('w-4 h-4')}</span>
                  <input
                    type="password"
                    .value=${this.password}
                    @input=${(e: Event) => this.password = (e.target as HTMLInputElement).value}
                    placeholder="••••••••"
                    required
                    class="w-full pl-10 pr-4 py-2.5 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  />
                </div>
              </div>

              <button
                type="submit"
                ?disabled=${this.loading}
                class="w-full bg-blue-600 hover:bg-blue-700 text-white font-medium py-2.5 rounded-lg transition disabled:opacity-50 disabled:cursor-not-allowed text-sm cursor-pointer"
              >
                ${this.loading ? 'Signing in...' : 'Sign In'}
              </button>
            </form>

            <div class="mt-6 p-4 bg-gray-50 rounded-lg text-xs text-gray-500 space-y-1">
              <p class="font-medium text-gray-600">Demo credentials:</p>
              <p>Admin: admin@psa.com / admin123</p>
              <p>Tenant: flat101@psa.com / tenant123</p>
            </div>
          </div>
        </div>
      </div>
    `;
  }
}
