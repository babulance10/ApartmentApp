import { html, render, TemplateResult } from 'lit';
import { getToken } from './lib/auth.js';

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

      render(html`
        <div class="psa-shell">
          <app-sidebar></app-sidebar>
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
}

export const router = new HashRouter();
