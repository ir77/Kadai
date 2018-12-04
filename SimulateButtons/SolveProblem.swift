//
//  SolveProblem.swift
//  SimulateButtons
//
//  Created by MiyukiHirose on 2018/11/28.
//  Copyright © 2018 Miyuki Hirose. All rights reserved.
//

import Foundation

class SolveProblem {
    let cells: [[Cell]]
    let maxSuji: Int

    /// 初期処理
    /// 全セルの定義を実施
    init(sujiRows: [[Int]], mojiRows: [[String]]) {
        self.maxSuji = sujiRows.compactMap({ $0.max() }).max() ?? 1

        var cells: [[Cell]] = []

        for row in 0 ..< sujiRows.count {
            let targetSujiRow = sujiRows[row]
            let targetMojiRow = mojiRows[row]

            var cellRow: [Cell] = []
            for collomn in 0 ..< targetSujiRow.count {
                let targetSuji = targetSujiRow[collomn]
                let targetMoji = targetMojiRow[collomn]
                let targetCellRow = Cell(suji: targetSuji, moji: targetMoji, x: collomn, y: row)
                cellRow.append(targetCellRow)
            }
            cells.append(cellRow)
        }

        self.cells = cells
    }

    /// 爆弾位置特定処理実行
    // 全セルOK判定が出るまで一連の処理を繰り返す
    func execution(previousNgCell: [Cell] = []) {
        allDelegate()
        // 前回のNG数と一致するか確認(一定数回るとボムの位置が動かなくなる)
        let currentNGCell = cells.ngs
        if previousNgCell.count == currentNGCell.count {
            for index in 0 ..< previousNgCell.count {
                // 別の位置でエラーが出ていた場合は結果が変わる可能性があるのでもう1週させる
                if(previousNgCell[index].position != currentNGCell[index].position) {
                    break
                }
            }
            // 爆弾以外のセルを一度全て空にする
            for row in cells {
                for cel in row where .bomb != cel.status {
                    cel.status = .empty
                }
            }
            // 爆弾のある場所だけ、移動可能な場所を探し、はてなに変更していく
            for row in cells {
                for col in row where .bomb == col.status {
                    searchChangeableBomb(bombCell: col)
                }
            }
            // 爆弾を一つづつはてなの場所にいれていき、NGが減った時だけ確定する
            for row in cells {
                for col in row where col.status == .bomb {
                    moveToSafety(bombCell: col, errCount: cells.ngs.count)
                }
            }
            // ここまできた場合には全て確定しているはずなので処理を強制的に抜ける
            return
        }

        if !cells.ngs.isEmpty {
            execution(previousNgCell: currentNGCell)
        }
    }

    /// 爆弾の位置の文字列を積の小さい順にならべ直し、連結して返却する
    ///
    /// - Returns: 完成したメッセージ
    func makeMassage() -> String {
        let bombCells: [Cell] = cells
            .flatMap({ $0 })
            .filter({ $0.status == .bomb })
        return bombCells
            .sorted(by: { $0 < $1 })
            .reduce("") { $0 + $1.moji }
    }

    /// 対象のセルを一度空状態にし、2階層内にある?に爆弾を埋めていく
    /// ？に埋めてもエラー数が変わらなければ戻して次の?にうつる
    ///
    /// - Parameters:
    ///   - bombCell: 爆弾配置セル
    ///   - errCount: 現在のエラー総数
    private func moveToSafety(bombCell: Cell, errCount: Int) {
        bombCell.status = .empty
        for layer1Cell in cells.pull(around: bombCell) {
            for layer2Cell in cells.pull(around: layer1Cell) where layer2Cell.position != bombCell.position && .hatena == layer2Cell.status{
                layer2Cell.status = .bomb
                // エラー数が減った時だけ確定する
                if(errCount > cells.ngs.count) {
                    return
                }
                layer2Cell.status = .hatena
            }
        }

        // 3階層目までチェック
        for layer1Cell in cells.pull(around: bombCell) {
            for layer2Cell in cells.pull(around: layer1Cell) {
                for layer3Cell in cells.pull(around: layer2Cell) where layer3Cell.position != bombCell.position && .hatena == layer3Cell.status {
                    layer3Cell.status = .bomb
                    // エラー数が減った時だけ確定する
                    if(errCount > cells.ngs.count) {
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

        var startPosition: (x: Int, y: Int) = (0, 0)

        // 爆弾保持数が多いセルを優先して先に設定する
        cells.flatMap({ $0 }).filter({ $0.suji == maxSuji }).forEach({ targetCell in
            startPosition = targetCell.position

            guard targetCell.suji != cells.countBomb(around: targetCell) else {
                return
            }

            setStatus(targetCell: targetCell)
        })

        cells
            .flatMap({ $0 })
            .filter({ $0.position != startPosition })
            .forEach({ targetCell in
                // 爆弾がいくつ設定されているか確認する
                let bombCount = cells.countBomb(around: targetCell)

                // 同数の場合
                guard targetCell.suji != bombCount else {
                    return
                }

                setStatus(targetCell: targetCell)
        })
    }

    /// セルのステータス設定
    ///
    /// - Parameter targetCell: ステータス設定対象のセル
    private func setStatus(targetCell: Cell) {

        let cellSet = cells.pull(around: targetCell)
        var addBombs = cells.countBomb(around: targetCell)

        var isNotAllSetting = true
        var startCell = 0
        var resetCount = 0

        while(isNotAllSetting) {
            for _ in 0 ..< cellSet.count {
                let item = cellSet[startCell]
                // 対象のセルに爆弾を追加しても問題ない時のみ設置する
                if item.status == .hatena && item.suji >= cells.countBomb(around: item) + 1 {
                    item.status = .bomb
                    var checkResult = true
                    // 設置した結果他のセルがNGになったら取り消す
                    for layer1Cell in cellSet {
                        if layer1Cell.suji < cells.countBomb(around: layer1Cell) {
                            if resetCount > 2 {
                                resetBombToEmpty(for: layer1Cell)
                            }
                            checkResult = false
                        }
                        if checkResult {
                            for layer2Cell in cells.pull(around: layer1Cell) where layer2Cell.suji < cells.countBomb(around: layer2Cell) {
                                if resetCount > 2 {
                                    resetBombToEmpty(for: layer2Cell)
                                }
                                checkResult = false
                            }
                        }
                    }
                    guard checkResult else {
                        item.status = .hatena
                        continue
                    }
                    addBombs = addBombs + 1
                }
                if addBombs == targetCell.suji {
                    isNotAllSetting = false
                    break
                }
            }

            if isNotAllSetting {
                startCell += 1
                if cellSet.count <= startCell {
                    startCell = 0
                    resetCount += 1
                    // スタート位置をずらしてもNGだった場合
                    for item in cellSet where item.status == .bomb {
                        item.status = .hatena
                    }
                    // セルと同数回分リセットしてもNGな場合はスルーする
                    if resetCount == cellSet.count {
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
        for layer1Cell in cells.pull(around: bombCell)
            where layer1Cell.position != bombCell.position && layer1Cell.status == .empty {
            for layer2Cell in cells.pull(around: bombCell)
                where layer2Cell.position != bombCell.position && moveExperiment(tryTarget: layer2Cell, changeTarget: layer1Cell) {
                    bombCell.status = .bomb
                    return
            }
            // ここまで処理が抜けたら爆弾を移動できなかったと判定し、元に戻す
            layer1Cell.status = .empty
        }
        // 2階層目
        for layer1Cell in cells.pull(around: bombCell) where layer1Cell.position != bombCell.position {
            for layer2Cell in cells.pull(around: layer1Cell) where layer2Cell.status == .empty {
                for layer3Cell in cells.pull(around: layer2Cell) where moveExperiment(tryTarget: layer3Cell, changeTarget: layer2Cell) {
                    bombCell.status = .bomb
                    return
                }
            }
        }

        // 3階層目
        for layer1Cell in cells.pull(around: bombCell) where layer1Cell.position != bombCell.position {
            for layer2Cell in cells.pull(around: layer1Cell) {
                for layer3Cell in cells.pull(around: layer2Cell) where layer3Cell.status == .empty {
                    for layer4Child in cells.pull(around: layer3Cell) where moveExperiment(tryTarget: layer4Child, changeTarget: layer3Cell) {
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
    private func moveExperiment(tryTarget: Cell, changeTarget: Cell) -> Bool {
        // ?と爆弾は検証対象から除外
        if tryTarget.status == .empty && tryTarget.position != changeTarget.position {
            tryTarget.status = .bomb
            if tryTarget.suji == cells.countBomb(around: tryTarget) {
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
        cells.map({ $0.reduce(""){ $0 + $1.status.rawValue + ", " }})
            .forEach { print($0) }
    }

    /// 爆弾を全て空に変更する
    ///
    /// - Parameter targetCell: 戻し対象セル
    private func resetBombToEmpty(for targetCell: Cell) {
        cells.pull(around: targetCell)
            .filter({ $0.status == .bomb })
            .forEach({ $0.status = .empty })
    }
}
