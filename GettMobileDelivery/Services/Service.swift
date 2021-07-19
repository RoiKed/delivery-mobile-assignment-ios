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
                }else {
                    completion(nil,response,ServiceError.parsingFailed)
                }
            }
        }.resume()
    }
    
    func fetchRoute(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D, completion: @escaping (Direction?,Error?) ->()) {
        
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

            if let directions = try? JSONDecoder().decode(Direction.self, from: data!) {
                completion(directions,nil)
            } else {
                completion(nil,ServiceError.parsingFailed)
            }
            return
        })
        task.resume()
    }
    
    func getDirections(origin:Double, destination:Double, completion:([Direction])) {
        
    }
}

