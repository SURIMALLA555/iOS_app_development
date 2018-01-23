//
//  StepsTableViewController.swift
//  ActivityMonitor
//
//  Created by cpl_user on 11/19/17.
//  Copyright © 2017 cpl_user. All rights reserved.
//

import UIKit

class StepsTableViewController: UITableViewController {

    var inputData:String = ""
    var stepData:[[String]]? = nil

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Steps Data"

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        readDataFromFile()
    }
    
    
    func readDataFromFile(){
        let documentDirURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        var fileURL = documentDirURL.appendingPathComponent("Steps").appendingPathExtension("csv")
        var readString = ""
        do{
            readString = try! String(contentsOf: fileURL )
            //            print("from file..............")
            //            print(readString)
            stepData = csv(data: readString)
            
            
        }catch{
            print("failed to read")
        }
        
        
    }
    
    func csv(data: String) -> [[String]] {
        var result: [[String]] = []
        let rows = data.components(separatedBy: "\n")
        var i = 0
        for row in rows {
            if i == 0 {
                
            }else{
                let columns = row.components(separatedBy: ",")
                result.append(columns)
            }
            i = i + 1
        }
        return result
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return (stepData?.count)!
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        // Configure the cell...
        let lblData1 = cell.viewWithTag(1) as! UILabel
        let lblData2 = cell.viewWithTag(2) as! UILabel
        
        lblData1.text = "Steps: " + stepData![indexPath.row][1] as String
        lblData2.text = "Time: " + stepData![indexPath.row][0] as String
        

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
