//
//  ResourceHelper.swift
//  GettMobileDelivery
//
//  Created by Roi Kedarya on 17/07/2021.
//

import Foundation
import UIKit

class ResourceHelper {
    static let pickupType = "pickup"
    static  let dropType = "drop_off"
    static let storyboard = UIStoryboard(name: "Main", bundle:nil)
    
    static var basicRouteUrlComponents: URLComponents = {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "maps.googleapis.com"
        urlComponents.path = "/maps/api/directions/json"
        urlComponents.queryItems = [
                URLQueryItem(name: "sensor", value: "false"),
                URLQueryItem(name: "key", value: ResourceHelper.apiKey),
                URLQueryItem(name: "mode", value: "driving"),
                URLQueryItem(name: "language", value: "EN")
            ]
        return urlComponents
    }()
    
    private static var apiKey: String = {
        guard let filePath = Bundle.main.path(forResource: "GoogleServices-Info", ofType: "plist") else {
          fatalError("Couldn't find file 'GoogleServices-Info.plist'.")
        }
        let plist = NSDictionary(contentsOfFile: filePath)
        guard let value = plist?.object(forKey: "API_KEY") as? String else {
          fatalError("Couldn't find key 'API_KEY' in 'GoogleServices-Info.plist'.")
        }
        if value == "<API KEY>" {
            fatalError("Insert API Key in GoogleServices-Info.plist")
        }
        return value
    }()
    
}
