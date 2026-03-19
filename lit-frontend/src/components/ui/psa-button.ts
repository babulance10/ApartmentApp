import { LitElement, html, css, nothing } from 'lit';
import { customElement, property } from 'lit/decorators.js';

@customElement('psa-button')
export class PsaButton extends LitElement {
  @property() variant = 'primary';
  @property() size = 'md';
  @property({ type: Boolean }) loading = false;
  @property({ type: Boolean }) disabled = false;

  // Shadow DOM so <slot> projects button label/icon content
  static styles = css`
    :host { display: inline-block; }
    button {
      display: inline-flex; align-items: center; justify-content: center; gap: 0.5rem;
      font-weight: 500; border-radius: 0.5rem; border: 1px solid transparent;
      cursor: pointer; font-family: inherit; line-height: 1.25; white-space: nowrap;
      transition: background-color 150ms, color 150ms, border-color 150ms, box-shadow 150ms;
    }
    button:disabled { opacity: 0.5; cursor: not-allowed; }
    /* Sizes */
    button.sm { padding: 0.375rem 0.75rem; font-size: 0.875rem; }
    button.md { padding: 0.5rem 1rem; font-size: 0.875rem; }
    button.lg { padding: 0.75rem 1.5rem; font-size: 1rem; }
    /* Primary */
    button.primary { background: #2563eb; color: #fff; }
    button.primary:hover:not(:disabled) { background: #1d4ed8; }
    /* Secondary */
    button.secondary { background: #f3f4f6; color: #1f2937; }
    button.secondary:hover:not(:disabled) { background: #e5e7eb; }
    /* Danger */
    button.danger { background: #dc2626; color: #fff; }
    button.danger:hover:not(:disabled) { background: #b91c1c; }
    /* Ghost */
    button.ghost { background: transparent; color: #374151; }
    button.ghost:hover:not(:disabled) { background: #f3f4f6; }
    /* Outline */
    button.outline { background: #fff; color: #374151; border-color: #d1d5db; }
    button.outline:hover:not(:disabled) { background: #f9fafb; }
    /* Spinner */
    @keyframes spin { to { transform: rotate(360deg); } }
    .spinner {
      width: 16px; height: 16px; border: 2px solid currentColor;
      border-top-color: transparent; border-radius: 50%;
      animation: spin 0.6s linear infinite;
    }
  `;

  render() {
    const isDisabled = this.disabled || this.loading;
    return html`
      <button
        ?disabled=${isDisabled}
        class="${this.variant} ${this.size}"
        @click=${(e: Event) => { if (isDisabled) e.stopPropagation(); }}
      >
        ${this.loading ? html`<span class="spinner"></span>` : nothing}
        <slot></slot>
      </button>
    `;
  }
}
