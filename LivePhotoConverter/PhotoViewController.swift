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
        view.insertSubview(livePhotoView, at: 0)
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
        self.progressView.isHidden = false
        
        let options = PHLivePhotoRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        options.progressHandler = { progress, _, _, _ in
            DispatchQueue.main.sync {
                self.progressView.progress = Float(progress)
            }
        }
        
        self.progressView.isHidden = false
        PHImageManager.default().requestLivePhoto(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options) { (livePhoto:PHLivePhoto?, params:[AnyHashable : Any]?) in
            
            self.progressView.isHidden = true
            
            guard let livePhoto = livePhoto
                else { return }
            
            self.livePhotoView.isHidden = false
            self.livePhotoView.livePhoto = livePhoto
        }
    }
    
    func play() {
        self.livePhotoView.startPlayback(with: .hint)
    }

    func makeVideo(urlToFile:@escaping (URL)->Void) {

        let filePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/" + "tmp" + ".mov"
        let fileUrl = URL(fileURLWithPath: filePath)
        
        guard let livePhoto = livePhotoView.livePhoto
            else { fatalError() }
        
        progressView.isHidden = false
        
        let options = PHAssetResourceRequestOptions()
        options.isNetworkAccessAllowed = true
        options.progressHandler = { progress in
            DispatchQueue.main.sync {
                self.progressView.progress = Float(progress)
            }
        }
        
        let assetResources = PHAssetResource.assetResources(for: livePhoto)
        var videoResource:PHAssetResource?
        for resource in assetResources {
            if (resource.type == PHAssetResourceType.pairedVideo) {
                videoResource = resource
                break;
            }
        }

        guard let _videoResource = videoResource
            else { return }

        
        PHAssetResourceManager.default().requestData(for: _videoResource, options: options, dataReceivedHandler: { (data:Data) in
            do {
                if !FileManager.default.fileExists(atPath: filePath) {
                    try data.write(to: fileUrl, options: Data.WritingOptions.atomic)
                } else {
                    let fileHandle = try FileHandle(forWritingTo: fileUrl)
                    fileHandle.seekToEndOfFile()
                    fileHandle.write(data)
                    fileHandle.closeFile()
                }
                
            } catch {
                fatalError()
            }
            
            
            if data.count == 0 {
                DispatchQueue.main.sync {
                    self.progressView.isHidden = true
                }
                urlToFile(fileUrl)
            }
            
        }) { (error:Error?) in
            DispatchQueue.main.sync {
                self.progressView.isHidden = true
            }
        }
    }

    
    
    
    @IBAction func makeVideoHandler(_ sender: Any) {
        makeVideo { (url:URL) in
            
        }
    }
    
    @IBAction func playHandler(_ sender: Any) {
        play()
    }
    
    
}



extension PhotoViewController: PHLivePhotoViewDelegate {
    
}

