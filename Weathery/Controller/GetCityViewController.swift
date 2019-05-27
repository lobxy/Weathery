//
//  GetCityViewController.swift
//  Weathery
//
//  Created by Sam Sherman on 04/04/19.
//  Copyright © 2019 lobxy. All rights reserved.
//

import UIKit
import SVProgressHUD

//Interfaces.
protocol CityDelegate {
    func getUserEnteredCity(city: String)
}

class GetCityViewController: UIViewController {

    @IBOutlet weak var cityTextField: UITextField!
    
    var cityName:String = ""
    var delegate : CityDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func submitButton(_ sender: Any) {
        cityName = cityTextField.text!
        if cityName.isEmpty{
            
            //show alert
            let alert = UIAlertController(title: "Alert", message: "Field is Empty", preferredStyle: .alert)
            let action = UIAlertAction(title: "Retry", style: .default)
            alert.addAction(action)
            present(alert, animated: true)
            
        }else{
            //change city.
            //pass value to the main view controller
            delegate?.getUserEnteredCity(city: cityName)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true) {
        }
    
    }

    
    
}
