//
//  DetailViewController.swift
//  ReferralsApp
//
//  Created by Austin Brewer on 4/20/15.
//  Copyright (c) 2015 Austin Brewer. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    @IBOutlet weak var detailDescriptionLabel: UILabel!

    var detailItem: Referral? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let detail = self.detailItem {
            if let label = self.detailDescriptionLabel {
                label.text = "Welcome to the web! " + detail.url
            }
            let oldURL = detail.url as String // explicit casts for serialization purposes
            let newcount = detail.count + 1 as Int // explicit casts for serialization purposes
            
            //set request parameters
            let url = NSURL(string: "http://localhost:8000/api/referrals/\(detail.pk)")
            let request = NSMutableURLRequest(URL: url!)
            request.HTTPMethod = "PUT"
            // build the html body with JSON
            let JSONData:NSDictionary = ["url_string" : oldURL, "count" : newcount] //build dictionary of referral data
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
            }

        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
        self.title = detailItem?.url
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

