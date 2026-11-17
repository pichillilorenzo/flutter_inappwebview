const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');

const headerPath = path.join(
  __dirname,
  '..',
  'plugin_scripts_js',
  'cursor_detection_js.h',
);
const header = fs.readFileSync(headerPath, 'utf8');
const rawStart = header.indexOf('return R"JS(');
const rawEnd = header.indexOf(')JS";', rawStart);
assert.notEqual(rawStart, -1, 'cursor script raw string should exist');
assert.notEqual(rawEnd, -1, 'cursor script raw string should be closed');

let script = header.slice(rawStart + 'return '.length, rawEnd + 1);
script = script.replace(
  /\)JS"\s*\+\s*JavaScriptBridgeJS::get_JAVASCRIPT_BRIDGE_NAME\(\)\s*\+\s*R"JS\(/g,
  'flutter_inappwebview',
);
script = script.replace(/^R"JS\(/, '').replace(/\)$/s, '');
assert.doesNotMatch(script, /JavaScriptBridgeJS|\)JS"/, 'C++ string joins should be resolved');

const listeners = new Map();
const scheduledFrames = new Map();
const hitTests = [];
const computedStyles = [];
const reportedCursors = [];
let nextFrameId = 1;
const bridge = {
  callHandler(name, cursor) {
    assert.equal(name, '_cursorChanged');
    reportedCursors.push(cursor);
  },
};
const window = {
  flutter_inappwebview: bridge,
  requestAnimationFrame(callback) {
    const id = nextFrameId++;
    scheduledFrames.set(id, { callback, cancelled: false });
    return id;
  },
  cancelAnimationFrame(id) {
    const frame = scheduledFrames.get(id);
    if (frame) frame.cancelled = true;
  },
  getComputedStyle(element) {
    computedStyles.push(element.x);
    return { cursor: element.cursor };
  },
};
const document = {
  body: {},
  addEventListener(type, listener) {
    listeners.set(type, listener);
  },
  elementFromPoint(x, y) {
    hitTests.push([x, y]);
    return { x, tagName: 'div', parentElement: document.body, cursor: `cursor-${x}` };
  },
};
const context = { window, document, Node: { TEXT_NODE: 3 } };
vm.runInNewContext(script, context, { filename: headerPath });

function fireFrame(id, { evenIfCancelled = false } = {}) {
  const frame = scheduledFrames.get(id);
  assert.ok(frame, `frame ${id} should exist`);
  if (!frame.cancelled || evenIfCancelled) frame.callback();
}

function dispatch(type, event) {
  listeners.get(type)(event);
}

// A burst defers all hit-testing, then calculates only for the latest coordinates.
dispatch('mousemove', { clientX: 1, clientY: 10 });
dispatch('mousemove', { clientX: 2, clientY: 20 });
dispatch('mousemove', { clientX: 3, clientY: 30 });
assert.equal(scheduledFrames.size, 1, 'a burst should queue one animation frame');
assert.equal(hitTests.length, 0, 'mousemove should not perform hit-testing immediately');
fireFrame(1);
assert.deepEqual(hitTests, [[3, 30]], 'the frame should hit-test the latest coordinates');
assert.deepEqual(computedStyles, [3], 'computed style should run once for the burst');
assert.deepEqual(reportedCursors, ['cursor-3']);

// A later event gets a later frame and can report another cursor.
dispatch('mousemove', { clientX: 4, clientY: 40 });
assert.equal(scheduledFrames.size, 2, 'a later event should schedule a new frame');
fireFrame(2);
assert.deepEqual(hitTests.at(-1), [4, 40]);
assert.deepEqual(reportedCursors, ['cursor-3', 'cursor-4']);

// Leaving resets immediately and invalidates queued work, even if a cancelled callback runs.
dispatch('mousemove', { clientX: 5, clientY: 50 });
dispatch('mouseout', { relatedTarget: null });
assert.deepEqual(reportedCursors, ['cursor-3', 'cursor-4', 'default']);
fireFrame(3, { evenIfCancelled: true });
assert.equal(hitTests.length, 2, 'stale work after leaving must not calculate a cursor');

// Reentry schedules fresh work; a stale callback cannot clear or replace it.
dispatch('mouseover', { clientX: 6, clientY: 60 });
dispatch('mousemove', { clientX: 7, clientY: 70 });
fireFrame(3, { evenIfCancelled: true });
assert.equal(hitTests.length, 2, 'an old callback must stay inert after reentry');
fireFrame(4);
assert.deepEqual(hitTests.at(-1), [7, 70]);
assert.deepEqual(reportedCursors, ['cursor-3', 'cursor-4', 'default', 'cursor-7']);

console.log('cursor_detection_js_test passed');
