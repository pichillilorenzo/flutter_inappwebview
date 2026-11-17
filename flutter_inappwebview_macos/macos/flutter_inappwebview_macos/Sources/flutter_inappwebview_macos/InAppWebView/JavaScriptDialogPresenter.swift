import AppKit
import Foundation

final class JavaScriptDialogCompletion<Value> {
    private var completion: ((Value) -> Void)?

    init(_ completion: @escaping (Value) -> Void) {
        self.completion = completion
    }

    func call(_ value: Value) {
        let completion = self.completion
        self.completion = nil
        completion?(value)
    }
}

enum JavaScriptDialogPresenter {
    static func present(
        _ alert: NSAlert,
        in window: NSWindow?,
        completionHandler: @escaping (NSApplication.ModalResponse) -> Void
    ) {
        if let window = window {
            alert.beginSheetModal(for: window, completionHandler: completionHandler)
        } else {
            completionHandler(alert.runModal())
        }
    }

    static func confirmResult(_ response: NSApplication.ModalResponse) -> Bool {
        response == .alertFirstButtonReturn
    }

    static func promptResult(
        _ response: NSApplication.ModalResponse,
        clientValue: String?,
        enteredValue: String
    ) -> String? {
        clientValue ?? (confirmResult(response) ? enteredValue : nil)
    }
}

final class PendingJavaScriptDialog {
    weak var window: NSWindow?
    let alert: NSAlert
    let completion: JavaScriptDialogCompletion<NSApplication.ModalResponse>

    init(window: NSWindow, alert: NSAlert, completion: @escaping (NSApplication.ModalResponse) -> Void) {
        self.window = window
        self.alert = alert
        self.completion = JavaScriptDialogCompletion(completion)
    }

    func cancel() {
        if let window = window, alert.window.sheetParent === window {
            window.endSheet(alert.window, returnCode: .abort)
        }
        completion.call(.abort)
    }
}
