//
//  API.swift
//  
//
//  Created by Hallie on 8/12/23.
//

import Foundation

public let GOVEE_API_PROTOCOL = "https"
public let GOVEE_API_HOST = "app.govee.com"
public let APP_VERSION = "3.2.1"
public let GOVEE_CLIENT_TYPE = "0"
public let GOVEE_API_KEY = goveeAPIKey
public let GOVEE_MQTT__PROTOCOL_NAME = "x-amzn-mqtt-ca"
public let GOVEE_MQTT_BROKER_HOST = "aqm3wd1qlc3dy-ats.iot.us-east-1.amazonaws.com"
public let GOVEE_MQTT_BROKER_PORT = 8883

class GoveeException: Error {
    
}

class Govee {
    
    public let Home: Govee = Govee(email: goveeEmail, password: goveePassword)
    
    private init(email: String, password: String, clientID: String? = nil) {
        
    }
}
