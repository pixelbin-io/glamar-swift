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
        GlamAr.applySku("48062362-cd9d-4a63-b755-3a9ed639f023")
    }
    
    @IBAction func onClearClick(_ sender: Any) {
        GlamAr.close()
    }
    
    @IBAction func onToggleClick(_ sender: Any) {
        
    }
    
    @IBAction func onExportClick(_ sender: Any) {
        GlamAr.snapshot()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let webview = GlamArWebViewManager.shared.getPreparedWebView() {
            
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
    }
}

