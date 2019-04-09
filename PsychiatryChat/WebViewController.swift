//
//  WebViewController.swift
//  PsychiatryChat
//
//  Created by YU on 2019/4/3.
//  Copyright © 2019 ameyo. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let webView = WKWebView(frame: CGRect(x: 0, y: 65, width: view.frame.width, height: view.frame.height))
        if let url = URL(string: "https://www.facebook.com/Find-Mend-2328917357385065/") {
        let myRequest = URLRequest(url: url)
            webView.load(myRequest)
        }
        view.addSubview(webView)
    }
}
