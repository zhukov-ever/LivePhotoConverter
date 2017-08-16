//
//  ViewController.swift
//  LivePhotoConverter
//
//  Created by Nikita Zhukov on 16/8/17.
//  Copyright © 2017 Nikita Zhukov. All rights reserved.
//

import UIKit
import Photos
import PhotosUI
import PermissionScope


class MainViewController: UIViewController {

    let pscope = { () -> PermissionScope in 
        let _pscope = PermissionScope()
        _pscope.closeButton.isHidden = true
        _pscope.addPermission(PhotosPermission(),
                              message: "Photos will use for further work of application")
        
        return _pscope
    }()
    
    @IBOutlet var viewWaitingForPermissions: UIView!
    @IBOutlet weak var buttonRequestPermission: UIButton!

    
    var fetchResult: PHFetchResult<PHAsset>!
    let imageManager = PHCachingImageManager()
    @IBOutlet var collectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        styleRequestPermissions()
        view = viewWaitingForPermissions
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        requestPermissions()
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let viewController = segue.destination as? PhotoViewController else {
            return
        }
        guard let assetItem = collectionView.indexPathsForSelectedItems?.first?.item else {
            return
        }
        
        viewController.asset = fetchResult.object(at: assetItem)
    }


}



extension MainViewController {
    
    func styleRequestPermissions() {
        viewWaitingForPermissions.backgroundColor = UIColor.white
        buttonRequestPermission.setTitle("grant permission", for: UIControlState.normal)
    }
    
    func requestPermissions() {
        
        pscope.show({ finished, results in
            self.view = self.collectionView
            self.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            self.reloadPhotosLibrary()
        }, cancelled: { (results) -> Void in
            
        })
    }
    
    @IBAction func requestPermissionHandler(_ sender: Any) {
        requestPermissions()
    }
    
}



extension MainViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    func reloadPhotosLibrary() {
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        fetchResult = PHAsset.fetchAssets(with: allPhotosOptions)
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let asset = fetchResult.object(at: indexPath.item)
        
        if asset.mediaSubtypes.contains(.photoLive) {
            performSegue(withIdentifier: "show-photo", sender: nil)
        } else {
            print("not a live photo")
        }
        
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return fetchResult.count
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? PhotosCollectionViewCell else {
            fatalError("unexpected cell in collection view")
        }
        
        let asset = fetchResult.object(at: indexPath.item)
        
        cell.labelLive.isHidden = !asset.mediaSubtypes.contains(.photoLive)
        
        cell.representedAssetIdentifier = asset.localIdentifier
        imageManager.requestImage(for: asset, targetSize: CGSize(width: 150, height: 150), contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
            if cell.representedAssetIdentifier == asset.localIdentifier && image != nil {
                cell.imageViewPhoto.image = image
            }
        })
        
        return cell
    }
    
    
    

    
}
