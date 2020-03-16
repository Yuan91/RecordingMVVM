//
//  Coordinator.swift
//  RecordingMVVM
//
//  Created by du on 2020/3/16.
//  Copyright © 2020 alpha. All rights reserved.
//

import Foundation
import UIKit

//定义协调器,处理界面跳转
final class Coordinator {
    let splitViewController: UISplitViewController
    
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    var folderNavigationController: UINavigationController {
        return splitViewController.viewControllers[0] as! UINavigationController
    }
    
    init(_ splitView: UISplitViewController) {
        self.splitViewController = splitView
        self.splitViewController.loadViewIfNeeded()
        
        let folderVc = folderNavigationController.viewControllers.first as! FolderViewController
        folderVc.delegate = self
        #warning("设置ViewModel")
        
        #warning("疑问1:为什么放这里")
        folderVc.navigationItem.leftItemsSupplementBackButton = true
        folderVc.navigationItem.leftBarButtonItem = folderVc.editButtonItem
        
        #warning("疑问2:为什么放这里")
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleChangeNotification(_:)),
                                               name: Store.changedNotification,
                                               object: nil)
    }
    
    @objc func handleChangeNotification(_ notification: Notification) {
        guard let
            userInfo = notification.userInfo,
            userInfo[Item.changeReasonKey] as? String == Item.removed,
            let folder = notification.object as? Folder
        else { return  }
        updateForRemoval(of: folder)
    }
    
    func updateForRemoval(of folder: Folder) {
        #warning("处理删除操作")
    }
}

// MARK:- FolderViewControllerDelegate
extension Coordinator: FolderViewControllerDelegate {
    func didSelect(_ item: Item) {
        
    }
    
    func createRecording(in folder: Folder) {
        
    }
}
