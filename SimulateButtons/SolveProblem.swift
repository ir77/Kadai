//
//  SolveProblem.swift
//  SimulateButtons
//
//  Created by MiyukiHirose on 2018/11/28.
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

class SolveProblem {
    let sujiRowCollection: [[Int]]
    let mojiRowCollection: [[String]]
    let cellCollection: [[Cell]]
    let maxSuji: Int

    var ngCell: [Cell] = []

    /// 初期処理
    /// 全セルの定義を実施
    init(sujiRows: [[Int]], mojiRows: [[String]]) {

        self.sujiRowCollection = sujiRows
        self.mojiRowCollection = mojiRows
        self.maxSuji = sujiRows.compactMap({ $0.max() }).max() ?? 1

        var cellCollection: [[Cell]] = []

        for row in 0 ..< sujiRowCollection.count {
            let targetSujiRow = sujiRowCollection[row]
            let targetMojiRow = mojiRowCollection[row]

            var cellRow: [Cell] = []
            for collomn in 0 ..< targetSujiRow.count {
                let targetSuji = targetSujiRow[collomn]
                let targetMoji = targetMojiRow[collomn]
                let targetCellRow = Cell(suji: targetSuji, moji: targetMoji, x: collomn, y: row)
                cellRow.append(targetCellRow)
            }
            cellCollection.append(cellRow)
        }

        self.cellCollection = cellCollection
    }

    /// 爆弾位置特定処理実行
    func exec() {

        var retryFlag = true
        var count = 0

        // 全セルOK判定が出るまで一連の処理を繰り返す
        while(retryFlag) {

            allDelegate()
            let firstResult = checkAllCell()
            retryFlag = !firstResult.result

            if(firstResult.result) {
                return
            }
            // 前回のNG数と一致するか確認(一定数回るとボムの位置が動かなくなる)
            var currentNGCell = firstResult.ng
            if(ngCell.count == currentNGCell.count) {
                for index in 0 ..< ngCell.count {
                    // 別の位置でエラーが出ていた場合は結果が変わる可能性があるのでもう1週させる
                    if(ngCell[index].ichi != currentNGCell[index].ichi) {
                        break
                    }
                }
                // 爆弾以外のセルを一度全て空にする
                for row in cellCollection {
                    for cel in row where .bomb != cel.status {
                        cel.status = .empty
                    }
                }
                // 爆弾のある場所だけ、移動可能な場所を探し、はてなに変更していく
                for row in cellCollection {
                    for col in row where .bomb == col.status {
                        searchChangeableBomb(bombCell: col)
                    }
                }
                // 爆弾を一つづつはてなの場所にいれていき、NGが減った時だけ確定する
                for row in cellCollection {
                    for col in row where col.status == .bomb {
                        moveToSafety(bombCell: col, errCount: checkAllCell().ng.count)
                    }
                }
                // ここまできた場合には全て確定しているはずなので処理を強制的に抜ける
                return
            }
            ngCell.removeAll()
            ngCell = currentNGCell
            count += 1
        }
    }

    /// 爆弾の位置の文字列を積の小さい順にならべ直し、連結して返却する
    ///
    /// - Returns: 完成したメッセージ
    func makeMassage() -> String {
        var bombList: [(seki: Int, moji: String)] = []
        for row in cellCollection {
            for col in row where col.status == .bomb {
                bombList.append((col.seki, col.moji))
            }
        }
        bombList.sort { (A, B) -> Bool in
            if A.seki == B.seki {
                return A.moji < B.moji
            }
            return A.seki < B.seki
        }
        return bombList.reduce("") { $0 + $1.moji }
    }

    /// 積の総和を算出する
    ///
    /// - Returns: 全てのセルの x * y の結果を足し合わせた数値
    func sumAllSeki() -> Int {
        return cellCollection.compactMap({
            $0.reduce(0) { $0 + $1.seki }
        }).reduce(0) { $0 + $1 }
    }

    /// 対象のセルを一度空状態にし、2階層内にある?に爆弾を埋めていく
    /// ？に埋めてもエラー数が変わらなければ戻して次の?にうつる
    ///
    /// - Parameters:
    ///   - bombCell: 爆弾配置セル
    ///   - errCount: 現在のエラー総数
    private func moveToSafety(bombCell: Cell, errCount: Int) {
        bombCell.status = .empty
        for layer1Cell in pullArraund(cell: bombCell) {
            for layer2Cell in pullArraund(cell: layer1Cell) {
                if(layer2Cell.ichi == bombCell.ichi || .hatena != layer2Cell.status) {
                    continue
                }
                layer2Cell.status = .bomb
                // エラー数が減った時だけ確定する
                if(errCount > checkAllCell().ng.count) {
                    return
                }
                layer2Cell.status = .hatena
            }
        }

        // 3階層目までチェック
        for layer1Cell in pullArraund(cell: bombCell) {
            for layer2Cell in pullArraund(cell: layer1Cell) {
                for layer3Cell in pullArraund(cell: layer2Cell) {
                    if(layer3Cell.ichi == bombCell.ichi || .hatena != layer3Cell.status) {
                        continue
                    }
                    layer3Cell.status = .bomb
                    // エラー数が減った時だけ確定する
                    if(errCount > checkAllCell().ng.count) {
                        return
                    }
                    layer3Cell.status = .hatena
                }
            }
        }
        bombCell.status = .bomb
    }

    /// 爆弾位置特定第一段階処理
    /// 爆弾の総数がオーバーしない範囲で場所を特定していく
    private func allDelegate() {

        var startRow = 0
        var startCol = 0

        // 爆弾保持数が多いセルを優先して先に設定する
        for row in 0 ..< cellCollection.count {
            var cellRow = cellCollection[row]

            for target in 0 ..< cellRow.count {
                let targetCell = cellRow[target]
                if(targetCell.suji != maxSuji) {
                    continue
                }
                startRow = row
                startCol = target
                // セルの爆弾保持数と、すでに設置されている爆弾の総数が同数の場合
                if(targetCell.suji == bombCounter(targetCell: targetCell)) {
                    continue
                }
                setStatus(targetCell: targetCell)
            }
        }
        for row in 0 ..< cellCollection.count {
            var cellRow = cellCollection[row]
            for target in 0 ..< cellRow.count {
                let targetCell = cellRow[target]

                if(startRow == row && startCol == target) {
                    break
                }
                // 爆弾がいくつ設定されているか確認する
                let bombCount = bombCounter(targetCell: targetCell)

                // 同数の場合
                if(targetCell.suji == bombCount) {
                    continue
                }
                setStatus(targetCell: targetCell)
            }
        }
    }

    /// セルのステータス設定
    ///
    /// - Parameter targetCell: ステータス設定対象のセル
    private func setStatus(targetCell: Cell) {

        let cellSet = pullArraund(cell: targetCell)
        var addBombs = bombCounter(targetCell: targetCell)

        var isNotAllSetting = true
        var startCell = 0
        var resetCount = 0

        while(isNotAllSetting) {
            for _ in 0 ..< cellSet.count {
                let item = cellSet[startCell]
                // 対象のセルに爆弾を追加しても問題ない時のみ設置する
                if item.status == .hatena && item.suji >= bombCounter(targetCell: item) + 1 {
                    item.status = .bomb
                    var checkResult = true
                    // 設置した結果他のセルがNGになったら取り消す
                    for layer1Cell in cellSet {
                        if(layer1Cell.suji < bombCounter(targetCell: layer1Cell)) {
                            if(resetCount > 2) {
                                resetBombToEmpty(targetCell: layer1Cell)
                            }
                            checkResult = false
                        }
                        if(checkResult) {
                            for layer2Cell in pullArraund(cell: layer1Cell) {
                                if(layer2Cell.suji < bombCounter(targetCell: layer2Cell)) {
                                    if(resetCount > 2) {
                                        resetBombToEmpty(targetCell: layer2Cell)
                                    }
                                    checkResult = false
                                }
                            }
                        }
                    }
                    if(!checkResult) {
                        item.status = .hatena
                        continue
                    }
                    addBombs = addBombs + 1
                }
                if (addBombs == targetCell.suji) {
                    isNotAllSetting = false
                    break
                }
            }

            if isNotAllSetting {
                startCell += 1
                if(cellSet.count <= startCell) {
                    startCell = 0
                    resetCount += 1
                    // スタート位置をずらしてもNGだった場合
                    for item in cellSet where item.status == .bomb {
                        item.status = .hatena
                    }
                    // セルと同数回分リセットしてもNGな場合はスルーする
                    if(resetCount == cellSet.count) {
                        isNotAllSetting = false
                        break
                    }
                }
            }
        }
    }

    /// 爆弾セル周囲で場所を変更可能な爆弾を探索する
    ///
    /// - Parameter bombCell: 対象の爆弾セル
    private func searchChangeableBomb(bombCell: Cell) {

        bombCell.status = .hatena
        // 1階層目
        for layer1Cell in pullArraund(cell: bombCell) {
            if(layer1Cell.ichi == bombCell.ichi) {
                continue
            }
            if(.empty == layer1Cell.status) {
                for layer2Cell in pullArraund(cell: bombCell) {
                    if(layer2Cell.ichi == bombCell.ichi) {
                        continue
                    }
                    if(moveExperiment(tryTarget: layer2Cell, changeTarget: layer1Cell)) {
                        bombCell.status = .bomb
                        return
                    }
                }
                // ここまで処理が抜けたら爆弾を移動できなかったと判定し、元に戻す
                layer1Cell.status = .empty
            }
        }
        // 2階層目
        for layer1Cell in pullArraund(cell: bombCell) {
            if(layer1Cell.ichi == bombCell.ichi) {
                continue
            }
            for layer2Cell in pullArraund(cell: layer1Cell) where layer2Cell.status == .empty {
                for layer3Cell in pullArraund(cell: layer2Cell) where moveExperiment(tryTarget: layer3Cell, changeTarget: layer2Cell) {
                    bombCell.status = .bomb
                    return
                }
            }
        }

        // 3階層目
        for layer1Cell in pullArraund(cell: bombCell) {
            if(layer1Cell.ichi == bombCell.ichi) {
                continue
            }
            for layer2Cell in pullArraund(cell: layer1Cell) {
                for layer3Cell in pullArraund(cell: layer2Cell) where layer3Cell.status == .empty {
                    for layer4Child in pullArraund(cell: layer3Cell) where moveExperiment(tryTarget: layer4Child, changeTarget: layer3Cell) {
                        bombCell.status = .bomb
                        return
                    }
                }
            }
        }
        // 最後まで来てしまったら爆弾に戻す
        bombCell.status = .bomb
    }

    /// ボムに変更可能なセルであるか、実際に変更してみてエラー検証する
    ///
    /// - Parameters:
    ///   - tryTarget: 空→爆弾 に変更しようとしているセル
    ///   - changeTarget: 爆弾→空 に変更しようとしているセル
    /// - Returns: true = ボムの移動が可能
    private func moveExperiment (tryTarget: Cell, changeTarget: Cell) -> Bool {

        // ?と爆弾は検証対象から除外
        if tryTarget.status == .empty && tryTarget.ichi != changeTarget.ichi {
            tryTarget.status = .bomb
            if(tryTarget.suji == bombCounter(targetCell: tryTarget)) {
                // 処理が成功したので処理を抜ける
                tryTarget.status = .hatena
                return true
            }
            // 失敗なら元に戻す
            tryTarget.status = .empty
        }
        return false
    }

    /// 全セルのステータスを出力する
    private func statusPrint() {
        for row in cellCollection {
            var concatenate = ""
            for item in row {
                concatenate = concatenate + "," + item.status.rawValue
            }
            print(concatenate)
        }
    }

    /// 全セルが爆弾の個数を守れているかチェックを実施する
    ///
    /// - Returns: (result:NGセルなし=true, ng:セルの数字と爆弾の個数が一致しなかったセルの一覧)
    private func checkAllCell() -> (result: Bool, ng: [Cell]) {
        var result = true
        var ng: [Cell] = []
        for row in 0 ..< cellCollection.count {
            var cellRow = cellCollection[row]
            for target in 0 ..< cellRow.count {
                let targetCell = cellRow[target]
                if(targetCell.suji != bombCounter(targetCell: targetCell)) {
                    ng.append(targetCell)
                    result = false
                }
            }
        }
        return (result, ng)
    }

    /// 自身を含む周囲8セルを取り出す
    ///
    /// - Parameter cell: 取り出したい対象のセル
    /// - Returns: 自身と周囲の最大9セル
    private func pullArraund(cell: Cell) -> [Cell] {
        let rownum = cell.ichi.y
        let colnum = cell.ichi.x
        let rowSize = cellCollection.count - 1
        let colSize = cellCollection[0].count - 1

        var cells: [Cell] = []

        // 上段を取得
        if rownum != 0 {
            if colnum != 0 {
                cells.append(cellCollection[rownum - 1][colnum - 1])
            }
            cells.append(cellCollection[rownum - 1][colnum])
            if colnum != colSize {
                cells.append(cellCollection[rownum - 1][colnum + 1])
            }
        }

        // 中段を取得
        if colnum != 0 {
            cells.append(cellCollection[rownum][colnum - 1])
        }

        cells.append(cellCollection[rownum][colnum])
        if colnum != colSize {
            cells.append(cellCollection[rownum][colnum + 1])
        }

        // 上段を取得
        if rownum != rowSize {
            if colnum != 0 {
                cells.append(cellCollection[rownum + 1][colnum - 1])
            }
            cells.append(cellCollection[rownum + 1][colnum])
            if colnum != colSize {
                cells.append(cellCollection[rownum + 1][colnum + 1])
            }
        }

        return cells
    }

    /// 渡されたセルの周囲で状態が爆弾になっているセルの数を返却する
    ///
    /// - Parameter targetCell: 対象のセル
    /// - Returns: 周囲にある爆弾セルの数
    private func bombCounter(targetCell: Cell) -> Int {
        return pullArraund(cell: targetCell).filter({ $0.status == .bomb }).count
    }

    /// 爆弾を全て空に変更する
    ///
    /// - Parameter targetCell: 戻し対象セル
    private func resetBombToEmpty(targetCell: Cell) {
        // スタート位置をリセットしても条件を満たせなかった場合
        for cell in pullArraund(cell: targetCell) where cell.status == .bomb {
            cell.status = .empty
        }
    }
}
