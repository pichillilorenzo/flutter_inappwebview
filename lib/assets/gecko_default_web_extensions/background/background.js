const port = browser.runtime.connectNative("background");
const contentScripts = [];

port.onMessage.addListener(message => {

  if (message.action === 'registerContentScript') {
    browser.contentScripts.register(message.contentScript).then(contentScript => {
      contentScripts.push(contentScript);
    });
  }

});

port.postMessage("I'm ready!");