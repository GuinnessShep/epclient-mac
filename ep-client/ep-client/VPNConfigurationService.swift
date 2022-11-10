//
//  ViewController.swift
//  mac
//
//  Created by 孔祥波 on 05/01/2018.
//  Copyright © 2018 Apple Inc. All rights reserved.
//

import Cocoa
import os.log
import NetworkExtension
import SystemExtensions

let mylog2 = OSLog(subsystem: "com.skyhighsecurity.systemextension.app", category: "config")

class ViewController: NSViewController {

    var manager:NETunnelProviderManager?
    var status: String = "none"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadManager()
        // Do any additional setup after loading the view.
    }
    @IBAction func save(_ sender: Any) {
        guard self.manager != nil else {
            fatalError()
        }
        
    }
    
    func installSystemExtension() {
        NSLog("Creating tunnel...will submit activation request")
        let request = OSSystemExtensionRequest.activationRequest(
            forExtensionWithIdentifier: "com.skyhighsecurity.epclient.networkextension",
            queue: .main
        )
        request.delegate = self
        OSSystemExtensionManager.shared.submitRequest(request)
        self.status = "Installing…"
        NSLog("Creating tunnel...did submit activation request")
    }
    
    func loadManager(){
        NETunnelProviderManager.loadAllFromPreferences { (ms, e) in
            print("Print ms")
            print(ms as Any)
            print("Done printing ms")
            if let ms = ms{
                if ms.count != 0 {
                    for m in ms {
                        NSLog("Creating tunnel...using old tunnel");
                        self.manager = m
                    }
                }else {
                    NSLog("Creating tunnel... creating new tunnel");
                    self.create()
                }
            }
        }
        sleep(2)
        _ = try! startStopToggled("")
        XPC()
//        sleep(2)
//        _ = try! startStopToggled("")
//        sleep(2)
//        _ = try! startStopToggled("")
    }
     @IBAction func dail(_ sender: Any) {
        _ = try! startStopToggled("")
    }
    func create(){
        NSLog("Creating tunnel...");
        let config = NETunnelProviderProtocol()
        //config.providerConfiguration = ["App": bId,"PluginType":"com.yarshure.Surf"]

            config.providerBundleIdentifier = "com.skyhighsecurity.epclient.networkextension"

        //config.serverAddress = "192.168.0.1:8890"
        config.serverAddress = "10.213.175.202:8891"
        
        let manager = NETunnelProviderManager()
        manager.protocolConfiguration = config
       manager.localizedDescription = "Surfing"
        
        
        
        manager.saveToPreferences(completionHandler: { (error) -> Void in
            if error != nil {
                NSLog("Creating tunnel...: error in saveToPreferences");
                print(error?.localizedDescription as Any)
            }else {
                self.manager = manager
            }
            
        })
    
    }
    func startStopToggled(_ config:String) throws ->Bool{
        NSLog("Creating tunnel...startStopToggled");
        if let m = manager {
           
            if m.connection.status == .disconnected || m.connection.status == .invalid {
                do {
                    
                    if  m.isEnabled {
                        NSLog("Creating tunnel...startVPNTunnel");
                        try m.connection.startVPNTunnel(options: [:])

                    }else {
                        NSLog("Creating tunnel...not startVPNTunnel");

                    }
                }
                catch let error  {
                    throw error
                    //mylog("Failed to start the VPN: \(error)")
                    NSLog("Creating tunnel...error in startVPNTunnel");
                }
            }
            else {
                print("stoping!!!")
                NSLog("Creating tunnel...stopVPNTunnel");
                m.connection.stopVPNTunnel()
            }
        }else {
            
            return false
        }
        return true
    }
    func XPC() {
        // Send a simple IPC message to the provider, handle the response.
        //AxLogger.log("send Hello Provider")
        NSLog("Creating tunnel...XPC");
        if let m = manager {
            let me = "|Hello Provider"
            if let session = m.connection as? NETunnelProviderSession,
                let message = me.data(using: .utf8), m.connection.status != .invalid
            {
                do {
                    try session.sendProviderMessage(message) { response in
                        if let response = response  {
                            if let responseString = String.init(data:response , encoding: .utf8){
                                _ = responseString.components(separatedBy: ":")
                                
                                print("Received response from the provider: \(responseString)")
                            }
                            
                            //self.registerStatus()
                        } else {
                            print("Got a nil response from the provider")
                        }
                    }
                } catch {
                    print("Failed to send a message to the provider")
                }
            }
        }else {
            print("message dont init")
        }
        
    }
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}


extension ViewController: OSSystemExtensionRequestDelegate {
    
    func request(_ request: OSSystemExtensionRequest, actionForReplacingExtension existing: OSSystemExtensionProperties, withExtension replacement: OSSystemExtensionProperties) -> OSSystemExtensionRequest.ReplacementAction {
        // As this is a do-nothing extension, we always replace old versions
        // with new versions.
        os_log(.default, log: mylog2, "Creating tunnel...allowing replacement of %{public}@ with %{public}@", existing.bundleVersion, replacement.bundleVersion)
        return .replace
    }
    
    func requestNeedsUserApproval(_ request: OSSystemExtensionRequest) {
        os_log(.default, log: mylog2,"Creating tunnel...activation request needs user approval")
    }
    
    func request(_ request: OSSystemExtensionRequest, didFinishWithResult result: OSSystemExtensionRequest.Result) {
        switch result {
        case .completed:
            os_log(.default, log: mylog2,"Creating tunnel...activation request succeeded")
            self.status = "Install succeeded."
        case .willCompleteAfterReboot:
            os_log(.default, log: mylog2,"Creating tunnel...activation request succeeded, requires restart")
            self.status = "Install succeeded but requires restart."
        @unknown default:
            os_log(.default, log: mylog2,"Creating tunnel...activation request succeeded, weird result: %zd", result.rawValue)
            self.status = "Install succeeded (with weird result)."
        }
    }
    
    func request(_ request: OSSystemExtensionRequest, didFailWithError error: Error) {
        let nsError = error as NSError
        os_log(.default, log: mylog2,"Creating tunnel...activation request failed, error: %{public}@ / %zd", nsError.domain, nsError.code)
        self.status = "Install failed."
    }
}


