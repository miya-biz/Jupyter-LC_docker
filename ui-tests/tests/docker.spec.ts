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

test('should emit an activation console message', async ({ page }) => {
  const logs: string[] = [];

  page.on('console', message => {
    logs.push(message.text());
  });

  // docker上のJupyter Labが起動するまで待機
  await delay(10000);
  // doxker上のJupyter Labに遷移
  await page.goto('');
  // 待機しないとエラーになる
  await delay(5000);
  
  // lc_index
  expect(
    logs.filter(s => s === 'JupyterLab extension lc_index is activated!')
  ).toHaveLength(1);
  
  // lc_multi_outputs
  // console.debug
  expect(
    logs.filter(s => s === 'JupyterLab extension lc_multi_outputs is activated!')
  ).toHaveLength(1);

  // lc_notebook_diff
  expect(
    logs.filter(s => s === 'JupyterLab extension lc_notebook_diff is activated!')
  ).toHaveLength(1);
  
  // lc_run_through
  // console.debug
  expect(
    logs.filter(s => s === 'JupyterLab extension lc_run_through is activated!')
  ).toHaveLength(1);

  // nblineage
  expect(
    logs.filter(s => s === 'JupyterLab extension nblineage is activated!')
  ).toHaveLength(1);

  // nbsearch(disabled)
  // nbwhisper(disabled)
  // sidestickies(disabled)
});