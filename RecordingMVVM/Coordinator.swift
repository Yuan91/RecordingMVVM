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
        folderVc.viewModel.folder.accept(Store.shared.rootFolder)
        
        #warning("疑问1:为什么放这里")
        folderVc.navigationItem.leftItemsSupplementBackButton = true
        folderVc.editButtonItem.tintColor = .darkGray
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
        print("这是什么操作")
        let folderVCs = folderNavigationController.viewControllers as! [FolderViewController]
        guard let index = folderVCs.firstIndex(where: {
            print("当前控制器持有的Folder对象:\($0.viewModel.folder.value)")
            print("当前删除的列表Folder对象:\(folder)")
           return $0.viewModel.folder.value === folder
        }) else { return }
        let previousIndex = index > 0 ? index - 1 : index
        folderNavigationController.popToViewController(folderVCs[previousIndex], animated: true)
    }
}

// MARK:- FolderViewControllerDelegate
extension Coordinator: FolderViewControllerDelegate {
    func didSelect(_ item: Item) {
        
    }
    
    func createRecording(in folder: Folder) {
        let recordVC = storyboard.instantiateRecordViewController(with: folder, delegate: self)
        recordVC.modalPresentationStyle = .formSheet
        recordVC.modalTransitionStyle = .crossDissolve
        splitViewController.present(recordVC, animated: true)
    }
}

//MARK: - RecordViewControllerDelegate
extension Coordinator: RecordViewControllerDelegate {
    func finishedRecording(_ recordVC: RecordViewController) {
        recordVC.dismiss(animated: true, completion: nil)
    }
}


//MARK: - 创建ViewController
extension UIStoryboard {
    func instantiateRecordViewController(with folder:Folder, delegate: RecordViewControllerDelegate) -> RecordViewController {
        let recordVc = instantiateViewController(withIdentifier: "recorderViewController") as! RecordViewController
        recordVc.delegate = delegate
        recordVc.viewModel.folder = folder
        return recordVc
    }
}
