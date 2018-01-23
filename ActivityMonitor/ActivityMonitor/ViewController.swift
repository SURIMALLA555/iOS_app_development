//
//  ViewController.swift
//  ActivityMonitor
//
//  Created by cpl_user on 11/18/17.
//  Copyright © 2017 cpl_user. All rights reserved.
//

import UIKit
import HealthKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    let healthStore = HKHealthStore()
    var fileURL:URL? = nil

    
    
    
    
    @IBOutlet weak var nameTxt: UITextField!
    
    @IBOutlet weak var imgLogo: UIImageView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    
    @IBOutlet weak var contentView: UIView!
    
    
   
    @IBOutlet weak var buttonStartOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.title = "User Activity tracker"
        self.imgLogo.layer.borderWidth = 1
//        self.imgLogo.layer.masksToBounds = false
        self.imgLogo.layer.borderColor = UIColor.white.cgColor
        self.imgLogo.layer.cornerRadius = imgLogo.frame.height/2
        self.imgLogo.clipsToBounds = true
        
        self.buttonStartOutlet.layer.cornerRadius = 25
        self.buttonStartOutlet.layer.borderWidth = 1
        self.buttonStartOutlet.layer.borderColor = UIColor.white.cgColor
        
        self.nameTxt.delegate = self
        
        
        let healthKitTypes: Set<HKObjectType> = [
            // access step count
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!,
            HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
            
        ]
        
        let objectTypes: Set<HKObjectType> = [
            HKObjectType.activitySummaryType()
        ]
        
        healthStore.requestAuthorization(toShare: nil, read: objectTypes) { (success, error) in
            
            // Authorization request finished, hopefully the user allowed access!
        }
        
        healthStore.requestAuthorization(toShare: healthKitTypes as! Set<HKSampleType>, read: healthKitTypes) { (_, _) in
            print("authrised???")
        }
        healthStore.requestAuthorization(toShare: healthKitTypes as? Set<HKSampleType>, read: healthKitTypes) { (bool, error) in
            if let e = error {
                print("oops something went wrong during authorisation \(e.localizedDescription)")
            } else {
                print("User has completed the authorization flow")
            }
        }
        
    }
    
    
    
    
    
    @IBAction func showDetails(_ sender: Any) {
        if nameTxt.text?.isEmpty != true {
            performSegue(withIdentifier: "viewToDetails", sender: self)
            print("not nil")
        }
        else{
            let alert = UIAlertController(title: "Name Missing", message: "Enter your name and try again ", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
//            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            print("nil")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewToDetails" {
            let segue1 = segue.destination as! DetailsViewController
            segue1.userName = nameTxt.text!
        }
    }
    
      
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //hide keyboard when user touches outside the keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.contentView.endEditing(true)
        
    }
    
   
    
    //hide keyboard when presses return key
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nameTxt.resignFirstResponder()
        return (true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        scrollView.setContentOffset(CGPoint(x:0,y:200) , animated: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        scrollView.setContentOffset(CGPoint(x:0,y:0) , animated: true)
    }


}

