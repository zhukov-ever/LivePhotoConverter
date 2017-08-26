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
        
        navigationController?.isToolbarHidden = false
        
        updateLivePhoto()
    }

    var targetSize: CGSize {
        let scale = UIScreen.main.scale
        return CGSize(width: livePhotoView.bounds.width * scale,
                      height: livePhotoView.bounds.height * scale)
    }
    
    func updateLivePhoto() {
        let options = PHLivePhotoRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        options.progressHandler = { progress, _, _, _ in
            DispatchQueue.main.sync {
                self.progressView.progress = Float(progress)
            }
        }
        
        self.progressView.isHidden = false
        
        PHImageManager.default().requestLivePhoto(for: asset,
                                                  targetSize: targetSize,
                                                  contentMode: .aspectFit,
                                                  options: options,
                                                  resultHandler:
            { livePhoto, _ in
                
                self.progressView.isHidden = true
                
                
                guard let livePhoto = livePhoto else { return }
                
                self.livePhotoView.isHidden = false
                self.livePhotoView.livePhoto = livePhoto
                
        })
    }
    
    func play() {
        self.livePhotoView.startPlayback(with: .full)
    }

    func makeVideo() {

        let filePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/" + asset.localIdentifier + ".mov"
        guard let fileUrl = URL(string: filePath)
            else { fatalError() }

        
        let options = PHVideoRequestOptions()
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .automatic
        options.progressHandler = { progress, _, _, _ in
            DispatchQueue.main.sync {
                self.progressView.progress = Float(progress)
            }
        }
        
        
        guard let livePhoto = livePhotoView.livePhoto else {
            return
        }
        let assetResources = PHAssetResource.assetResources(for: livePhoto)
        var videoResource:PHAssetResource?
        for resource in assetResources {
            if (resource.type == PHAssetResourceType.pairedVideo) {
                videoResource = resource;
                break;
            }
        }

        guard let _videoResource = videoResource else {
            return
        }
        
        print("kek")

        PHAssetResourceManager.default().writeData(for: _videoResource, toFile: fileUrl, options: nil) { (error:Error?) in
//            assert(error == nil)
        }
    }

    
    
    
    @IBAction func makeVideoHandler(_ sender: Any) {
        makeVideo()
    }
    
    @IBAction func playHandler(_ sender: Any) {
        play()
    }
    
    
}



extension PhotoViewController: PHLivePhotoViewDelegate {
    
}

