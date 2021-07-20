//
//  Unown.swift
//  CurrencyConverterApp
//
//  Created by Trick Gorospe on 7/20/21.
//  Copyright © 2021 Trick Gorospe. All rights reserved.
//

func unown<T: AnyObject, U, V>(_ instance: T, _ classFunction: @escaping (T) -> ((U) -> V)) -> ((U) -> V) {
    return { [unowned instance] arg1 in
        let instanceFunction = classFunction(instance)
        return instanceFunction(arg1)
    }
}

func unown<T: AnyObject, U, W, V>(_ instance: T, _ classFunction: @escaping (T) -> ((U, W) -> V)) -> ((U, W) -> V) {
    return { [unowned instance] arg1, arg2 in
        let instanceFunction = classFunction(instance)
        return instanceFunction(arg1, arg2)
    }
}

func unown<T: AnyObject, U, W, Y, V>(_ instance: T, _ classFunction: @escaping (T) -> ((U, W, Y) -> V)) -> ((U, W, Y) -> V) {
    return { [unowned instance] arg1, arg2, arg3 in
        let instanceFunction = classFunction(instance)
        return instanceFunction(arg1, arg2, arg3)
    }
}

func unown<T: AnyObject, U>(_ instance: T, _ classFunction: @escaping (T) -> (() -> U)) -> (() -> U) {
    return { [unowned instance] in
        let instanceFunction = classFunction(instance)
        return instanceFunction()
    }
}
