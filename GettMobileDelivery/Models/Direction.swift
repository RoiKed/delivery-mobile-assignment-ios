//
//  Direction.swift
//  GettMobileDelivery
//
//  Created by Roi Kedarya on 19/07/2021.
//

import Foundation

struct Direction: Decodable {
    let routes: [Route]
    let status: String
}

struct Route: Decodable {
    let legs: [Leg]?
    let overview_polyline: overviewPolyline
}

struct Leg: Decodable {
    let steps: [Step]?
}

struct overviewPolyline: Decodable {
    let points: String
}

struct Step: Decodable {
    let html_instructions: String?
    let polyline: polyline
    let distance: Distance
    let duration: Duration
}

struct polyline: Decodable {
    let points: String
}

struct Distance: Decodable {
    let text: String
    let duration: Int?
}

struct Duration: Decodable {
    let text: String
    let duration: Int?
}

