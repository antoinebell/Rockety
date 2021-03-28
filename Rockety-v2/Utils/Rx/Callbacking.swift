//
//  Callbacking.swift
//  Rockety-v2
//
//  Created by Antoine Bellanger on 06.08.20.
//  Copyright © 2020 Antoine Bellanger. All rights reserved.
//

import Foundation
import RxSwift

// Definition of callbacks that do not capture self when passing an instance method as closure.
// The idea is taken from:
// https://forums.swift.org/t/pitch-syntactic-sugar-for-circumventing-closure-capture-lists/23425
// ucall = "unowned self in call", wcall = "weak self in call"

// MARK: Unowned self callbacks

func ucall<Self: AnyObject, T>(_ passedSelf: Self, _ classMethod: @escaping (Self) -> () -> T) -> () -> T {
    return { [unowned passedSelf] in classMethod(passedSelf)() }
}

func ucall<Self: AnyObject, T, A1>(_ passedSelf: Self, _ classMethod: @escaping (Self) -> (A1) -> T) -> (A1) -> T {
    return { [unowned passedSelf] a1 in classMethod(passedSelf)(a1) }
}

func ucall<Self: AnyObject, T, A1, A2>(_ passedSelf: Self, _ classMethod: @escaping (Self) -> (A1, A2) -> T) -> (A1, A2) -> T {
    return { [unowned passedSelf] a1, a2 in classMethod(passedSelf)(a1, a2) }
}

func ucall<Self: AnyObject, T, A1, A2, A3>(_ passedSelf: Self, _ classMethod: @escaping (Self) -> (A1, A2, A3) -> T) -> (A1, A2, A3) -> T {
    return { [unowned passedSelf] a1, a2, a3 in classMethod(passedSelf)(a1, a2, a3) }
}

func ucall<Self: AnyObject, T, A1, A2, A3, A4>(_ passedSelf: Self, _ classMethod: @escaping (Self) -> (A1, A2, A3, A4) -> T) -> (A1, A2, A3, A4) -> T {
    return { [unowned passedSelf] a1, a2, a3, a4 in classMethod(passedSelf)(a1, a2, a3, a4) }
}

func ucall<Self: AnyObject, T, A1, A2, A3, A4, A5>(_ passedSelf: Self, _ classMethod: @escaping (Self) -> (A1, A2, A3, A4, A5) -> T) -> (A1, A2, A3, A4, A5) -> T {
    return { [unowned passedSelf] a1, a2, a3, a4, a5 in classMethod(passedSelf)(a1, a2, a3, a4, a5) }
}

// MARK: Weak self callbacks

func wcall<Self: AnyObject, T>(_ passedSelf: Self, _ classMethod: @escaping (Self) -> () -> T, defaultValue: T) -> () -> T {
    return { [weak passedSelf] in
        guard let passedSelf = passedSelf else { return defaultValue }
        return classMethod(passedSelf)()
    }
}

func wcall<Self: AnyObject, T, A1>(_ passedSelf: Self, _ classMethod: @escaping (Self) -> (A1) -> T, defaultValue: T) -> (A1) -> T {
    return { [weak passedSelf] a1 in
        guard let passedSelf = passedSelf else { return defaultValue }
        return classMethod(passedSelf)(a1)
    }
}

func wcall<Self: AnyObject, T, A1, A2>(_ passedSelf: Self, _ classMethod: @escaping (Self) -> (A1, A2) -> T, defaultValue: T) -> (A1, A2) -> T {
    return { [weak passedSelf] a1, a2 in
        guard let passedSelf = passedSelf else { return defaultValue }
        return classMethod(passedSelf)(a1, a2)
    }
}

func wcall<Self: AnyObject, T, A1, A2, A3>(_ passedSelf: Self, _ classMethod: @escaping (Self) -> (A1, A2, A3) -> T, defaultValue: T) -> (A1, A2, A3) -> T {
    return { [weak passedSelf] a1, a2, a3 in
        guard let passedSelf = passedSelf else { return defaultValue }
        return classMethod(passedSelf)(a1, a2, a3)
    }
}

func wcall<Self: AnyObject, T, A1, A2, A3, A4>(_ passedSelf: Self, _ classMethod: @escaping (Self) -> (A1, A2, A3, A4) -> T, defaultValue: T) -> (A1, A2, A3, A4) -> T {
    return { [weak passedSelf] a1, a2, a3, a4 in
        guard let passedSelf = passedSelf else { return defaultValue }
        return classMethod(passedSelf)(a1, a2, a3, a4)
    }
}

func wcall<Self: AnyObject, T, A1, A2, A3, A4, A5>(_ passedSelf: Self, _ classMethod: @escaping (Self) -> (A1, A2, A3, A4, A5) -> T, defaultValue: T) -> (A1, A2, A3, A4, A5) -> T {
    return { [weak passedSelf] a1, a2, a3, a4, a5 in
        guard let passedSelf = passedSelf else { return defaultValue }
        return classMethod(passedSelf)(a1, a2, a3, a4, a5)
    }
}

// MARK: Weak self callbacks, Void return type

func wcall<Self: AnyObject>(_ passedSelf: Self, _ classMethod: @escaping (Self) -> () -> Void) -> () -> Void {
    return { [weak passedSelf] in
        guard let passedSelf = passedSelf else { return }
        return classMethod(passedSelf)()
    }
}

func wcall<Self: AnyObject, A1>(_ passedSelf: Self, _ classMethod: @escaping (Self) -> (A1) -> Void) -> (A1) -> Void {
    return { [weak passedSelf] a1 in
        guard let passedSelf = passedSelf else { return }
        return classMethod(passedSelf)(a1)
    }
}

func wcall<Self: AnyObject, A1, A2>(_ passedSelf: Self, _ classMethod: @escaping (Self) -> (A1, A2) -> Void) -> (A1, A2) -> Void {
    return { [weak passedSelf] a1, a2 in
        guard let passedSelf = passedSelf else { return }
        return classMethod(passedSelf)(a1, a2)
    }
}

func wcall<Self: AnyObject, A1, A2, A3>(_ passedSelf: Self, _ classMethod: @escaping (Self) -> (A1, A2, A3) -> Void) -> (A1, A2, A3) -> Void {
    return { [weak passedSelf] a1, a2, a3 in
        guard let passedSelf = passedSelf else { return }
        return classMethod(passedSelf)(a1, a2, a3)
    }
}

func wcall<Self: AnyObject, A1, A2, A3, A4>(_ passedSelf: Self, _ classMethod: @escaping (Self) -> (A1, A2, A3, A4) -> Void) -> (A1, A2, A3, A4) -> Void {
    return { [weak passedSelf] a1, a2, a3, a4 in
        guard let passedSelf = passedSelf else { return }
        return classMethod(passedSelf)(a1, a2, a3, a4)
    }
}

func wcall<Self: AnyObject, A1, A2, A3, A4, A5>(_ passedSelf: Self, _ classMethod: @escaping (Self) -> (A1, A2, A3, A4, A5) -> Void) -> (A1, A2, A3, A4, A5) -> Void {
    return { [weak passedSelf] a1, a2, a3, a4, a5 in
        guard let passedSelf = passedSelf else { return }
        return classMethod(passedSelf)(a1, a2, a3, a4, a5)
    }
}

// MARK: Weak self callbacks, Observable<T> return type

func wcall<Self: AnyObject, T>(_ passedSelf: Self, _ classMethod: @escaping (Self) -> () -> Observable<T>, defaultValue: Observable<T> = Observable.never()) -> () -> Observable<T> {
    return { [weak passedSelf] in
        guard let passedSelf = passedSelf else { return defaultValue }
        return classMethod(passedSelf)()
    }
}

func wcall<Self: AnyObject, T, A1>(_ passedSelf: Self, _ classMethod: @escaping (Self) -> (A1) -> Observable<T>, defaultValue: Observable<T> = Observable.never()) -> (A1) -> Observable<T> {
    return { [weak passedSelf] a1 in
        guard let passedSelf = passedSelf else { return defaultValue }
        return classMethod(passedSelf)(a1)
    }
}

func wcall<Self: AnyObject, T, A1, A2>(_ passedSelf: Self, _ classMethod: @escaping (Self) -> (A1, A2) -> Observable<T>, defaultValue: Observable<T> = Observable.never()) -> (A1, A2) -> Observable<T> {
    return { [weak passedSelf] a1, a2 in
        guard let passedSelf = passedSelf else { return defaultValue }
        return classMethod(passedSelf)(a1, a2)
    }
}

func wcall<Self: AnyObject, T, A1, A2, A3>(_ passedSelf: Self, _ classMethod: @escaping (Self) -> (A1, A2, A3) -> Observable<T>, defaultValue: Observable<T> = Observable.never()) -> (A1, A2, A3) -> Observable<T> {
    return { [weak passedSelf] a1, a2, a3 in
        guard let passedSelf = passedSelf else { return defaultValue }
        return classMethod(passedSelf)(a1, a2, a3)
    }
}

func wcall<Self: AnyObject, T, A1, A2, A3, A4>(_ passedSelf: Self, _ classMethod: @escaping (Self) -> (A1, A2, A3, A4) -> Observable<T>, defaultValue: Observable<T> = Observable.never()) -> (A1, A2, A3, A4) -> Observable<T> {
    return { [weak passedSelf] a1, a2, a3, a4 in
        guard let passedSelf = passedSelf else { return defaultValue }
        return classMethod(passedSelf)(a1, a2, a3, a4)
    }
}

func wcall<Self: AnyObject, T, A1, A2, A3, A4, A5>(_ passedSelf: Self, _ classMethod: @escaping (Self) -> (A1, A2, A3, A4, A5) -> Observable<T>, defaultValue: Observable<T> = Observable.never()) -> (A1, A2, A3, A4, A5) -> Observable<T> {
    return { [weak passedSelf] a1, a2, a3, a4, a5 in
        guard let passedSelf = passedSelf else { return defaultValue }
        return classMethod(passedSelf)(a1, a2, a3, a4, a5)
    }
}
