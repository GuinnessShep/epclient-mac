//
//  main.swift
//  vpn-tunnel
//
//  Created by Amit on 08/11/22.
//

import Foundation
import NetworkExtension
import os.log
//let mylog = OSLog(subsystem: "com.skyhighsecurity.systemextension.app", category: "app")

autoreleasepool {
    os_log("Creating tunnel...: main called for system extension")
    NEProvider.startSystemExtensionMode()
}

dispatchMain()
