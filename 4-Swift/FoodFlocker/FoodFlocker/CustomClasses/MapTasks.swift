//
//  MapTasks.swift
//

import Foundation
import UIKit

class MapTasks: NSObject {
   
    let baseURLGeocode = "https://maps.googleapis.com/maps/api/geocode/json?"
    
    var lookupAddressResults: Dictionary<String, AnyObject>!
    
    var fetchedFormattedAddress: String!
    
    var fetchedAddressLongitude: Double!
    
    var fetchedAddressLatitude: Double!
    
    let baseURLDirections = "https://maps.googleapis.com/maps/api/directions/json?"
    
    var selectedRoute: Dictionary<String, AnyObject>!
    
    var overviewPolyline: Dictionary<String, AnyObject>!
//
//    var originCoordinate: CLLocationCoordinate2D!
//
//    var destinationCoordinate: CLLocationCoordinate2D!
    
    var originAddress: String!
    
    var destinationAddress: String!
    
    var totalDistanceInMeters: UInt = 0
    
    var totalDistance: String!
    
    var totalDurationInSeconds: UInt = 0
    
    var totalDuration: String!
    
    override init() {
        super.init()
    }

    func geocodeAddress(_ address: String!, withCompletionHandler completionHandler: @escaping ((_ status: String, _ success: Bool) -> Void)) {
        if let lookupAddress = address {
//            \(AppInfo.GOOGLE_MAP_API_KEY.returnAppInfo())
            var geocodeURLString = baseURLGeocode + "key=\(AppInfo.GOOGLE_MAP_API_KEY.returnAppInfo())" + "&address=" + lookupAddress
            geocodeURLString = geocodeURLString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            let geocodeURL = URL(string: geocodeURLString)
            let geocodingResultsData = try? Data(contentsOf: geocodeURL!)
            if geocodingResultsData != nil {
                do {
                    let dictionary: Dictionary<String, AnyObject> = try JSONSerialization.jsonObject(with: geocodingResultsData!, options: JSONSerialization.ReadingOptions.mutableContainers) as! Dictionary<String, AnyObject>
                    
                    // Get the response status.
                    let status = dictionary["status"] as! String
                    
                    if status == "OK" {
                        let allResults = dictionary["results"] as! Array<Dictionary<String, AnyObject>>
                        self.lookupAddressResults = allResults[0] as Dictionary<String, AnyObject>?
                        
                        // Keep the most important values.
                        self.fetchedFormattedAddress = self.lookupAddressResults["formatted_address"] as? String
                        let geometry = self.lookupAddressResults["geometry"] as! Dictionary<String, AnyObject>
                        self.fetchedAddressLongitude = ((geometry["location"] as! Dictionary<String, AnyObject>)["lng"] as! NSNumber).doubleValue
                        self.fetchedAddressLatitude = ((geometry["location"] as! Dictionary<String, AnyObject>)["lat"] as! NSNumber).doubleValue
                        
                        completionHandler(status, true)
                    }
                    else {
                        completionHandler(status, false)
                    }
                }catch let error as NSError {
                    print("\(error)")
                }
            }else {
                completionHandler("No valid address.", false)
            }
        }
        else {
            completionHandler("No valid address.", false)
        }
    }
    
//    func getDirections(_ origin: String!, destination: String!, waypoints: Array<String>!, travelMode: TravelModes!, completionHandler: @escaping ((_ status: String, _ success: Bool) -> Void)) {
//        
//        if let originLocation = origin {
//            if let destinationLocation = destination {
//                var directionsURLString = baseURLDirections + "origin=" + originLocation + "&destination=" + destinationLocation
//                
//                if let routeWaypoints = waypoints {
//                    directionsURLString += "&waypoints=optimize:true"
//                    
//                    for waypoint in routeWaypoints {
//                        directionsURLString += "|" + waypoint
//                    }
//                }
//                
//                if (travelMode) != nil {
//                    var travelModeString = ""
//                    
//                    switch travelMode.rawValue {
//                    case TravelModes.walking.rawValue:
//                        travelModeString = "walking"
//                        
//                    case TravelModes.bicycling.rawValue:
//                        travelModeString = "bicycling"
//                        
//                    default:
//                        travelModeString = "driving"
//                    }
//                    directionsURLString += "&mode=" + travelModeString
//                }
//                
//                
//                 directionsURLString = directionsURLString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
//                
//                let directionsURL = URL(string: directionsURLString)
//                
//                DispatchQueue.main.async {
//                    let directionsData = try? Data(contentsOf: directionsURL!)
//                    
//                    do {
//                     
//                        let dictionary = try JSONSerialization.jsonObject(with: directionsData! as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as? Dictionary<String, AnyObject>
//
//                        
//                        let status = dictionary?["status"] as! String
//                        
//                        if status == "OK" {
//                            self.selectedRoute = (dictionary?["routes"] as! Array<Dictionary<String, AnyObject>>)[0]
//                            self.overviewPolyline = self.selectedRoute["overview_polyline"] as! Dictionary<String, AnyObject>
//                            
//                            let legs = self.selectedRoute["legs"] as! Array<Dictionary<String, AnyObject>>
//                            
//                            let startLocationDictionary = legs[0]["start_location"] as! Dictionary<String, AnyObject>
//                            self.originCoordinate = CLLocationCoordinate2DMake(startLocationDictionary["lat"] as! Double, startLocationDictionary["lng"] as! Double)
//                            
//                            let endLocationDictionary = legs[legs.count - 1]["end_location"] as! Dictionary<String, AnyObject>
//                            self.destinationCoordinate = CLLocationCoordinate2DMake(endLocationDictionary["lat"] as! Double, endLocationDictionary["lng"] as! Double)
//                            
//                            self.originAddress = legs[0]["start_address"] as! String
//                            self.destinationAddress = legs[legs.count - 1]["end_address"] as! String
//                            self.calculateTotalDistanceAndDuration()
//                            
//                            completionHandler(status, true)
//                        }
//                        else {
//                            completionHandler(status, false)
//                        }
//
//                        // do your works
//                    } catch {
//                        print("Got error: \(error)")
//                    }
//                        
//                    }
//            }
//            else {
//                completionHandler("Destination is nil.", false)
//            }
//        }
//        else {
//            completionHandler("Origin is nil", false)
//        }
//    }
    
    func calculateTotalDistanceAndDuration() {
        let legs = self.selectedRoute["legs"] as! Array<Dictionary<String, AnyObject>>
        
        totalDistanceInMeters = 0
        totalDurationInSeconds = 0
        
        for leg in legs {
            totalDistanceInMeters += (leg["distance"] as! Dictionary<String, AnyObject>)["value"] as! UInt
            totalDurationInSeconds += (leg["duration"] as! Dictionary<String, AnyObject>)["value"] as! UInt
        }
        
        
        let distanceInKilometers: Double = Double(totalDistanceInMeters / 1000)
        totalDistance = "Total Distance: \(distanceInKilometers) Km"
        
        
        let mins = totalDurationInSeconds / 60
        let hours = mins / 60
        let days = hours / 24
        let remainingHours = hours % 24
        let remainingMins = mins % 60
        let remainingSecs = totalDurationInSeconds % 60
        
        totalDuration = "Duration: \(days) d, \(remainingHours) h, \(remainingMins) mins, \(remainingSecs) secs"
    }
    
    
}
