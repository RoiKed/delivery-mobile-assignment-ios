//
//  LaunchView.swift
//  GettMobileDelivery
//
//  Created by Roi Kedarya on 18/07/2021.
//

import Foundation
import UIKit

class LaunchView: UIView {
    
    static let identifier = "LaunchView"
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initSubViews()
    }
    
    private func initSubViews() {
        if let nib = Bundle.main.loadNibNamed(LaunchView.identifier, owner: self, options: nil)?.first,let viewFromXib = nib as? UIView {
            viewFromXib.frame = self.bounds
            addSubview(viewFromXib)
        }
    }
}
