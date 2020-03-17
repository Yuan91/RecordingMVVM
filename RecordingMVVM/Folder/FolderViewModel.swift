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
   
    //1.ViewModel肯定是需要一个Model来初始化的
    let folder: BehaviorRelay<Folder>
   //3. RxSwift 通过序列的变更来实现逻辑,这个属性表示folder的最新值,当folder被删除时会置位nil
    private let folderUntilDeleted: Observable<Folder?>
    
    init(_ folder: Folder = Store.shared.rootFolder) {
        //2.folderModel 需要是可观测的,它的变化需要反映到界面上
        self.folder = BehaviorRelay(value: folder)
        
        //4. folderUntilDeleted 表示当前文件夹最新值,如果被删除则为nil
        folderUntilDeleted = self.folder.flatMapLatest({ (currentFolder) -> Observable<Folder?> in
            
            Observable.just(currentFolder)
                .concat(currentFolder.changeObservable.map({ _ -> Folder in
                    print("folder changeObservable 先到这里")
                return currentFolder
            }))
                .takeUntil(currentFolder.deleteObservable)
                .concat(Observable.just(nil))
        })
            .share(replay: 1, scope: .whileConnected)
    }
    
    //MARK:- 分离到ViewModel 的逻辑
    func create(folderNamed name: String?) {
        guard let s = name else {
            return
        }
        let newFolder = Folder(name: s, uuid: UUID())
        self.folder.value.add(newFolder)
        self.folder.accept(self.folder.value)
    }
    
    func deleteItem(_ item: Item)  {
        self.folder.value.deleteItem(item)
        self.folder.accept(self.folder.value)
    }
    
    //MARK: - 数据变形,生成能成直接显示在View的数据. 同时将这些数据变成可观测序列,方便进行绑定
    var navigationTitle: Observable<String> {
        return folderUntilDeleted.map { (currentFolder) -> String in
            guard let folder = currentFolder else {
                return ""
            }
            return folder.parent == nil ?  .recordings : folder.name
        }
    }
    
    var navigationTitleDriver: Driver<String> {
        return folderUntilDeleted.asDriver(onErrorJustReturn: nil).map { (currentFolder) -> String in
            guard let folder = currentFolder else {
                return ""
            }
            return folder.parent == nil ?  .recordings : folder.name
        }
    }
    
    //数据源
    var folderContents: Observable<[AnimatableSectionModel<Int,Item>]> {
        return folderUntilDeleted.map { (currentFolder)  in
            guard let folder = currentFolder else { return [AnimatableSectionModel(model: 0, items: [])] }
            return [AnimatableSectionModel(model: 0, items: folder.contents)]
        }
    }
    
    var folderContentsDriver: Driver<[AnimatableSectionModel<Int,Item>]> {
        return folderUntilDeleted.asDriver(onErrorJustReturn: nil).map { (currentFolder)  in
            guard let folder = currentFolder else { return [AnimatableSectionModel(model: 0, items: [])] }
            return [AnimatableSectionModel(model: 0, items: folder.contents)]
        }
    }
    
    //MARK: - 工具方法
    static func textForItem(_ item: Item) -> String {
        return "\(item.isFolder ? "📁" : "🔊") \(item.name)"
    }
    
}

fileprivate extension String {
    static let recordings = NSLocalizedString("Recordings", comment: "Heading for the list of recorded audio items and folders.")
}
