//
//  DonateViewController.swift
//  NightOwl
//
//  Created by Benjamin Kramser on 02.09.18.
//  Copyright © 2018 Benjamin Kramser. All rights reserved.
//

import Cocoa
import WebKit

class DonateViewController: NSViewController {
    
    let donateURL = "https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=benjamin@kramser.xyz&lc=US&item_name=NightOwl+Donation&no_note=0&no_shipping=2&curency_code=USD&bn=PP-DonationsBF:btn_donateCC_LG.gif:NonHosted"

    @IBOutlet weak var webView: WKWebView!
    
    @IBAction func backButton(_ sender: Any) {
        webView.goBack()
    }
    @IBAction func browserButton(_ sender: Any) {
        if let url = URL(string: donateURL),
            NSWorkspace.shared.open(url) {
            GoogleReporter.shared.event("Donation", action: "Donation Browser opened", label: appVersion, parameters: [ : ])
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.load(URLRequest(url: URL(string: donateURL)!))
        GoogleReporter.shared.event("Donation", action: "Donation Window shown", label: appVersion, parameters: [ : ])
    }
    
}
