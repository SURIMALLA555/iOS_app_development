//
//  StepViewController.swift
//  ActivityMonitor
//
//  Created by cpl_user on 11/30/17.
//  Copyright © 2017 cpl_user. All rights reserved.
//

import UIKit
import Charts

class StepViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var inputData:String = ""
    var fileURL:URL? = nil
    
    var flag_heartRateNil = 0
    var flag_stepNil = 0
    
    var stepCounts:[[String]]? = nil
//    var heartBpm:[[String]]? = nil

    @IBOutlet weak var barChart: BarChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = "Steps Data"
        
        readData_from_step_file()
        setBarChart()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return(stepCounts?.count)!
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as UITableViewCell
        
        // Configure the cell...
        let lblData1 = cell.viewWithTag(1) as! UILabel
        let lblData2 = cell.viewWithTag(2) as! UILabel
        
        lblData1.text = "Steps: " + stepCounts![indexPath.row][1] as String
        lblData2.text = "Time: " + stepCounts![indexPath.row][0] as String
        
        
//
//        cell.textLabel?.text = stepCounts![indexPath.row][1]
        
        return cell
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
    
        func setBarChart() {
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
    
            }
    
            print(stepArray)
    
            barChart.noDataText = "No data from your watch"
            var dataEntries: [BarChartDataEntry] = []
    
            print(stepCounts)
            print("Items start here")
    
            for i in 0...23{
    //            print(item)
                let dataEntry = BarChartDataEntry(x: Double(timeArray[i])!, y: Double(stepArray[i]))
                dataEntries.append(dataEntry)
    
            }
            print("Items ends ")
    //
            let chartDataSet = BarChartDataSet(values: dataEntries, label: "Step Count per hour")
            // removes zero values
            let noZeroFormatter = NumberFormatter()
            noZeroFormatter.zeroSymbol = ""
            chartDataSet.valueFormatter = DefaultValueFormatter(formatter: noZeroFormatter)
            
            chartDataSet.colors = [UIColor.blue]
            chartDataSet.axisDependency = .left
    
    //        chartDataSet.colors = ChartColorTemplates.joyful()
            let chartData = BarChartData()
            chartData.addDataSet(chartDataSet)
    
            //Axes Setup
    //        let formatter: ChartFormatter = ChartFormatter()
    
//            barChart.drawGridBackgroundEnabled = true
//            barChart.gridBackgroundColor = UIColor.lightGray
//            barChart.backgroundColor = UIColor.lightGray
    
            barChart.chartDescription?.text = ""
            //chartView.title.text = "Step Count Chart"
    
            barChart.xAxis.labelPosition = .bottom
    
            barChart.scaleYEnabled = false
            barChart.scaleXEnabled = false
            barChart.pinchZoomEnabled = false
            barChart.doubleTapToZoomEnabled = false
            barChart.rightAxis.enabled = false
            barChart.leftAxis.axisMinimum = 0
            barChart.highlighter = nil
            barChart.xAxis.drawGridLinesEnabled = false
            barChart.leftAxis.labelTextColor = UIColor.blue
    
    
            barChart.data = chartData
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
