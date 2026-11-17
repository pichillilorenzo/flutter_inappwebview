import AppKit
import Foundation

@main
enum JavaScriptDialogPresenterRegressionTest {
    static func main() {
        let application = NSApplication.shared
        application.setActivationPolicy(.regular)
        testWindowUsesSheet(application)
        testOwnerCompletesAndReleasesSheet(application)
        testOwnerCancellationCompletesOnce(application)
        testHostCloseCompletesDialogsOnce(application)
        testOwnerReleaseCompletesSheet(application)
        testNoWindowUsesModalFallback()
        testConfirmationAndPromptResponses()
        print("JavaScriptDialogPresenter regression checks passed")
    }

    private static func testOwnerCompletesAndReleasesSheet(_ application: NSApplication) {
        let hostWindow = makeWindow(application)
        let host = DialogHostUnderTest()
        host.window = hostWindow
        let alert = makeAlert()
        var responses: [NSApplication.ModalResponse] = []
        host.runJavaScriptDialog(alert) { responses.append($0) }
        precondition(host.activeJavaScriptDialogPresentations.count == 1)
        weak var presentation = host.activeJavaScriptDialogPresentations.values.first
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            alert.buttons.first?.performClick(nil)
        }
        runMainLoop(until: { !responses.isEmpty })
        precondition(responses == [.alertFirstButtonReturn])
        precondition(host.activeJavaScriptDialogPresentations.isEmpty)
        precondition(presentation == nil, "Completed sheets must release their presentation")
        hostWindow.close()
    }

    private static func testOwnerCancellationCompletesOnce(_ application: NSApplication) {
        let hostWindow = makeWindow(application)
        let host = DialogHostUnderTest()
        host.window = hostWindow
        let alert = makeAlert()
        var responses: [NSApplication.ModalResponse] = []
        host.runJavaScriptDialog(alert) { responses.append($0) }
        host.cancelHostDialogs()
        host.cancelHostDialogs()
        // AppKit also delivers the endSheet callback after cancellation.
        RunLoop.main.run(until: Date().addingTimeInterval(0.2))
        precondition(responses == [.abort])
        precondition(host.activeJavaScriptDialogPresentations.isEmpty)
        hostWindow.close()
    }

    private static func testHostCloseCompletesDialogsOnce(_ application: NSApplication) {
        let hostWindow = makeWindow(application)
        hostWindow.isReleasedWhenClosed = false
        let host = DialogHostUnderTest()
        host.window = hostWindow
        var responses: [NSApplication.ModalResponse] = []
        let alert = makeAlert()
        host.runJavaScriptDialog(alert) { responses.append($0) }
        hostWindow.close()
        precondition(responses == [.abort], "Closing the host must resolve pending WebKit replies")
        RunLoop.main.run(until: Date().addingTimeInterval(0.2))
        precondition(responses == [.abort])
        precondition(host.activeJavaScriptDialogPresentations.isEmpty)
        precondition(host.hostDialogWindowCloseObserver == nil)

        let panelWindow = makeWindow(application)
        panelWindow.isReleasedWhenClosed = false
        host.window = panelWindow
        let panel = NSOpenPanel()
        var panelCalls = 0
        let completion = JavaScriptDialogCompletion<[URL]?> { urls in
            precondition(urls?.isEmpty == true)
            panelCalls += 1
        }
        host.currentOpenPanel = panel
        host.currentOpenPanelCompletion = completion
        host.observeHostDialogWindowClose(panelWindow)
        panel.beginSheetModal(for: panelWindow) { _ in completion.call([]) }
        panelWindow.close()
        precondition(panelCalls == 1)
        RunLoop.main.run(until: Date().addingTimeInterval(0.2))
        precondition(panelCalls == 1)
        precondition(host.currentOpenPanel == nil && host.currentOpenPanelCompletion == nil)
    }

    private static func testOwnerReleaseCompletesSheet(_ application: NSApplication) {
        let window = makeWindow(application)
        var host: DialogHostUnderTest? = DialogHostUnderTest()
        host?.window = window
        var responses: [NSApplication.ModalResponse] = []
        let alert = makeAlert()
        host?.runJavaScriptDialog(alert) { responses.append($0) }
        host = nil
        precondition(responses == [.abort])
        RunLoop.main.run(until: Date().addingTimeInterval(0.2))
        precondition(responses == [.abort])
        window.close()
    }

    private static func makeWindow(_ application: NSApplication) -> NSWindow {
        let window = NSWindow(
            contentRect: NSRect(x: 100, y: 100, width: 400, height: 300),
            styleMask: [.titled], backing: .buffered, defer: false
        )
        window.makeKeyAndOrderFront(nil)
        application.activate(ignoringOtherApps: true)
        return window
    }

    private static func testWindowUsesSheet(_ application: NSApplication) {
        let hostWindow = NSWindow(
            contentRect: NSRect(x: 100, y: 100, width: 400, height: 300),
            styleMask: [.titled],
            backing: .buffered,
            defer: false
        )
        hostWindow.makeKeyAndOrderFront(nil)
        application.activate(ignoringOtherApps: true)

        let alert = makeAlert()
        var response: NSApplication.ModalResponse?
        JavaScriptDialogPresenter.present(alert, in: hostWindow) { response = $0 }
        precondition(alert.window.sheetParent === hostWindow)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            alert.buttons.first?.performClick(nil)
        }
        runMainLoop(until: { response != nil })
        precondition(response == .alertFirstButtonReturn)
        hostWindow.close()
    }

    private static func testNoWindowUsesModalFallback() {
        let alert = makeAlert()
        var response: NSApplication.ModalResponse?
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            alert.buttons.last?.performClick(nil)
        }
        var watchdogFired = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            watchdogFired = true
            NSApp.abortModal()
        }
        JavaScriptDialogPresenter.present(alert, in: nil) { response = $0 }
        precondition(!watchdogFired, "Timed out waiting for the modal fallback dialog")
        precondition(response == .alertSecondButtonReturn)
    }

    private static func testConfirmationAndPromptResponses() {
        precondition(JavaScriptDialogPresenter.confirmResult(.alertFirstButtonReturn))
        precondition(!JavaScriptDialogPresenter.confirmResult(.alertSecondButtonReturn))
        precondition(JavaScriptDialogPresenter.promptResult(
            .alertFirstButtonReturn, clientValue: nil, enteredValue: "typed"
        ) == "typed")
        precondition(JavaScriptDialogPresenter.promptResult(
            .alertSecondButtonReturn, clientValue: nil, enteredValue: "typed"
        ) == nil)
        precondition(JavaScriptDialogPresenter.promptResult(
            .alertSecondButtonReturn, clientValue: "client", enteredValue: "typed"
        ) == "client")
    }

    private static func makeAlert() -> NSAlert {
        let alert = NSAlert()
        alert.messageText = "Regression test"
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        return alert
    }

    private static func runMainLoop(until predicate: () -> Bool) {
        let deadline = Date().addingTimeInterval(3)
        while !predicate() && Date() < deadline {
            RunLoop.main.run(until: Date().addingTimeInterval(0.01))
        }
        precondition(predicate(), "Timed out waiting for the AppKit dialog completion")
    }
}
