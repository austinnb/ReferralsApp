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
                for referral in referralsArray { // array of referral "objects"
                    if let referralAtIndex = referral as? NSDictionary { // each "object is convertible to a dictionary
                        let referralObject = Referral()
                        if let url = referralAtIndex["url_string"] as? String {
                            referralObject.url = url
                        }
                        if let count = referralAtIndex["count"] as? Int {
                            referralObject.count = count
                        }
                        if let pk = referralAtIndex["id"] as? Int {
                            referralObject.pk = pk
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
        let actionSheetController: UIAlertController = UIAlertController(title: "Add Referral", message: "Enter your custom URL", preferredStyle: .Alert)
        
        //Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
            //Do some stuff
        }
        actionSheetController.addAction(cancelAction)
        //Create and an option action
        let nextAction: UIAlertAction = UIAlertAction(title: "Add", style: .Default) { action -> Void in
            let text = actionSheetController.textFields?[0] as! String
        }
        actionSheetController.addAction(nextAction)
        //Add a text field
        actionSheetController.addTextFieldWithConfigurationHandler { textField -> Void in
            //TextField configuration
            textField.textColor = UIColor.blueColor()
        }
        
        //Present the AlertController
        self.presentViewController(actionSheetController, animated: true, completion: nil)
        
        
        
//        var referral = Referral()
//        
//        objects.insert(referral, atIndex: 0)
//        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
//        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
//        
//        // add it on the back end
//        let url = NSURL(string: "http://localhost:8000/api/referrals/")
//        let request = NSMutableURLRequest(URL: url!)
//        request.HTTPMethod = "POST"
//        var bodyData = "url_string=\(referral.url)&count=\(referral.count)"
//        request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding)
//        
//        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue())
//            {(response, data, error) in
//                //Useful for monitoring the API JSON reponse (aka fixing bugs)
//                println(NSString(data: data, encoding:NSUTF8StringEncoding))
//        }

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
            let referral = objects[indexPath.row]
            objects.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            // It's deleted client side, time to make it real
            
            let url = NSURL(string: "http://localhost:8000/api/referrals/\(referral.pk)")
            let request = NSMutableURLRequest(URL: url!)
            request.HTTPMethod = "DELETE"
            
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue())
            {(response, data, error) in
                //Useful for monitoring the API JSON reponse (aka fixing bugs)
                println(NSString(data: data, encoding:NSUTF8StringEncoding))
            }
            
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }


}

