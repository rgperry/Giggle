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
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        return view
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.contentMode = .scaleAspectFill
        //imageView.backgroundColor = UIColor.purple
        imageView.clipsToBounds = true
        //mask
        contentView.addSubview(overlayView)
        contentView.sendSubviewToBack(overlayView)
        
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        let padding: CGFloat = 0
        imageView.frame = bounds.insetBy(dx: padding, dy: padding)
        overlayView.frame = CGRect(
            x: padding,
            y: padding,
            width: contentView.bounds.width - padding * 2,
            height: contentView.bounds.height - padding * 2
        )
        imageView.layer.cornerRadius = 10
        overlayView.layer.cornerRadius = 10
    }
}
