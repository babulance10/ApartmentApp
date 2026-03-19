import { LitElement, html, css, nothing } from 'lit';
import { customElement, property } from 'lit/decorators.js';

@customElement('psa-modal')
export class PsaModal extends LitElement {
  @property({ type: Boolean }) open = false;
  @property() modalTitle = '';
  @property() size = 'md';

  // Shadow DOM so <slot> projects modal body content correctly.
  // Slotted content inherits Tailwind from light DOM.
  static styles = css`
    :host { display: contents; }
    .overlay {
      position: fixed; inset: 0; z-index: 50;
      display: flex; align-items: center; justify-content: center;
      padding: 1rem;
    }
    .backdrop {
      position: absolute; inset: 0;
      background: rgba(0,0,0,0.5);
      backdrop-filter: blur(4px);
      -webkit-backdrop-filter: blur(4px);
    }
    .modal {
      position: relative; background: #fff;
      border-radius: 0.75rem;
      box-shadow: 0 25px 50px -12px rgba(0,0,0,0.25);
      width: 100%; max-height: 90vh;
      display: flex; flex-direction: column;
      animation: modalIn 200ms ease-out;
    }
    .modal.sm { max-width: 28rem; }
    .modal.md { max-width: 32rem; }
    .modal.lg { max-width: 42rem; }
    @keyframes modalIn {
      from { opacity: 0; transform: scale(0.96) translateY(8px); }
      to { opacity: 1; transform: scale(1) translateY(0); }
    }
    .header {
      display: flex; align-items: center; justify-content: space-between;
      padding: 1rem 1.5rem;
      border-bottom: 1px solid #f3f4f6;
    }
    .header h2 { font-size: 1.125rem; font-weight: 600; color: #111827; margin: 0; }
    .close-btn {
      padding: 0.375rem; border-radius: 0.5rem; background: transparent;
      border: none; cursor: pointer; color: #6b7280;
      display: flex; align-items: center; justify-content: center;
      transition: background 150ms;
    }
    .close-btn:hover { background: #f3f4f6; }
    .close-btn svg { width: 20px; height: 20px; }
    .body { overflow-y: auto; flex: 1; padding: 1rem 1.5rem; }
  `;

  private _close() {
    this.dispatchEvent(new CustomEvent('close', { bubbles: true, composed: true }));
  }

  render() {
    if (!this.open) return nothing;
    return html`
      <div class="overlay">
        <div class="backdrop" @click=${this._close}></div>
        <div class="modal ${this.size}">
          <div class="header">
            <h2>${this.modalTitle}</h2>
            <button class="close-btn" @click=${this._close}>
              <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M18 6 6 18"/><path d="m6 6 12 12"/></svg>
            </button>
          </div>
          <div class="body">
            <slot></slot>
          </div>
        </div>
      </div>
    `;
  }
}
