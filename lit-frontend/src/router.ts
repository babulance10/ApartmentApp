import { html, render, TemplateResult } from 'lit';
import { getToken, getUser } from './lib/auth.js';

type RouteHandler = () => TemplateResult;

interface Route {
  path: string;
  handler: RouteHandler;
  layout?: boolean;
}

class HashRouter {
  private routes: Route[] = [];
  private outlet: HTMLElement | null = null;

  register(path: string, handler: RouteHandler, layout = false) {
    this.routes.push({ path, handler, layout });
    return this;
  }

  start(outlet: HTMLElement) {
    this.outlet = outlet;
    window.addEventListener('hashchange', () => this._resolve());
    this._resolve();
  }

  private _homeForRoles(roles: string[]): string {
    if (roles.includes('ADMIN')) return '#/admin';
    if (roles.includes('OWNER')) return '#/owner';
    if (roles.includes('VIEWER')) return '#/admin';
    if (roles.includes('WATER_MANAGER')) return '#/admin/water-purchases';
    if (roles.includes('TENANT')) return '#/tenant';
    return '#/login';
  }

  private _isRouteAllowed(hash: string, roles: string[]): boolean {
    if (roles.includes('ADMIN')) return true;
    if (hash === '/profile') return true;
    if (roles.includes('VIEWER') && (hash === '/admin' || hash === '/admin/events')) return true;
    if (roles.includes('WATER_MANAGER') && hash.startsWith('/admin/water-purchases')) return true;
    if (roles.includes('OWNER') && (hash.startsWith('/owner') || hash === '/admin/contributions')) return true;
    if (roles.includes('TENANT') && hash.startsWith('/tenant')) return true;
    return false;
  }

  private _resolve() {
    if (!this.outlet) return;
    const rawHash = window.location.hash.slice(1);

    // Redirect logged-in users away from login / empty URL to their home
    if (!rawHash || rawHash === '/' || rawHash === '/login') {
      const token = getToken();
      if (token) {
        const roles: string[] = getUser()?.roles || [];
        window.location.hash = this._homeForRoles(roles);
        return;
      }
    }

    const hash = rawHash || '/login';

    // Exact match first
    let route = this.routes.find(r => r.path === hash);
    // Then longest prefix match (skip root)
    if (!route) {
      const sorted = [...this.routes].filter(r => r.path !== '/').sort((a, b) => b.path.length - a.path.length);
      route = sorted.find(r => hash.startsWith(r.path));
    }
    if (!route) route = this.routes[0];

    if (!route) {
      render(html`<p class="p-8 text-gray-500">Page not found</p>`, this.outlet);
      return;
    }

    const content = route.handler();

    if (route.layout) {
      // Auth guard
      if (!getToken()) { window.location.hash = '#/login'; return; }

      // Role guard — unified check across all roles
      const user = getUser();
      const roles: string[] = user?.roles || [];

      if (!this._isRouteAllowed(hash, roles)) {
        window.location.hash = this._homeForRoles(roles);
        return;
      }

      render(html`
        <div class="psa-shell">
          <app-sidebar></app-sidebar>
          <div class="psa-overlay" id="psa-overlay" @click=${() => this._closeMobile()}></div>
          <div class="psa-topbar">
            <button class="psa-hamburger" @click=${() => this._openMobile()} aria-label="Open menu">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <line x1="3" y1="6" x2="21" y2="6"/><line x1="3" y1="12" x2="21" y2="12"/><line x1="3" y1="18" x2="21" y2="18"/>
              </svg>
            </button>
            <div class="psa-topbar-logo">
              <div style="width:30px;height:30px;border-radius:8px;background:linear-gradient(135deg,#3b82f6,#6366f1);display:flex;align-items:center;justify-content:center">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 21h18M5 21V7l7-4 7 4v14M9 21v-4h6v4"/></svg>
              </div>
              <span style="color:white;font-weight:700;font-size:15px;letter-spacing:-0.3px">PSA Portal</span>
            </div>
          </div>
          <main class="psa-main">
            <div class="psa-content">
              ${content}
            </div>
          </main>
        </div>
      `, this.outlet);
    } else {
      render(content, this.outlet);
    }
  }

  navigate(path: string) {
    window.location.hash = path;
  }

  private _openMobile() {
    document.querySelector('.psa-sidebar')?.classList.add('mobile-open');
    document.getElementById('psa-overlay')?.style.setProperty('display', 'block');
  }

  private _closeMobile() {
    document.querySelector('.psa-sidebar')?.classList.remove('mobile-open');
    document.getElementById('psa-overlay')?.style.setProperty('display', 'none');
  }
}

export const router = new HashRouter();
