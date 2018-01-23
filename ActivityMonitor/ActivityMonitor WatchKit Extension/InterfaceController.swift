//
//  InterfaceController.swift
//  ActivityMonitor WatchKit Extension
//
//  Created by cpl_user on 11/18/17.
//  Copyright © 2017 cpl_user. All rights reserved.
//

import WatchKit
import Foundation
import HealthKit


class InterfaceController: WKInterfaceController, HKWorkoutSessionDelegate {
    
    
    @IBOutlet var lblButton: WKInterfaceButton!
    @IBOutlet var lblStartTime: WKInterfaceLabel!
    
    let healthKitManager = HealthKitManager.sharedInstance
    
    var isTrackingInProgress = false
    
    var workoutSession:HKWorkoutSession?
    
    var workoutStartDate:Date?
    
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        self.lblButton.setEnabled(false)
        
        healthKitManager.authorizeHealthKit { (success, error) in
            print("was authorized? \(success)")
            self.lblButton.setEnabled(true)
            
            self.createTrackingSession()
        }
        
        
        
        
        
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
   
    @IBAction func startAndStopButton() {
        
        if isTrackingInProgress{
            print("tracking stopped")
            stopWorkoutSession()
            createTrackingSession()
        }else{
            print("tracking started")
            startWorkoutSession()
        }
        
        isTrackingInProgress = !isTrackingInProgress
        
        self.lblButton.setTitle(isTrackingInProgress ? "End tracking" : "Start tracking")
        
    }
    
    func createTrackingSession(){
       // initialize workoutConfiguration
        let workoutConfig = HKWorkoutConfiguration()
        
       // activity type is other because don't know the type
       // locationType is also unknown because we dont know is it indoor or outdoor
        workoutConfig.activityType = .other
        workoutConfig.locationType = .unknown
        
        
        
        do{
           workoutSession = try HKWorkoutSession(configuration: workoutConfig)
           workoutSession?.delegate = self
        }catch{
            print("Exception occured.")
        }
    }
    
    func startWorkoutSession(){
        if self.workoutSession == nil{
            createTrackingSession()
        }
        
        guard let session = workoutSession else{
            print("Not started without  workout session ")
            return
        }
        
        healthKitManager.healthStore.start(session)
        self.workoutStartDate = Date()
    }
    
    func stopWorkoutSession(){
        guard let session = workoutSession else{
            print("Not started without  workout session ")
            return
        }
        
        healthKitManager.healthStore.end(session)
        saveWorkoutSession()
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        print("Workout failed with error: \(error)")
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        switch toState{
        case .running:
            print("workout started")
        case .ended:
            print("workout ended")
        default:
            print("other workout State")
        }
    }
    
    
    func saveWorkoutSession(){
        
        guard let startDate = workoutStartDate else{
            return
        }
        
        let workout = HKWorkout(activityType: .other, start: startDate, end: Date())
        
        healthKitManager.healthStore.save(workout, withCompletion: {(success,error)in
            print("Successfully save? \(success)")
        })
    }
    
    
}




