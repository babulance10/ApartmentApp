import { LitElement, html } from 'lit';
import { customElement, state } from 'lit/decorators.js';
import { iconZap, iconMessageCircle, iconEdit2, iconMail, iconSend, iconChevronDown } from '../../lib/icons.js';
import { formatCurrency, monthName, currentMonthYear, MONTHS } from '../../lib/utils.js';
import api from '../../lib/api.js';

const APARTMENT_ID = 'psa-main';

@customElement('admin-bills')
export class AdminBills extends LitElement {
  @state() private month = currentMonthYear().month;
  @state() private year = currentMonthYear().year;
  @state() private bills: any[] = [];
  @state() private loading = true;
  @state() private generating = false;
  @state() private payModal: any = null;
  @state() private payAmount = '';
  @state() private payMethod = 'UPI';
  @state() private payRef = '';
  @state() private saving = false;
  @state() private editModal: any = null;
  @state() private editForm = { maintenanceAmount: '', waterAmount: '', previousDue: '' };
  @state() private bulkSending = false;
  @state() private bulkDropdown = false;

  createRenderRoot() { return this; }
  connectedCallback() { super.connectedCallback(); this._load(); }

  private async _load() {
    this.loading = true;
    try {
      const { data } = await api.get(`/bills/summary?apartmentId=${APARTMENT_ID}&month=${this.month}&year=${this.year}`);
      this.bills = data.bills || [];
    } catch { this.bills = []; }
    this.loading = false;
  }

  updated(changed: Map<string, any>) {
    if (changed.has('month') || changed.has('year')) {
      if (changed.has('month') && changed.get('month') !== undefined) this._load();
      if (changed.has('year') && changed.get('year') !== undefined) this._load();
    }
  }

  private _sendWhatsApp(bill: any) {
    const tenant = bill.flat?.tenancies?.[0]?.user;
    if (!tenant?.phone) { alert("No phone number for this flat's tenant."); return; }
    const phone = tenant.phone.replace(/\D/g, '');
    const dialPhone = phone.startsWith('91') ? phone : `91${phone}`;
    const balance = bill.totalAmount - bill.paidAmount;
    const msg = encodeURIComponent(
      `Dear ${tenant.name},\n\nYour maintenance bill for ${monthName(this.month)} ${this.year}:\n` +
      `• Flat: ${bill.flat?.flatNumber}\n• Maintenance: ₹${bill.maintenanceAmount}\n` +
      (bill.waterAmount > 0 ? `• Water: ₹${bill.waterAmount}\n` : '') +
      (bill.previousDue > 0 ? `• Previous Due: ₹${bill.previousDue}\n` : '') +
      `• Total: ₹${bill.totalAmount}\n` +
      (bill.paidAmount > 0 ? `• Paid: ₹${bill.paidAmount}\n` : '') +
      `• Balance Due: ₹${balance}\n\nPlease pay via UPI. Thank you!`
    );
    window.open(`https://wa.me/${dialPhone}?text=${msg}`, '_blank');
  }

  private _sendEmail(bill: any) {
    const tenant = bill.flat?.tenancies?.[0]?.user;
    if (!tenant?.email) { alert("No email for this flat's tenant."); return; }
    const balance = bill.totalAmount - bill.paidAmount;
    const subject = encodeURIComponent(`Maintenance Bill - ${monthName(this.month)} ${this.year} - Flat ${bill.flat?.flatNumber}`);
    const body = encodeURIComponent(
      `Dear ${tenant.name},\n\nYour maintenance bill for ${monthName(this.month)} ${this.year}:\n\n` +
      `Flat: ${bill.flat?.flatNumber}\nMaintenance: Rs.${bill.maintenanceAmount}\n` +
      (bill.waterAmount > 0 ? `Water: Rs.${bill.waterAmount}\n` : '') +
      (bill.previousDue > 0 ? `Previous Due: Rs.${bill.previousDue}\n` : '') +
      `Total: Rs.${bill.totalAmount}\n` +
      (bill.paidAmount > 0 ? `Paid: Rs.${bill.paidAmount}\n` : '') +
      `Balance Due: Rs.${balance}\n\nPlease make the payment at your earliest convenience.\n\nRegards,\nPSA Association`
    );
    window.open(`mailto:${tenant.email}?subject=${subject}&body=${body}`, '_blank');
  }

  private async _bulkSendWhatsApp() {
    this.bulkSending = true; this.bulkDropdown = false;
    for (const bill of this.bills.filter(b => b.status !== 'PAID')) {
      this._sendWhatsApp(bill); await new Promise(r => setTimeout(r, 600));
    }
    this.bulkSending = false;
  }

  private async _bulkSendEmail() {
    this.bulkDropdown = false;
    if (!confirm('Make sure SMTP is configured in backend .env.\n\nContinue?')) return;
    this.bulkSending = true;
    try {
      const { data } = await api.post('/bills/bulk-send-email', { apartmentId: APARTMENT_ID, month: this.month, year: this.year });
      alert(`Email sent to ${data.sent.length} flat(s): ${data.sent.join(', ') || 'none'}\n${data.failed.length ? `Failed: ${data.failed.join(', ')}` : ''}`);
    } catch (e: any) { alert(e.response?.data?.message || 'Error sending emails.'); }
    this.bulkSending = false;
  }

  private async _generateBills() {
    this.generating = true;
    try { await api.post('/bills/generate', { apartmentId: APARTMENT_ID, month: this.month, year: this.year, maintenanceAmount: 2000 }); await this._load(); }
    catch (e: any) { alert(e.response?.data?.message || 'Error generating bills'); }
    this.generating = false;
  }

  private async _handlePayment() {
    if (!this.payModal) return;
    this.saving = true;
    try {
      await api.post('/payments', { billId: this.payModal.bill.id, amount: parseFloat(this.payAmount), paymentMethod: this.payMethod, transactionRef: this.payRef, paymentDate: new Date().toISOString() });
      await this._load(); this.payModal = null; this.payAmount = ''; this.payRef = '';
    } catch (e: any) { alert(e.response?.data?.message || 'Error recording payment'); }
    this.saving = false;
  }

  private async _handleEditBill() {
    if (!this.editModal) return;
    this.saving = true;
    try {
      await api.patch(`/bills/${this.editModal.bill.id}`, { maintenanceAmount: +this.editForm.maintenanceAmount, waterAmount: +this.editForm.waterAmount, previousDue: +this.editForm.previousDue });
      await this._load(); this.editModal = null;
    } catch (e: any) { alert(e.response?.data?.message || 'Error updating bill'); }
    this.saving = false;
  }

  private _statusColor(s: string) { return s === 'PAID' ? 'bg-green-100 text-green-700' : s === 'PARTIAL' ? 'bg-yellow-100 text-yellow-700' : 'bg-red-100 text-red-700'; }
  private _years = [2024, 2025, 2026, 2027];

  private get _totalDue() { return this.bills.reduce((s, b) => s + b.totalAmount, 0); }
  private get _totalPaid() { return this.bills.reduce((s, b) => s + b.paidAmount, 0); }
  private get _totalPending() { return this._totalDue - this._totalPaid; }
  private get _paidCount() { return this.bills.filter(b => b.status === 'PAID').length; }
  private get _pendingCount() { return this.bills.filter(b => b.status !== 'PAID').length; }

  render() {
    return html`
      <div class="animate-fadeIn">

        <!-- ── Header ── -->
        <div class="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4 mb-8">
          <div>
            <h1 class="text-2xl font-bold text-gray-900 tracking-tight">Bills</h1>
            <p class="text-gray-500 text-sm mt-1">Manage monthly billing for all flats</p>
          </div>
          <div class="flex items-center gap-3">
            <!-- Bulk Send -->
            <div class="relative">
              <button @click=${() => this.bulkDropdown = !this.bulkDropdown} ?disabled=${this.bulkSending || this.bills.length === 0}
                class="inline-flex items-center gap-2 px-4 py-2.5 bg-white border border-gray-200 rounded-xl text-sm font-medium text-gray-700 hover:bg-gray-50 hover:border-gray-300 shadow-sm disabled:opacity-50 cursor-pointer transition-all">
                ${iconSend('w-4 h-4 text-blue-500')}
                <span>${this.bulkSending ? 'Sending...' : 'Bulk Send'}</span>
                <span class="ml-1 bg-blue-50 text-blue-600 text-xs font-bold px-2 py-0.5 rounded-full">${this._pendingCount}</span>
                ${iconChevronDown('w-3.5 h-3.5 text-gray-400')}
              </button>
              ${this.bulkDropdown ? html`
                <div class="absolute right-0 top-full mt-2 w-56 bg-white border border-gray-200 rounded-xl shadow-xl z-20 overflow-hidden">
                  <div class="px-4 py-2.5 bg-gradient-to-r from-gray-50 to-gray-100 border-b border-gray-100">
                    <p class="text-xs font-semibold text-gray-500 uppercase tracking-wider">Send to unpaid flats</p>
                  </div>
                  <button @click=${this._bulkSendWhatsApp} class="w-full flex items-center gap-3 px-4 py-3 text-sm text-gray-700 hover:bg-green-50 cursor-pointer bg-transparent border-none transition-colors">
                    <div class="w-9 h-9 bg-green-100 rounded-xl flex items-center justify-center">${iconMessageCircle('w-4 h-4 text-green-600')}</div>
                    <div class="text-left"><p class="font-medium text-gray-800">WhatsApp</p><p class="text-xs text-gray-400">Open chat for each flat</p></div>
                  </button>
                  <button @click=${this._bulkSendEmail} class="w-full flex items-center gap-3 px-4 py-3 text-sm text-gray-700 hover:bg-blue-50 cursor-pointer bg-transparent border-none border-t border-gray-100 transition-colors">
                    <div class="w-9 h-9 bg-blue-100 rounded-xl flex items-center justify-center">${iconMail('w-4 h-4 text-blue-600')}</div>
                    <div class="text-left"><p class="font-medium text-gray-800">Email</p><p class="text-xs text-gray-400">Send all via SMTP</p></div>
                  </button>
                </div>
                <div class="fixed inset-0 z-10" @click=${() => this.bulkDropdown = false}></div>
              ` : ''}
            </div>
            <!-- Generate -->
            <button @click=${this._generateBills} ?disabled=${this.generating}
              class="inline-flex items-center gap-2 px-5 py-2.5 bg-gradient-to-r from-blue-600 to-indigo-600 hover:from-blue-700 hover:to-indigo-700 text-white text-sm font-semibold rounded-xl shadow-md shadow-blue-500/20 disabled:opacity-50 cursor-pointer border-none transition-all">
              ${iconZap('w-4 h-4')} ${this.generating ? 'Generating...' : 'Generate Bills'}
            </button>
          </div>
        </div>

        <!-- ── Filter Bar + Summary ── -->
        <div class="bg-white rounded-2xl border border-gray-200/80 shadow-sm p-5 mb-6">
          <div class="flex flex-col lg:flex-row items-start lg:items-center justify-between gap-5">
            <!-- Filters -->
            <div class="flex items-center gap-3">
              <div class="flex items-center gap-2 bg-gray-50 rounded-xl px-3 py-1.5">
                <span class="text-xs font-semibold text-gray-400 uppercase tracking-wider">Period</span>
              </div>
              <psa-select .value=${String(this.month)} @value-changed=${(e: CustomEvent) => this.month = +e.detail}>
                ${MONTHS.map((m, i) => html`<option value=${i + 1}>${m}</option>`)}
              </psa-select>
              <psa-select .value=${String(this.year)} @value-changed=${(e: CustomEvent) => this.year = +e.detail}>
                ${this._years.map(y => html`<option value=${y}>${y}</option>`)}
              </psa-select>
              <span class="text-sm text-gray-400 ml-1">${this.bills.length} flats</span>
            </div>
            <!-- Summary pills -->
            <div class="flex items-center gap-3 flex-wrap">
              <div class="flex items-center gap-2 bg-blue-50 rounded-xl px-4 py-2">
                <div class="w-2 h-2 rounded-full bg-blue-500"></div>
                <span class="text-xs font-medium text-blue-600">Total Due</span>
                <span class="text-sm font-bold text-blue-700">${formatCurrency(this._totalDue)}</span>
              </div>
              <div class="flex items-center gap-2 bg-green-50 rounded-xl px-4 py-2">
                <div class="w-2 h-2 rounded-full bg-green-500"></div>
                <span class="text-xs font-medium text-green-600">Collected</span>
                <span class="text-sm font-bold text-green-700">${formatCurrency(this._totalPaid)}</span>
              </div>
              <div class="flex items-center gap-2 bg-red-50 rounded-xl px-4 py-2">
                <div class="w-2 h-2 rounded-full bg-red-500"></div>
                <span class="text-xs font-medium text-red-600">Pending</span>
                <span class="text-sm font-bold text-red-700">${formatCurrency(this._totalPending)}</span>
              </div>
              <div class="flex items-center gap-2 bg-gray-50 rounded-xl px-4 py-2">
                <span class="text-xs font-medium text-gray-500">Paid</span>
                <span class="text-sm font-bold text-gray-700">${this._paidCount}/${this.bills.length}</span>
              </div>
            </div>
          </div>
        </div>

        <!-- ── Table ── -->
        <div class="bg-white rounded-2xl border border-gray-200/80 shadow-sm overflow-hidden">
          <div class="overflow-x-auto">
            <table class="w-full text-xs">
              <thead>
                <tr class="bg-gradient-to-r from-gray-50 to-slate-50 border-b border-gray-200/60">
                  <th class="text-left pl-4 pr-2 py-3 font-semibold text-gray-500 uppercase tracking-wider">Flat</th>
                  <th class="text-right px-2 py-3 font-semibold text-gray-500 uppercase tracking-wider">Maint.</th>
                  <th class="text-right px-2 py-3 font-semibold text-gray-500 uppercase tracking-wider">Water</th>
                  <th class="text-right px-2 py-3 font-semibold text-gray-500 uppercase tracking-wider">Prev Due</th>
                  <th class="text-right px-2 py-3 font-semibold text-gray-500 uppercase tracking-wider">Total</th>
                  <th class="text-right px-2 py-3 font-semibold text-gray-500 uppercase tracking-wider">Paid</th>
                  <th class="text-right px-2 py-3 font-semibold text-gray-500 uppercase tracking-wider">Balance</th>
                  <th class="text-center px-2 py-3 font-semibold text-gray-500 uppercase tracking-wider">Status</th>
                  <th class="text-center pl-2 pr-4 py-3 font-semibold text-gray-500 uppercase tracking-wider">Actions</th>
                </tr>
              </thead>
              <tbody>
                ${this.loading ? html`
                  <tr><td colspan="10" class="px-5 py-16 text-center">
                    <div class="flex flex-col items-center gap-3">
                      <div class="w-8 h-8 border-3 border-blue-200 border-t-blue-600 rounded-full animate-spin"></div>
                      <span class="text-sm text-gray-400">Loading bills...</span>
                    </div>
                  </td></tr>` :
                  this.bills.length === 0 ? html`
                  <tr><td colspan="10" class="px-5 py-16 text-center">
                    <div class="flex flex-col items-center gap-3">
                      <div class="w-16 h-16 bg-gray-100 rounded-2xl flex items-center justify-center">${iconZap('w-8 h-8 text-gray-300')}</div>
                      <p class="text-gray-500 font-medium">No bills for ${monthName(this.month)} ${this.year}</p>
                      <p class="text-sm text-gray-400">Click "Generate Bills" to create them</p>
                    </div>
                  </td></tr>` :
                  this.bills.map((bill, idx) => html`
                    <tr class="border-b border-gray-100/80 hover:bg-blue-50/30 transition-colors ${idx % 2 === 0 ? 'bg-white' : 'bg-gray-50/40'}">
                      <td class="pl-4 pr-2 py-3">
                        <div class="flex items-center gap-2.5">
                          <div class="w-8 h-8 rounded-lg bg-gradient-to-br from-blue-500 to-indigo-600 flex items-center justify-center text-white text-[10px] font-bold shrink-0">
                            ${bill.flat?.flatNumber}
                          </div>
                          <div class="min-w-0">
                            <p class="font-semibold text-gray-900 text-xs">Flat ${bill.flat?.flatNumber}</p>
                            <p class="text-[10px] text-gray-400 truncate">${bill.flat?.tenancies?.[0]?.user?.name || '—'}</p>
                          </div>
                        </div>
                      </td>
                      <td class="text-right px-2 py-3 text-gray-600 font-medium tabular-nums">${formatCurrency(bill.maintenanceAmount)}</td>
                      <td class="text-right px-2 py-3 text-gray-600 font-medium tabular-nums">${formatCurrency(bill.waterAmount)}</td>
                      <td class="text-right px-2 py-3 tabular-nums">
                        ${bill.previousDue < 0
                          ? html`<span class="text-green-600 font-semibold">CR ${formatCurrency(Math.abs(bill.previousDue))}</span>`
                          : html`<span class="text-gray-600 font-medium">${formatCurrency(bill.previousDue)}</span>`}
                      </td>
                      <td class="text-right px-2 py-3 font-bold text-gray-900 tabular-nums text-sm">${formatCurrency(bill.totalAmount)}</td>
                      <td class="text-right px-2 py-3 tabular-nums">
                        ${bill.paidAmount > 0
                          ? html`<span class="text-green-600 font-semibold">${formatCurrency(bill.paidAmount)}</span>`
                          : html`<span class="text-gray-300">—</span>`}
                      </td>
                      <td class="text-right px-2 py-3 tabular-nums">
                        ${(bill.totalAmount - bill.paidAmount) < 0
                          ? html`<span class="text-green-600 font-semibold">CR ${formatCurrency(Math.abs(bill.totalAmount - bill.paidAmount))}</span>`
                          : (bill.totalAmount - bill.paidAmount) === 0
                            ? html`<span class="text-green-600 font-semibold">₹0</span>`
                            : html`<span class="text-red-600 font-semibold">${formatCurrency(bill.totalAmount - bill.paidAmount)}</span>`}
                      </td>
                      <td class="text-center px-2 py-3">
                        <span class="inline-flex items-center gap-1 text-[10px] font-semibold px-2 py-0.5 rounded-full ${
                          bill.status === 'PAID' ? 'bg-green-100 text-green-700' :
                          bill.status === 'PARTIAL' ? 'bg-amber-100 text-amber-700' :
                          'bg-red-50 text-red-600'
                        }">
                          <span class="w-1.5 h-1.5 rounded-full ${
                            bill.status === 'PAID' ? 'bg-green-500' : bill.status === 'PARTIAL' ? 'bg-amber-500' : 'bg-red-500'
                          }"></span>
                          ${bill.status}
                        </span>
                      </td>
                      <td class="pl-2 pr-4 py-3">
                        <div class="flex items-center justify-center gap-0.5">
                          ${bill.status !== 'PAID' ? html`
                            <button @click=${() => { this.payModal = { open: true, bill }; this.payAmount = String(bill.totalAmount - bill.paidAmount); }}
                              class="inline-flex items-center px-2.5 py-1 text-[10px] font-bold text-white bg-blue-600 hover:bg-blue-700 rounded-md cursor-pointer border-none shadow-sm transition-all whitespace-nowrap">
                              Pay
                            </button>` : ''}
                          <button @click=${() => { this.editForm = { maintenanceAmount: String(bill.maintenanceAmount), waterAmount: String(bill.waterAmount), previousDue: String(bill.previousDue) }; this.editModal = { open: true, bill }; }}
                            title="Edit" class="p-1 text-gray-400 hover:text-blue-600 hover:bg-blue-50 rounded cursor-pointer bg-transparent border-none transition-all">${iconEdit2('w-3 h-3')}</button>
                          <button @click=${() => this._sendWhatsApp(bill)}
                            title="WhatsApp" class="p-1 text-gray-400 hover:text-green-600 hover:bg-green-50 rounded cursor-pointer bg-transparent border-none transition-all">${iconMessageCircle('w-3 h-3')}</button>
                          <button @click=${() => this._sendEmail(bill)}
                            title="Email" class="p-1 text-gray-400 hover:text-blue-600 hover:bg-blue-50 rounded cursor-pointer bg-transparent border-none transition-all">${iconMail('w-3 h-3')}</button>
                        </div>
                      </td>
                    </tr>
                  `)}
              </tbody>
            </table>
          </div>
        </div>

        <!-- ── Edit Bill Modal ── -->
        <psa-modal ?open=${!!this.editModal?.open} modalTitle="Edit Bill — Flat ${this.editModal?.bill?.flat?.flatNumber || ''}" size="sm" @close=${() => this.editModal = null}>
          <div class="space-y-4">
            <p class="text-xs text-gray-500">Adjust amounts. Total will be recalculated automatically.</p>
            <psa-input label="Maintenance (₹)" type="number" .value=${this.editForm.maintenanceAmount} @value-changed=${(e: CustomEvent) => this.editForm = { ...this.editForm, maintenanceAmount: e.detail }}></psa-input>
            <psa-input label="Water Amount (₹)" type="number" .value=${this.editForm.waterAmount} @value-changed=${(e: CustomEvent) => this.editForm = { ...this.editForm, waterAmount: e.detail }}></psa-input>
            <psa-input label="Previous Due (₹)" type="number" .value=${this.editForm.previousDue} @value-changed=${(e: CustomEvent) => this.editForm = { ...this.editForm, previousDue: e.detail }}></psa-input>
            <div class="bg-gradient-to-r from-blue-50 to-indigo-50 rounded-xl px-4 py-3 text-sm flex justify-between items-center">
              <span class="text-gray-500 font-medium">New Total</span>
              <span class="text-lg font-bold text-blue-700">${formatCurrency((+this.editForm.maintenanceAmount || 0) + (+this.editForm.waterAmount || 0) + (+this.editForm.previousDue || 0))}</span>
            </div>
            <div class="flex gap-2 justify-end pt-2">
              <psa-button variant="secondary" @click=${() => this.editModal = null}>Cancel</psa-button>
              <psa-button .loading=${this.saving} @click=${this._handleEditBill}>Save Changes</psa-button>
            </div>
          </div>
        </psa-modal>

        <!-- ── Pay Modal ── -->
        <psa-modal ?open=${!!this.payModal?.open} modalTitle="Record Payment — Flat ${this.payModal?.bill?.flat?.flatNumber || ''}" size="sm" @close=${() => this.payModal = null}>
          <div class="space-y-4">
            <div class="bg-gradient-to-r from-gray-50 to-slate-50 rounded-xl p-4 text-sm space-y-2 border border-gray-100">
              <div class="flex justify-between"><span class="text-gray-500">Total Amount</span><span class="font-semibold text-gray-800">${formatCurrency(this.payModal?.bill?.totalAmount ?? 0)}</span></div>
              <div class="flex justify-between"><span class="text-gray-500">Already Paid</span><span class="font-semibold text-green-600">${formatCurrency(this.payModal?.bill?.paidAmount ?? 0)}</span></div>
              <div class="h-px bg-gray-200 my-1"></div>
              <div class="flex justify-between"><span class="text-gray-600 font-medium">Balance Due</span><span class="font-bold text-lg text-red-600">${formatCurrency((this.payModal?.bill?.totalAmount ?? 0) - (this.payModal?.bill?.paidAmount ?? 0))}</span></div>
            </div>
            <psa-input label="Payment Amount (₹)" type="number" .value=${this.payAmount} @value-changed=${(e: CustomEvent) => this.payAmount = e.detail}></psa-input>
            <psa-select label="Payment Method" .value=${this.payMethod} @value-changed=${(e: CustomEvent) => this.payMethod = e.detail}>
              <option value="UPI">UPI</option><option value="CASH">Cash</option><option value="BANK_TRANSFER">Bank Transfer</option><option value="CHEQUE">Cheque</option>
            </psa-select>
            <psa-input label="Transaction Ref (optional)" .value=${this.payRef} @value-changed=${(e: CustomEvent) => this.payRef = e.detail} placeholder="UPI txn ID / ref number"></psa-input>
            <div class="flex gap-2 justify-end pt-2">
              <psa-button variant="secondary" @click=${() => this.payModal = null}>Cancel</psa-button>
              <psa-button .loading=${this.saving} .disabled=${!this.payAmount} @click=${this._handlePayment}>Save Payment</psa-button>
            </div>
          </div>
        </psa-modal>
      </div>
    `;
  }
}
