//
//  DiagnoseMailHelper.swift
//  CllocationManagerBackgroundTest
//
//  Created by Sjoerd Perfors on 15/10/2018.
//  Copyright © 2018 Flitsmeister. All rights reserved.
//

import Foundation
import CocoaLumberjackSwift
import MessageUI

extension Formatter {
    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        return formatter
    }()
}

extension String {
    var dateFromISO8601: Date? {
        return Formatter.iso8601.date(from: self)   // "Mar 22, 2017, 10:22 AM"
    }
}

extension UIApplication {
    func version() -> String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        return version ?? ""
    }
    
    func buildNumber() -> String {
        let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
        return buildNumber ?? ""
    }
    
    func versionWithBuildNumber() -> String {
        return version() + " " + buildNumber()
    }
}

struct DiagnoseMailHelper {
    private init() {}
    
    private static var iso8601Formatter = DateFormatter.iso8601
    
    static func diagnoseMailVC(delegate: MFMailComposeViewControllerDelegate) -> UIViewController {
        
        // Check if we can send mail
        guard MFMailComposeViewController.canSendMail() else {
            let alert = UIAlertController.init(
                title: NSLocalizedString("Oeps", comment: "Default title for alert when something not right happend"),
                message: NSLocalizedString("Deze optie werkt alleen als er e-mail accounts zijn ingesteld op je toestel en de Apple mail app juist is geconfigureerd", comment: "Alert message"),
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "General OK button for an alert"), style: .cancel, handler: nil))
            
            return alert
        }
        
        let mailController = MFMailComposeViewController()
        
        // - Setup text parts of mail
        // Subject
        mailController.setSubject(NSLocalizedString("Diagnose bestand iOS", comment: "Mail subject diagnosis file"))
        
        // Body
        let appVersion = UIApplication.shared.versionWithBuildNumber()
        let osVersion:String = UIDevice.current.systemVersion
        let iso8601Date = iso8601Formatter.string(from: Date())
        
        let mailText = String(
            format: NSLocalizedString("\n\nApp version: %@\niOS version: %@\n\nDate: %@\n\n", comment: "Mail text when a user wants to send a problem with location files attached."),
            appVersion,
            osVersion,
            iso8601Date
        )
        mailController.setMessageBody(mailText, isHTML: false)

        // Attach error log
        if let logFile = errorLogData() {
            mailController.addAttachmentData(logFile, mimeType: "text/plain", fileName: "debug.log")
        }
        
        // Style the mail composer a bit
        mailController.navigationBar.tintColor = UIColor.black
        
        // Set delegate
        mailController.mailComposeDelegate = delegate
        
        return mailController
    }

    // MARK: - Log file
    private static func errorLogData() -> Data? {
        
        // Get the file logger
        guard let fileLogger = DDLog.allLoggers.last(where: { $0 is DDFileLogger }) as? DDFileLogger else { return nil }
        
        return fileLogger.logFileManager.sortedLogFilePaths
            .compactMap { logFilePath in
                let fileUrl = URL(fileURLWithPath: logFilePath)
                return try? Data(contentsOf: fileUrl)
            }
            .reversed() // Need to revers as we want to work our way backwards through to sort it correctly
            .reduce(into: Data()) { (allLogData, logData) in
                allLogData.append(logData)
        }
    }
    
    static func lastErrorLogData() -> String? {
        
        // Get the file logger
        guard let fileLogger = DDLog.allLoggers.last(where: { $0 is DDFileLogger }) as? DDFileLogger else { return nil }
        
        if let logFilePath = fileLogger.logFileManager.sortedLogFilePaths.first {
            let fileUrl = URL(fileURLWithPath: logFilePath)
            if let data = try? Data(contentsOf: fileUrl) {
                return String(data: data, encoding: String.Encoding.utf8)
            }
        }
        
        return nil
    }
}
