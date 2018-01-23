//
//  DetailsViewController.swift
//  ActivityMonitor
//
//  Created by cpl_user on 11/19/17.
//  Copyright © 2017 cpl_user. All rights reserved.
//

import UIKit
import HealthKit
import HealthKitUI
import AWSS3
import AWSCore
import Charts


class DetailsViewController: UIViewController {
    
    let healthStore = HKHealthStore()
    var userName:String = ""
    var fileURL:URL? = nil
    
    var flag_heartRateNil = 0
    var flag_stepNil = 0
    
    var stepCounts:[[String]]? = nil
    var heartBpm:[[String]]? = nil
    
    var totalStep:Int = 0
    var avgHeartRate:Int = 0
    
    
    let heartRateUnit:HKUnit = HKUnit(from: "count/min")
    let heartRateType:HKQuantityType   = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
    var heartRateQuery:HKSampleQuery?

    @IBOutlet weak var btnStepOutlet: UIButton!
    @IBOutlet weak var btnHeartOutlet: UIButton!
    @IBOutlet weak var btnUploadOutlet: UIButton!
    @IBOutlet weak var awsLogo: UIImageView!
    
    @IBOutlet weak var barChart: BarChartView!
    @IBOutlet weak var lineChart: LineChartView!
    @IBOutlet weak var combinedChart: CombinedChartView!
    
    @IBOutlet weak var lblTotalStep: UILabel!
    @IBOutlet weak var lblAvgHeartRate: UILabel!
    
   
    @IBAction func uploadBtn(_ sender: Any) {
        let accessKey = "AKIAIX26WJV2UZYVIXOA"
        let secretKey = "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"
        let credentialsProvider = AWSStaticCredentialsProvider(accessKey: accessKey, secretKey: secretKey)
        let configuration = AWSServiceConfiguration(region: AWSRegionType.USWest1, credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        let documentDirURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        let fileURL1 = documentDirURL.appendingPathComponent("HeartRate").appendingPathExtension("csv")
        let fileURL2 = documentDirURL.appendingPathComponent("Steps").appendingPathExtension("csv")
        let url1 = fileURL1
        let url2 = fileURL2
        
        let remoteName1 = "heartRate/"+userName+"_heartData.csv"
        let remoteName2 = "steps/"+userName+"_stepsData.csv"
        let S3BucketName = "cplactivitymonitor"
        let uploadRequest1 = AWSS3TransferManagerUploadRequest()!
        uploadRequest1.body = url1
        uploadRequest1.key = remoteName1
        uploadRequest1.bucket = S3BucketName
        uploadRequest1.acl = .publicRead
        
        let uploadRequest2 = AWSS3TransferManagerUploadRequest()!
        uploadRequest2.body = url2
        uploadRequest2.key = remoteName2
        uploadRequest2.bucket = S3BucketName
        uploadRequest2.acl = .publicRead
        
        
        
        let transferManager = AWSS3TransferManager.default()
        
        transferManager.upload(uploadRequest1).continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask<AnyObject>) -> Any? in
            if let error = task.error {
                print("Upload failed with error: (\(error.localizedDescription))")
                let alert = UIAlertController(title: "AWS file upload", message: "Upload error", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .default , handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            }
            if task.result != nil {
                let url = AWSS3.default().configuration.endpoint.url
                let publicURL = url?.appendingPathComponent(uploadRequest1.bucket!).appendingPathComponent(uploadRequest1.key!)
                print("Uploaded to:\(String(describing: publicURL))")
                let alert = UIAlertController(title: "AWS file upload", message: "Successfully uploaded", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .default , handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            }
            return nil
        })
        
        transferManager.upload(uploadRequest2).continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask<AnyObject>) -> Any? in
            if let error = task.error {
                print("Upload failed with error: (\(error.localizedDescription))")
                let alert = UIAlertController(title: "AWS file upload", message: "Upload error", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .default , handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            if task.result != nil {
                let url = AWSS3.default().configuration.endpoint.url
                let publicURL = url?.appendingPathComponent(uploadRequest2.bucket!).appendingPathComponent(uploadRequest2.key!)
                print("Uploaded to:\(String(describing: publicURL))")
                let alert = UIAlertController(title: "AWS file upload", message: "Successfully uploaded", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .default , handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            return nil
        })
        
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = "Statistics of user " + userName
        
       
        
        self.btnStepOutlet.layer.cornerRadius = 25
        self.btnStepOutlet.layer.borderWidth = 1
        self.btnStepOutlet.layer.borderColor = UIColor.white.cgColor
        self.btnStepOutlet.clipsToBounds = true

        self.btnHeartOutlet.layer.cornerRadius = 25
        self.btnHeartOutlet.layer.borderWidth = 1
        self.btnHeartOutlet.layer.borderColor = UIColor.white.cgColor
        self.btnHeartOutlet.clipsToBounds = true
        
        self.btnUploadOutlet.layer.cornerRadius = 25
        self.btnUploadOutlet.layer.borderWidth = 1
        self.btnUploadOutlet.layer.borderColor = UIColor.white.cgColor
        self.btnUploadOutlet.clipsToBounds = true
        
        self.awsLogo.layer.cornerRadius = 10
        self.awsLogo.layer.borderWidth = 1
        self.awsLogo.layer.borderColor = UIColor.white.cgColor
        self.awsLogo.clipsToBounds = true
        
        stepData()
        read_heart_data()
        
        
//        setBarChart()
//        setLineChart()
        
            setCombinedChart()
        
        lblTotalStep.text = "Today's Total: \(totalStep)"
        lblAvgHeartRate.text = "Today's Avg.: \(avgHeartRate)(bpm)"
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    
    
    
    @IBAction func btnSteps(_ sender: Any) {
        if flag_stepNil==1{
//             performSegue(withIdentifier: "detailsToSteps", sender: self)
            performSegue(withIdentifier: "stepSegue", sender: self)
        }else{
            print("Steps data is not available")
            let alert = UIAlertController(title: "No data", message: "Steps data is not available", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
       
   
        
    }
    
    
   
    @IBAction func btnHeartData(_ sender: Any) {
        if flag_heartRateNil == 0{
//            performSegue(withIdentifier: "detailsToHeart", sender: self)
            performSegue(withIdentifier: "heartSegue", sender: self)
            
        }else{
            print("heart rate data is not available")
            let alert = UIAlertController(title: "No data", message: "Heart rate data is not available", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            self.present(alert, animated: true)
            
        }
    }
    
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailsToSteps" {
            let seg1 = segue.destination as! StepsTableViewController
//            seg1.inputData = "a"
        }
        
        if segue.identifier == "detailsToHeart" {
            let seg2 = segue.destination as! HeartRateTableViewController
        }
        if segue.identifier == "stepSegue" {
            let seg3 = segue.destination as! StepViewController
            //            seg1.inputData = "a"
        }
        
        if segue.identifier == "heartSegue" {
            let seg4 = segue.destination as! HeartViewController
        }
        
    }
    
    
    
    func stepData(){
        
        var csvText = "Time,Steps\n"
        
//        let startDate = Date()
//        let endDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())
        let startDate = Calendar.current.startOfDay(for: Date())
        let endDate = Date()
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate as Date, options: .strictStartDate)
        
//        let calendar = NSCalendar.current
//        let unitFlags = Set<Calendar.Component>([.day, .month, .year, .hour])
////        let anchorComponents = calendar.dateComponents(unitFlags, from: startDate as Date,  to: endDate as! Date)
//        let anchorComponents = calendar.dateComponents(unitFlags, from: startDate as Date,  to: endDate as! Date)
//
        let interval = NSDateComponents()
        interval.minute = 1
        
        // Set the anchor date to Monday at 3:00 a.m.
        
        //        let anchorComponents =
        //            calendar.components([NSCalendar.Unit.Day, NSCalendar.Unit.Month, NSCalendar.Unit.Year], fromDate: Calendar.cu)
        //
        //        let anchorDate = calendar.dateFromComponents(anchorComponents)
        
        let quantityType =
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)
        
        // Create the query
        let query = HKStatisticsCollectionQuery(quantityType: quantityType!,
                                                quantitySamplePredicate: predicate,
                                                options: .cumulativeSum,
                                                anchorDate: Date(),
                                                intervalComponents: interval as DateComponents)
        
        // Set the results handler
        query.initialResultsHandler = {
            query, results, error in
            
            if error != nil {
                // Perform proper error handling here
                print("*** An error occurred while calculating the statistics: \(error?.localizedDescription) ***")
                abort()
            }
            
            let endDate = NSDate()
            
//            let startDate = Calendar.current.date(byAdding: .day, value: -1, to: endDate as Date)
            let startDate = Calendar.current.startOfDay(for: Date())
            
            // Plot the weekly step counts over the past 3 months
            results?.enumerateStatistics(from: startDate, to: endDate as Date) {
                statistics, stop in
                
                if let quantity = statistics.sumQuantity() {
                    let date = statistics.startDate
                    let value = quantity.doubleValue(for: HKUnit.count())
                    
                    var dateString = "\(date)"
                    var dateCleaned = dateString.replacingOccurrences(of: " +0000", with: "")
                    
                    print(dateCleaned)
                    print(value)
                    csvText = csvText + "\(dateCleaned),\(Int(value))\n"
                    //                    self.plotData(value, forDate: date)
                    self.flag_stepNil = 1
                }
            }
            
           
            
            
            
            self.writeFilecsv(csvText: csvText, fname: "Steps")
            self.readDataFromFile(file: "Steps")
        }
        
        
        healthStore.execute(query)
        
        //        hm.healthKitStore.executeQuery(query)
    }
    
    func read_heart_data(){
        
        var csvText = "Time,HeartRate\n"
        
        
        let endDate = NSDate()
        
//        let startDate = Calendar.current.date(byAdding: .day, value: -1, to: endDate as Date)
        let startDate = Calendar.current.startOfDay(for: Date())
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate as Date, options: .strictStartDate)
        
        
        let tHeartRate = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)
        let tHeartRateQuery = HKSampleQuery(sampleType: tHeartRate!, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { query, results, error in
            
            var string:String = ""
            for result in results as! [HKQuantitySample]
            {
                
                let dateValue = result.startDate
                
                let HeartRate = result.quantity
                string = "\(HeartRate)"
                var heartBeat = string.replacingOccurrences(of: " count/min", with: "")
                var dateString = "\(dateValue)"
                var dateCleaned = dateString.replacingOccurrences(of: " +0000", with: "")
                
                print("\(dateCleaned)")
                print(heartBeat)
                csvText = csvText + "\(dateCleaned),\(heartBeat)\n"
                self.flag_heartRateNil = 0
            }
            
            if results?.count == 0 {
                print("0")
                print("0")
//                csvText = csvText + "0,0\n"
                self.flag_heartRateNil = 1
            }
                
            self.writeFilecsv(csvText: csvText, fname: "HeartRate")
            self.readDataFromFile(file: "HeartRate")
            
        }
        healthStore.execute(tHeartRateQuery)
    }
    
    func writeFilecsv(csvText:String, fname:String) -> Bool {
        let fileName = fname
        let documentDirURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        fileURL = documentDirURL.appendingPathComponent(fileName).appendingPathExtension("csv")
        
        print("FILE Path: \(fileURL?.path)")
        
        
        do{
            try csvText.write(to: fileURL!, atomically: true, encoding: String.Encoding.utf8)
        }catch{
            print("Something wrong")
        }
        
        
        
        return true
    }
    
    func readDataFromFile(file:String) -> Bool{
        var readString = ""
        do{
            readString = try! String(contentsOf: fileURL! )
            //            print("from file..............")
            print(readString)
            return true
        }catch{
            print("failed to read")
        }
        
        return true
    }
    

    
//    func setBarChart() {
//        readData_from_step_file()
//        var timeData = dateFormatfromString(data:stepCounts!)
//        var timeArray:[String] = ["00","01","02","03","04","05","06","07","08","09","10","11","12","13","14","15","16","17","18","19","20","21","22","23"]
//        var stepArray:[Int] = []
//
//
//        for i in timeArray{
//            var sum = 0
//            var indexFlag = 0
//            for j in timeData!{
//                if i==j {
//                    sum = sum + Int(stepCounts![indexFlag][1])!
//                }
//
//
//                indexFlag = indexFlag + 1
//            }
//
//            stepArray.append(sum)
//
//        }
//
//        print(stepArray)
//
//        barChart.noDataText = "No data from your watch"
//        var dataEntries: [BarChartDataEntry] = []
//
//        print(stepCounts)
//        print("Items start here")
//
//        for i in 0...23{
////            print(item)
//            let dataEntry = BarChartDataEntry(x: Double(timeArray[i])!, y: Double(stepArray[i]))
//            dataEntries.append(dataEntry)
//
//        }
//        print("Items ends ")
////
//        let chartDataSet = BarChartDataSet(values: dataEntries, label: "Step Count")
//        chartDataSet.colors = [UIColor.blue]
//        chartDataSet.axisDependency = .left
//
////        chartDataSet.colors = ChartColorTemplates.joyful()
//        let chartData = BarChartData()
//        chartData.addDataSet(chartDataSet)
//
//        //Axes Setup
////        let formatter: ChartFormatter = ChartFormatter()
//
//        barChart.drawGridBackgroundEnabled = true
//        barChart.gridBackgroundColor = UIColor.lightGray
//        barChart.backgroundColor = UIColor.lightGray
//
//        barChart.chartDescription?.text = ""
//        //chartView.title.text = "Step Count Chart"
//
//        barChart.xAxis.labelPosition = .bottom
//
//        barChart.scaleYEnabled = false
//        barChart.scaleXEnabled = false
//        barChart.pinchZoomEnabled = false
//        barChart.doubleTapToZoomEnabled = false
//        barChart.rightAxis.enabled = false
//        barChart.leftAxis.axisMinimum = 0
//        barChart.highlighter = nil
//        barChart.xAxis.drawGridLinesEnabled = false
//
//
//        barChart.data = chartData
//    }
//
//    func setLineChart() {
//        readData_from_heart_file()
//        var timeData = dateFormatfromString(data:heartBpm!)
//        var timeArray:[String] = ["00","01","02","03","04","05","06","07","08","09","10","11","12","13","14","15","16","17","18","19","20","21","22","23"]
//        var heartArray:[Double] = []
//
//
//        for i in timeArray{
//            var sum = 0
//            var counter = 1
//            var indexFlag = 0
//            for j in timeData!{
//                if i==j {
//                    sum = sum + Int(heartBpm![indexFlag][1])!
//                    counter = counter + 1
//                }
//
//
//                indexFlag = indexFlag + 1
//
//            }
//
//
//
//            heartArray.append(Double(sum/counter))
//
//        }
//
////        print(heartArray)
//        lineChart.noDataText = "No data from your watch"
//        var dataEntries: [ChartDataEntry] = []
//
//        for i in 0...23 {
//            let dataEntry = ChartDataEntry(x: Double(timeArray[i])!, y: Double(heartArray[i]))
//            dataEntries.append(dataEntry)
//        }
//
//        let chartDataSet = LineChartDataSet(values: dataEntries, label: "Heart Rate")
//        chartDataSet.colors = [UIColor.red]
//
//        chartDataSet.setCircleColor(UIColor.red) // our circle will be dark red
//        chartDataSet.lineWidth = 1.0
//        chartDataSet.circleRadius = 5.0 // the radius of the node circle
//        chartDataSet.fillAlpha = 65 / 255.0
//        chartDataSet.fillColor = UIColor.red
//        chartDataSet.highlightColor = UIColor.white
//        chartDataSet.drawCircleHoleEnabled = true
//
//        let chartData = LineChartData()
//        chartData.addDataSet(chartDataSet)
//
//        //Axes Setup
//        //let formatter: ChartFormatter = ChartFormatter()
//
//        lineChart.drawGridBackgroundEnabled = true
//        lineChart.gridBackgroundColor = UIColor.lightGray
//        lineChart.backgroundColor = UIColor.lightGray
//
//
//
//        lineChart.xAxis.labelPosition = .bottom
//
//        lineChart.scaleYEnabled = false
//        lineChart.scaleXEnabled = false
//        lineChart.pinchZoomEnabled = false
//        lineChart.doubleTapToZoomEnabled = false
//        lineChart.rightAxis.enabled = false
//        lineChart.leftAxis.axisMinimum = 0
//        lineChart.highlighter = nil
//        lineChart.xAxis.drawGridLinesEnabled = false
//        lineChart.chartDescription?.text = ""
//
//
//
//        lineChart.data = chartData
//    }
    
    func setCombinedChart(){
        
//        combinedChart.drawGridBackgroundEnabled = true
//        combinedChart.drawBarShadowEnabled      = true
//        combinedChart.highlightFullBarEnabled   = false
        combinedChart.drawOrder                 = [DrawOrder.bar.rawValue, DrawOrder.line.rawValue]
        
        // MARK: xAxis
        let xAxis                           = combinedChart.xAxis
        xAxis.labelPosition                 = .bottom
        xAxis.axisMinimum                   = 0
        xAxis.granularity                   = 1.0
//        xAxis.valueFormatter                = BarChartFormatter()
//        xAxis.centerAxisLabelsEnabled = true
//        xAxis.setLabelCount( 12, force: true)
        
        // MARK: leftAxis
        let leftAxis                        = combinedChart.leftAxis
        leftAxis.drawGridLinesEnabled       = false
        leftAxis.axisMinimum                = 0
        leftAxis.labelTextColor = UIColor.blue
        
//        leftAxis.nameAxis = "left Axis"
//        leftAxis.nameAxisEnabled = true
       
        
        // MARK: rightAxis
        let rightAxis                       = combinedChart.rightAxis
        rightAxis.drawGridLinesEnabled      = false
        rightAxis.axisMinimum               = 0
        rightAxis.axisMaximum               = 180
        rightAxis.labelTextColor = UIColor.red
        
        
//        rightAxis.nameAxis = "right Axis"
//        rightAxis.nameAxisEnabled = true
        
        // MARK: legend
        let legend                          = combinedChart.legend
        legend.wordWrapEnabled              = true
        legend.horizontalAlignment          = .center
        legend.verticalAlignment            = .bottom
        legend.orientation                  = .horizontal
        legend.drawInside                   = false
        
        // MARK: description
        combinedChart.chartDescription?.enabled = false
        combinedChart.pinchZoomEnabled = false
        combinedChart.doubleTapToZoomEnabled = false
        combinedChart.highlighter = nil
        combinedChart.xAxis.drawGridLinesEnabled = true
//        combinedChart.backgroundColor = UIColor.lightGray
//        combinedChart.gridBackgroundColor = UIColor.white
//        combinedChart.leftAxis.drawAxisLineEnabled = false
//        combinedChart.leftAxis.drawGridLinesEnabled = true
//        combinedChart.rightAxis.drawAxisLineEnabled = false
//        combinedChart.rightAxis.drawGridLinesEnabled = false
//        combinedChart.leftAxis.axisLineColor = UIColor.gray
//         combinedChart.rightAxis.axisLineColor = UIColor.gray
        
        
        
        setChartData()
        
        
    }
    
    func setChartData(){
        let data = CombinedChartData()
        data.lineData = generateLineData()
        data.barData = generateBarData()
        combinedChart.data = data
    }
    
    func generateLineData() -> LineChartData{
        readData_from_heart_file()
        var timeData = dateFormatfromString(data:heartBpm!)
        var timeArray:[String] = ["00","01","02","03","04","05","06","07","08","09","10","11","12","13","14","15","16","17","18","19","20","21","22","23"]
        var heartArray:[Double] = []
        
        var total = 0
        var t_count = 0
        
        for i in timeArray{
            var sum = 0
            var counter = 1
            var indexFlag = 0
            for j in timeData!{
                if i==j {
                    sum = sum + Int(heartBpm![indexFlag][1])!
                    counter = counter + 1
                }
                
                
                indexFlag = indexFlag + 1
                
            }
            
            
            
            heartArray.append(Double(sum/counter))
            
            avgHeartRate = avgHeartRate + (sum/counter)
            if (Int(sum/counter) != 0){
                t_count = t_count + 1
            }
            
        }
        
        
        if t_count != 0{
            avgHeartRate = Int(avgHeartRate/t_count)
        }else{
            avgHeartRate = 0
        }
       
        
        //        print(heartArray)
//        lineChart.noDataText = "No data from your watch"
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0...23 {
            let dataEntry = ChartDataEntry(x: Double(timeArray[i])!, y: Double(heartArray[i]))
            dataEntries.append(dataEntry)
        }

//        // MARK: ChartDataEntry
//        var entries = [ChartDataEntry]()
//        for index in 0..<ITEM_COUNT
//        {
//            entries.append(ChartDataEntry(x: Double(index) + 0.5, y: (Double(arc4random_uniform(15) + 5))))
//        }
        
        // MARK: LineChartDataSet
        let set = LineChartDataSet(values: dataEntries, label: "Avg. Heart Rate(bpm) per hour")
        // removes zero values
        let noZeroFormatter = NumberFormatter()
        noZeroFormatter.zeroSymbol = ""
        set.valueFormatter = DefaultValueFormatter(formatter: noZeroFormatter)
        
        set.colors = [UIColor.red]
        set.lineWidth = 1
        set.circleColors = [UIColor.red]
//        set.circleHoleRadius = 2.5
        set.circleRadius = 2
        set.fillColor = UIColor.red
//        set.mode = .cubicBezier
        set.drawValuesEnabled = true
//        set.valueFont = NSUIFont.systemFont(ofSize: CGFloat(10.0))
        set.valueTextColor = UIColor.red
        set.axisDependency = .right
        
        // MARK: LineChartData
        let data = LineChartData()
        data.addDataSet(set)
        return data
    }
    
    func generateBarData() -> BarChartData{
        readData_from_step_file()
        var timeData = dateFormatfromString(data:stepCounts!)
        var timeArray:[String] = ["00","01","02","03","04","05","06","07","08","09","10","11","12","13","14","15","16","17","18","19","20","21","22","23"]
        var stepArray:[Int] = []
        
        
        for i in timeArray{
            var sum = 0
            var indexFlag = 0
            for j in timeData!{
                if i==j {
                    sum = sum + Int(stepCounts![indexFlag][1])!
                }
                
                
                indexFlag = indexFlag + 1
            }
            
            stepArray.append(sum)
            totalStep = totalStep + sum
            
        }
        
        print(stepArray)
        
//        barChart.noDataText = "No data available"
        var dataEntries: [BarChartDataEntry] = []
        
        print(stepCounts)
        print("Items start here")
        
        for i in 0...23{
            //            print(item)
            let dataEntry = BarChartDataEntry(x: Double(timeArray[i])!, y: Double(stepArray[i]))
            dataEntries.append(dataEntry)
            
        }
        print("Items ends ")
        
        
        // MARK: BarChartDataSet
        let set1            = BarChartDataSet(values: dataEntries, label: "Step Count per hour")
        // removes zero values
        let noZeroFormatter = NumberFormatter()
        noZeroFormatter.zeroSymbol = ""
        set1.valueFormatter = DefaultValueFormatter(formatter: noZeroFormatter)
        
        set1.colors         = [UIColor.blue]
        set1.valueTextColor = UIColor.blue
//        set1.valueFont      = NSUIFont.systemFont(ofSize: CGFloat(10.0))
        set1.axisDependency = .left
       
        
       
        
        // MARK: BarChartData
//        let groupSpace = 0.06
//        let barSpace = 0.01
//        let barWidth = 0.46
        
        // x2 dataset
        // (0.45 + 0.02) * 2 + 0.06 = 1.00 -> interval per "group"
        let data = BarChartData()
        data.addDataSet(set1)
        
//        data.barWidth = barWidth
//        // make this BarData object grouped
//        data.groupBars(fromX: 0.0, groupSpace: groupSpace, barSpace: barSpace)     // start at x = 0
        return data
    }
    
    
    func readData_from_step_file(){
        let documentDirURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        var fileURL = documentDirURL.appendingPathComponent("Steps").appendingPathExtension("csv")
        var readString = ""
        do{
            readString = try! String(contentsOf: fileURL )
            //            print("from file..............")
            //            print(readString)
            stepCounts = csv(data: readString)
            
            
        }catch{
            print("failed to read")
        }
        
        
    }
    
    func readData_from_heart_file(){
        let documentDirURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        var fileURL = documentDirURL.appendingPathComponent("HeartRate").appendingPathExtension("csv")
        var readString = ""
        do{
            readString = try! String(contentsOf: fileURL )
            //            print("from file..............")
            //            print(readString)
            heartBpm = csv(data: readString)
            
            
        }catch{
            print("failed to read")
        }
        
        
    }
    
    func dateFormatfromString(data:[[String]])->[String]?{
        
        
        var timeData:[String] = []
        let dateFormatter = DateFormatter()
        
        for item in data{
            if item[0] == "0" {
                break
            }
            
                var dateString = item[0]
                //            print("Date string : \(dateString)")

                dateFormatter.dateFormat = "yyyy-mm-dd HH:mm:ss"
                dateFormatter.locale = Locale.init(identifier: "en_GB")
                var dateObj = dateFormatter.date(from: dateString)
                //
                dateFormatter.dateFormat = "HH"
            
            
            
            timeData.append(dateFormatter.string(from: dateObj!))
//                print("Dateobj: \(dateFormatter.string(from: dateObj!))")

            
                
                
            
            
        }
//        print(timeData)
       return  timeData
    }
    
    func csv(data: String) -> [[String]] {
        var result: [[String]] = []
        let rows = data.components(separatedBy: "\n")
        var i = 0
        for row in rows {
            if i == 0 {
                
            }else if i == (rows.count-1) {
                
            }else{
                let columns = row.components(separatedBy: ",")
                result.append(columns)
            }
            i = i + 1
        }
        return result
    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
