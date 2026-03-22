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

  private _resolve() {
    if (!this.outlet) return;
    const hash = window.location.hash.slice(1) || '/login';

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

      // Role guard
      const user = getUser();
      const roles: string[] = user?.roles || [];
      const isAdmin = roles.includes('ADMIN');
      const isOwner = roles.includes('OWNER');
      const isTenant = roles.includes('TENANT');
      const isViewer = roles.includes('VIEWER');
      const isWaterManager = roles.includes('WATER_MANAGER');

      if (hash.startsWith('/admin') && !isAdmin && !isViewer && !(isWaterManager && hash === '/admin/water-meter')) {
        // Non-admins cannot access /admin/* except VIEWER (dashboard/events) and WATER_MANAGER (water-meter)
        if (isViewer) { window.location.hash = '#/admin'; return; }
        if (isWaterManager) { window.location.hash = '#/admin/water-meter'; return; }
        if (isOwner) { window.location.hash = '#/owner'; return; }
        window.location.hash = '#/tenant'; return;
      }
      if (hash.startsWith('/admin') && isViewer && !isAdmin) {
        // VIEWER can only see dashboard and events
        if (hash !== '/admin' && hash !== '/admin/events') { window.location.hash = '#/admin'; return; }
      }
      if (hash.startsWith('/owner') && !isOwner && !isAdmin) {
        window.location.hash = '#/tenant'; return;
      }
      if (hash.startsWith('/tenant') && !isTenant && !isAdmin) {
        if (isOwner) { window.location.hash = '#/owner'; return; }
        if (isViewer) { window.location.hash = '#/admin'; return; }
        if (isWaterManager) { window.location.hash = '#/admin/water-meter'; return; }
        window.location.hash = '#/login'; return;
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
