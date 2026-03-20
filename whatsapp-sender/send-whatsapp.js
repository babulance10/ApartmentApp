#!/usr/bin/env node
/**
 * PSA WhatsApp Bulk Sender
 * Run: node send-whatsapp.js
 *
 * First time: Scan QR code in WhatsApp Web to log in.
 * After that, session is saved and reused automatically.
 */

require('dotenv').config();
const { chromium } = require('playwright');
const axios = require('axios');
const path = require('path');
const fs = require('fs');

const API_URL = process.env.API_URL || 'http://localhost:3001/api';
const API_TOKEN = process.env.API_TOKEN || '';
const APARTMENT_ID = process.env.APARTMENT_ID || 'psa-main';
const SESSION_DIR = path.join(__dirname, '.whatsapp-session');

// Get current month/year from args or default to current
const args = process.argv.slice(2);
const now = new Date();
const MONTH = parseInt(args[0]) || now.getMonth() + 1;
const YEAR = parseInt(args[1]) || now.getFullYear();

const MONTH_NAMES = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

async function fetchUnpaidBills() {
  console.log(`\nFetching unpaid bills for ${MONTH_NAMES[MONTH - 1]} ${YEAR}...`);
  const { data } = await axios.get(
    `${API_URL}/bills/summary?apartmentId=${APARTMENT_ID}&month=${MONTH}&year=${YEAR}`,
    { headers: { Authorization: `Bearer ${API_TOKEN}` } }
  );
  const bills = (data.bills || []).filter(b => b.status !== 'PAID');
  console.log(`Found ${bills.length} unpaid bill(s).`);
  return bills;
}

function buildMessage(bill) {
  const tenant = bill.flat?.tenancies?.[0]?.user;
  const name = tenant?.name || 'Resident';
  const flat = bill.flat?.flatNumber;
  const balance = bill.totalAmount - bill.paidAmount;
  return (
    `Dear ${name},\n\n` +
    `Your maintenance bill for *${MONTH_NAMES[MONTH - 1]} ${YEAR}*:\n` +
    `• Flat: *${flat}*\n` +
    `• Maintenance: ₹${bill.maintenanceAmount}\n` +
    (bill.waterAmount > 0 ? `• Water: ₹${bill.waterAmount}\n` : '') +
    (bill.previousDue > 0 ? `• Previous Due: ₹${bill.previousDue}\n` : '') +
    `• *Total: ₹${bill.totalAmount}*\n` +
    (bill.paidAmount > 0 ? `• Paid: ₹${bill.paidAmount}\n` : '') +
    `• *Balance Due: ₹${balance}*\n\n` +
    `Please pay via UPI at your earliest convenience.\n\nThank you!\n— PSA Association`
  );
}

async function sendWhatsApp(page, phone, message) {
  const dialPhone = phone.replace(/\D/g, '');
  const intlPhone = dialPhone.startsWith('91') ? dialPhone : `91${dialPhone}`;
  const encodedMsg = encodeURIComponent(message);
  const url = `https://web.whatsapp.com/send?phone=${intlPhone}&text=${encodedMsg}`;

  console.log(`  Opening chat for +${intlPhone}...`);
  await page.goto(url, { waitUntil: 'networkidle', timeout: 30000 });

  // Wait for the send button or input field
  try {
    await page.waitForSelector('[data-testid="send-btn"], [data-testid="compose-btn-send"]', { timeout: 15000 });
    await page.click('[data-testid="send-btn"], [data-testid="compose-btn-send"]');
    await page.waitForTimeout(1500);
    console.log(`  ✓ Message sent!`);
    return true;
  } catch {
    // Try alternate selector
    try {
      const btn = await page.$('button[aria-label="Send"]');
      if (btn) { await btn.click(); await page.waitForTimeout(1500); console.log(`  ✓ Sent (alt)!`); return true; }
    } catch {}
    console.log(`  ✗ Could not send — check phone number format.`);
    return false;
  }
}

async function main() {
  if (!API_TOKEN) {
    console.error('\nERROR: Set API_TOKEN in whatsapp-sender/.env\n');
    console.error('Create .env file:\n  API_TOKEN=<your admin JWT token>\n  APARTMENT_ID=<your apartment id>');
    process.exit(1);
  }

  let bills;
  try {
    bills = await fetchUnpaidBills();
  } catch (e) {
    console.error('Failed to fetch bills:', e.message);
    process.exit(1);
  }

  if (bills.length === 0) {
    console.log('No unpaid bills. Nothing to send.');
    return;
  }

  // Filter bills that have a phone number
  const billsWithPhone = bills.filter(b => b.flat?.tenancies?.[0]?.user?.phone);
  const billsNoPhone = bills.filter(b => !b.flat?.tenancies?.[0]?.user?.phone);

  if (billsNoPhone.length > 0) {
    console.log(`\nSkipping ${billsNoPhone.length} flat(s) with no phone number:`);
    billsNoPhone.forEach(b => console.log(`  • Flat ${b.flat?.flatNumber}`));
  }

  console.log(`\nWill send WhatsApp to ${billsWithPhone.length} flat(s):`);
  billsWithPhone.forEach(b => {
    const phone = b.flat?.tenancies?.[0]?.user?.phone;
    const balance = b.totalAmount - b.paidAmount;
    console.log(`  • Flat ${b.flat?.flatNumber} — ${b.flat?.tenancies?.[0]?.user?.name} (${phone}) — Balance: ₹${balance}`);
  });

  console.log('\nLaunching browser...');
  const browser = await chromium.launchPersistentContext(SESSION_DIR, {
    headless: false,
    viewport: { width: 1280, height: 800 },
    args: ['--no-sandbox'],
  });

  const page = await browser.newPage();

  // Open WhatsApp Web and wait for QR or main chat
  console.log('\nOpening WhatsApp Web...');
  await page.goto('https://web.whatsapp.com', { waitUntil: 'networkidle', timeout: 60000 });

  // Check if we need to scan QR
  const qrCode = await page.$('[data-testid="qrcode"]');
  if (qrCode) {
    console.log('\n*** SCAN THE QR CODE IN THE BROWSER WINDOW ***');
    console.log('Waiting for WhatsApp login (up to 60 seconds)...');
    try {
      await page.waitForSelector('[data-testid="chat-list"]', { timeout: 60000 });
      console.log('✓ Logged in!\n');
    } catch {
      console.error('Login timed out. Please try again and scan QR faster.');
      await browser.close();
      process.exit(1);
    }
  } else {
    console.log('✓ Already logged in (session restored)!\n');
    await page.waitForTimeout(2000);
  }

  // Send messages
  let sent = 0, failed = 0;
  for (const bill of billsWithPhone) {
    const phone = bill.flat?.tenancies?.[0]?.user?.phone;
    const msg = buildMessage(bill);
    console.log(`\nSending to Flat ${bill.flat?.flatNumber}...`);
    const ok = await sendWhatsApp(page, phone, msg);
    if (ok) sent++; else failed++;
    // Delay between messages to avoid spam detection
    await page.waitForTimeout(2000);
  }

  console.log(`\n========================================`);
  console.log(`Done! Sent: ${sent} | Failed: ${failed} | Skipped (no phone): ${billsNoPhone.length}`);
  console.log(`========================================\n`);

  await browser.close();
}

main().catch(e => {
  console.error('Fatal error:', e);
  process.exit(1);
});
