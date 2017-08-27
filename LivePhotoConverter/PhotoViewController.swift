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
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        livePhotoView.frame = view.bounds
        view.insertSubview(livePhotoView, at: 0)
        livePhotoView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        livePhotoView.delegate = self
        livePhotoView.contentMode = .scaleAspectFit
        
        updateLivePhoto()
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
        PHImageManager.default().requestLivePhoto(for: asset, targetSize: livePhotoView.bounds.size, contentMode: PHImageContentMode.aspectFit, options: options) { (livePhoto:PHLivePhoto?, params:[AnyHashable : Any]?) in
            
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

    func makeTempVideoFile(urlToFile:@escaping (URL)->Void) {

        let filePath = NSTemporaryDirectory() + "tmp" + ".mov"
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

        do {
            if FileManager.default.fileExists(atPath: filePath) {
                try FileManager.default.removeItem(at: fileUrl)
            }
        } catch {
            fatalError()
        }
        
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

    func saveToDocumentsHandler() {
        makeTempVideoFile { (url:URL) in
            let dfDay = DateFormatter()
            dfDay.dateFormat = "yyyyMMdd"
            let dfTime = DateFormatter()
            dfTime.dateFormat = "HHmmss"
            
            let moviesDirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]  + "/" + dfDay.string(from: Date()) + "/"
            let moviesDirUrl = URL(fileURLWithPath: moviesDirPath, isDirectory: true)
            let filePath = moviesDirPath + dfTime.string(from: Date()) + ".mov"
            let fileUrl = URL(fileURLWithPath: filePath)
            
            do {
                if !FileManager.default.fileExists(atPath: moviesDirPath) {
                    try FileManager.default.createDirectory(at: moviesDirUrl, withIntermediateDirectories: true, attributes: nil)
                }
                try FileManager.default.copyItem(at: url, to: fileUrl)
            } catch {
                fatalError()
            }
        }
    }
    
    func shareWithOtherHandler() {
        makeTempVideoFile { (url:URL) in
            let dfDay = DateFormatter()
            dfDay.dateFormat = "yyyyMMdd"
            let dfTime = DateFormatter()
            dfTime.dateFormat = "HHmmss"
            
            let moviesDirPath = NSTemporaryDirectory() + dfDay.string(from: Date()) + "/"
            let moviesDirUrl = URL(fileURLWithPath: moviesDirPath, isDirectory: true)
            let filePath = moviesDirPath + dfTime.string(from: Date()) + ".mov"
            let fileUrl = URL(fileURLWithPath: filePath)
            
            do {
                if !FileManager.default.fileExists(atPath: moviesDirPath) {
                    try FileManager.default.createDirectory(at: moviesDirUrl, withIntermediateDirectories: true, attributes: nil)
                }
                try FileManager.default.copyItem(at: url, to: fileUrl)
            } catch {
                fatalError()
            }
            
            let vc = UIActivityViewController(activityItems: [fileUrl], applicationActivities: nil)
            vc.popoverPresentationController?.barButtonItem = self.shareButton
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func shareHandler(_ sender: Any) {
        let alert = UIAlertController(title: "Choose action", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        alert.addAction(UIAlertAction(title: "save to Documents", style: UIAlertActionStyle.default, handler: { _ in
            self.saveToDocumentsHandler()
        }))
        alert.addAction(UIAlertAction(title: "share with ...", style: UIAlertActionStyle.default, handler: { _ in
            self.shareWithOtherHandler()
        }))
        alert.addAction(UIAlertAction(title: "cancel", style: UIAlertActionStyle.destructive	, handler: { _ in
        }))
        alert.popoverPresentationController?.barButtonItem = self.shareButton
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func playHandler(_ sender: Any) {
        play()
    }
    
    
}



extension PhotoViewController: PHLivePhotoViewDelegate {
    
}

