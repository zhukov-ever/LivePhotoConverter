//
//  PhotoViewController.swift
//  LivePhotoConverter
//
//  Created by Nikita Zhukov on 16/8/17.
//  Copyright © 2017 Nikita Zhukov. All rights reserved.
//

import UIKit
import Photos
import PhotosUI


class PhotoViewController: UIViewController {

    let livePhotoView = PHLivePhotoView()
    
    var asset: PHAsset!
    
    @IBOutlet weak var progressView: UIProgressView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        livePhotoView.frame = view.bounds
        view.addSubview(livePhotoView)
        livePhotoView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        livePhotoView.delegate = self
        
        updateLivePhoto()
    }

    var targetSize: CGSize {
        let scale = UIScreen.main.scale
        return CGSize(width: livePhotoView.bounds.width * scale,
                      height: livePhotoView.bounds.height * scale)
    }
    
    func updateLivePhoto() {
        // Prepare the options to pass when fetching the live photo.
        let options = PHLivePhotoRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        options.progressHandler = { progress, _, _, _ in
            // Handler might not be called on the main queue, so re-dispatch for UI work.
            DispatchQueue.main.sync {
                self.progressView.progress = Float(progress)
            }
        }
        
        self.progressView.isHidden = false
        // Request the live photo for the asset from the default PHImageManager.
        PHImageManager.default().requestLivePhoto(for: asset,
                                                  targetSize: targetSize,
                                                  contentMode: .aspectFit,
                                                  options: options,
                                                  resultHandler:
            { livePhoto, _ in
//                // Hide the progress view now the request has completed.
                self.progressView.isHidden = true
                
                // If successful, show the live photo view and display the live photo.
                guard let livePhoto = livePhoto else { return }
                
                // Now that we have the Live Photo, show it.
//                self.imageView.isHidden = true
//                self.animatedImageView.isHidden = true
                self.livePhotoView.isHidden = false
                self.livePhotoView.livePhoto = livePhoto
                
                self.livePhotoView.startPlayback(with: .full)
//                if !self.isPlayingHint {
//                    // Playback a short section of the live photo; similar to the Photos share sheet.
//                    self.isPlayingHint = true
//                    self.livePhotoView.startPlayback(with: .hint)
//                }
                
        })
    }

}



extension PhotoViewController: PHLivePhotoViewDelegate {
    
}

