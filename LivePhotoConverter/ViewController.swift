//
//  ViewController.swift
//  LivePhotoConverter
//
//  Created by Nikita Zhukov on 16/8/17.
//  Copyright © 2017 Nikita Zhukov. All rights reserved.
//

import UIKit
import Photos
import PermissionScope


class ViewController: UIViewController {

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



}



extension ViewController {
    
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



extension ViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    func reloadPhotosLibrary() {
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        fetchResult = PHAsset.fetchAssets(with: allPhotosOptions)
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
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
