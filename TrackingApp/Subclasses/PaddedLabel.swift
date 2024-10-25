//
//  PaddedLabel.swift
//  TrackingApp
//
//  Created by Jose on 25/10/2024.
//

import UIKit

final class PaddedLabel: UILabel {
    var contentEdgeInsets = UIEdgeInsets.zero
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: contentEdgeInsets))
    }
    
    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        size.width += contentEdgeInsets.left + contentEdgeInsets.right
        size.height += contentEdgeInsets.top + contentEdgeInsets.bottom
        return size
    }
}
