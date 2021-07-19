//
//  BasicAlertViewController.swift
//  GettMobileDelivery
//
//  Created by Roi Kedarya on 17/07/2021.
//

import Foundation
import UIKit

class BasicAlertViewController: UIViewController {
    
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var alertLabel: UILabel!
    
    static let identifier = "BasicAlertViewController"
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        loadNib()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadNib()
    }
    
    private func addGesture() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(dismissAlert))
        self.view.addGestureRecognizer(gesture)
    }
    
    @objc private func dismissAlert() {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func loadNib() {
        Bundle.main.loadNibNamed("BasicAlertViewController", owner: self, options: nil)
        addGesture()
    }
}
