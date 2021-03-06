//
//  Folder.swift
//  RecordingsMVC
//
//  Created by du on 2020/2/29.
//

import UIKit

class Folder: Item, Codable {
    private(set) var contents: [Item]
    override weak var store: Store? {
        didSet {
            contents.forEach({ $0.store = store })
        }
    }
    
    override init(name: String, uuid: UUID) {
        contents = [Item]()
        super.init(name: name, uuid: uuid)
    }
    
    // MARK: --- logic ---
    /**
     一个合理的addItem 操作:
     1.(model 层)外部完成的Item处理及自定义,如修改名称
     2.model 层,将item 添加到数组,并进行排序等操作
     3.model 层调用 Store 层方法,存储数据,并把一些变更的信息传递过去
     4.Store 层存储数据,发送通知
     */
    func add(_ item: Item) {
        assert(contents.contains(where: { $0 === item }) == false )
        contents.append(item)
        contents.sort { return $0.name < $1.name }
        let newIndex = contents.firstIndex(where: { $0 === item })!
        //将item 添加到folder 的时候才有 parent;
        //添加录音 setName 时,就利用这一特性,拦截了部分操作
        item.parent = self
        let userInfo: [AnyHashable:Any] = [
                        Item.changeReasonKey:Item.added,
                        Item.newValueKey:newIndex,
                        Item.parentFolderKey:self]
        store?.save(item, userInfo: userInfo)
    }
    
    /// 重新排序
    func reSort(changedItem: Item) -> (oldIndex:Int, newIndex: Int){
        let oldIndex = contents.firstIndex(where: { $0 === changedItem })!
        contents.sort { $0.name < $1.name }
        let newIndex = contents.firstIndex(where: { $0 === changedItem })!
        return (oldIndex, newIndex)
    }
    
    /// 删除操作
 /**
     item.deleted() 这个操作很精髓
     因为Recording和Folder 都重写了父类的 delete() 方法,
     所以当是recording 的时候, 就调用录音的删除方法
     当时folder 的时候,就调用Folder类重写的delete() 方法
     */
    
    func deleteItem(_ item: Item) {
        guard let index = contents.firstIndex(where: { $0 === item }) else { return }
        item.deleted()
        contents.remove(at: index)
        let userInfo: [AnyHashable: Any] = [Item.changeReasonKey: Item.removed,
                                            Item.parentFolderKey: self,
                                            Item.oldValueKey: index]
        store?.save(item, userInfo: userInfo)
    }
    
    //循环删除当前folder 下的内容,包括录音和文件夹
    override func deleted() {
        for item in contents {
            deleteItem(item)
        }
        super.deleted()
    }
    
    // MARK: --- 序列化 ---
    enum FolderKeys: CodingKey { case name, uuid, contents }
    enum FolderOrRecording: CodingKey { case folder, recording }
    
    required init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: FolderKeys.self)
        contents = [Item]()
        var nested = try c.nestedUnkeyedContainer(forKey: .contents)
        while true {
            let wrapper = try nested.nestedContainer(keyedBy: FolderOrRecording.self)
            if let f = try wrapper.decodeIfPresent(Folder.self, forKey: .folder) {
                contents.append(f)
            } else if let r = try wrapper.decodeIfPresent(Recording.self, forKey: .recording) {
                contents.append(r)
            } else {
                break
            }
        }

        let uuid = try c.decode(UUID.self, forKey: .uuid)
        let name = try c.decode(String.self, forKey: .name)
        super.init(name: name, uuid: uuid)
        
        for c in contents {
            c.parent = self
        }
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: FolderKeys.self)
        try c.encode(name, forKey: .name)
        try c.encode(uuid, forKey: .uuid)
        var nested = c.nestedUnkeyedContainer(forKey: .contents)
        for c in contents {
            var wrapper = nested.nestedContainer(keyedBy: FolderOrRecording.self)
            switch c {
            case let f as Folder: try wrapper.encode(f, forKey: .folder)
            case let r as Recording: try wrapper.encode(r, forKey: .recording)
            default: break
            }
        }
        _ = nested.nestedContainer(keyedBy: FolderOrRecording.self)
    }
    
    override func item(atUUIDPath path: ArraySlice<UUID>) -> Item? {
        guard path.count > 1 else { return super.item(atUUIDPath: path) }
        guard path.first == uuid else { return nil }
        let subsequent = path.dropFirst()
        guard let second = subsequent.first else { return nil }
        return contents.first { $0.uuid == second }.flatMap { $0.item(atUUIDPath: subsequent) }
    }
    
}
