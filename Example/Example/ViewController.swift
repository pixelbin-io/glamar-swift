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
                self.glamArView.startPreview(previewMode: .image("https://cdn.pixelbin.io/v2/glamar-fynd-835885/original/glamar-custom-data/models/makeup/2.jpg"), isBeauty: false)
//        self.glamArView.startPreview(previewMode: .none)
        //        self.glamArView.startPreview(previewMode: .camera)
        
    }
}

