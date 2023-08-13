//
//  GoveeDevice.swift
//
//
//  Created by Hallie on 8/12/23.
//

import SwiftUI

public class GoveeDevice: Codable {
    let controllable: Bool
    let mac: String
    let model: String
    let retrievable: Bool
    let name: String
    let supportedCommands: [String]
    
    let colorTempRangeLow: Int
    let colorTempRangeHigh: Int
    
    public var online: Bool = false
    public var brightness: Int = 0
    public var colorTemp: Int? = nil
    public var color: [String: Int]? = nil
    
    init(data: [String: Any]) {
        if let dprops = data["properties"] as? [String: Any], let dColorTemp = dprops["colorTem"] as? [String : Any], let dRange = dColorTemp["range"] as? [String : Int] {
            self.colorTempRangeLow = dRange["min"] ?? 0
            self.colorTempRangeHigh = dRange["max"] ?? 0
        } else {
            self.colorTempRangeLow = 0
            self.colorTempRangeHigh = 0
        }
        
        if let dDeviceName = data["deviceName"] as? String {
            self.name = dDeviceName
        } else {
            self.name = "Device"
        }
        
        self.retrievable = data["retrievable"] as? Bool ?? false
        
        self.controllable = data["controllable"] as? Bool ?? false
        
        self.mac = data["device"] as? String ?? ""
        
        if let commands = data["supportCmds"] as? [String] {
            self.supportedCommands = commands
        } else {
            self.supportedCommands = []
        }
        
        self.model = data["model"] as? String ?? ""
    }
}
