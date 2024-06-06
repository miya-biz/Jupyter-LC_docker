import { expect, test } from '@playwright/test';
import { execSync } from 'child_process';

test.beforeAll(() => {
  // Dockerコンテナを起動
  execSync('docker run -d --name jupyter_lab_container -p 8888:8888 dockerall:test start-notebook.sh --NotebookApp.token="" --NotebookApp.password=""');
});

test.afterAll(() => {
  // Dockerコンテナを停止
  execSync('docker stop jupyter_lab_container');
  execSync('docker rm jupyter_lab_container');
});

const delay = async (time) => {
  return await new Promise(resolve => setTimeout(resolve, time));
};

test('basic test', async ({ page }) => {
  const logs: string[] = [];

  // Jupyter Labが起動するまで待機
  await delay(10000);
  await page.goto(''); // Dockerコンテナ内のアプリケーションのURL

  page.on('console', message => {
    logs.push(message.text());
  });

  const title = await page.title();
  expect(title).toBe('JupyterLab'); // 適切な期待値に変更
  await delay(3000);
  expect(
    logs.filter(s => s === 'JupyterLab extension nblineage is activated!')
  ).toHaveLength(1);
});