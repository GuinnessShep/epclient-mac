//
//  PacketTunnelProvider.swift
//  vpn-tunnel
//
//  Created by vkumar4 on 07/11/22.
//

import NetworkExtension
import os.log

let log = OSLog(subsystem: "com.skyhighsecurity.systemextension.app", category: "app")

class PacketTunnelProvider: NEPacketTunnelProvider {

    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        // Add code here to start the process of connecting the tunnel.
        os_log("Creating tunnel...: Starting Tunnel: startTunnel")
        DispatchQueue.main.async {
            let settings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "10.213.175.202")
            // virtual interface utun interface address
            os_log("Creating tunnel...: startTunnel: hardcode virtual interface utun interface address: 10.10.10.10/32")
            settings.ipv4Settings = NEIPv4Settings(addresses: ["10.10.10.10"], subnetMasks: ["255.255.255.255"])
            
            // hardcode 20.20.20.0/24 route to tunnel
            var includedRoutes = [NEIPv4Route]()
            var excludedRoutes = [NEIPv4Route]()
            NSLog("Creating tunnel... includedRoutes: 20.20.20.0");
            includedRoutes.append(NEIPv4Route(destinationAddress: "20.20.20.0", subnetMask: "255.255.255.0"))
            excludedRoutes.append(NEIPv4Route(destinationAddress: "20.20.20.10", subnetMask: "255.255.255.255"))

            settings.ipv4Settings?.includedRoutes = includedRoutes
            settings.ipv4Settings?.excludedRoutes = excludedRoutes
            
            // No routes specified, set default route to the tunnel interface.
            //settings.ipv4Settings?.includedRoutes = [NEIPv4Route.default()]
            
            // let us hard code the dns for testing. A DNS request will be sent to these servers then tunneled to VPN server. use sudo killall -HUP mDNSResponder to clear DNS cache
            NSLog("Creating tunnel... let us hard code the dns for testing. ");
            settings.dnsSettings = NEDNSSettings(servers: ["8.8.8.8", "1.1.1.1"])
            //Note: settings.dnsSettings: This thing is notb working. I am note sure of the purpose
            settings.dnsSettings?.searchDomains = ["test1", "test2.com", "test3.com", "ttest1.com"] //<== There is not affect of these settings in DNS requesds
            //Note: dnsSettings?.matchDomains: only these domain names request will be sent VPN server for servers in NEDNSSettings
            settings.dnsSettings?.matchDomains = ["test4.com", "test5.com", "test6.com", "test1.com"] // ""*.whatsapp.net""
            settings.dnsSettings?.matchDomainsNoSearch = true // Not impact seen on DNS configuration
            
            // Change utun mtu as needed
            settings.mtu = 1500
            
            
            // TODO: Configure DNS/split-tunnel/etc settings if needed
            /*
             Sample settings when printed:
             setup tunnel settings: {
                 tunnelRemoteAddress = 10.213.175.17
                 DNSSettings = {
                     protocol = cleartext
                     server = (
                         8.8.8.8,
                         1.1.1.1,
                     )
                     searchDomains = (
                         test1,
                         test2.com,
                         test3.com,
                         ttest1.com,
                     )
                     matchDomains = (
                         test4.com,
                         test5.com,
                         test6.com,
                         test1.com,
                     )
                     matchDomainsNoSearch = YES
                 }
                 IPv4Settings = {
                     configMethod = PPP
                     addresses = (
                         192.168.2.2,
                     )
                     subnetMasks = (
                         255.255.255.255,
                     )
                     includedRoutes = (
                         {
                             destinationAddress = 20.20.20.0
                             destinationSubnetMask = 255.255.255.0
                         },
                     )
                     excludedRoutes = (
                         {
                             destinationAddress = 20.20.20.10
                             destinationSubnetMask = 255.255.255.255
                         },
                     )
                     overridePrimary = NO
                 }
                 tunnelOverhead<…>, error: <decode: missing data>



             */
            
            self.setTunnelNetworkSettings(settings) { error in
                os_log("Creating tunnel...: Did setup tunnel settings: %{public}@, error: %{public}@", "\(settings)", "\(String(describing: error))")
                completionHandler(nil)
            }
        }
    }
    
    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        // Add code here to start the process of stopping the tunnel.
        os_log("Creating tunnel...: stopTunnel")
        completionHandler()
    }
    
    override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)?) {
        // Add code here to handle the message.
        os_log("Creating tunnel...: handleAppMessage")
        guard let messageString = NSString(data: messageData, encoding: String.Encoding.utf8.rawValue) else {
            completionHandler?(nil)
            return
        }

        os_log("Got a message from the app: %{public}s", messageString)

        let responseData = "Hello app".data(using: String.Encoding.utf8)
        completionHandler?(responseData)
    }
    
    override func sleep(completionHandler: @escaping () -> Void) {
        // Add code here to get ready to sleep.
        completionHandler()
    }
    
    override func wake() {
        // Add code here to wake up.
    }
}
