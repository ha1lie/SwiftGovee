//
//  API.swift
//  
//
//  Created by Hallie on 8/12/23.
//

import Foundation
import CryptoKit

public let GOVEE_API_HOST = "https://developer-api.govee.com/v1"
public let GOVEE_API_KEY = goveeAPIKey

public class GoveeAPI {
    
    private static func makeRequest(withHeaders: [String: String]? = nil, toRoute route: String) async throws -> [String : Any]? {
        guard let requestURL = URL(string: GOVEE_API_HOST + route) else { throw GoveeError.noURLAvailable }
        
        print("Request to: \(requestURL.absoluteString)")
        
        var req = URLRequest(url: requestURL)
        req.httpMethod = "GET"
        req.allHTTPHeaderFields = [
            "Govee-API-Key": GOVEE_API_KEY
        ]
        
        let (data, response) = try await URLSession.shared.data(for: req)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw GoveeError.apiProblem }
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw GoveeError.noData("Request to \(route) returned unreadable or no data")
        }
        
        return json
    }
    
    public static func getDevices() async -> [GoveeDevice] {
        do {
            
            guard let json = try await GoveeAPI.makeRequest(toRoute: "/devices") else {
                print("Failed to parse updated device information")
                return []
            }
            
            var newDevices: [GoveeDevice] = []
            
            if let jsonData = json["data"] as? [String: Any] {
                if let jsonDataDevices = jsonData["devices"] as? [[String: Any]] {
                    for device in jsonDataDevices {
                        newDevices.append(GoveeDevice(data: device))
                    }
                }
            }
            
            return newDevices
            
        } catch {
            print("Encountered issue while getting an updated device list")
            print(error)
        }
        
        return []
    }
    
    public static func updateStatus(forDevice device: inout GoveeDevice) async {
        do {
            guard let json = try await GoveeAPI.makeRequest(toRoute: "/devices/state?device=\(device.mac)&model=\(device.model)") else {
                print("Unable to make a status request for this device")
                return
            }
            
            guard let data = json["data"] as? [String : Any] else {
                print("Unable to process data from device update request")
                return
            }
            
            guard let properties = data["properties"] as? [[String : Any]] else {
                print("Unable to process properties from device update request")
                return
            }
            
            for prop in properties {
                if let online = prop["powerState"] as? String {
                    device.online = online == "on"
                } else if let brightness = prop["brightness"] as? Int {
                    device.brightness = brightness
                } else if let colorTemp = prop["colorTemInKelvin"] as? Int {
                    device.colorTemp = colorTemp
                } else if let color = prop["color"] as? [String : Int] {
                    device.color = color
                }
            }
        } catch {
            print("Error while updating device status!")
        }
    }
}

public enum GoveeError: Error {
    case noURLAvailable
    case apiProblem
    case noData(String)
}

public class Govee {
    
    public static let Home: Govee = Govee()
    
    public var devices: [GoveeDevice] = []
    
    private init() {
        do {
            try self.updateDeviceList()
        } catch {
            print("Encountered error while attempting to update device list")
        }
    }
    
    public func updateDeviceList() throws {
        Task { //TODO: Move this to a background thread
            self.devices = await GoveeAPI.getDevices()
            
            for i in 0..<self.devices.count {
                await GoveeAPI.updateStatus(forDevice: &self.devices[i])
            }
            
            for device in self.devices {
                if device.online {
                    print("\(device.name) is on!")
                }
            }
        }
    }
}
