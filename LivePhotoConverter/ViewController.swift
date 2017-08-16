//
//  ViewController.swift
//  LivePhotoConverter
//
//  Created by Nikita Zhukov on 16/8/17.
//  Copyright © 2017 Nikita Zhukov. All rights reserved.
//

import UIKit
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        styleRequestPermissions()
        view = viewWaitingForPermissions
        
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
            
        }, cancelled: { (results) -> Void in
            
        })
    }
    
    @IBAction func requestPermissionHandler(_ sender: Any) {
        requestPermissions()
    }
    
}
