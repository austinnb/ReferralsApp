//
//  AddReferralViewController.swift
//  ReferralsApp
//
//  Created by Austin Brewer on 4/20/15.
//  Copyright (c) 2015 Austin Brewer. All rights reserved.
//

import UIKit

class AddReferralViewController: UIViewController {
    @IBOutlet weak var urlTextField: UITextField!
    
    
    @IBAction func add(sender: UIButton) {
        if let newurl = urlTextField.text { //pull url from string in text feild
            let url = NSURL(string: "http://localhost:8000/api/referrals/")
            let request = NSMutableURLRequest(URL: url!)
            request.HTTPMethod = "POST" // we're posting this time
            var bodyData = "url_string=\(newurl)&count=0" // set the variables
            request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue())
                {(response, data, error) in
                    //Useful for monitoring the API JSON reponse (aka fixing bugs)
                    println(NSString(data: data, encoding:NSUTF8StringEncoding))
                    //segue here to prevent master view from reloading before this request processes
                    //otherwise changes are updated surratically
                    self.performSegueWithIdentifier("leaveFromAddReferral", sender: nil)
            }
        }
    }
}
