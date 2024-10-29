//
//  ImageCell.swift
//  Giggle
//
//  Created by Tamaer Alharastani on 10/27/24.
//

import UIKit

class ImageCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    private let overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 10  // Adjust radius as needed
        view.layer.masksToBounds = true
        return view
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.contentMode = .scaleAspectFit // Makes the image fit within the cell without cropping
        //imageView.backgroundColor = UIColor.purple
        imageView.clipsToBounds = true          // Ensures the image is clipped to the bounds
        
        // Add overlayView to the contentView and ensure it appears above the image
        contentView.addSubview(overlayView)
        contentView.sendSubviewToBack(overlayView)
        
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Add padding by setting imageView's frame to be smaller than cell bounds
        let padding: CGFloat = 0
        imageView.frame = bounds.insetBy(dx: padding, dy: padding)
        overlayView.frame = CGRect(
            x: padding,
            y: padding,
            width: contentView.bounds.width - padding * 2,
            height: contentView.bounds.height - padding * 2
        )
    }
}
