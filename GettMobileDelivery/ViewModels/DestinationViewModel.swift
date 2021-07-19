//
//  DestinationViewModel.swift
//  GettMobileDelivery
//
//  Created by Roi Kedarya on 17/07/2021.
//

import Foundation
import CoreLocation


struct DestinationViewModel {
    
    var destinations:[Destination]?
    
    init(_ destinations: [Destination]?) {
        let filterd = destinations?.filter {
            ($0.type == ResourceHelper.pickupType || $0.type == ResourceHelper.dropType)
        }
        self.destinations = filterd
    }
    
    func getDestinationGeo(_ destination: Destination) -> CLLocation {
        return CLLocation(latitude: destination.geo.latitue, longitude: destination.geo.longitude)
    }
    
    func getDestinationAddress(_ destination: Destination) -> String {
        return destination.geo.address
    }
    
    func getDestinationType(_ destination: Destination) -> String {
        return destination.type
    }
    
    func getDestination(at index: Int) -> Destination? {
        if let destinations = destinations {
            return  destinations[index]
        } else {
            return nil
        }
    }
    
    func getParcelsForType(_ type: String) -> [Parcel]? {
        if let destination = destinations?.first(where: { $0.type == type }) {
            return destination.parcels
        } else {
            return nil
        }
    }
    
    func isEmpty() -> Bool {
        if let destinations = self.destinations {
            return destinations.isEmpty
        } else {
            return true
        }
    }
    
    // navigation is done when there are less two points to navigate to
    func isNavigationCompleted() -> Bool {
        var retVal = false
        if let destinations = self.destinations , destinations.count < 2 {
            retVal = true
        }
        return retVal
    }
    
    // get the next destination and remove from the array
    mutating func popNextDestination() -> Destination? {
        if self.destinations != nil, self.destinations!.count > 0 {
            self.destinations!.remove(at: 0)
            if self.destinations!.count > 0 {
                return self.destinations?[0]
            }
        }
        return nil
    }
    
}
