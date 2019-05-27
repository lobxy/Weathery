//
//  ViewController.swift
//  Weathery
//
//  Created by Sam Sherman on 04/04/19.
//  Copyright © 2019 lobxy. All rights reserved.
//

import UIKit
import SVProgressHUD
import CoreLocation
import SwiftyJSON
import Alamofire

class ViewController: UIViewController, CLLocationManagerDelegate{

    @IBOutlet weak var tempSwitch: UISwitch!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var maxTempLabel: UILabel!
    @IBOutlet weak var minTempLabel: UILabel!
    @IBOutlet weak var windSpeedLabel: UILabel!
    
    @IBOutlet weak var weatherImage: UIImageView!
    
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "8d50279ebc4408fdf5bce4ead1648643"
    
    let locationManager = CLLocationManager()
    let weatherModel = WeatherModel()
    
    //TODO: Implement Toggle to show temperature in c and F;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        SVProgressHUD.show()
        locationManager.delegate = self
        
        //set accuracy of location
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        
        //when the location info will be taken from the device.
        locationManager.requestWhenInUseAuthorization()
        
        //get gps data. works in the background. Asynchronous
        locationManager.startUpdatingLocation()
        
        SVProgressHUD.dismiss()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func switchTemperatureValue(_ sender: UISwitch) {
        if sender.isOn == true{
            //show temp in °C
            updateUI("C")
        }else{
            //show temperature in °F
            updateUI("F")
        }
    }
    
    //MARK: get location data and show error.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //locations has multiple location values while increasing accuracy of the results
        let location = locations[locations.count - 1]
        
        //check if info is valid
        if location.horizontalAccuracy > 0{
            
            //as you get the location, stop  the process of getting the location
            locationManager.stopUpdatingLocation()
            
            //removes multiple data retrieval by locationManager
            locationManager.delegate = nil
            
            let lati = String(location.coordinate.latitude)
            let longi = String(location.coordinate.longitude)
            
            //create a dictionary.
            let params: [String : String] = ["lat" : lati, "lon" : longi, "appid" : APP_ID]
            
            tempSwitch.setOn(true, animated: false)
            getWeatherData(WEATHER_URL,params)
            
        }
    
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        loadingLabel.text = "Location Unavailable"
        showPlaceholderDataToUser()
    }
    
    func getWeatherData(_ url: String ,_ params: [String : String]){
        SVProgressHUD.show()
        
        Alamofire.request(url, method: .get, parameters: params).responseJSON { (response) in
        
            if response.result.isSuccess{
                SVProgressHUD.dismiss()
                print("Success")
                
                let weatherJSON: JSON = JSON(response.result.value!)
                self.updateWeatherData(jsonData: weatherJSON)
                
            }
            else {
                SVProgressHUD.dismiss()
                print(response.result.error as Any)
                self.loadingLabel.text = "Connection Issues"
                self.showPlaceholderDataToUser()
            }
            
        }//End of request.
        
    }//EOF
    
    func updateWeatherData(jsonData : JSON){
        
        if let tempResult = jsonData["main"]["temp"].double{
          SVProgressHUD.dismiss()
            
            weatherModel.temperature = tempResult
            weatherModel.city = jsonData["name"].string!
            weatherModel.humidity = jsonData["main"]["humidity"].double!

            weatherModel.tempMax = jsonData["main"]["temp_max"].double!
            weatherModel.tempMin = jsonData["main"]["temp_min"].double!
            
            weatherModel.windSpeed = jsonData["wind"]["speed"].double!
            weatherModel.condition = jsonData["weather"][0]["id"].int!
            
            weatherModel.iconName = weatherModel.updateWeatherIcon(condition: weatherModel.condition)
            
            updateUI("C")
            
        }else{
            loadingLabel.text = "Weather Unavailable"
            showPlaceholderDataToUser()
        }
    }
    
    //MARK: Update UI
    func updateUI(_ mode: String){
        //if mode equals C, show C else show F
        let mainTemp = weatherModel.temperature
        
        if mode.elementsEqual("C"){
            temperatureLabel.text = "\(mainTemp - 273.15)°C"
            maxTempLabel.text = "Max. Temperature: \((weatherModel.tempMax) - 273.15)°C"
            minTempLabel.text = "Min. Temperature: \((weatherModel.tempMin) - 273.15)°C"
        }else {
            temperatureLabel.text = "\(mainTemp)°F"
            maxTempLabel.text = "Max. Temperature: \(weatherModel.tempMax)°F"
            minTempLabel.text = "Min. Temperature: \(weatherModel.tempMin)°F"
        }

        loadingLabel.text = "\(weatherModel.city)"
        humidityLabel.text = "Humidity: \(weatherModel.humidity) hpa"
        windSpeedLabel.text = "Wind Speed: \(weatherModel.windSpeed) m/sec"

        
        //show image here.
        weatherImage.image = UIImage(named: weatherModel.iconName)
    }
    
    func showPlaceholderDataToUser(){
        temperatureLabel.text = "0°C"
        maxTempLabel.text = "Max. Temperature: 0°C"
        minTempLabel.text = "Min. Temperature: 0°C"
        humidityLabel.text = "Humidity: 0 hpa"
        windSpeedLabel.text = "Wind Speed: 0 m/sec"
        
        //show image here.
        weatherImage.image = UIImage(named:"")
    }
    
    @IBAction func changeCityButton(_ sender: Any) {
        let alert = UIAlertController(title: "Alert", message: "Enter City", preferredStyle: .alert)
      
        alert.addTextField { (textField) in
            textField.placeholder = "Enter City Name"
            textField.keyboardType = .asciiCapable
        }
        
        let action = UIAlertAction(title: "Ok", style: .default) { (UIAlertAction) in
            //get the city name and show weather data.
            let cityName = alert.textFields?.first?.text!
            if (cityName?.isEmpty)! {
                self.loadingLabel.text = "City Field Empty"
                self.showPlaceholderDataToUser()
            }else{
                let params : [String:String] = ["q": cityName!,"appid" : self.APP_ID]
                self.tempSwitch.setOn(true, animated: false)
                self.getWeatherData(self.WEATHER_URL, params)
            }
       
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(action)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true)
        
    }
    
}//EOC
