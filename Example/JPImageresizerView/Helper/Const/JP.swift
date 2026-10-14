//
//  JP.swift
//  Neves_Example
//
//  Created by 周健平 on 2020/10/9.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

struct JP<Base> {
    let base: Base
    init(_ base: Base) {
        self.base = base
    }
}

protocol JPCompatible {}
extension JPCompatible {
    static var jp: JP<Self>.Type {
        set {}
        get { JP<Self>.self }
    }
    var jp: JP<Self> {
        set {}
        get { JP(self) }
    }
}

