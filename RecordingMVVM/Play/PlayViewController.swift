//
//  PlayViewController.swift
//  RecordingsMVC
//
//  Created by du on 2020/2/12.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: UISlider {
    public var maximumValue: Binder<Float> {
        return Binder(self.base, binding: { slider, value in
            slider.maximumValue = value
        })
    }
}

class PlayViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var noRecordingLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    
  
    let viewModel = PlayViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.delegate = self
        
        let noRecordingObserver = AnyObserver<Bool> {[weak self] (event) in
               switch event {
               case .next(let value):
                self?.setNoRecordStatus(showOrHidden: value)
               default:break
               }
           }
        
        let hasRecording = AnyObserver<Bool> { [weak self] (event) in
            switch event {
            case .next(let value):
                self?.setPlayerStatus(showOrHidden: value)
            default: break
            }
        }
        
        viewModel.navagtionTitle.bind(to: rx.title).disposed(by: disposeBag)
        viewModel.noRecording.bind(to: noRecordingObserver).disposed(by: disposeBag)
        viewModel.hasRecording.bind(to: hasRecording).disposed(by: disposeBag)
        viewModel.timeLabelText.bind(to: progressLabel.rx.text).disposed(by: disposeBag)
        viewModel.durationLabelText.bind(to: durationLabel.rx.text).disposed(by: disposeBag)
        viewModel.sliderDuration.bind(to: progressSlider.rx.maximumValue).disposed(by: disposeBag)
        viewModel.sliderProgress.bind(to: progressSlider.rx.value).disposed(by: disposeBag)
        viewModel.playButtonTitle.bind(to: playButton.rx.title(for: .normal)).disposed(by: disposeBag)
        viewModel.nameText.bind(to: nameTextField.rx.text).disposed(by: disposeBag)
    }
    
    func setPlayerStatus(showOrHidden: Bool) {
        nameTextField.isHidden = !showOrHidden
        nameLabel.isHidden = !showOrHidden
        durationLabel.isHidden = !showOrHidden
        progressLabel.isHidden = !showOrHidden
        progressSlider.isHidden = !showOrHidden
        playButton.isHidden = !showOrHidden
    }
    
    func setNoRecordStatus(showOrHidden: Bool) {
        noRecordingLabel.isHidden = !showOrHidden
    }
    
    //MARK:- delegate
    func textFieldDidEndEditing(_ textField: UITextField) {
        viewModel.nameChanged(textField.text)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    // MARK: ---Action---
    @IBAction func playClick(_ sender: Any) {
        viewModel.togglePlay.onNext(())
    }
    
    
    @IBAction func sliderValueChanged(_ sender: Any) {
        guard let s = progressSlider else { return }
        viewModel.setProgress.onNext(TimeInterval(s.value))
    }
    

}

fileprivate extension String {
    static let uuidPathKey = "uuidPath"
    
    static let pause = NSLocalizedString("Pause", comment: "")
    static let resume = NSLocalizedString("Resume playing", comment: "")
    static let play = NSLocalizedString("Play", comment: "")
}
