//
//  HeartViewController.swift
//  ActivityMonitor
//
//  Created by cpl_user on 11/30/17.
//  Copyright © 2017 cpl_user. All rights reserved.
//

import UIKit
import Charts

class HeartViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {

    var inputData:String = ""
    var fileURL:URL? = nil
    
    var flag_heartRateNil = 0
    var flag_stepNil = 0
    
    var heartBpm:[[String]]? = nil
    
    @IBOutlet weak var lineChart: LineChartView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = "Heart Rate Data"
        
        readData_from_heart_file()
        setLineChart()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (heartBpm?.count)!
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as UITableViewCell
        
        // Configure the cell...
        let lblData1 = cell.viewWithTag(1) as! UILabel
        let lblData2 = cell.viewWithTag(2) as! UILabel

        lblData1.text = "Heart Rate: " + heartBpm![indexPath.row][1] as String + "(bpm)"
        lblData2.text = "Time: " + heartBpm![indexPath.row][0] as String


        //
        //        cell.textLabel?.text = stepCounts![indexPath.row][1]
        
        return cell
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
    
    func setLineChart() {
        readData_from_heart_file()
        var timeData = dateFormatfromString(data:heartBpm!)
        var timeArray:[String] = ["00","01","02","03","04","05","06","07","08","09","10","11","12","13","14","15","16","17","18","19","20","21","22","23"]
        var heartArray:[Int] = []
        
        
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
            
            
            
            heartArray.append(Int(sum/counter))
            
        }
        
        //        print(heartArray)
        lineChart.noDataText = "No data from your watch"
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0...23 {
            let dataEntry = ChartDataEntry(x: Double(timeArray[i])!, y: Double(heartArray[i]))
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = LineChartDataSet(values: dataEntries, label: "Average Heart Rate(bpm) per hour")
       
        // removes zero values
        let noZeroFormatter = NumberFormatter()
        noZeroFormatter.zeroSymbol = ""
        chartDataSet.valueFormatter = DefaultValueFormatter(formatter: noZeroFormatter)
        
        
        chartDataSet.colors = [UIColor.red]
        
        chartDataSet.setCircleColor(UIColor.red) // our circle will be dark red
        chartDataSet.lineWidth = 1
        chartDataSet.circleRadius = 2// the radius of the node circle
        chartDataSet.fillAlpha = 65 / 255
        chartDataSet.fillColor = UIColor.red
        chartDataSet.highlightColor = UIColor.white
        chartDataSet.drawCircleHoleEnabled = true
        
        
        
        
        
        let chartData = LineChartData()
        chartData.addDataSet(chartDataSet)
        
        //Axes Setup
        //let formatter: ChartFormatter = ChartFormatter()
        
//        lineChart.drawGridBackgroundEnabled = true
//        lineChart.gridBackgroundColor = UIColor.lightGray
//        lineChart.backgroundColor = UIColor.lightGray
        
        
        
        lineChart.xAxis.labelPosition = .bottom
        
        lineChart.scaleYEnabled = false
        lineChart.scaleXEnabled = false
        lineChart.pinchZoomEnabled = false
        lineChart.doubleTapToZoomEnabled = false
        lineChart.rightAxis.enabled = false
        lineChart.leftAxis.axisMinimum = 0
        lineChart.highlighter = nil
        lineChart.xAxis.drawGridLinesEnabled = false
        lineChart.chartDescription?.text = ""
        lineChart.leftAxis.granularity = 1
        lineChart.leftAxis.granularityEnabled = true
        lineChart.xAxis.granularity = 1
        lineChart.xAxis.granularityEnabled = true
        lineChart.leftAxis.labelTextColor = UIColor.red
        
        
        
        
        
        
        lineChart.data = chartData
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
