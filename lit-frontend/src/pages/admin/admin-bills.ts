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
  @state() private payDate = new Date().toISOString().slice(0, 10);
  @state() private saving = false;
  @state() private editModal: any = null;
  @state() private editForm = { maintenanceAmount: '', waterAmount: '', previousDue: '' };
  @state() private bulkSending = false;
  @state() private bulkDropdown = false;
  @state() private waBulkModal = false;
  @state() private waSentFlats: Set<string> = new Set();
  @state() private printBill: any = null;
  @state() private regenerating = false;
  @state() private printingAll = false;

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

  private _getBestTenant(bill: any) {
    const tenancies: any[] = bill.flat?.tenancies || [];
    // Prefer tenancy with a phone number AND a real name (not seed "Resident XXX")
    return (
      tenancies.find(t => t.user?.phone && !/^Resident \d+$/i.test(t.user?.name || '')) ||
      tenancies.find(t => t.user?.phone) ||
      tenancies[0]
    )?.user;
  }

  private _sendWhatsApp(bill: any) {
    const tenant = this._getBestTenant(bill);
    if (!tenant?.phone) { alert("No phone number for this flat's tenant."); return; }
    const phone = tenant.phone.replace(/\D/g, '');
    const dialPhone = phone.startsWith('91') ? phone : `91${phone}`;
    const balance = bill.totalAmount - bill.paidAmount;
    const prevDue = bill.previousDue ?? 0;
    const lines = [
      `*Primark Sreenidhi Apartments*`,
      ``,
      `Dear ${tenant.name},`,
      ``,
      `Your maintenance bill for *${monthName(this.month)} ${this.year}* is ready.`,
      ``,
      `*Flat ${bill.flat?.flatNumber}*`,
      `Maintenance: Rs.${bill.maintenanceAmount}`,
      ...(bill.waterAmount > 0 ? [`Water: Rs.${bill.waterAmount}`] : []),
      ...(prevDue > 0 ? [`Previous Due: Rs.${prevDue}`] : []),
      ...(prevDue < 0 ? [`Credit Carried Forward: -Rs.${Math.abs(prevDue)}`] : []),
      ``,
      `*Total: Rs.${bill.totalAmount}*`,
      ...(bill.paidAmount > 0 ? [`Paid: Rs.${bill.paidAmount}`] : []),
      balance > 0 ? `*Balance Due: Rs.${balance}*` : `*Credit Balance: Rs.${Math.abs(balance)}* (adjusted next month)`,
      ``,
      `Please pay via UPI. Thank you!`,
      ``,
      `Track your bills online: gruha.sarvavidha.in`,
    ];
    const msg = encodeURIComponent(lines.join('\n'));
    window.open(`https://wa.me/${dialPhone}?text=${msg}`, '_blank');
  }

  private _sendLaunchAnnouncement(phone: string) {
    const cleanPhone = phone.replace(/\D/g, '');
    const dialPhone = cleanPhone.startsWith('91') ? cleanPhone : `91${cleanPhone}`;
    const lines = [
      `*Primark Sreenidhi Apartments*`,
      ``,
      `We are excited to announce - our Apartment Portal is now LIVE!`,
      ``,
      `You can now view your maintenance bills, payment history, and dues online - anytime, anywhere.`,
      ``,
      `Visit us at: https://gruha.sarvavidha.in`,
      ``,
      `What you can do:`,
      `- View monthly bills`,
      `- Check payment history`,
      `- Track water usage`,
      ``,
      `This is a *beta launch* - we appreciate your patience as we continue to improve.`,
      ``,
      `For any queries, contact the PSA office.`,
      ``,
      `Thank you!`,
    ];
    const msg = encodeURIComponent(lines.join('\n'));
    window.open(`https://wa.me/${dialPhone}?text=${msg}`, '_blank');
  }

  private async _sendAnnouncementToAll() {
    this.bulkDropdown = false;
    if (!confirm('Send website launch announcement to ALL tenants with a phone number?')) return;
    const tenants = this.bills
      .map(b => this._getBestTenant(b))
      .filter(u => u?.phone);
    const unique = [...new Map(tenants.map(u => [u.phone, u])).values()];
    for (const user of unique) {
      this._sendLaunchAnnouncement(user.phone);
      await new Promise(r => setTimeout(r, 800));
    }
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

  private async _printBill(bill: any) {
    this.printBill = bill;
    await this.updateComplete;
    setTimeout(() => {
      window.print();
      this.printBill = null;
    }, 200);
  }

  private async _printAllBills() {
    this.printingAll = true;
    await this.updateComplete;
    setTimeout(() => {
      window.print();
      this.printingAll = false;
    }, 200);
  }

  private _openWaBulkModal() {
    this.bulkDropdown = false;
    this.waSentFlats = new Set();
    this.waBulkModal = true;
  }

  private _sendWaBulk(bill: any) {
    this._sendWhatsApp(bill);
    this.waSentFlats = new Set([...this.waSentFlats, bill.flat?.flatNumber]);
  }

  private async _sendAllWhatsApp() {
    const unpaid = this.bills.filter(b => b.status !== 'PAID' && b.flat?.tenancies?.[0]?.user?.phone);
    for (const bill of unpaid) {
      this._sendWaBulk(bill);
      await new Promise(r => setTimeout(r, 800));
    }
  }

  private async _recalculateAll() {
    if (!confirm('This will recalculate and fix statuses of ALL bills based on actual payments recorded. Continue?')) return;
    try {
      const { data } = await api.post('/bills/recalculate-all', {});
      alert(`Done! Fixed ${data.fixed} of ${data.total} bills.`);
      await this._load();
    } catch (e: any) { alert('Error: ' + (e.response?.data?.message || e.message)); }
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

  private async _regenerateBills() {
    if (!confirm('Delete existing bills for this month and regenerate with updated water amounts? This will include any new water meter readings.')) return;
    this.regenerating = true;
    try {
      await api.post('/bills/regenerate', { apartmentId: APARTMENT_ID, month: this.month, year: this.year, maintenanceAmount: 2000 });
      alert('Bills regenerated successfully with updated water amounts!');
      await this._load();
    } catch (e: any) {
      alert(e.response?.data?.message || 'Error regenerating bills');
    }
    this.regenerating = false;
  }

  private async _handlePayment() {
    if (!this.payModal) return;
    this.saving = true;
    try {
      await api.post('/payments', { billId: this.payModal.bill.id, amount: parseFloat(this.payAmount), paymentMethod: this.payMethod, transactionRef: this.payRef, paymentDate: new Date(this.payDate).toISOString() });
      await this._load(); this.payModal = null; this.payAmount = ''; this.payRef = ''; this.payDate = new Date().toISOString().slice(0, 10);
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
                  <button @click=${() => this._openWaBulkModal()} class="w-full flex items-center gap-3 px-4 py-3 text-sm text-gray-700 hover:bg-green-50 cursor-pointer bg-transparent border-none transition-colors">
                    <div class="w-9 h-9 bg-green-100 rounded-xl flex items-center justify-center">${iconMessageCircle('w-4 h-4 text-green-600')}</div>
                    <div class="text-left"><p class="font-medium text-gray-800">WhatsApp Bulk</p><p class="text-xs text-gray-400">Send to all unpaid flats</p></div>
                  </button>
                  <button @click=${this._bulkSendEmail} class="w-full flex items-center gap-3 px-4 py-3 text-sm text-gray-700 hover:bg-blue-50 cursor-pointer bg-transparent border-none border-t border-gray-100 transition-colors">
                    <div class="w-9 h-9 bg-blue-100 rounded-xl flex items-center justify-center">${iconMail('w-4 h-4 text-blue-600')}</div>
                    <div class="text-left"><p class="font-medium text-gray-800">Email</p><p class="text-xs text-gray-400">Send all via SMTP</p></div>
                  </button>
                  <button @click=${this._sendAnnouncementToAll} class="w-full flex items-center gap-3 px-4 py-3 text-sm text-gray-700 hover:bg-purple-50 cursor-pointer bg-transparent border-none border-t border-gray-100 transition-colors">
                    <div class="w-9 h-9 bg-purple-100 rounded-xl flex items-center justify-center">🚀</div>
                    <div class="text-left"><p class="font-medium text-gray-800">Launch Announcement</p><p class="text-xs text-gray-400">Announce gruha.sarvavidha.in</p></div>
                  </button>
                </div>
                <div class="fixed inset-0 z-10" @click=${() => this.bulkDropdown = false}></div>
              ` : ''}
            </div>
            <!-- Recalculate -->
            <button @click=${this._recalculateAll} title="Fix bill statuses based on actual payments"
              class="inline-flex items-center gap-2 px-4 py-2.5 bg-white border border-gray-200 rounded-xl text-sm font-medium text-gray-700 hover:bg-amber-50 hover:border-amber-300 shadow-sm cursor-pointer border-none transition-all">
              ${iconZap('w-4 h-4 text-amber-500')} Fix Statuses
            </button>
            <!-- Print All -->
            <button @click=${this._printAllBills} ?disabled=${this.bills.length === 0}
              class="inline-flex items-center gap-2 px-5 py-2.5 bg-gradient-to-r from-purple-600 to-pink-600 hover:from-purple-700 hover:to-pink-700 text-white text-sm font-semibold rounded-xl shadow-md shadow-purple-500/20 disabled:opacity-50 cursor-pointer border-none transition-all">
              🖨️ Print All Bills
            </button>
            <!-- Regenerate -->
            <button @click=${this._regenerateBills} ?disabled=${this.regenerating}
              class="inline-flex items-center gap-2 px-5 py-2.5 bg-gradient-to-r from-orange-600 to-red-600 hover:from-orange-700 hover:to-red-700 text-white text-sm font-semibold rounded-xl shadow-md shadow-orange-500/20 disabled:opacity-50 cursor-pointer border-none transition-all">
              ${iconZap('w-4 h-4')} ${this.regenerating ? 'Regenerating...' : 'Regenerate Bills'}
            </button>
            <!-- Generate -->
            <button @click=${this._generateBills} ?disabled=${this.generating}
              class="inline-flex items-center gap-2 px-5 py-2.5 bg-gradient-to-r from-blue-600 to-indigo-600 hover:from-blue-700 hover:to-indigo-700 text-white text-sm font-semibold rounded-xl shadow-md shadow-blue-500/20 disabled:opacity-50 cursor-pointer border-none transition-all">
              ${iconZap('w-4 h-4')} ${this.generating ? 'Generating...' : 'Generate Bills'}
            </button>
          </div>
        </div>

        <!-- ── Filter Bar + Summary ── -->
        <div class="bg-white rounded-2xl border border-gray-200/80 shadow-sm p-4 mb-6">
          <!-- Filters row -->
          <div class="flex flex-wrap items-center gap-2 mb-4">
            <span class="text-xs font-semibold text-gray-400 uppercase tracking-wider bg-gray-50 rounded-xl px-3 py-1.5">Period</span>
            <psa-select .value=${String(this.month)} @value-changed=${(e: CustomEvent) => this.month = +e.detail}>
              ${MONTHS.map((m, i) => html`<option value=${i + 1}>${m}</option>`)}
            </psa-select>
            <psa-select .value=${String(this.year)} @value-changed=${(e: CustomEvent) => this.year = +e.detail}>
              ${this._years.map(y => html`<option value=${y}>${y}</option>`)}
            </psa-select>
            <span class="text-sm text-gray-400">${this.bills.length} flats</span>
          </div>
          <!-- Summary pills -->
          <div class="grid grid-cols-2 sm:flex sm:flex-wrap gap-2">
            <div class="flex items-center gap-2 bg-blue-50 rounded-xl px-3 py-2">
              <div class="w-2 h-2 rounded-full bg-blue-500 shrink-0"></div>
              <div>
                <p class="text-[10px] font-medium text-blue-500 uppercase">Total Due</p>
                <p class="text-sm font-bold text-blue-700">${formatCurrency(this._totalDue)}</p>
              </div>
            </div>
            <div class="flex items-center gap-2 bg-green-50 rounded-xl px-3 py-2">
              <div class="w-2 h-2 rounded-full bg-green-500 shrink-0"></div>
              <div>
                <p class="text-[10px] font-medium text-green-500 uppercase">Collected</p>
                <p class="text-sm font-bold text-green-700">${formatCurrency(this._totalPaid)}</p>
              </div>
            </div>
            <div class="flex items-center gap-2 bg-red-50 rounded-xl px-3 py-2">
              <div class="w-2 h-2 rounded-full bg-red-500 shrink-0"></div>
              <div>
                <p class="text-[10px] font-medium text-red-500 uppercase">Pending</p>
                <p class="text-sm font-bold text-red-700">${formatCurrency(this._totalPending)}</p>
              </div>
            </div>
            <div class="flex items-center gap-2 bg-gray-50 rounded-xl px-3 py-2">
              <div class="w-2 h-2 rounded-full bg-gray-400 shrink-0"></div>
              <div>
                <p class="text-[10px] font-medium text-gray-400 uppercase">Paid Flats</p>
                <p class="text-sm font-bold text-gray-700">${this._paidCount}/${this.bills.length}</p>
              </div>
            </div>
          </div>
        </div>

        <!-- ── Desktop Table (hidden on mobile) ── -->
        <div class="mobile-hidden bg-white rounded-2xl border border-gray-200/80 shadow-sm overflow-hidden">
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
                          <button @click=${() => this._printBill(bill)}
                            title="Print" class="p-1 text-gray-400 hover:text-purple-600 hover:bg-purple-50 rounded cursor-pointer bg-transparent border-none transition-all">🖨️</button>
                        </div>
                      </td>
                    </tr>
                  `)}
              </tbody>
            </table>
          </div>
        </div>

        <!-- ── Mobile Cards (shown only on mobile) ── -->
        <div class="mobile-only" style="display:none;flex-direction:column;gap:12px">
          ${this.loading ? html`
            <div class="bg-white rounded-2xl border border-gray-200 p-8 text-center">
              <div class="flex flex-col items-center gap-3">
                <div class="w-8 h-8 border-2 border-blue-200 border-t-blue-600 rounded-full animate-spin"></div>
                <span class="text-sm text-gray-400">Loading bills...</span>
              </div>
            </div>` :
            this.bills.length === 0 ? html`
            <div class="bg-white rounded-2xl border border-gray-200 p-8 text-center">
              <div class="flex flex-col items-center gap-3">
                <div class="w-14 h-14 bg-gray-100 rounded-2xl flex items-center justify-center">${iconZap('w-7 h-7 text-gray-300')}</div>
                <p class="text-gray-500 font-medium text-sm">No bills for ${monthName(this.month)} ${this.year}</p>
                <p class="text-xs text-gray-400">Tap "Generate Bills" to create them</p>
              </div>
            </div>` :
            this.bills.map((bill) => {
              const balance = bill.totalAmount - bill.paidAmount;
              const statusCls = bill.status === 'PAID' ? 'bg-green-100 text-green-700' : bill.status === 'PARTIAL' ? 'bg-amber-100 text-amber-700' : 'bg-red-50 text-red-600';
              const dotCls = bill.status === 'PAID' ? 'bg-green-500' : bill.status === 'PARTIAL' ? 'bg-amber-500' : 'bg-red-500';
              return html`
              <div class="bg-white rounded-2xl border border-gray-200 shadow-sm overflow-hidden">
                <!-- Card Header -->
                <div class="flex items-center justify-between px-4 py-3 border-b border-gray-100">
                  <div class="flex items-center gap-3">
                    <div class="w-9 h-9 rounded-xl bg-gradient-to-br from-blue-500 to-indigo-600 flex items-center justify-center text-white text-xs font-bold shrink-0">
                      ${bill.flat?.flatNumber}
                    </div>
                    <div>
                      <p class="font-bold text-gray-900 text-sm">Flat ${bill.flat?.flatNumber}</p>
                      <p class="text-xs text-gray-400">${bill.flat?.tenancies?.[0]?.user?.name || 'No tenant'}</p>
                    </div>
                  </div>
                  <span class="inline-flex items-center gap-1 text-xs font-semibold px-2.5 py-1 rounded-full ${statusCls}">
                    <span class="w-1.5 h-1.5 rounded-full ${dotCls}"></span>
                    ${bill.status}
                  </span>
                </div>
                <!-- Amounts grid -->
                <div class="grid grid-cols-3 divide-x divide-gray-100 border-b border-gray-100">
                  <div class="px-3 py-2.5 text-center">
                    <p class="text-[10px] text-gray-400 uppercase tracking-wide">Total</p>
                    <p class="text-sm font-bold text-gray-900">${formatCurrency(bill.totalAmount)}</p>
                  </div>
                  <div class="px-3 py-2.5 text-center">
                    <p class="text-[10px] text-gray-400 uppercase tracking-wide">Paid</p>
                    <p class="text-sm font-semibold ${bill.paidAmount > 0 ? 'text-green-600' : 'text-gray-300'}">${bill.paidAmount > 0 ? formatCurrency(bill.paidAmount) : '—'}</p>
                  </div>
                  <div class="px-3 py-2.5 text-center">
                    <p class="text-[10px] text-gray-400 uppercase tracking-wide">Balance</p>
                    <p class="text-sm font-bold ${balance > 0 ? 'text-red-600' : 'text-green-600'}">${balance > 0 ? formatCurrency(balance) : '₹0'}</p>
                  </div>
                </div>
                <!-- Bill breakdown -->
                <div class="px-4 py-2.5 flex gap-4 text-xs text-gray-500 border-b border-gray-100">
                  <span>Maint: <span class="font-medium text-gray-700">${formatCurrency(bill.maintenanceAmount)}</span></span>
                  ${bill.waterAmount > 0 ? html`<span>Water: <span class="font-medium text-gray-700">${formatCurrency(bill.waterAmount)}</span></span>` : ''}
                  ${bill.previousDue !== 0 ? html`<span>Prev: <span class="font-medium ${bill.previousDue < 0 ? 'text-green-600' : 'text-orange-600'}">${bill.previousDue < 0 ? `CR ${formatCurrency(Math.abs(bill.previousDue))}` : formatCurrency(bill.previousDue)}</span></span>` : ''}
                </div>
                <!-- Actions -->
                <div class="flex items-center gap-2 px-4 py-2.5">
                  ${bill.status !== 'PAID' ? html`
                    <button @click=${() => { this.payModal = { open: true, bill }; this.payAmount = String(balance); }}
                      class="flex-1 py-2 text-xs font-bold text-white bg-blue-600 hover:bg-blue-700 rounded-xl cursor-pointer border-none transition-all">
                      Record Payment
                    </button>` : html`
                    <div class="flex-1 py-2 text-xs font-bold text-green-600 text-center">✓ Paid</div>`}
                  <button @click=${() => { this.editForm = { maintenanceAmount: String(bill.maintenanceAmount), waterAmount: String(bill.waterAmount), previousDue: String(bill.previousDue) }; this.editModal = { open: true, bill }; }}
                    class="p-2 text-gray-400 hover:text-blue-600 hover:bg-blue-50 rounded-xl cursor-pointer bg-white border border-gray-200 transition-all">${iconEdit2('w-4 h-4')}</button>
                  <button @click=${() => this._sendWhatsApp(bill)}
                    class="p-2 text-gray-400 hover:text-green-600 hover:bg-green-50 rounded-xl cursor-pointer bg-white border border-gray-200 transition-all">${iconMessageCircle('w-4 h-4')}</button>
                  <button @click=${() => this._sendEmail(bill)}
                    class="p-2 text-gray-400 hover:text-blue-600 hover:bg-blue-50 rounded-xl cursor-pointer bg-white border border-gray-200 transition-all">${iconMail('w-4 h-4')}</button>
                </div>
              </div>`;
            })
          }
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
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Payment Date</label>
              <input type="date" .value=${this.payDate} @input=${(e: Event) => this.payDate = (e.target as HTMLInputElement).value}
                class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500" />
            </div>
            <div class="flex gap-2 justify-end pt-2">
              <psa-button variant="secondary" @click=${() => this.payModal = null}>Cancel</psa-button>
              <psa-button .loading=${this.saving} .disabled=${!this.payAmount} @click=${this._handlePayment}>Save Payment</psa-button>
            </div>
          </div>
        </psa-modal>

        <!-- ── WhatsApp Bulk Send Modal ── -->
        <psa-modal ?open=${this.waBulkModal} modalTitle="WhatsApp Bulk Send — ${monthName(this.month)} ${this.year}" size="md" @close=${() => this.waBulkModal = false}>
          <div class="space-y-3">
            <div class="flex items-center gap-2 bg-green-50 border border-green-200 rounded-xl px-4 py-3 mb-2">
              ${iconMessageCircle('w-5 h-5 text-green-600')}
              <div>
                <p class="text-sm font-medium text-green-800">Click "Send" next to each flat to open WhatsApp</p>
                <p class="text-xs text-green-600">Each click opens a pre-filled WhatsApp message. Tap send in WhatsApp, then come back for the next one.</p>
              </div>
            </div>
            <div class="flex items-center justify-between text-xs text-gray-500 px-1">
              <span>${this.waSentFlats.size} of ${this.bills.filter(b => b.status !== 'PAID').length} sent</span>
              <span class="font-medium">${this.bills.filter(b => b.status !== 'PAID' && b.flat?.tenancies?.[0]?.user?.phone).length} have phone numbers</span>
            </div>
            <div class="max-h-80 overflow-y-auto space-y-1.5">
              ${this.bills.filter(b => b.status !== 'PAID').map(bill => {
                const tenant = bill.flat?.tenancies?.[0]?.user;
                const phone = tenant?.phone;
                const flat = bill.flat?.flatNumber;
                const sent = this.waSentFlats.has(flat);
                const balance = bill.totalAmount - bill.paidAmount;
                return html`
                  <div class="flex items-center gap-3 px-3 py-2.5 rounded-xl border ${sent ? 'bg-green-50 border-green-200' : 'bg-white border-gray-200'} transition-all">
                    <div class="w-8 h-8 rounded-lg bg-gradient-to-br from-blue-500 to-indigo-600 flex items-center justify-center text-white text-[10px] font-bold shrink-0">${flat}</div>
                    <div class="flex-1 min-w-0">
                      <p class="text-sm font-medium text-gray-900 truncate">${tenant?.name || 'No tenant'}</p>
                      <p class="text-xs text-gray-400">${phone || 'No phone'} · Balance: <span class="font-semibold text-red-600">${formatCurrency(balance)}</span></p>
                    </div>
                    ${!phone ? html`<span class="text-xs text-gray-400 bg-gray-100 px-2 py-1 rounded-lg">No phone</span>` :
                      sent ? html`<span class="text-xs text-green-600 bg-green-100 px-2.5 py-1 rounded-lg font-semibold">✓ Sent</span>` :
                      html`<button @click=${() => this._sendWaBulk(bill)}
                        class="text-xs font-bold text-white bg-green-600 hover:bg-green-700 px-3 py-1.5 rounded-lg cursor-pointer border-none shadow-sm transition-all">Send</button>`}
                  </div>
                `;
              })}
            </div>
            <div class="flex items-center justify-between pt-2">
              <button @click=${() => this._sendAllWhatsApp()}
                class="text-sm font-semibold text-white bg-green-600 hover:bg-green-700 px-4 py-2 rounded-xl cursor-pointer border-none shadow-sm transition-all"
                ?disabled=${this.bills.filter(b => b.status !== 'PAID' && b.flat?.tenancies?.[0]?.user?.phone).length === 0}>
                Send All (${this.bills.filter(b => b.status !== 'PAID' && b.flat?.tenancies?.[0]?.user?.phone).length} with phone)
              </button>
              <psa-button variant="secondary" @click=${() => this.waBulkModal = false}>Close</psa-button>
            </div>
          </div>
        </psa-modal>

        <!-- ── Print Template ── -->
        ${this.printingAll ? html`
          <div class="print-only">
            <div style="padding:15px;font-family:Arial,sans-serif;line-height:1.4;max-width:100%">
              <!-- Header -->
              <div style="text-align:center;margin-bottom:15px;border-bottom:3px solid #000;padding-bottom:10px">
                <h1 style="color:#006600;font-size:18px;margin:0;font-weight:bold">PRIMARK SREENIDHI APARTMENT ASSOCIATION, KONDAPUR,</h1>
                <h1 style="color:#006600;font-size:18px;margin:5px 0 0 0;font-weight:bold">HYDERABAD</h1>
              </div>

              <!-- Greeting -->
              <div style="margin-bottom:20px">
                <p style="margin:0;font-size:14px"><strong>To</strong></p>
                <p style="margin:5px 0;font-size:14px">All the Owners and Residents of PSA</p>
                <p style="margin:10px 0 0 0;font-size:16px;font-weight:bold">Namaste.</p>
                <p style="text-align:right;font-size:13px;margin:10px 0 0 0">Date: ${new Date().toLocaleDateString('en-IN')}</p>
              </div>

              <!-- Salutation -->
              <p style="margin:20px 0;font-size:14px">Dear Sir/Madam,</p>
              <p style="margin:10px 0;font-size:14px;text-align:center;font-weight:bold;text-decoration:underline">${monthName(this.month)} ${this.year} Maintenance</p>

              <!-- Payment Instructions -->
              <p style="margin:15px 0;font-size:13px">You can transfer the amount to below account.</p>
              <div style="margin:15px 0;font-size:13px">
                <p style="margin:5px 0"><strong>1. UPI Pay</strong></p>
                <p style="margin:5px 0 5px 20px">Mobile Number : 7093991333</p>
              </div>

              <!-- Note -->
              <p style="margin:15px 0;font-size:12px;font-weight:bold">
                <strong>Note:</strong> Please include the <strong>FLAT NUMBER</strong> in the payment description. Kindly <u>sign</u> after completing the payment.
              </p>

              <!-- Bill Table -->
              <p style="margin:20px 0 10px 0;font-size:13px;font-weight:bold;text-decoration:underline">Maintenance and Water Amount :</p>
              <table style="width:100%;border-collapse:collapse;margin:10px 0;font-size:11px;border:1px solid #000">
                <tr style="background:#f0f0f0">
                  <th style="border:1px solid #000;padding:6px;text-align:left">Flats</th>
                  <th style="border:1px solid #000;padding:6px;text-align:center">Maintenance<br/>Amount (Rs)</th>
                  <th style="border:1px solid #000;padding:6px;text-align:center">${monthName(this.month === 1 ? 12 : this.month - 1)} Water<br/>Amount (Rs)</th>
                  <th style="border:1px solid #000;padding:6px;text-align:center">Last Month<br/>Due (Rs)</th>
                  <th style="border:1px solid #000;padding:6px;text-align:center">Liters<br/>Consumed</th>
                  <th style="border:1px solid #000;padding:6px;text-align:center">Total (Rs)</th>
                  <th style="border:1px solid #000;padding:6px;text-align:center">Signature</th>
                </tr>
                ${this.bills.filter(bill => bill.flat?.flatNumber !== 'Common').map(bill => html`
                  <tr>
                    <td style="border:1px solid #000;padding:6px">${bill.flat?.flatNumber}</td>
                    <td style="border:1px solid #000;padding:6px;text-align:center">${bill.maintenanceAmount}</td>
                    <td style="border:1px solid #000;padding:6px;text-align:center">${bill.waterAmount}</td>
                    <td style="border:1px solid #000;padding:6px;text-align:center">${bill.previousDue > 0 ? bill.previousDue : 'Nil'}</td>
                    <td style="border:1px solid #000;padding:6px;text-align:center">${bill.litersConsumed ? bill.litersConsumed * 10 : '-'}</td>
                    <td style="border:1px solid #000;padding:6px;text-align:center;font-weight:bold">${bill.totalAmount}</td>
                    <td style="border:1px solid #000;padding:6px;text-align:center"></td>
                  </tr>
                `)}
              </table>

              <!-- Footer -->
              <div style="margin-top:15px;text-align:center;font-size:13px">
                <p style="margin:10px 0">With Best Regards,</p>
                <p style="margin:0">PSA Association, Kondapur, Hyderabad</p>
              </div>
            </div>
          </div>
        ` : ''}

        ${this.printBill && !this.printingAll ? html`
          <div class="print-only">
            <div style="max-width:900px;margin:0 auto;padding:40px;font-family:Arial,sans-serif;line-height:1.6">
              <!-- Header -->
              <div style="text-align:center;margin-bottom:30px;border-bottom:3px solid #000;padding-bottom:20px">
                <h1 style="color:#006600;font-size:18px;margin:0;font-weight:bold">PRIMARK SREENIDHI APARTMENT ASSOCIATION, KONDAPUR,</h1>
                <h1 style="color:#006600;font-size:18px;margin:5px 0 0 0;font-weight:bold">HYDERABAD</h1>
              </div>

              <!-- Greeting -->
              <div style="margin-bottom:20px">
                <p style="margin:0;font-size:14px"><strong>To,</strong></p>
                <p style="margin:5px 0;font-size:14px">All the Owners and Residents of PSA</p>
                <p style="margin:10px 0 0 0;font-size:16px;font-weight:bold">Namaste.</p>
                <p style="text-align:right;font-size:13px;margin:10px 0 0 0">Date: ${new Date().toLocaleDateString('en-IN')}</p>
              </div>

              <!-- Salutation -->
              <p style="margin:20px 0;font-size:14px">Dear Sir/Madam,</p>
              <p style="margin:10px 0;font-size:14px;text-align:center;font-weight:bold;text-decoration:underline">${monthName(this.month)} ${this.year} Maintenance</p>

              <!-- Payment Instructions -->
              <p style="margin:15px 0;font-size:13px">You can transfer the amount to below account.</p>
              <div style="margin:15px 0;font-size:13px">
                <p style="margin:5px 0"><strong>1. UPI Pay</strong></p>
                <p style="margin:5px 0 5px 20px">Mobile Number : 7093991333</p>
              </div>

              <!-- Note -->
              <p style="margin:15px 0;font-size:12px;font-weight:bold">
                <strong>Note:</strong> Please include the <strong>FLAT NUMBER</strong> in the payment description. Kindly <u>sign</u> after completing the payment.
              </p>

              <!-- Bill Table -->
              <p style="margin:20px 0 10px 0;font-size:13px;font-weight:bold;text-decoration:underline">Maintenance and Water Amount :</p>
              <table style="width:100%;border-collapse:collapse;margin:10px 0;font-size:12px">
                <tr style="background:#f0f0f0;border:1px solid #000">
                  <th style="border:1px solid #000;padding:8px;text-align:left">Flat</th>
                  <th style="border:1px solid #000;padding:8px;text-align:center">Maintenance Amount (Rs)</th>
                  <th style="border:1px solid #000;padding:8px;text-align:center">${monthName(this.month)} Water (Rs)</th>
                  <th style="border:1px solid #000;padding:8px;text-align:center">Last Month Due (Rs)</th>
                  <th style="border:1px solid #000;padding:8px;text-align:center">Liters Consumed</th>
                  <th style="border:1px solid #000;padding:8px;text-align:center">Total (Rs)</th>
                  <th style="border:1px solid #000;padding:8px;text-align:center">Signature</th>
                </tr>
                <tr style="border:1px solid #000">
                  <td style="border:1px solid #000;padding:8px">${this.printBill.flat?.flatNumber}</td>
                  <td style="border:1px solid #000;padding:8px;text-align:center">${this.printBill.maintenanceAmount}</td>
                  <td style="border:1px solid #000;padding:8px;text-align:center">${this.printBill.waterAmount}</td>
                  <td style="border:1px solid #000;padding:8px;text-align:center">${this.printBill.previousDue > 0 ? this.printBill.previousDue : 'Nil'}</td>
                  <td style="border:1px solid #000;padding:8px;text-align:center">${this.printBill.litersConsumed || '-'}</td>
                  <td style="border:1px solid #000;padding:8px;text-align:center;font-weight:bold">${this.printBill.totalAmount}</td>
                  <td style="border:1px solid #000;padding:8px;text-align:center"></td>
                </tr>
              </table>

              <!-- Footer -->
              <div style="margin-top:40px;text-align:center;font-size:13px">
                <p style="margin:20px 0">With Best Regards,</p>
                <p style="margin:0">PSA Association, Kondapur, Hyderabad</p>
              </div>
            </div>
          </div>
        ` : ''}

        <style>
          .print-only {
            position: absolute;
            left: -9999px;
            top: 0;
            visibility: hidden;
          }
          
          @media print {
            body * { 
              visibility: hidden !important; 
            }
            .print-only, .print-only * { 
              visibility: visible !important;
            }
            .print-only { 
              position: absolute !important;
              left: 0 !important;
              top: 0 !important;
              width: 100% !important;
            }
          }
        </style>
      </div>
    `;
  }
}
