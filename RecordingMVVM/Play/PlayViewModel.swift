//
//  PlayViewModel.swift
//  RecordingMVVM
//
//  Created by du on 2020/3/17.
//  Copyright © 2020 alpha. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class PlayViewModel {
    let recording = BehaviorRelay<Recording?>(value: nil)
    let playState: Observable<Player.State?>
    let togglePlay = PublishSubject<()>()
    let setProgress = PublishSubject<TimeInterval>()
    
    private let recordingUntilDeleted: Observable<Recording?>
    
    init() {

        recordingUntilDeleted = recording.asObservable().flatMapLatest{ (recording) -> Observable<Recording?> in
            guard let currentRecording = recording else { return Observable.just(nil) }
            return Observable.just(currentRecording)
//                .concat(currentRecording.changeObservable.map({ (ac) -> Recording in
//                return currentRecording
//            }))
//                .takeUntil(currentRecording.deleteObservable)
//                .concat(Observable.just(nil))
            }.share(replay: 1)
        


        playState = recordingUntilDeleted.flatMapLatest { [togglePlay, setProgress] recording throws -> Observable<Player.State?> in
            guard let r = recording else {
                return Observable<Player.State?>.just(nil)
            }
            return Observable<Player.State?>.create { (o: AnyObserver<Player.State?>) -> Disposable in
                guard let url = r.fileURL, let p = Player(url: url, update: { playState in
                    o.onNext(playState)
                }) else {
                    o.onNext(nil)
                    return Disposables.create {}
                }
                o.onNext(p.state)
                let disposables = [
                    togglePlay.subscribe(onNext: {
                        p.start()
                    }),
                    setProgress.subscribe(onNext: { progress in
                        p.setProgress(progress)
                    })
                ]
                return Disposables.create {
                    p.stop()
                    disposables.forEach { $0.dispose() }
                }
            }
        }.share(replay: 1)
    }
    
    
    func nameChanged(_ name:String?) {
        guard let r = recording.value, let text = name else { return  }
        r.setName(text)
    }
    
    var navagtionTitle: Observable<String> {
        return recordingUntilDeleted.map {
            $0?.name ?? ""
        }
    }
    
    var hasRecording: Observable<Bool> {
        return recordingUntilDeleted.map({
            $0 != nil
        })
    }
    
    var noRecording: Observable<Bool> {
        return hasRecording.map { !$0 }.delay(0, scheduler: MainScheduler())
    }
    var timeLabelText: Observable<String?> {
        return progress.map { $0.map(timeString) }
    }
    var durationLabelText: Observable<String?> {
        return playState.map { $0.map { timeString($0.duration) } }
    }
    var sliderDuration: Observable<Float> {
        return playState.map { $0.flatMap { Float($0.duration) } ?? 1.0 }
    }
    var sliderProgress: Observable<Float> {
        return playState.map { $0.flatMap { Float($0.currentTime) } ?? 0.0 }
    }
    var progress: Observable<TimeInterval?> {
        return playState.map { $0?.currentTime }
    }
    var isPaused: Observable<Bool> {
        return playState.map { $0?.activity == .paused }
    }
    var isPlaying: Observable<Bool> {
        return playState.map { $0?.activity == .playing }
    }
    var nameText: Observable<String?> {
        return recordingUntilDeleted.map { $0?.name }
    }
    var playButtonTitle: Observable<String> {
        return playState.map { s in
            switch s?.activity {
            case .playing?: return .pause
            case .paused?: return .resume
            default: return .play
            }
        }
    }
    
}

fileprivate extension String {
    static let pause = NSLocalizedString("Pause", comment: "")
    static let resume = NSLocalizedString("Resume playing", comment: "")
    static let play = NSLocalizedString("Play", comment: "")
}
