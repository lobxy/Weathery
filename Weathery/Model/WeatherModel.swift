//
//  WeatherModel.swift
//  Weathery
//
//  Created by Sam Sherman on 05/04/19.
//  Copyright © 2019 lobxy. All rights reserved.
//

import Foundation

class WeatherModel {
    
    var temperature : Double = 0
    var condition : Int = 0
    var city : String = ""
    var iconName : String = ""
    var humidity: Double = 0
    var windSpeed : Double = 0
    var tempMin: Double = 0
    var tempMax: Double = 0
 
    func updateWeatherIcon(condition: Int) -> String{
        switch condition {
        case 0...300:
            return "tstorm1"
        case 301...500:
            return "light_rain"
        case 501...600:
            return "shower3"
        case 601...700:
            return "snow4"
        case 701...771:
            return "fog"
        case 772...800:
            return "tstorm3"
        case 801...804:
                return "cloudy2"
        case 900...903, 905...1000:
            return "tstorm3"
        case 903:
            return "snow5"
        case 904:
            return "sunny"
        default:
            return "shit"
        }
    }
    
}
