import { LitElement, html } from 'lit';
import { customElement } from 'lit/decorators.js';

// Layout is now handled directly by the router.
// This component is kept as a no-op for backwards compat.
@customElement('app-layout')
export class AppLayout extends LitElement {
  createRenderRoot() { return this; }
  render() { return html``; }
}
