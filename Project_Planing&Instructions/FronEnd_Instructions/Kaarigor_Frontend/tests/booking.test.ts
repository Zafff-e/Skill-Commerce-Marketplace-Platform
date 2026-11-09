import { test } from 'node:test';
import assert from 'node:assert/strict';
import {
  totals,
  nextWorkState,
  validBangladeshPhone,
  validUpload,
} from '../shared-design/src/booking.ts';
test('multi-task labour and optional urgency are charged once, commission is included', () => {
  assert.deepEqual(
    totals(
      [
        { taskId: 'fan', quantity: 2 },
        { taskId: 'switch', quantity: 1 },
      ],
      true,
    ),
    { labor: 900, urgency: 300, total: 1200, platformCommission: 120 },
  );
  assert.equal(totals([], true).total, 0);
});
test('invalid and unknown cart items cannot produce a quote', () => {
  for (const line of [
    { taskId: 'unknown', quantity: 1 },
    { taskId: 'fan', quantity: 0 },
    { taskId: 'fan', quantity: 1.5 },
    { taskId: 'fan', quantity: 21 },
  ])
    assert.throws(() => totals([line], false));
});
test('work lifecycle progresses once and completed remains terminal', () => {
  assert.equal(nextWorkState('Accepted'), 'OnTheWay');
  assert.equal(nextWorkState('InProgress'), 'Completed');
  assert.equal(nextWorkState('Completed'), 'Completed');
});
test('Bangladesh mobile validation accepts local and international formats', () => {
  for (const value of ['01712345678', '+8801712345678', '8801712345678', '01712 345678'])
    assert.equal(validBangladeshPhone(value), true);
  for (const value of ['01212345678', '0171234567', '+911712345678', 'abcdefghijk'])
    assert.equal(validBangladeshPhone(value), false);
});
test('identity document client checks allow expected formats and bounded size', () => {
  assert.equal(validUpload({ type: 'application/pdf', size: 1024 }), true);
  assert.equal(validUpload({ type: 'text/html', size: 1024 }), false);
  assert.equal(validUpload({ type: 'image/png', size: 5 * 1024 * 1024 + 1 }), false);
  assert.equal(validUpload({ type: 'image/jpeg', size: 0 }), false);
});
