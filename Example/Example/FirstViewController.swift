//
//  InitialViewController.swift
//  Example
//
//  Created by Anitha Sangu on 03/01/25.
//

import UIKit
import GlamAR

class FirstViewController: UIViewController {
        
    @IBAction func nextTapped(_ sender: UIButton) {
        nextTapped()
    }
 
    func nextTapped() {
        if let secondVC = storyboard?.instantiateViewController(withIdentifier: "ViewController") as? ViewController {
            self.navigationController?.pushViewController(secondVC, animated: true)
        }
    }
}
