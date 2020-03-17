//
//  RecordViewController.swift
//  RecordingsMVC
//
//  Created by du on 2020/2/28.
//

import UIKit
import RxSwift
import RxCocoa

protocol RecordViewControllerDelegate: class {
    func finishedRecording(_ recordVC: RecordViewController)
}

/**
 修改的地方:
 ①viewModel持有一个Recorder,这个Record应该是可以观测的.每次值的变化,都绑定到timeLabel 上
 ②stopButton 的点击事件,通过Rx来实现
 ③点击stop 时,model的处理放到ViewModel 中实现
 */
class RecordViewController: UIViewController {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var stopButton: UIButton!
    
    var audioRecorder: Recorder?
    
   
    
    weak var delegate: RecordViewControllerDelegate?
    let viewModel = RecordViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
    func bind() {
        viewModel.timeLabelText.drive(timeLabel.rx.text).disposed(by: disposeBag)
        viewModel.dismiss = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let url = viewModel.folder?.store?.fileURL(viewModel.recording) else {
            delegate?.finishedRecording(self)
            return
        }
        print(url.absoluteString)

        audioRecorder = Recorder(url: url, update: { [weak self] (timeInterval) in
            self?.viewModel.recorderStateChanged(time: timeInterval)
        })
    }
    

    @IBAction func stopClick(_ sender: Any) {
        audioRecorder?.stop()
        modelTextAlert(title: .saveRecording, accept: .save,  placeholder: .nameForRecording) { string in
            self.viewModel.recordingStopped(recordName: string)
            self.delegate?.finishedRecording(self)
        }
    }
    

}


fileprivate extension String{
    static let saveRecording = NSLocalizedString("Save Record", comment: "")
    static let save = NSLocalizedString("Save", comment: "")
    static let nameForRecording = NSLocalizedString("nameForRecording", comment: "")
    static let placeholderName = "placeholderName.m4a"
}
