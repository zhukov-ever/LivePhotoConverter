//
//  PhotosCollectionViewCell.swift
//  LivePhotoConverter
//
//  Created by Nikita Zhukov on 16/8/17.
//  Copyright © 2017 Nikita Zhukov. All rights reserved.
//

import UIKit

class PhotosCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var labelLive: UILabel!
    @IBOutlet weak var imageViewPhoto: UIImageView!
    
    var representedAssetIdentifier: String!
    
}
