//
//  RecordViewModel.swift
//  RecordingMVVM
//
//  Created by du on 2020/3/17.
//  Copyright © 2020 alpha. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class RecordViewModel {
    var folder: Folder? = nil
    let recording = Recording(name: "", uuid: UUID())
    let duration = BehaviorRelay<TimeInterval>(value: 0)

    //点击stop
    func recordingStopped(recordName: String?) {
        guard let name = recordName else {
            recording.deleted()
            return
        }
        recording.setName(name)
        folder?.add(recording)
    }
    
    //时间发生变化
    func recorderStateChanged(time:TimeInterval?)  {
        if let t = time {
            duration.accept(t)
        }
        else {
            dismiss?()
        }
    }
    
    
    // output
    var timeLabelText: Driver<String> {
        return duration.asDriver(onErrorJustReturn: 0).map { timeString($0) }
    }
    
    var dismiss: (() -> ())?
}
