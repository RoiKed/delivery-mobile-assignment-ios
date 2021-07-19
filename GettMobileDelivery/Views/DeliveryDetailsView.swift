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
    var instructions = [String]() {
        didSet {
            if instructions.count > 0 {
                instructionsLabel.text = instructions.first
            }
        }
    }
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var forward: UIButton!
    @IBOutlet weak var backword: UIButton!
    
    static let identifier = "DeliveryDetailsView"
    var index: Int
    
    func loadViewFromNib() -> UIView? {
        let nib = UINib(nibName: DeliveryDetailsView.identifier, bundle: Bundle.main)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
    
    init(frame: CGRect, instructions: [String]) {
        self.index = 0
        super.init(frame: frame)
        xibSetUp()
    }
    
    required init?(coder: NSCoder) {
        self.index = 0
        super.init(coder: coder)
        xibSetUp()
    }
    
    private func xibSetUp() {
        view = loadViewFromNib()
        view.frame = self.bounds
        view.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        addSubview(view)
        setButtonCornerRadius(button: self.forward)
        setButtonCornerRadius(button: self.backword)
    }
    
    private func setButtonCornerRadius(button: UIButton) {
        if let imageView = button.imageView {
            imageView.layer.masksToBounds = false
            imageView.layer.borderWidth = 1.0
            imageView.layer.borderColor = UIColor.black.cgColor
            imageView.layer.cornerRadius = imageView.frame.height/2
            imageView.clipsToBounds = true
        }
    }
    
    //MARK: IBActions
    
    @IBAction func backButtonTapped(_ sender: Any) {
        if index > 0 {
            index -= 1
            instructionsLabel.text = instructions[index]
        }
    }
    
    @IBAction func forwardButtonTapped(_ sender: Any) {
        if index < instructions.count - 1 {
            index += 1
            instructionsLabel.text = instructions[index]
        }
    }
}
