//
//  PreviewTableViewCell.swift
//  TableViewPrefetching
//
//  Created by Sudhakar on 27/01/20.
//  Copyright © 2020 Sudhakar. All rights reserved.
//

import UIKit

class PreviewTableViewCell: UITableViewCell {

    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var previewImg: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func updateAppearanceFor(_ image:UIImage?){
        DispatchQueue.main.async { [unowned self] in
            self.displayPreview(image)
        }
    }
    private func displayPreview(_ image:UIImage?){
        if let image = image{
            previewImg.image = image
            loader.stopAnimating()
        }else{
            loader.startAnimating()
            previewImg.image = .none
        }
    }
}
