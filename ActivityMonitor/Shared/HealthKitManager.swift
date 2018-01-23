//
//  HealthKitManager.swift
//  ActivityMonitor WatchKit Extension
//
//  Created by cpl_user on 11/18/17.
//  Copyright © 2017 cpl_user. All rights reserved.
//

import Foundation
import HealthKit


class HealthKitManager: NSObject{
//    creates singleton project, only this app can acces the healthkit api
    static let sharedInstance = HealthKitManager()
    
    private override init() {}
    
    let healthStore = HKHealthStore()
    
    func authorizeHealthKit(_ completion: @escaping ((_ success: Bool, _ error: Error?) -> Void)) {
        
        guard let heartRateType: HKQuantityType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            return
        }
        let typesToShare = Set([HKObjectType.workoutType(), heartRateType])
        let typesToRead = Set([HKObjectType.workoutType(), heartRateType])
        
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { (success, error) in
            print("Was authorization successful? \(success)")
            completion(success, error)
        }
    }
    
    
}
