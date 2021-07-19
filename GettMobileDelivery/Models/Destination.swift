//
//  Destination.swift
//  GettMobileDelivery
//
//  Created by Roi Kedarya on 17/07/2021.
//

import Foundation

struct Destination: Decodable {
    let type: String
    let state: String
    let geo: Geo
    let parcels: [Parcel]?
}

struct Geo: Decodable {
    let address: String
    let latitue: Double
    let longitude: Double
    
}

struct Parcel: Decodable {
    let barcode: String
    let display_identifier: String
}


