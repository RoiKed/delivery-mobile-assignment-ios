//
//  DeliveryDetailsView.swift
//  GettMobileDelivery
//
//  Created by Roi Kedarya on 17/07/2021.
//

import Foundation
import UIKit

class DeliveryDetailsView: UIView {
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet var view: UIView!
    @IBOutlet weak var addressLabel: UILabel!
    
    static let identifier = "DeliveryDetailsView"
    
    func loadViewFromNib() -> UIView? {
        let nib = UINib(nibName: DeliveryDetailsView.identifier, bundle: Bundle.main)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
    
    override init(frame: CGRect) {
            super.init(frame: frame)
            xibSetUp()
        }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        xibSetUp()
    }
    
    func xibSetUp() {
        view = loadViewFromNib()
        view.frame = self.bounds
        view.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        addSubview(view)
    }
    
}
