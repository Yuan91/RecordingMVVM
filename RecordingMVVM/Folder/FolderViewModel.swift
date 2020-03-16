//
//  FolderViewModel.swift
//  RecordingMVVM
//
//  Created by du on 2020/3/16.
//  Copyright © 2020 alpha. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

/**
 按照MVVM的设计
 ①ViewModel 应该接受处理更改Model的操作. 即需要从ViewController中分离出来这部分操作
 ②ViewModel 负责观察Model的变更. ViewModel 需要订阅 Model 的变更
 ③ViewModel 负责将变更发送到ViewController. ViewModel 需要包含一个 Observable 对象,Controller 将它的内容绑定到 View 上.
 
 */

class FolderViewModel {
    var folder: Folder
    
    var test: BehaviorRelay<Folder>?
    
    init(_ folder: Folder) {
        self.folder = folder
        
//        folder.deleteObservable
    }
}
