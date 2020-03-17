//
//  Item+Rx.swift
//  RecordingMVVM
//
//  Created by du on 2020/3/16.
//  Copyright © 2020 alpha. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

extension Item: IdentifiableType, Hashable {
    var hashValue: Int { return uuid.hashValue }
    static func ==(lhs: Item, rhs: Item) -> Bool {
        return lhs.uuid == rhs.uuid
    }
    
    var identity: UUID { return uuid }
    
    //NotificationCenter.default.rx.notification(Store.changedNotification) folder元素变化的通知
    //转换为一个 changeObservable: Observable<()> 可观测序列
    var changeObservable: Observable<()> {
        //filter 对 序列中的元素按照闭包中的条件进行过滤
        return NotificationCenter.default.rx.notification(Store.changedNotification).filter { [weak self] (note) -> Bool in
            print("接收到change notification --> 1")
            guard let s = self else { return false }
            if let item = note.object as? Item, item == s, !(note.userInfo?[Item.changeReasonKey] as? String == Item.removed) {
                return true
            } else if let userInfo = note.userInfo, userInfo[Item.parentFolderKey] as? Folder == s {
                return true
            }
            return false
        }.map { _ -> () in
            print("change notification过滤为 changeObservable序列")
        }
    }
    
    
    //将删除通知转化为 序列
    var deleteObservable: Observable<()> {
        return NotificationCenter.default.rx.notification(Store.changedNotification).filter { [weak self] (notification) -> Bool in
            print("接收到change notification --> 2")
            guard let `self` = self else { return false }
            if let item = notification.object as? Item, item == self, let userInfo = notification.userInfo , userInfo[Item.changeReasonKey] as? String == Item.removed {
                return true
            }
            return false
        }.map { (_) -> Void in
            print("change notification过滤为 deleteObservable序列")
        }
    }
    
}
