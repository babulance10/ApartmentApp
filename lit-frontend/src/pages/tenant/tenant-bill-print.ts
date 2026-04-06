import { LitElement, html } from 'lit';
import { customElement, state } from 'lit/decorators.js';
import { monthName } from '../../lib/utils.js';
import api from '../../lib/api.js';

@customElement('tenant-bill-print')
export class TenantBillPrint extends LitElement {
  @state() private bill: any = null;
  @state() private flat: any = null;
  @state() private apartment: any = null;
  @state() private loading = true;

  createRenderRoot() { return this; }

  connectedCallback() {
    super.connectedCallback();
    this._load();
  }

  private async _load() {
    try {
      const params = new URLSearchParams(window.location.hash.split('?')[1]);
      const billId = params.get('billId');
      if (!billId) { this.loading = false; return; }

      const billRes = await api.get(`/bills/${billId}`);
      this.bill = billRes.data;
      this.flat = this.bill.flat;
      this.apartment = this.flat.apartment;
    } catch (e) { console.error(e); }
    this.loading = false;
  }

  private _print() {
    window.print();
  }

  render() {
    if (this.loading) return html`<p class="p-8 text-gray-500">Loading...</p>`;
    if (!this.bill) return html`<p class="p-8 text-gray-500">Bill not found</p>`;

    const balance = this.bill.totalAmount - this.bill.paidAmount;
    const monthLabel = `${monthName(this.bill.month)} ${this.bill.year}`;

    return html`
      <style>
        @media print {
          body { margin: 0; padding: 0; }
          .no-print { display: none; }
          .bill-container { max-width: 100%; margin: 0; padding: 0; }
          .bill-page { page-break-after: always; }
        }
        @page {
          size: A4;
          margin: 0.5in;
        }
      </style>

      <div class="no-print p-4 flex gap-2 mb-4">
        <button @click=${this._print} class="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 cursor-pointer border-none">
          🖨️ Print Bill
        </button>
        <button @click=${() => window.history.back()} class="px-4 py-2 bg-gray-300 text-gray-800 rounded-lg hover:bg-gray-400 cursor-pointer border-none">
          ← Back
        </button>
      </div>

      <div class="bill-container">
        <div class="bill-page bg-white p-8 max-w-3xl mx-auto" style="font-family: Arial, sans-serif;">
          <!-- Header -->
          <div class="text-center mb-8 pb-6 border-b-2 border-gray-300">
            <h1 class="text-3xl font-bold text-gray-900 m-0">${this.apartment?.name || 'Apartment'}</h1>
            <p class="text-gray-600 m-2 text-sm">Primark Sreenidhi Apartment Association</p>
            <p class="text-gray-500 m-1 text-xs">Maintenance Bill</p>
          </div>

          <!-- Bill Details -->
          <div class="grid grid-cols-2 gap-8 mb-8">
            <div>
              <p class="text-xs text-gray-500 uppercase tracking-wide mb-1">Bill Period</p>
              <p class="text-lg font-bold text-gray-900">${monthLabel}</p>
            </div>
            <div>
              <p class="text-xs text-gray-500 uppercase tracking-wide mb-1">Flat Number</p>
              <p class="text-lg font-bold text-gray-900">${this.flat?.flatNumber}</p>
            </div>
          </div>

          <!-- Tenant Info -->
          <div class="mb-8 p-4 bg-gray-50 rounded-lg">
            <p class="text-xs text-gray-500 uppercase tracking-wide mb-2">Tenant Details</p>
            <p class="text-sm font-semibold text-gray-900 m-0">${this.flat?.tenancies?.[0]?.user?.name || 'N/A'}</p>
            <p class="text-xs text-gray-600 m-0">${this.flat?.tenancies?.[0]?.user?.phone || 'N/A'}</p>
          </div>

          <!-- Bill Breakdown -->
          <div class="mb-8">
            <h2 class="text-sm font-bold text-gray-900 uppercase tracking-wide mb-4 pb-2 border-b border-gray-300">Bill Breakdown</h2>
            <table class="w-full text-sm">
              <tbody>
                <tr class="border-b border-gray-200">
                  <td class="py-3 text-gray-700">Maintenance Charge</td>
                  <td class="py-3 text-right font-semibold text-gray-900">₹${this.bill.maintenanceAmount.toLocaleString('en-IN')}</td>
                </tr>
                ${this.bill.waterAmount > 0 ? html`
                <tr class="border-b border-gray-200">
                  <td class="py-3 text-gray-700">Water Charges</td>
                  <td class="py-3 text-right font-semibold text-gray-900">₹${this.bill.waterAmount.toLocaleString('en-IN')}</td>
                </tr>
                ` : ''}
                ${this.bill.previousDue > 0 ? html`
                <tr class="border-b border-gray-200">
                  <td class="py-3 text-red-700 font-semibold">Previous Due</td>
                  <td class="py-3 text-right font-semibold text-red-700">₹${this.bill.previousDue.toLocaleString('en-IN')}</td>
                </tr>
                ` : ''}
                ${this.bill.previousDue < 0 ? html`
                <tr class="border-b border-gray-200">
                  <td class="py-3 text-green-700 font-semibold">Credit Adjusted</td>
                  <td class="py-3 text-right font-semibold text-green-700">-₹${Math.abs(this.bill.previousDue).toLocaleString('en-IN')}</td>
                </tr>
                ` : ''}
                <tr class="bg-gray-100 font-bold">
                  <td class="py-4 text-gray-900">TOTAL AMOUNT DUE</td>
                  <td class="py-4 text-right text-gray-900">₹${this.bill.totalAmount.toLocaleString('en-IN')}</td>
                </tr>
                ${this.bill.paidAmount > 0 ? html`
                <tr class="border-b border-gray-200">
                  <td class="py-3 text-green-700 font-semibold">Amount Paid</td>
                  <td class="py-3 text-right font-semibold text-green-700">₹${this.bill.paidAmount.toLocaleString('en-IN')}</td>
                </tr>
                ` : ''}
                <tr class="bg-red-50 font-bold">
                  <td class="py-4 text-red-900">BALANCE DUE</td>
                  <td class="py-4 text-right text-red-900">₹${balance.toLocaleString('en-IN')}</td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Payment Instructions -->
          ${balance > 0 ? html`
          <div class="mb-8 p-4 bg-blue-50 border-l-4 border-blue-500 rounded">
            <p class="text-xs font-bold text-blue-900 uppercase tracking-wide mb-2">Payment Instructions</p>
            <p class="text-sm text-blue-900 m-0 leading-relaxed">
              Please make the payment of <strong>₹${balance.toLocaleString('en-IN')}</strong> at your earliest convenience.
              You can pay via UPI, bank transfer, or cash. Contact the management for payment details.
            </p>
          </div>
          ` : html`
          <div class="mb-8 p-4 bg-green-50 border-l-4 border-green-500 rounded">
            <p class="text-sm text-green-900 font-semibold m-0">✓ This bill is fully paid. Thank you!</p>
          </div>
          `}

          <!-- Footer -->
          <div class="mt-12 pt-6 border-t border-gray-300 text-center text-xs text-gray-500">
            <p class="m-1">Generated on ${new Date().toLocaleDateString('en-IN')}</p>
            <p class="m-1">This is an official bill from ${this.apartment?.name || 'Apartment'}</p>
            <p class="m-1 font-semibold text-gray-700 mt-4">For queries, contact the management</p>
          </div>
        </div>
      </div>
    `;
  }
}
