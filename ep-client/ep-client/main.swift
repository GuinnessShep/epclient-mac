//
//  main.swift
//  ep-client
//
//  Created by vkumar4 on 07/11/22.
//


import Foundation
import os.log

let mylog = OSLog(subsystem: "com.skyhighsecurity.systemextension.app", category: "config")
let service: ViewController

print ("Hello World!!!")



if (CommandLine.argc <= 1)
{
    os_log(.default, log: mylog, "ep-client-cli app: no command recieved");
    print ("ep-client-cli app: no command recieved")
    //exit(0);
}

if (CommandLine.arguments[1].isEqual("Enable-PacketTunnel"))
{
    os_log(.default, log: mylog, "ep-client-cli app: request recieved for enable Packet Tunnel Provider");
//    service.setTunnelStatus(true)
//    service.startVPNService()
}
else if (CommandLine.arguments[1].isEqual("Disable-PacketTunnel"))
{
    os_log(.default, log: mylog, "ep-client-cli app: request recieved for diable Packet Tunnel Provider");
    //service.setTunnelStatus(false)
}
else if (CommandLine.arguments[1].isEqual("uninstall"))
{
    os_log(.default, log: mylog, "McAfeeSystemExtension app:: CMD: UNINSTALL\n");
    DispatchQueue.global(qos: .default).async {
        //let result = appProxyExtController.uninstallSystemExtension(with: CommandLine.arguments[2]) == true ? 0 : -1;
        //exit(Int32(result));
        //service.removeProfile()
        exit(0)
    }
}
else
{
    DispatchQueue.global(qos: .background).async {
        if (CommandLine.arguments[1].isEqual("INSTALL"))
        {
            os_log(.default, log: mylog, "ep-client-cli app: CMD: INSTALL\n");
            
            DispatchQueue.global(qos: .default).async {
                let service = ViewController()
                os_log(.default, log: mylog, "McAfeeSystemExtension app:: Installing System extension")
                service.installSystemExtension()
                service.loadManager()
                
                //service.setTunnelStatus(true)
                //service.startVPNService()
                /*service.installProfile { result in
                 isLoading = false
                 switch result {
                 case .success:
                 break // Do nothing, router will show what's next
                 case let .failure(error):
                 let errorMessage = error.localizedDescription
                 os_log(.default, log: log, "ep-client-cli app: VPN failed to install: %{public}@", errorMessage)
                 }
                 }*/
            }
            
            sleep(500)
            os_log(.default, log: mylog, "McAfeeSystemExtension app:: Exiting INSTALLATION with exit")
            exit(0);
        }
        else
        {
            os_log(.default, log: mylog, "McAfeeSystemExtension app:: Unknown Arguements in Install command")
            print("Unknown Arguements")

        }
    }
}

dispatchMain()
