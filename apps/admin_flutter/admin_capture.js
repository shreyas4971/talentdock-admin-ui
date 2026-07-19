const puppeteer = require('puppeteer');
const fs = require('fs');
const path = require('path');

const delay = ms => new Promise(res => setTimeout(res, ms));

async function capture() {
  const screenshotsDir = path.join(__dirname, '..', '..', 'admin_screenshots');
  if (!fs.existsSync(screenshotsDir)) {
    fs.mkdirSync(screenshotsDir, { recursive: true });
  }

  const browser = await puppeteer.launch({ headless: 'new', args: ['--no-sandbox', '--disable-setuid-sandbox'] });
  const page = await browser.newPage();

  const viewports = [
    { name: 'desktop', width: 1920, height: 1080 },
    { name: 'tablet', width: 768, height: 1024 },
    { name: 'mobile', width: 390, height: 844 }
  ];

  const routes = [
    { name: '1_Login', hash: '/login' },
    { name: '2_Dashboard', hash: '/' },
    { name: '3_Position_List', hash: '/positions' },
    { name: '4_Position_Editor', hash: '/positions/new' },
    { name: '5_Candidate_List', hash: '/candidates' },
    { name: '6_Candidate_Details', hash: '/candidates/can-001' }
  ];

  let isFirst = true;

  for (const viewport of viewports) {
    await page.setViewport({ width: viewport.width, height: viewport.height });
    console.log(`\nStarting capture for ${viewport.name} (${viewport.width}x${viewport.height})`);

    for (const route of routes) {
      console.log(`Navigating to ${route.hash}...`);
      await page.goto(`http://localhost:8083/#${route.hash}`, { waitUntil: 'networkidle2' });
      if (isFirst) {
        await delay(10000); // Wait 10 seconds on first load for flutter engine
        isFirst = false;
      } else {
        await delay(3000); // Wait 3 seconds for route transitions
      }
      const fileName = `${viewport.name}_${route.name}.png`;
      const filePath = path.join(screenshotsDir, fileName);
      await page.screenshot({ path: filePath, fullPage: true });
      console.log(`Saved ${fileName}`);
    }
  }

  await browser.close();
  console.log("\nAll screenshots captured.");
}

capture().catch(console.error);
