// Execute the production Swift string, including its interpolation boundaries.
const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');

const scripts = path.resolve(__dirname,
  '../macos/flutter_inappwebview_macos/Sources/flutter_inappwebview_macos/PluginScriptsJS');
const constants = Object.fromEntries([...fs.readFileSync(
  path.join(scripts, 'PluginScriptsUtil.swift'), 'utf8')
  .matchAll(/public static let (VAR_[A-Z_]+) = "([^"]+)"/g)]
  .map((match) => [match[1], match[2]]));
const template = fs.readFileSync(
  path.join(scripts, 'CallAsyncJavaScriptBelowIOS14WrapperJS.swift'), 'utf8')
  .split('return """')[1].split('"""')[0]
  .replace(/\\\(PluginScriptsUtil\.(VAR_[A-Z_]+)\)/g, (_, key) => {
    assert.ok(constants[key], `Unknown production placeholder: ${key}`);
    return constants[key];
  })
  .replaceAll('\\(JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME())', 'testBridge');
assert.ok(!template.includes('\\('), 'Unresolved Swift interpolation');

async function evaluate(functionBody, args = {}) {
  const replies = [];
  const replacements = {
    VAR_FUNCTION_ARGUMENT_NAMES: Object.keys(args).join(', '),
    VAR_FUNCTION_ARGUMENT_VALUES: Object.keys(args).map((key) => `obj.${key}`).join(', '),
    VAR_FUNCTION_ARGUMENTS_OBJ: JSON.stringify(args),
    VAR_FUNCTION_BODY: functionBody,
    VAR_RESULT_UUID: 'test-request',
  };
  let source = template;
  for (const [key, value] of Object.entries(replacements)) {
    source = source.replaceAll(constants[key], value);
  }
  const context = {
    window: { testBridge: { callHandler(name, result) {
      // The actual bridge serializes arguments before native delivery.
      replies.push([name, JSON.parse(JSON.stringify(result))]);
    } } },
  };
  assert.equal(vm.runInNewContext(source, context), null);
  await new Promise(setImmediate);
  assert.equal(replies.length, 1, 'One result must reach the native handler');
  assert.equal(replies[0][0], 'onCallAsyncJavaScriptResultBelowIOS14Received');
  assert.equal(replies[0][1].resultUuid, 'test-request');
  return replies[0][1];
}

test('legacy wrapper executes a normal async result without arguments', async () => {
  assert.deepEqual(await evaluate('return await Promise.resolve(42);'), {
    value: 42, error: null, resultUuid: 'test-request',
  });
});

test('legacy wrapper preserves argument values and result JSON', async () => {
  const args = { text: 'עברית 😀 "quotes" \\ newline\n', object: { nested: [1, null, true] } };
  assert.deepEqual(await evaluate('return {text, object};', args), {
    value: args, error: null, resultUuid: 'test-request',
  });
});

test('legacy wrapper reports a rejected async function once', async () => {
  assert.deepEqual(await evaluate('throw new Error("expected rejection");'), {
    value: null, error: 'Error: expected rejection', resultUuid: 'test-request',
  });
});
