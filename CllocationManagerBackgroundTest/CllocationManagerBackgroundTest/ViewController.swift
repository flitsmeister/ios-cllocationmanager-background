//
//  ViewController.swift
//  CllocationManagerBackgroundTest
//
//  Created by Sjoerd Perfors on 12/10/2018.
//  Copyright © 2018 Flitsmeister. All rights reserved.
//

import UIKit
import MessageUI
import CocoaLumberjackSwift

class ViewController: UIViewController {


    @IBOutlet weak var logView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DDLogInfo("[ViewController] - [START]")
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.viewWillEnterForeGround), name: UIApplication.willEnterForegroundNotification, object: nil)

        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.btnRefreshPressed(nil)
    }
    
    @IBAction func btnClearLogPressed(_ sender: Any) {
        
        if let logger = DDLog.allLoggers.last {
            DDLog.remove(logger)
        }
        
        if let fileLogger = DDFileLogger.init() {
            fileLogger.rollingFrequency = 60 * 60 * 24 // 24 hour rolling, new file every day
            fileLogger.logFileManager.maximumNumberOfLogFiles = 10; // between 1 and 10 days of logs.
            fileLogger.maximumFileSize = 1024 * 4096; // 4MB so, max 40MB log file
            
            DDLog.add(fileLogger, with: .info)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.btnRefreshPressed(nil)
        }
    }
    
    @IBAction func btnRefreshPressed(_ sender: Any?) {
        logView.text = nil
        if let data = DiagnoseMailHelper.lastErrorLogData() {
            logView.text = data
            logView.scrollRangeToVisible(NSMakeRange(logView.text.count - 1, 1))
        }
    }
    @objc func viewWillEnterForeGround() {
        self.btnRefreshPressed(nil)
    }

    @IBAction func btnSendLogsPresesd(_ sender: Any) {
        let vc = DiagnoseMailHelper.diagnoseMailVC(delegate: self)
        
        self.present(vc, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        DDLogInfo("[VIEWCONTROLLER] [didReceiveMemoryWarning]")
    }
    
}

extension ViewController : MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

