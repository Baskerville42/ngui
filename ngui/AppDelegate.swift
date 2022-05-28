//
//  AppDelegate.swift
//  ngui
//
//  Created by Alexander Tartmin on 27.05.2022.
//

import Cocoa
import Foundation

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var statusBarItem: NSStatusItem!
    let process = Process()
    let menu = NSMenu()
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        updateAll()
        
        Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(updateAll), userInfo: nil, repeats: true)
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    @objc func updateAll() {
        currentVersion()
        buildMenuItems()
    }
    
    @objc func runNCommand(_ sender: NSMenuItem) {
        shell(launchPath: "/usr/local/bin/n", arguments: [sender.title]);
        currentVersion()
    }
    
    @objc func installLatestVersion(_ sender: NSMenuItem) {
        let script = """
            do shell script \"sudo /usr/local/bin/n latest" with administrator privileges
        """
        
        var error: NSDictionary?
        
        let scriptObject = NSAppleScript(source: script)!
        scriptObject.executeAndReturnError(&error)
        
        currentVersion()
    }
    
    @objc func installLTSVersion(_ sender: NSMenuItem) {
        let script = """
            do shell script \"sudo /usr/local/bin/n lts" with administrator privileges
        """
        
        var error: NSDictionary?
        
        let scriptObject = NSAppleScript(source: script)!
        scriptObject.executeAndReturnError(&error)
        
        currentVersion()
    }
    
    func buildMenuItems() {
        menu.removeAllItems()
        
        let versionsListString: String = shell(launchPath: "/usr/local/bin/n", arguments: ["list"])
        let versionsList = versionsListString.split(whereSeparator: \.isNewline);
        
        menu.addItem(withTitle: "Install Latest", action: #selector(installLatestVersion(_:)), keyEquivalent: "")
        menu.addItem(withTitle: "Install LTS", action: #selector(installLTSVersion(_:)), keyEquivalent: "")
        
        menu.addItem(.separator())
        
        for item in versionsList {
            menu.addItem(withTitle: String(item), action: #selector(runNCommand(_:)), keyEquivalent: "")
        }
        
        menu.addItem(.separator())
        
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApp.terminate(_:)), keyEquivalent: "q"))
        
        statusBarItem.menu = menu
    }
    
    func showError(messageText message: String) {
        let alert: NSAlert = NSAlert()
        alert.messageText = message
        alert.addButton(withTitle: "OK")
        alert.alertStyle = .critical
        alert.runModal()
    }
    
    func findAndCloseApp() {
        for runningApplication in NSWorkspace.shared.runningApplications {
            let appName = runningApplication.localizedName
            if appName == "ngui" {
                runningApplication.terminate()
            }
        }
    }
    
    @objc func currentVersion() {
        let nPathAvailable = FileManager.default.fileExists(atPath: "/usr/local/bin/n")
        let nodePathAvailable = FileManager.default.fileExists(atPath: "/usr/local/bin/node")
        
        if nodePathAvailable == false {
            showError(messageText: "Can't found Node.js installed")
            findAndCloseApp()
        }
        
        if  nPathAvailable == false {
            showError(messageText: "Can't found package \"n\" installed")
            findAndCloseApp()
        }
        
        if (self.statusBarItem == nil) {
            self.statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))
        }
        
        if let button = self.statusBarItem.button {
            let version = shell(launchPath: "/usr/local/bin/node", arguments: ["-v"]);
            
            button.title = version.components(separatedBy: .whitespacesAndNewlines).joined()
        }
    }
}


@discardableResult
func shell(launchPath path: String, arguments args: [String]) -> String {
    let task = Process()
    let pipe = Pipe()
    
    task.standardOutput = pipe
    task.standardError = pipe
    task.arguments = args
    task.launchPath = path
    task.standardInput = nil
    task.launch()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)!
    
    return output
}
