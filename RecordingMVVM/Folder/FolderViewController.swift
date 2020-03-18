//
//  FolderViewController.swift
//  RecordingsMVC
//
//  Created by du on 2020/2/12.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

fileprivate extension String{
    static let showRecorder = "showRecorder"
    static let showPlayer = "showPlayer"
    static let showFolder = "showFolder"
    static let recordings = NSLocalizedString("Recordings", comment: "Heading for the list of recorded audio items and folders.")
}

//定义协议 处理界面跳转
protocol FolderViewControllerDelegate: class {
    //跳转到 Item 详情界面
    func didSelect(_ item: Item)
    //跳转到 录音界面
    func createRecording(in folder: Folder)
}

class FolderViewController: UITableViewController {
    
    weak var delegate: FolderViewControllerDelegate?
    let viewModel = FolderViewModel()
    let disposeBag = DisposeBag()
    
    var dataSource: RxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<Int,Item>> {
        return RxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<Int,Item>>(
            configureCell: { (dataSource,tableView,index,item) in
            let identifier = item is Recording ? "RecordingCell" : "FolderCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: index)
            cell.textLabel!.text = FolderViewModel.textForItem(item)
            return cell
        },
            canEditRowAtIndexPath: { _, _ in
                return true
        }
        )
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindData()
    }
    
    
    //MARK: - Bind
    func bindData() {
        //因为继承 UITableViewController 所以默认带一个 dataSource?
        tableView.dataSource = nil
        tableView.delegate = nil
        
        viewModel.navigationTitle
            .bind(to: self.navigationItem.rx.title)
            .disposed(by: disposeBag)
        
        viewModel.folderContents
            .bind(to: self.tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        tableView.rx.modelDeleted(Item.self)
            .subscribe(onNext: { [weak self] in
            self?.viewModel.deleteItem($0)
            })
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(Item.self)
            .subscribe(onNext: { [weak self]  in
                self?.delegate?.didSelect($0)
            })
            .disposed(by: disposeBag)
    }

   
    // MARK: - Navigation && Action
    @IBAction func createNewFolder(_ sender: Any) {
        modelTextAlert(title: "Create Folder", accept: "Create", placeholder: "Input folder name") { (string) in
            guard let folderName = string, folderName.isEmpty == false else { return }
            self.viewModel.create(folderNamed: folderName)
            self.dismiss(animated: true)
        }
    }
    
    @IBAction func createNewRecording(_ sender: Any) {
        delegate?.createRecording(in: viewModel.folder.value)
    }
    
}
