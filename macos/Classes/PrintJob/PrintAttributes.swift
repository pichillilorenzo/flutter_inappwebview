//
//  PrintAttributes.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 10/05/22.
//

import Foundation

public class PrintAttributes : NSObject {
    var orientation: NSPrintInfo.PaperOrientation?
    var margins: NSEdgeInsets?
    var paperRect: CGRect?
    var colorMode: String?
    var duplex: Int?
    
    public init(fromPrintJobController: PrintJobController) {
        super.init()
        if let job = fromPrintJobController.job {
            let printInfo = job.printInfo
            orientation = printInfo.orientation
            margins = NSEdgeInsets(top: printInfo.topMargin,
                                   left: printInfo.leftMargin,
                                   bottom: printInfo.bottomMargin,
                                   right: printInfo.rightMargin)
            paperRect = CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: printInfo.paperSize)
            colorMode = printInfo.printSettings["ColorModel"] as? String
            duplex = printInfo.printSettings["com_apple_print_PrintSettings_PMDuplexing"] as? Int
            print(printInfo.printSettings)
        }
    }
    
    public func toMap () -> [String:Any?] {
        return [
            "paperRect": paperRect?.toMap(),
            "margins": margins?.toMap(),
            "orientation": orientation?.rawValue,
            "colorMode": colorMode,
            "duplex": duplex
        ]
    }
}
