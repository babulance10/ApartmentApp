import { LitElement, html } from 'lit';
import { customElement, state } from 'lit/decorators.js';
import { clearAuth, getUser } from '../../lib/auth.js';
import {
  iconBuilding2, iconHome, iconUsers, iconDroplets, iconReceipt,
  iconCreditCard, iconWrench, iconBarChart3, iconLogOut, iconChevronRight,
  iconTruck, iconHandCoins, iconUserCircle, iconPanelLeftClose, iconPanelLeftOpen,
  iconSettings,
} from '../../lib/icons.js';

interface NavItem { href: string; label: string; icon: (c?: string) => any; group?: string; }

const adminNav: NavItem[] = [
  { href: '#/admin', label: 'Dashboard', icon: iconBarChart3, group: 'Overview' },
  { href: '#/admin/apartments', label: 'Apartment', icon: iconBuilding2, group: 'Management' },
  { href: '#/admin/flats', label: 'Flats', icon: iconHome, group: 'Management' },
  { href: '#/admin/users', label: 'Users', icon: iconUsers, group: 'Management' },
  { href: '#/admin/water-meter', label: 'Water Meter', icon: iconDroplets, group: 'Water' },
  { href: '#/admin/water-purchases', label: 'Water Tankers', icon: iconTruck, group: 'Water' },
  { href: '#/admin/bills', label: 'Bills', icon: iconReceipt, group: 'Finance' },
  { href: '#/admin/payments', label: 'Payments', icon: iconCreditCard, group: 'Finance' },
  { href: '#/admin/contributions', label: 'Contributions', icon: iconHandCoins, group: 'Finance' },
  { href: '#/admin/expenses', label: 'Expenses', icon: iconBarChart3, group: 'Finance' },
  { href: '#/admin/maintenance', label: 'Maintenance', icon: iconWrench, group: 'Operations' },
  { href: '#/admin/events', label: 'Events', icon: iconHandCoins, group: 'Operations' },
];

const ownerNav: NavItem[] = [
  { href: '#/owner', label: 'My Flats & Tenants', icon: iconHome },
  { href: '#/profile', label: 'My Profile', icon: iconUserCircle },
];

const tenantNav: NavItem[] = [
  { href: '#/tenant', label: 'My Bills', icon: iconReceipt },
  { href: '#/tenant/payments', label: 'Payment History', icon: iconCreditCard },
  { href: '#/tenant/maintenance', label: 'Maintenance', icon: iconWrench },
  { href: '#/profile', label: 'My Profile', icon: iconUserCircle },
];

@customElement('app-sidebar')
export class AppSidebar extends LitElement {
  @state() private user: any = null;
  @state() private currentPath = '';
  @state() private collapsed = false;

  createRenderRoot() { return this; }

  connectedCallback() {
    super.connectedCallback();
    this.user = getUser();
    this.currentPath = window.location.hash || '#/';
    this.collapsed = localStorage.getItem('psa-sidebar-collapsed') === 'true';
    window.addEventListener('hashchange', this._onHashChange);
  }

  disconnectedCallback() {
    super.disconnectedCallback();
    window.removeEventListener('hashchange', this._onHashChange);
  }

  private _onHashChange = () => {
    this.currentPath = window.location.hash;
    // Close mobile sidebar on navigation — target the <aside> inside this component
    const aside = this.querySelector('.psa-sidebar') || this.shadowRoot?.querySelector('.psa-sidebar');
    if (aside) aside.classList.remove('mobile-open');
    const overlay = document.getElementById('psa-overlay');
    if (overlay) overlay.style.display = 'none';
  };

  private _toggleCollapse() {
    this.collapsed = !this.collapsed;
    localStorage.setItem('psa-sidebar-collapsed', String(this.collapsed));
    this.dispatchEvent(new CustomEvent('sidebar-toggle', { detail: this.collapsed, bubbles: true, composed: true }));
  }

  private _logout() {
    clearAuth();
    window.location.hash = '#/login';
  }

  private _isActive(href: string) {
    const path = this.currentPath;
    if (href === '#/admin' || href === '#/tenant' || href === '#/owner') return path === href;
    return path === href || path.startsWith(href + '/');
  }

  private _initials(name: string) {
    return (name || 'U').split(' ').map(w => w[0]).join('').slice(0, 2).toUpperCase();
  }

  private _renderGrouped(items: NavItem[]) {
    const groups: Record<string, NavItem[]> = {};
    items.forEach(item => {
      const g = item.group || 'General';
      if (!groups[g]) groups[g] = [];
      groups[g].push(item);
    });

    return Object.entries(groups).map(([group, navItems]) => html`
      ${!this.collapsed ? html`
        <div class="px-3 pt-4 pb-1.5">
          <p class="text-[10px] font-semibold uppercase tracking-[0.12em] text-slate-500">${group}</p>
        </div>
      ` : html`<div class="pt-3"></div>`}
      ${navItems.map(item => this._renderNavItem(item))}
    `);
  }

  private _renderNavItem({ href, label, icon }: NavItem) {
    const active = this._isActive(href);
    const c = this.collapsed;
    return html`
      <a href=${href} title=${c ? label : ''}
        class="psa-nav-item flex items-center gap-3 rounded-xl text-[13px] font-medium no-underline relative
          ${c ? 'justify-center px-0 py-2.5 mx-1.5' : 'px-3 py-2 mx-2'}
          ${active
            ? 'bg-gradient-to-r from-blue-600 to-indigo-600 text-white shadow-lg shadow-blue-600/25'
            : 'text-slate-400 hover:text-white hover:bg-white/[0.06]'
          }"
      >
        <span class="flex-shrink-0 ${c ? '' : ''}">${icon(`w-[18px] h-[18px] ${active ? 'text-white' : ''}`)}</span>
        ${!c ? html`<span class="truncate">${label}</span>` : ''}
        ${!c && active ? html`<span class="ml-auto">${iconChevronRight('w-3.5 h-3.5 text-white/60')}</span>` : ''}
      </a>
    `;
  }

  render() {
    const roles = this.user?.roles || [];
    const nav = roles.includes('ADMIN') ? adminNav
      : roles.includes('OWNER') ? ownerNav
      : tenantNav;
    const c = this.collapsed;
    const hasGroups = nav.some(n => n.group);

    return html`
      <aside class="psa-sidebar ${c ? 'psa-sidebar--collapsed' : ''}" style="width: ${c ? '72px' : '260px'}">
        <!-- Header / Logo -->
        <div class="flex items-center ${c ? 'justify-center px-2' : 'justify-between px-5'} py-4 border-b border-white/[0.06]">
          ${!c ? html`
            <div class="flex items-center gap-3">
              <div class="w-9 h-9 rounded-xl bg-gradient-to-br from-blue-500 to-indigo-600 flex items-center justify-center shadow-lg shadow-blue-500/30">
                ${iconBuilding2('w-5 h-5 text-white')}
              </div>
              <div>
                <p class="font-bold text-[15px] text-white leading-tight tracking-tight">PSA Portal</p>
                <p class="text-[11px] text-slate-500 leading-tight">Primark Sreenidhi</p>
              </div>
            </div>
          ` : html`
            <div class="w-9 h-9 rounded-xl bg-gradient-to-br from-blue-500 to-indigo-600 flex items-center justify-center shadow-lg shadow-blue-500/30">
              ${iconBuilding2('w-5 h-5 text-white')}
            </div>
          `}
          <button @click=${this._toggleCollapse}
            class="psa-collapse-btn p-1.5 rounded-lg text-slate-500 hover:text-white hover:bg-white/10 cursor-pointer bg-transparent border-none ${c ? 'mt-3' : ''}"
            title=${c ? 'Expand sidebar' : 'Collapse sidebar'}
          >
            ${c ? iconPanelLeftOpen('w-4 h-4') : iconPanelLeftClose('w-4 h-4')}
          </button>
        </div>

        <!-- Navigation -->
        <nav class="flex-1 py-2 overflow-y-auto psa-sidebar-nav">
          ${hasGroups ? this._renderGrouped(nav) : nav.map(item => this._renderNavItem(item))}
        </nav>

        <!-- Bottom Section -->
        <div class="border-t border-white/[0.06] p-2.5">
          <!-- Profile Link -->
          ${this._renderNavItem({ href: '#/profile', label: 'My Profile', icon: iconSettings })}

          <!-- User Info -->
          <div class="flex items-center gap-3 ${c ? 'justify-center' : ''} px-3 py-2.5 mt-1">
            <div class="w-8 h-8 rounded-full bg-gradient-to-br from-violet-500 to-fuchsia-500 flex items-center justify-center text-white text-xs font-bold flex-shrink-0 shadow-lg shadow-violet-500/25">
              ${this._initials(this.user?.name)}
            </div>
            ${!c ? html`
              <div class="flex-1 min-w-0">
                <p class="text-[13px] font-semibold text-white truncate">${this.user?.name}</p>
                <p class="text-[11px] text-slate-500 truncate">${this.user?.email}</p>
              </div>
            ` : ''}
          </div>

          <!-- Logout -->
          <button @click=${this._logout} title="Logout"
            class="flex items-center gap-3 w-full rounded-xl text-[13px] font-medium text-slate-400 hover:text-red-400 hover:bg-red-500/10 cursor-pointer bg-transparent border-none
              ${c ? 'justify-center px-0 py-2.5 mx-auto' : 'px-3 py-2.5 mx-0'}"
          >
            ${iconLogOut('w-[18px] h-[18px]')}
            ${!c ? html`<span>Logout</span>` : ''}
          </button>
        </div>
      </aside>
    `;
  }
}
