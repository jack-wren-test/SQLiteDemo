//
//  IncrementDecrement.swift
//  SQLiteDemo
//
//  Created by Jack Smith on 29/11/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

postfix operator ++

extension Int32 {
    static postfix func ++( x: inout Int32) -> Int32 {
        x += 1
        return (x - 1)
    }
}
