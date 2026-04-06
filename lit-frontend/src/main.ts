import './styles/global.css';
import { html } from 'lit';
import { router } from './router.js';

// UI Components
import './components/ui/psa-button.js';
import './components/ui/psa-card.js';
import './components/ui/psa-input.js';
import './components/ui/psa-modal.js';
import './components/ui/psa-badge.js';

// Layout
import './components/layout/app-layout.js';
import './components/layout/app-sidebar.js';

// Pages
import './pages/login-page.js';
import './pages/admin/admin-dashboard.js';
import './pages/admin/admin-apartments.js';
import './pages/admin/admin-flats.js';
import './pages/admin/admin-users.js';
import './pages/admin/admin-water-meter.js';
import './pages/admin/admin-water-purchases.js';
import './pages/admin/admin-bills.js';
import './pages/admin/admin-payments.js';
import './pages/admin/admin-contributions.js';
import './pages/admin/admin-expenses.js';
import './pages/admin/admin-maintenance.js';
import './pages/admin/admin-events.js';
import './pages/tenant/tenant-bills.js';
import './pages/tenant/tenant-payments.js';
import './pages/tenant/tenant-maintenance.js';
import './pages/tenant/tenant-bill-print.js';
import './pages/owner/owner-dashboard.js';
import './pages/profile-page.js';

// Routes
router
  .register('/login', () => html`<login-page></login-page>`)
  .register('/admin', () => html`<admin-dashboard></admin-dashboard>`, true)
  .register('/admin/apartments', () => html`<admin-apartments></admin-apartments>`, true)
  .register('/admin/flats', () => html`<admin-flats></admin-flats>`, true)
  .register('/admin/users', () => html`<admin-users></admin-users>`, true)
  .register('/admin/water-meter', () => html`<admin-water-meter></admin-water-meter>`, true)
  .register('/admin/water-purchases', () => html`<admin-water-purchases></admin-water-purchases>`, true)
  .register('/admin/bills', () => html`<admin-bills></admin-bills>`, true)
  .register('/admin/payments', () => html`<admin-payments></admin-payments>`, true)
  .register('/admin/contributions', () => html`<admin-contributions></admin-contributions>`, true)
  .register('/admin/expenses', () => html`<admin-expenses></admin-expenses>`, true)
  .register('/admin/maintenance', () => html`<admin-maintenance></admin-maintenance>`, true)
  .register('/admin/events', () => html`<admin-events></admin-events>`, true)
  .register('/tenant', () => html`<tenant-bills></tenant-bills>`, true)
  .register('/tenant/payments', () => html`<tenant-payments></tenant-payments>`, true)
  .register('/tenant/maintenance', () => html`<tenant-maintenance></tenant-maintenance>`, true)
  .register('/tenant/bill-print', () => html`<tenant-bill-print></tenant-bill-print>`, true)
  .register('/owner', () => html`<owner-dashboard></owner-dashboard>`, true)
  .register('/owner/water-meter', () => html`<admin-water-meter></admin-water-meter>`, true)
  .register('/profile', () => html`<profile-page></profile-page>`, true);

// Start
const app = document.getElementById('app');
if (app) {
  if (!window.location.hash) window.location.hash = '#/login';
  router.start(app);
}
