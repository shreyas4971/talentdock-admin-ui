import { app } from './src/app';
import request from 'supertest';

async function run() {
  console.log('Running smoke test...');
  let hasError = false;
  
  const healthRes = await request(app).get('/health');
  if (healthRes.status !== 200) {
    console.error('Health check failed', healthRes.body);
    hasError = true;
  }
  
  const readyRes = await request(app).get('/ready');
  if (readyRes.status !== 200) {
    console.error('Ready check failed', readyRes.body);
    hasError = true;
  }

  if (hasError) process.exit(1);
  console.log('Smoke test passed successfully!');
  process.exit(0);
}

run();
