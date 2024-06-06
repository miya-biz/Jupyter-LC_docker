/**
 * Configuration for Playwright using default from @jupyterlab/galata
 */
const baseConfig = require('@jupyterlab/galata/lib/playwright-config');

module.exports = {
  ...baseConfig,
  use: {
    baseURL: 'http://localhost:8888/lab',
    headless: false,
    viewport: { width: 1280, height: 720 },
  }
};