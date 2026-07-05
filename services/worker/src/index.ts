import { app } from './app';

const PORT = process.env.WORKER_PORT || 3001;
app.listen(PORT, () => {
  console.log(`Worker service running on port ${PORT}`);
});
