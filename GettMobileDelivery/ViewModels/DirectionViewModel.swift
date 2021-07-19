//
//  DirectionViewModel.swift
//  GettMobileDelivery
//
//  Created by Roi Kedarya on 19/07/2021.
//

import Foundation

struct DirectionViewModel {
    var direction: Direction
    lazy var instructions: [String] = {
        return getInstructions()
    }()
    
    init(direction: Direction) {
        self.direction = direction
    }
    
    func getRoutes() -> [Route]? {
        let routes = direction.routes
        if routes.count > 0 {
            return routes
        }
        return nil
    }
    
    func getRoute(for index: Int) -> Route? {
        if let routes = getRoutes(), routes.count > index {
            return routes[index]
        }
        return nil
    }
    
    func getFirstRoute() -> Route? {
        return getRoute(for: 0)
    }
    
    func getPolyline() -> String? {
        if direction.routes.count > 0,
           let route = self.getFirstRoute() {
            let overviewPolyline = route.overview_polyline.points
            return overviewPolyline
        }
        return nil
        
    }
    
    private func getStepsForRoute(at index: Int) -> [Step] {
        var steps = [Step]()
        if let legs = getRoute(for: index)?.legs {
            for leg in legs {
                if let legSteps = leg.steps {
                    steps.append(contentsOf: legSteps)
                }
            }
        }
        return steps
    }
    
    private func getDirectionsForRoute(at index: Int) -> [String] {
        var instructions = [String]()
        let steps = getStepsForRoute(at: index)
        for step in steps {
            if let stepInstructions = step.html_instructions {
                instructions.append(stepInstructions)
            }
        }
        return instructions
    }
    
    private func getInstructions() -> [String] {
        var instructions = [String]()
        for index in 0 ..< getRoutes()!.count {
            let routeInstructions = htmlStringToString(getDirectionsForRoute(at: index))
            instructions.append(contentsOf: routeInstructions)
        }
        return instructions
    }
    
    private func htmlStringToString(_ htmls: [String]) -> [String] {
        var retVal = [String]()
        for html in htmls {
            let data = Data(html.utf8)
            let options: [NSAttributedString.DocumentReadingOptionKey : Any] = [.documentType: NSAttributedString.DocumentType.html]
            if let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) {
                let string = String(attributedString.string.filter {
                    !"\n".contains($0)
                })
                retVal.append(string)
            } else {
                retVal.append(html)
            }
        }
        return retVal
    }
}
