//
//  MasterViewController.swift
//  ReferralsApp
//
//  Created by Austin Brewer on 4/20/15.
//  Copyright (c) 2015 Austin Brewer. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {

    var objects = [Referral]()


    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.editButtonItem()

        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
        self.navigationItem.rightBarButtonItem = addButton
        
        /*
            Make a request to .../api/referrals
        */
        let url = NSURL(string: "http://localhost:8000/api/referrals")
        let request = NSURLRequest(URL: url!)
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue())
        {(response, data, error) in
            //Useful for monitoring the API JSON reponse (aka fixing bugs)
            println(NSString(data: data, encoding:NSUTF8StringEncoding))
            
            var parseError: NSError?
            let JSONdata: AnyObject? = NSJSONSerialization.JSONObjectWithData(data,
                options: NSJSONReadingOptions.AllowFragments, error: &parseError)
            
            //And begins the unfortunate checking of everything while parsing the JSON in case anything could be Nil
            if let referralsArray = JSONdata as? NSArray {
                for referral in referralsArray {
                    if let referralAtIndex = referral as? NSDictionary {
                        let referralObject = Referral()
                        if let url = referralAtIndex["url_string"] as? String {
                            referralObject.url = url
                        }
                        if let count = referralAtIndex["count"] as? Int {
                            referralObject.count = count
                        }
                        self.objects.append(referralObject)
                    }
                }
            self.tableView.reloadData()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func insertNewObject(sender: AnyObject) {
        //objects.insert(NSDate(), atIndex: 0)
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == "showDetail" {
//            if let indexPath = self.tableView.indexPathForSelectedRow() {
//                //let object = objects[indexPath.row] as! NSDate
//            (segue.destinationViewController as! DetailViewController).detailItem = object
//            }
//        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell

        let object = objects[indexPath.row]
        cell.textLabel!.text = object.url
        cell.detailTextLabel!.text = String(object.count)
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            objects.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }


}

