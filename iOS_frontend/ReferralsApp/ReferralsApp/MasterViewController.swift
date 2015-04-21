//
//  MasterViewController.swift
//  ReferralsApp
//
//  Created by Austin Brewer on 4/20/15.
//  Copyright (c) 2015 Austin Brewer. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController, UISearchBarDelegate, UISearchDisplayDelegate {

    var objects = [Referral]()
    var filterdObjects = [Referral]()

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func displayGeneralNetworkFailAlert() {
        var inputTextField: UITextField?
        let alertController = UIAlertController(title: "Network Error", message: "We could not process your request. Try again.", preferredStyle: .Alert)
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel) { (action) -> Void in}
        alertController.addAction(cancel)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func fetchReferrals() {
        /*
        Make a request to .../api/referrals
        */
        let url = NSURL(string: "http://localhost:8000/api/referrals")
        let request = NSURLRequest(URL: url!)
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue())
        {(response, data, error) in
            //Useful for monitoring the API JSON reponse (aka fixing bugs)
            println(NSString(data: data, encoding:NSUTF8StringEncoding))
            
            // try to parse the response data
            var parseError: NSError?
            let JSONdata: AnyObject? = NSJSONSerialization.JSONObjectWithData(data,
                options: NSJSONReadingOptions.AllowFragments, error: &parseError)
            
            //And begins the unfortunate checking of everything while parsing the JSON in case anything could be Nil
            if let referralsArray = JSONdata as? NSArray {
                self.objects.removeAll(keepCapacity: false)
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
                self.objects.sort({$0.count > $1.count})
                self.filterContentForSearchText(self.searchDisplayController!.searchBar!.text)
                self.searchDisplayController!.searchResultsTableView.reloadData()
                self.tableView.reloadData()
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.displayGeneralNetworkFailAlert()
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.editButtonItem()

        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
        self.navigationItem.rightBarButtonItem = addButton
        
        self.title = "Referral List"
        
        self.searchDisplayController?.searchResultsTableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "Cell")
        
        fetchReferrals()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func insertNewObject(sender: AnyObject) {
        var inputTextField: UITextField?
        let alertController = UIAlertController(title: "Add URL", message: "Enter a new referral URL", preferredStyle: .Alert)
        let add = UIAlertAction(title: "Add", style: .Default, handler: { (action) -> Void in
            // Do whatever you want with inputTextField?.text
            println("\(inputTextField?.text)")
            let newURl = inputTextField!.text
            let url = NSURL(string: "http://localhost:8000/api/referrals/")
            let request = NSMutableURLRequest(URL: url!)
            request.HTTPMethod = "POST" // we're posting this time
            var bodyData = "url_string=\(newURl)&count=0" // set the variables
            request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue())
                {(response, data, error) in
                    //Useful for monitoring the API JSON reponse (aka fixing bugs)
                    println(NSString(data: data, encoding:NSUTF8StringEncoding))
                    if let HTTPResponse = response as? NSHTTPURLResponse {
                        let statusCode = HTTPResponse.statusCode
                        if statusCode == 201 { // check code
                            dispatch_async(dispatch_get_main_queue()) {
                                self.fetchReferrals()
                            }
                        } else {
                            dispatch_async(dispatch_get_main_queue()) {
                                self.displayGeneralNetworkFailAlert()
                            }
                        }
                    }

            }
        })
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel) { (action) -> Void in}
        alertController.addAction(add)
        alertController.addAction(cancel)
        alertController.addTextFieldWithConfigurationHandler { (textField) -> Void in
            inputTextField = textField
        }
        presentViewController(alertController, animated: true, completion: nil)
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let destinationVC = segue.destinationViewController as? DetailViewController {
                if let sourceCell = sender as? UITableViewCell {
                    if self.searchDisplayController!.active {
                        let indexPathRow = self.searchDisplayController!.searchResultsTableView.indexPathForSelectedRow();
                        destinationVC.detailItem = self.filterdObjects[indexPathRow!.row]
                    } else {
                        let indexPathRow = self.tableView.indexPathForSelectedRow();
                        destinationVC.detailItem = objects[indexPathRow!.row];
                    }
                }
            }
        }
    }
    
    @IBAction func unwindToSegue(segue:UIStoryboardSegue) {
        // this is modified in the detail view to eliminate the nav bar, so reset here
        //self.navigationController?.navigationBarHidden = false;
        //refresh the table (make another URL request) to apply changes made on the back end
        //fetchReferrals()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.fetchReferrals() // attempt to reload the table to give it up to date readings
    }
    
    // MARK: - Search
    
    private func filterContentForSearchText(searchText: String) {
        self.filterdObjects = self.objects.filter {
            (referral: Referral) -> Bool in
            if var stringMatch = referral.url as? String {
                stringMatch = stringMatch.lowercaseString;
                if stringMatch.rangeOfString(searchText.lowercaseString) != nil {
                    return true;
                }
            }
            return false;
        }
    }
    
    func searchDisplayController(controller: UISearchDisplayController, shouldReloadTableForSearchString searchString: String!) -> Bool {
        self.filterContentForSearchText(searchString)
        return true
    }
//    
//    func searchDisplayController(controller: UISearchDisplayController, shouldReloadTableForSearchScope searchOption: Int) -> Bool {
//        self.filterContentForSearchText(self.searchDisplayController!.searchBar.text)
//        return true
//    }


    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.searchDisplayController!.searchResultsTableView {
            return self.filterdObjects.count;
        } else {
            return self.objects.count;
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = self.tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as? UITableViewCell
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
        }
        var referral: Referral
        if tableView == self.searchDisplayController!.searchResultsTableView {
            referral = self.filterdObjects[indexPath.row];
        } else {
            referral = self.objects[indexPath.row];
        }
        cell!.textLabel?.text = "URL: " + referral.url
        cell!.detailTextLabel?.text = "Count: " + String(referral.count)
        return cell!
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]?  {
        var editAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Edit" , handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
            var inputTextField: UITextField?
            let alertController = UIAlertController(title: "Edit URL", message: "enter the new URL you'd like to use", preferredStyle: .Alert)
            let add = UIAlertAction(title: "Change", style: .Default, handler: { (action) -> Void in
                // Do whatever you want with inputTextField?.text
                var referral: Referral
                if tableView == self.searchDisplayController!.searchResultsTableView {
                    referral = self.filterdObjects[indexPath.row];
                } else {
                    referral = self.objects[indexPath.row];
                }

                println("\(inputTextField?.text)")
                let newURl = inputTextField!.text
                let url = NSURL(string: "http://localhost:8000/api/referrals/\(referral.pk)")
                let request = NSMutableURLRequest(URL: url!)
                request.HTTPMethod = "PUT"
                // build the html body with JSON
                let JSONData:NSDictionary = ["url_string" : inputTextField!.text, "count" : referral.count] //build dictionary of referral data
                var serialError: NSError?
                request.HTTPBody = NSJSONSerialization.dataWithJSONObject(JSONData, options: nil, error: &serialError)
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                //Connect
                NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue())
                    {(response, data, error) in
                        //Useful for monitoring the API JSON reponse (aka fixing bugs)
                        println(response.description)
                        println(NSString(data: data, encoding:NSUTF8StringEncoding))
                        if let HTTPResponse = response as? NSHTTPURLResponse {
                            let statusCode = HTTPResponse.statusCode
                            if statusCode == 200 { // check code
                                dispatch_async(dispatch_get_main_queue()) {
                                    self.fetchReferrals()
                                }
                            } else {
                                dispatch_async(dispatch_get_main_queue()) {
                                    self.displayGeneralNetworkFailAlert()
                                }
                            }
                        }
                }
            })
            let cancel = UIAlertAction(title: "Cancel", style: .Cancel) { (action) -> Void in}
            alertController.addAction(add)
            alertController.addAction(cancel)
            alertController.addTextFieldWithConfigurationHandler { (textField) -> Void in
                inputTextField = textField
            }
            self.presentViewController(alertController, animated: true, completion: nil)
        })

        var deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete" , handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
            var referral: Referral
            if tableView == self.searchDisplayController!.searchResultsTableView {
                referral = self.filterdObjects[indexPath.row];
            } else {
                referral = self.objects[indexPath.row];
            }
            
            // make it real on the server
            let url = NSURL(string: "http://localhost:8000/api/referrals/\(referral.pk)")
            let request = NSMutableURLRequest(URL: url!)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            request.HTTPMethod = "DELETE"
            //request.addValue("application/json", forHTTPHeaderField: "Accept")
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue())
                {(response, data, error) in
                    //Useful for monitoring the API JSON reponse (aka fixing bugs)
                    println(NSString(data: data, encoding:NSUTF8StringEncoding))
                    println(response.description)
                    
                    //now we can get rid of it client side
                    if let HTTPResponse = response as? NSHTTPURLResponse {
                        let statusCode = HTTPResponse.statusCode
                        if statusCode == 204 { // check code
                            dispatch_async(dispatch_get_main_queue()) {
                                self.objects.removeAtIndex(indexPath.row)
                                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                            }
    
                        } else {
                            self.displayGeneralNetworkFailAlert()
                        }
                    }
                    
            }
        })
        return [deleteAction,editAction]
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Passing over thankd to overwritten editing function above
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }


}

