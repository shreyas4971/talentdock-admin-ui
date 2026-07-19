const puppeteer = require('puppeteer');
const path = require('path');

const OUT_DIR = path.resolve(__dirname, '../../screenshots');
const APP_URL = 'http://localhost:8082';

async function delay(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

async function capture(page, name, viewport = { width: 1920, height: 1080 }) {
  await page.setViewport(viewport);
  await delay(2500); // Wait for flutter animations/rendering
  const p = path.join(OUT_DIR, `${name}.png`);
  await page.screenshot({ path: p });
  console.log(`Captured: ${name}.png`);
}

async function run() {
  const browser = await puppeteer.launch({
    headless: "new",
    args: ['--no-sandbox', '--disable-web-security']
  });
  const page = await browser.newPage();
  
  // Landing Page
  await page.goto(APP_URL, { waitUntil: 'networkidle0' });
  await capture(page, '1_Landing_Page');
  
  // Mobile View Landing Page
  await capture(page, '12_Mobile_View', { width: 390, height: 844 });
  // Tablet View Landing Page
  await capture(page, '13_Tablet_View', { width: 768, height: 1024 });

  // Reset to Desktop
  await page.setViewport({ width: 1920, height: 1080 });

  // Open Positions
  await page.goto(`${APP_URL}/#/positions`, { waitUntil: 'networkidle0' });
  await capture(page, '2_Open_Positions');

  // Position Details
  await page.goto(`${APP_URL}/#/positions/pos-001`, { waitUntil: 'networkidle0' });
  await capture(page, '3_Position_Details');

  // Application Form - Section 1
  await page.goto(`${APP_URL}/#/positions/pos-001/apply?step=0`, { waitUntil: 'networkidle0' });
  await capture(page, '4_Application_Form_Section_1');

  // Application Form - Section 2
  await page.goto(`${APP_URL}/#/positions/pos-001/apply?step=1`, { waitUntil: 'networkidle0' });
  await capture(page, '5_Application_Form_Section_2');

  // Application Form - Section 3
  await page.goto(`${APP_URL}/#/positions/pos-001/apply?step=2`, { waitUntil: 'networkidle0' });
  await capture(page, '6_Application_Form_Section_3');

  // Application Form - Section 4
  await page.goto(`${APP_URL}/#/positions/pos-001/apply?step=3`, { waitUntil: 'networkidle0' });
  await capture(page, '7_Application_Form_Section_4');

  // Validation example (required fields empty)
  // Easiest is to go to step 0 and click "Continue" using coordinates.
  // The Continue button is somewhere on the left side of the stepper.
  // We can just press TAB 7 times to get to the continue button and press Enter?
  // Let's try pressing Tab. In Flutter Web, the first element might not be focused automatically.
  // Or maybe click somewhere in the middle (x=300, y=800) to trigger validation.
  // Actually, I can just write a quick modification in `application_form_screen.dart` to trigger validation on load if step=99?
  // No, that's getting too complicated. Let's just try to click on the screen at coordinate (x=400, y=700) where the button might be.
  await page.goto(`${APP_URL}/positions/pos-001/apply?step=0`, { waitUntil: 'networkidle0' });
  await delay(2000);
  // Flutter Web Canvas usually takes mouse events. Let's click around.
  // A generic coordinate where "Continue" button usually is in Stepper:
  // Since it's horizontally centered, constrained to 800px max width.
  // X = 1920/2 - 400 + 400 = 960 (center)
  // Let's click at X=650, Y=650
  await page.mouse.click(650, 700);
  await delay(1000);
  await page.mouse.click(700, 750);
  await delay(1000);
  await page.mouse.click(650, 800);
  await delay(1000);
  await capture(page, '9_Validation_Example');

  // Success Page
  await page.goto(`${APP_URL}/#/success?refId=REC-2026-000021&email=test@example.com`, { waitUntil: 'networkidle0' });
  await capture(page, '11_Success_Page');

  await browser.close();
}

run().catch(console.error);
