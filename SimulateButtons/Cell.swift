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
    let position: (x: Int, y: Int)
    var seki: Int {
        return (position.x + 1) * (position.y + 1)
    }

    var status: Status

    init(suji: Int, moji: String, x: Int, y: Int) {
        self.suji = suji
        self.moji = moji
        self.status = .hatena
        self.position = (x, y)
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
            && lhs.position == rhs.position
    }
}

extension Array where Element == [Cell] {
    /// 積の総和を算出する
    ///
    /// - Returns: 全てのセルの x * y の結果を足し合わせた数値
    var allSeki: Int {
        return compactMap({
            $0.reduce(0) { $0 + $1.seki }
        }).reduce(0) { $0 + $1 }
    }

    var ngs: [Cell] {
        return flatMap({ $0 })
            .filter({ $0.suji != countBomb(around: $0) })
    }

    /// 自身を含む周囲9セルを取り出す
    ///
    /// - Parameter cell: 取り出したい対象のセル
    /// - Returns: 自身と周囲の最大9セル
    func pull(around cell: Cell) -> [Cell] {
        let rownum = cell.position.y
        let colnum = cell.position.x
        let rowSize = self.count - 1
        let colSize = self[0].count - 1

        var cells: [Cell] = []

        // 上段を取得
        if rownum != 0 {
            if colnum != 0 {
                cells.append(self[rownum - 1][colnum - 1])
            }
            cells.append(self[rownum - 1][colnum])
            if colnum != colSize {
                cells.append(self[rownum - 1][colnum + 1])
            }
        }

        // 中段を取得
        if colnum != 0 {
            cells.append(self[rownum][colnum - 1])
        }
        cells.append(self[rownum][colnum])
        if colnum != colSize {
            cells.append(self[rownum][colnum + 1])
        }

        // 下段を取得
        if rownum != rowSize {
            if colnum != 0 {
                cells.append(self[rownum + 1][colnum - 1])
            }
            cells.append(self[rownum + 1][colnum])
            if colnum != colSize {
                cells.append(self[rownum + 1][colnum + 1])
            }
        }

        return cells
    }

    /// 渡されたセルの周囲で状態が爆弾になっているセルの数を返却する
    ///
    /// - Parameter targetCell: 対象のセル
    /// - Returns: 周囲にある爆弾セルの数
    func countBomb(around cell: Cell) -> Int {
        return pull(around: cell)
            .filter({ $0.status == .bomb })
            .count
    }
}
