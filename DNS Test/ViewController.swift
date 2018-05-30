//
//  ViewController.swift
//  DNS Test
//
//  Created by Ricardo on 30/05/2018.
//  Copyright © 2018 Ricardo. All rights reserved.
//

import UIKit
import NetworkExtension

class ViewController: UIViewController {
    
    @IBOutlet weak var filterSwitch: UISwitch!
    let manager = NEVPNManager.shared()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.filterSwitch.isEnabled = false

        self.manager.loadFromPreferences { [unowned self] error in
            
            if let error = error {
                print("vpn error in loading preferences : \(error)")
                
            } else {
                self.filterSwitch.isEnabled = true
                self.filterSwitch.isOn = true
                self.activateConfiguration()
            }
        }
    }
    
    @IBAction func onSwitchValueChanged(_ sender: UISwitch) {
        if sender.isOn {
            self.activateConfiguration()
        } else {
            self.deactivateConfguration()
        }
    }
    
    private func activateConfiguration() {
        
        //if self.manager.protocolConfiguration == nil {
        let myIPSec = NEVPNProtocolIPSec()
        myIPSec.username = "username"
        myIPSec.serverAddress = "NO NEED TO CONNECT"
        myIPSec.authenticationMethod = NEVPNIKEAuthenticationMethod.sharedSecret
        myIPSec.useExtendedAuthentication = true
        self.manager.protocolConfiguration = myIPSec
        
        let evaluationRule = NEEvaluateConnectionRule(matchDomains: ["*.com"], andAction: NEEvaluateConnectionRuleAction.connectIfNeeded)
        evaluationRule.useDNSServers = ["208.67.220.123"] // OpenDNS that filters adult content
        let onDemandRule = NEOnDemandRuleEvaluateConnection()
        onDemandRule.connectionRules = [evaluationRule]
        onDemandRule.interfaceTypeMatch = NEOnDemandRuleInterfaceType.any
        self.manager.onDemandRules = [onDemandRule]
        
        self.manager.localizedDescription = "Filter activated"
        self.manager.isOnDemandEnabled = true
        self.manager.isEnabled = true
        
        self.manager.saveToPreferences { error in
            if let error = error {
                print("vpn error in saving preferences : \(error)")
            }
        }
        //}
    }
    
    private func deactivateConfguration() {
        
        let myIPSec = NEVPNProtocolIPSec()
        myIPSec.username = "username"
        myIPSec.serverAddress = "NO NEED TO CONNECT"
        myIPSec.authenticationMethod = NEVPNIKEAuthenticationMethod.sharedSecret
        myIPSec.useExtendedAuthentication = true
        self.manager.protocolConfiguration = myIPSec

        self.manager.localizedDescription = "Filter deactivated"
        self.manager.onDemandRules = nil
        self.manager.isOnDemandEnabled = false
        self.manager.isEnabled = false
        
        self.manager.saveToPreferences { error in
            if let error = error {
                print("vpn error in saving preferences : \(error)")
            }
        }
    }
    
}
