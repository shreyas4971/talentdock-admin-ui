import { app } from './app';
import { env } from './config/env';
import { logger } from './utils/logger';
import { setupEventDispatcher } from './events/dispatcher';

// Initialize the EventBus listeners
setupEventDispatcher();

app.listen(env.PORT, () => {
  logger.info(`Server started on port ${env.PORT}`);
});
