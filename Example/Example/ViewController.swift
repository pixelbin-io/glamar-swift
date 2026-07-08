//
//  ViewController.swift
//  Example
//
//  Created by Dipendra Sharma on 29/08/24.
//

import UIKit
import GlamAR
import WebKit

class ViewController: UIViewController {
    private var showingOriginal = false
    
    @IBOutlet weak var glamARWebView: WKWebView!
    
    @IBAction func onApplyClick(_ sender: Any) {
      GlamAr.applySku("e823e409-324f-44f8-8708-6463f89d36a5")
    }
    
    @IBAction func onClearClick(_ sender: Any) {
        GlamAr.reset(["skuIds": ["e823e409-324f-44f8-8708-6463f89d36a5"]])
    }
    
    @IBAction func onToggleClick(_ sender: Any) {
        GlamAr.skinAnalysis(options: "start")
    }
    
    @IBAction func onExportClick(_ sender: Any) {
      GlamAr.applySku("694b5a2f-1d9d-4448-a0c9-27a4b6917cd9")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let webview = GlamArWebViewManager.shared.getPreparedWebView(), (glamARWebView != nil) {
            
            glamARWebView.addSubview(webview)
            
            webview.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                webview.topAnchor.constraint(equalTo: glamARWebView.topAnchor),
                webview.bottomAnchor.constraint(equalTo: glamARWebView.bottomAnchor),
                webview.leadingAnchor.constraint(equalTo: glamARWebView.leadingAnchor),
                webview.trailingAnchor.constraint(equalTo: glamARWebView.trailingAnchor)
            ])
        }
        
        GlamAr.addEventListener(event: "sku-applied") { (callbackValue) in
            print("sku-applied: \(callbackValue ?? "")")
        }
        
        GlamAr.addEventListener(event: "sku-failed") { (callbackValue) in
            print("sku-failef: \(callbackValue ?? "")")
        }
        
        GlamAr.addEventListener(event: "init-complete") { (callbackValue) in
            print("init-complete: \(callbackValue ?? "")")
        }
        
        GlamAr.addEventListener(event: "loaded") { (callbackValue) in
            print("loaded-callback: \(callbackValue ?? "")")
        }
    }
}

