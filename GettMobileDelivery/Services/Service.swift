//
//  Service.swift
//  GettMobileDelivery
//
//  Created by Roi Kedarya on 17/07/2021.
//

import Foundation
import CoreLocation

enum ServiceError: Error {
    case badResponse
    case parsingFailed
    case invalidUrl
    case fileNotFound
}



class Service {
    static let shared = Service()
    private var url: URL?
    
    private init () {
        if let urlPathString = Bundle.main.path(forResource: "journey", ofType: "json") {
            url = URL(fileURLWithPath: urlPathString)
        } else {
            // the file could not be located
            
        }

    }
    
    func getDirections(completion: @escaping ([Destination]?, URLResponse?, Error?) -> ()) {
        guard let url = url else {
            // the file could not be located
            completion(nil,nil,ServiceError.fileNotFound)
            fatalError("file not found")
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print(error.localizedDescription)
                completion(nil,nil,error)
                return
            }
            guard response != nil else {
                completion(nil, nil, ServiceError.badResponse)
                return
            }
            if let data = data {
                //parsing the data
                if let destinations =  try? JSONDecoder().decode([Destination].self, from: data) {
                    completion(destinations,response,nil)
                }
            }
        }.resume()
    }
    
    func fetchRoute(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D, completion: @escaping (String?,Error?) ->()) {
        
        var routeUrlComponents = ResourceHelper.basicRouteUrlComponents
        let sourceQueryItem = URLQueryItem(name: "origin", value: "\(source.latitude),\(source.longitude)")
        let destinationQueryItem = URLQueryItem(name: "destination", value: "\(destination.latitude),\(destination.longitude)")
        routeUrlComponents.queryItems!.append(sourceQueryItem)
        routeUrlComponents.queryItems!.append(destinationQueryItem)

        guard let url = routeUrlComponents.url else {
            completion(nil, ServiceError.invalidUrl)
            return
        }
        let task = URLSession.shared.dataTask(with: url, completionHandler: {
            (data, response, error) in
            
            guard error == nil else {
                completion(nil,error)
                return
            }

            guard let jsonResponse = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any]
            else {
                completion(nil,ServiceError.parsingFailed)
                return
            }
            guard jsonResponse["status"] as! String != "REQUEST_DENIED" else {
                completion(nil,ServiceError.badResponse)
                return
            }
            guard let routes = jsonResponse["routes"] as? [Any], routes.count > 0,
                  let route = routes[0] as? [String: Any],
                  let overview_polyline = route["overview_polyline"] as? [String: Any],
                  let polyLineString = overview_polyline["points"] as? String else {
                return
            }
            completion(polyLineString, nil)
            return
        })
        task.resume()
    }
}

