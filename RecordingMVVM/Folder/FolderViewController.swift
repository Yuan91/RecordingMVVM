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
        return RxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<Int,Item>>(configureCell: {
            (dataSource,tableView,index,item) in
            let identifier = item is Recording ? "RecordingCell" : "FolderCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: index)
            cell.textLabel!.text = FolderViewModel.textForItem(item)
            return cell
        })
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindData()
    }
    
    
    //MARK: - Bind
    func bindData() {
        // ??? 
        tableView.dataSource = nil
        tableView.delegate = nil
        viewModel.navigationTitle.bind(to: self.navigationItem.rx.title).disposed(by: disposeBag)
        viewModel.folderContents.bind(to: self.tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
    }

   

    
    
    // MARK: - Navigation && Action
    @IBAction func createNewFolder(_ sender: Any) {
        modelTextAlert(title: "Create Folder", accept: "Create", placeholder: "Input folder name") { (string) in
            guard let folderName = string, folderName.isEmpty == false else { return }
            self.viewModel.create(folderNamed: folderName)
        }
    }
    
    @IBAction func createNewRecording(_ sender: Any) {
        performSegue(withIdentifier: .showRecorder, sender: sender)
    }
    
    //该方法的执行,会在 tableView-didSelecetRowAtIndexPath 之前
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        guard let identifier = segue.identifier else { return  }
        
//        if identifier == .showFolder {
//            guard let folderVC = segue.destination as? FolderViewController else { return  }
//            guard let indexPath = tableView.indexPathForSelectedRow else { return  }
//            guard let folder = folder.contents[indexPath.row] as? Folder else { return }
//            folderVC.folder = folder
//        }
//        else if identifier == .showPlayer{
//            guard let playVc = (segue.destination as? UINavigationController)?.topViewController as? PlayViewController else { return  }
//            guard let indexPath = tableView.indexPathForSelectedRow else { return  }
//            guard let recording = folder.contents[indexPath.row] as? Recording else { return }
//            playVc.recording = recording
//        }
//        else if identifier == .showRecorder{
//            guard let recordVc = segue.destination as? RecordViewController else { return  }
//            recordVc.folder = folder
//        }
//
        //反选
        guard let indexPath = tableView.indexPathForSelectedRow else { return  }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
