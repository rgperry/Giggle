//
//  ImageCell.swift
//  Giggle
//
//  Created by Tamaer Alharastani on 10/27/24.
//

import UIKit

class ImageCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.contentMode = .scaleAspectFit // Makes the image fit within the cell without cropping
        imageView.clipsToBounds = true          // Ensures the image is clipped to the bounds
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Add padding by setting imageView's frame to be smaller than cell bounds
        let padding: CGFloat = 0
        imageView.frame = bounds.insetBy(dx: padding, dy: padding)
    }


}
