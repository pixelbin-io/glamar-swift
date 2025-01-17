//
//  ViewController.swift
//  Example
//
//  Created by Dipendra Sharma on 29/08/24.
//

import UIKit
import GlamAR

class ViewController: UIViewController {
    private var showingOriginal = false
    
    @IBOutlet weak var glamArView: GlamArView!
    
    @IBAction func onApplyClick(_ sender: Any) {
        self.glamArView.applySku(skuId: "666b311f-1b34-4082-99d1-c525451b44a1", category: "beauty")
    }
    @IBAction func onClearClick(_ sender: Any) {
        self.glamArView.clear()
    }
    @IBAction func onToggleClick(_ sender: Any) {
        showingOriginal = !showingOriginal
        self.glamArView.toggle(showOriginal: showingOriginal)
    }
    @IBAction func onExportClick(_ sender: Any) {
        self.glamArView.snapshot()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        glamArView.setCallback(self)
    }
}

extension ViewController: GlamArViewCallback {
    func onLoaded(mode: GlamAR.PreviewMode) {
        print("onLoaded loaded")
    }
    
    func onFaceAnalysisCompleted(payload: [String : Any]) {
        print("onFaceAnalysisCompleted loaded")
    }
    
    func onInitComplete() {
        print("onInitComplete loaded")
    }
    
    func onLoading() {
        print("onLoading called")
    }
    
    func onSkuApplied() {
        print("onSkuApplied called")
    }
    
    func onSkuFailed() {
        print("onSkuFailed called")
    }
    
    func onPhotoLoaded(payload: [String : Any]) {
        print("onPhotoLoaded called")
    }
    
    func onLoaded() {
        print("onLoaded called")
    }
    
    func onOpened() {
        print("onOpened called")
    }
    
    func onError(message: String) {
        print("onError called")
    }
}

