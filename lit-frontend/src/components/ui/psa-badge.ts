import { LitElement, html, css } from 'lit';
import { customElement, property } from 'lit/decorators.js';

@customElement('psa-badge')
export class PsaBadge extends LitElement {
  @property() variant = 'default';

  static styles = css`
    :host { display: inline-flex; }
    span {
      display: inline-flex; align-items: center;
      padding: 0.125rem 0.625rem; border-radius: 9999px;
      font-size: 0.75rem; font-weight: 500; line-height: 1.25rem;
    }
    span.green { background: #dcfce7; color: #15803d; }
    span.red { background: #fee2e2; color: #b91c1c; }
    span.yellow { background: #fef9c3; color: #a16207; }
    span.blue { background: #dbeafe; color: #1d4ed8; }
    span.gray { background: #f3f4f6; color: #374151; }
    span.default { background: #f3f4f6; color: #374151; }
  `;

  render() {
    return html`<span class="${this.variant}"><slot></slot></span>`;
  }
}
