//
//  RxSwiftTest.swift
//  RecordingMVVM
//
//  Created by du on 2020/3/18.
//  Copyright © 2020 alpha. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

let disposeBag = DisposeBag()

func test() {
 
//    contactTest()
    
//    testTakeUntil()
    
//    asyncSubjectTest()
    
//    publishTest()
    
//    flatTest()
}

func flatTest() {
    
    //map: 将序列中的元素,应用你定义的转换方法. map闭包内返回是一个普通类型,map方法返回值是一个 可观测序列
    Observable.of(1,2,3)
        .map({ element -> Int in
            element * 10
        })
    .subscribe(onNext: {
      print($0)
    })
    .disposed(by: disposeBag)
    
    /**
     10
     20
     30
     */
    
    //flatMap 操作符将源 Observable 的每一个元素应用一个转换方法，将他们[转换成 Observables]。 然后将这些 Observables 的元素[合并之后]再发送出来
    
    struct Player {
        var score: BehaviorRelay<Int>
    }
    
    let player = Player(score: BehaviorRelay(value: 80))
    let variable = BehaviorRelay(value: player)
    
    //flatMap 闭包内返回一个 可观测序列
    variable.flatMap { (element) -> BehaviorRelay<Int> in
        element.score
    }
    .subscribe(onNext: { (element) in
        print("score:\(element)")
    })
    .disposed(by: disposeBag)
    
    variable.value.score.accept(85)
    variable.value.score.accept(100)
    
    /**
     score:80
     score:85
     score:100
     */
    
    //flatMapLatest
    let first = BehaviorSubject(value: "👦🏻")
    let second = BehaviorSubject(value: "🅰️")
    let reply = BehaviorRelay(value: first)
    
    reply.flatMapLatest { (element) -> BehaviorSubject<String> in
        return element
    }
    .subscribe(onNext: {
        print("flatMapLatest:\($0)")
    })
    .disposed(by: disposeBag)
    
    first.onNext("🐱")
    //reply 接受新的值,因为用的是flatMapLatest, 那么 first 值的变更,将不会被发送出来
    //如果将flatMapLatest变为flatMap 则都可以发送
    //flatMap 是合并,flatMapLatest是发送最新.
    //源序列中的中的元素 又是序列,那么flatMap 可以接受多个元素的事件,flatMapLatest只接受最新一个
    reply.accept(second)
    second.onNext("🅱️")
    first.onNext("🐶")
}

func publishTest(){
    
    let subject = ReplaySubject<String>.create(bufferSize: 2)
    
    subject.onNext("🐉")
    subject.onNext("🐶")
    subject.onNext("🐱")
    
    subject
      .subscribe { print("Subscription: 1 Event:", $0) }
      .disposed(by: disposeBag)

    subject.onNext("1")
    subject.onNext("2")

    subject
      .subscribe { print("Subscription: 2 Event:", $0) }
      .disposed(by: disposeBag)

    subject.onNext("🅰️")
    subject.onNext("🅱️")
}

//AsyncSubject
func asyncSubjectTest() {
    let async = AsyncSubject<String>()
    async.subscribe { (event) in
        print(event)
    }
    .disposed(by: disposeBag)
    async.onNext("a")
    async.onNext("b")
    async.onNext("c")
    
    //next(c)
//    completed
//    async.onCompleted()
    
    //error(Sequence timeout.)
    async.onError(RxError.timeout)
}

//takeUntil 测试
func testTakeUntil() {
    /**
     takeUntil: 观测两个序列,当第二个序列发送next/error 事件时,第一个序列将不在能够接收next 事件
     
     */
    let sourceSeq = PublishSubject<String>()
    let refreSeq = PublishSubject<String>()
    
    sourceSeq.takeUntil(refreSeq).subscribe(onNext: {
        print($0)
    },onError: {
        print($0)
    },onCompleted: {
        print("接受到complete")
    })
    .disposed(by: disposeBag)
    
    sourceSeq.onNext("🐱")
    sourceSeq.onNext("🐰")
    sourceSeq.onNext("🐶")
    
    //complete 不会终止
//    refreSeq.onCompleted()
    // 终止
//    refreSeq.onError(RxError.timeout)
    //终止
    refreSeq.onNext("11")
    
    sourceSeq.onNext("🐸")
    sourceSeq.onNext("🐖")
    sourceSeq.onNext("🐵")
}

//contact 测试
func contactTest() {
    /**
     contact:将两个 Observable 链接起来
     第一个序列调用 onCompleted调用后,才会订阅第二个序列.
     也就是说,在第一个序列complete之后,第二个序列发出的元素才能接受到
     
     BehaviorSubject 即时观察者,也是序列
     当被 subscribe 时,会向观察者发送最新的元素,或者默认值
     */
    let subject1 = BehaviorSubject(value: "🍎")
    let subject2 = BehaviorSubject(value: "🐶")
    let reply = BehaviorRelay(value: subject1)
    
    reply.concat()
        .subscribe(onNext: { print($0)
        })
        .disposed(by: disposeBag)
    
    subject1.onNext("🍐")
    subject1.onNext("🍊")
    
    reply.accept(subject2)
    
    subject2.onNext("I would be ignored")
    subject2.onNext("🐱")
    
    subject1.onCompleted()
//    subject1.onError(RxError.timeout)
    
    subject2.onNext("🐭")
}
