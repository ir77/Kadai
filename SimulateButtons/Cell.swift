//
//  Cell.swift
//  SimulateButtons
//
//  Created by yuchimur on 2018/12/04.
//  Copyright © 2018 Miyuki Hirose. All rights reserved.
//

import Foundation

/// セルクラス
class Cell {
    let suji: Int
    let moji: String
    var status: Status
    var seki: Int
    var ichi: (x: Int, y: Int)

    init(suji: Int, moji: String, x: Int, y: Int) {
        self.suji = suji
        self.moji = moji
        self.status = .hatena
        self.seki = (x + 1) * (y + 1)
        self.ichi = (x, y)
    }

    enum Status: String {
        case bomb = "x" // 爆弾
        case empty = "-" // 空
        case hatena = "?" // 未確定
    }
}

extension Cell: Comparable {
    static func < (lhs: Cell, rhs: Cell) -> Bool {
        if lhs.seki == rhs.seki {
            return lhs.moji < rhs.moji
        }
        return lhs.seki < rhs.seki
    }

    static func == (lhs: Cell, rhs: Cell) -> Bool {
        return lhs.suji == rhs.suji
            && lhs.moji == rhs.moji
            && lhs.status == rhs.status
            && lhs.seki == rhs.seki
            && lhs.ichi == rhs.ichi
    }
}
