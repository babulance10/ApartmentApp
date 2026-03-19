import { LitElement, html, css } from 'lit';
import { customElement } from 'lit/decorators.js';

@customElement('psa-card')
export class PsaCard extends LitElement {
  static styles = css`
    :host { display: block; }
    .card {
      background: #fff; border-radius: 0.75rem;
      border: 1px solid #e5e7eb; box-shadow: 0 1px 2px rgba(0,0,0,0.05);
    }
  `;
  render() { return html`<div class="card"><slot></slot></div>`; }
}

@customElement('psa-card-header')
export class PsaCardHeader extends LitElement {
  static styles = css`
    :host { display: block; }
    .hdr { padding: 1rem 1.5rem; border-bottom: 1px solid #f3f4f6; }
  `;
  render() { return html`<div class="hdr"><slot></slot></div>`; }
}

@customElement('psa-card-body')
export class PsaCardBody extends LitElement {
  static styles = css`
    :host { display: block; }
    .body { padding: 1rem 1.5rem; }
  `;
  render() { return html`<div class="body"><slot></slot></div>`; }
}
