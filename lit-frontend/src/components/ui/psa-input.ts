import { LitElement, html, css, nothing } from 'lit';
import { customElement, property } from 'lit/decorators.js';

@customElement('psa-input')
export class PsaInput extends LitElement {
  @property() label = '';
  @property() error = '';
  @property() type = 'text';
  @property() value = '';
  @property() placeholder = '';
  @property({ type: Boolean }) disabled = false;
  @property() extraClass = '';

  createRenderRoot() { return this; }

  private _onInput(e: Event) {
    const input = e.target as HTMLInputElement;
    this.value = input.value;
    this.dispatchEvent(new CustomEvent('value-changed', { detail: input.value, bubbles: true, composed: true }));
  }

  render() {
    const borderCls = this.error ? 'border-red-400' : 'border-gray-300';
    return html`
      <div class="flex flex-col gap-1">
        ${this.label ? html`<label class="text-sm font-medium text-gray-700">${this.label}</label>` : nothing}
        <input
          type=${this.type}
          .value=${this.value}
          placeholder=${this.placeholder}
          ?disabled=${this.disabled}
          @input=${this._onInput}
          class="px-3 py-2 border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition ${borderCls} ${this.extraClass}"
        />
        ${this.error ? html`<span class="text-xs text-red-500">${this.error}</span>` : nothing}
      </div>
    `;
  }
}

@customElement('psa-select')
export class PsaSelect extends LitElement {
  @property() label = '';
  @property() error = '';
  @property() value = '';
  @property() extraClass = '';

  private _observer: MutationObserver | null = null;

  static styles = css`
    :host { display: block; min-width: 130px; }
    .wrap { display: flex; flex-direction: column; gap: 4px; }
    label { font-size: 0.875rem; font-weight: 500; color: #374151; }
    select {
      padding: 0.5rem 0.75rem;
      border: 1px solid #d1d5db;
      border-radius: 0.5rem;
      font-size: 0.875rem;
      line-height: 1.25rem;
      background: #fff;
      color: #111827;
      outline: none;
      font-family: inherit;
      cursor: pointer;
      appearance: auto;
      transition: border-color 150ms, box-shadow 150ms;
      width: 100%;
      min-width: 120px;
    }
    select:focus {
      border-color: #3b82f6;
      box-shadow: 0 0 0 3px rgba(59,130,246,0.15);
    }
    select.err { border-color: #f87171; }
    .err-msg { font-size: 0.75rem; color: #ef4444; }
  `;

  private _onChange(e: Event) {
    const select = e.target as HTMLSelectElement;
    this.value = select.value;
    this.dispatchEvent(new CustomEvent('value-changed', { detail: select.value, bubbles: true, composed: true }));
  }

  private _syncOptions() {
    const select = this.shadowRoot?.querySelector('select') as HTMLSelectElement | null;
    if (!select) return;
    const lightOptions = Array.from(this.querySelectorAll(':scope > option'));
    if (lightOptions.length === 0) return;
    select.innerHTML = '';
    lightOptions.forEach(o => select.appendChild(o.cloneNode(true)));
    if (this.value) select.value = this.value;
  }

  connectedCallback() {
    super.connectedCallback();
    this._observer = new MutationObserver(() => {
      requestAnimationFrame(() => this._syncOptions());
    });
    this._observer.observe(this, { childList: true, subtree: true });
  }

  disconnectedCallback() {
    super.disconnectedCallback();
    this._observer?.disconnect();
  }

  protected firstUpdated() {
    requestAnimationFrame(() => this._syncOptions());
  }

  protected updated() {
    this._syncOptions();
  }

  render() {
    return html`
      <div class="wrap">
        ${this.label ? html`<label>${this.label}</label>` : nothing}
        <select @change=${this._onChange} class="${this.error ? 'err' : ''}"></select>
        ${this.error ? html`<span class="err-msg">${this.error}</span>` : nothing}
      </div>
    `;
  }
}

@customElement('psa-textarea')
export class PsaTextarea extends LitElement {
  @property() label = '';
  @property() value = '';
  @property() placeholder = '';
  @property({ type: Number }) rows = 3;

  createRenderRoot() { return this; }

  private _onInput(e: Event) {
    const ta = e.target as HTMLTextAreaElement;
    this.value = ta.value;
    this.dispatchEvent(new CustomEvent('value-changed', { detail: ta.value, bubbles: true, composed: true }));
  }

  render() {
    return html`
      <div class="flex flex-col gap-1">
        ${this.label ? html`<label class="text-sm font-medium text-gray-700">${this.label}</label>` : nothing}
        <textarea
          .value=${this.value}
          placeholder=${this.placeholder}
          rows=${this.rows}
          @input=${this._onInput}
          class="px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 resize-none"
        ></textarea>
      </div>
    `;
  }
}
