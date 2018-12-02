//
//  SolveProblemTests.swift
//  SimulateButtonsTests
//
//  Created by Miyuki Hirose on 2018/11/29.
//  Copyright © 2018 Miyuki Hirose. All rights reserved.
//

import XCTest

@testable import SimulateButtons
class SolveProblemTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    // 数字配列
    let sujiRow1: [Int] = [1, 2, 2, 1, 1, 1]
    let sujiRow2: [Int] = [1, 2, 2, 2, 2, 2]
    let sujiRow3: [Int] = [1, 2, 1, 2, 3, 3]
    let sujiRow4: [Int] = [2, 2, 2, 2, 3, 2]
    let sujiRow5: [Int] = [2, 2, 2, 1, 3, 2]
    let sujiRow6: [Int] = [2, 2, 2, 1, 2, 1]
    let sujiRow7: [Int] = [2, 2, 2, 1, 3, 2]
    let sujiRow8: [Int] = [2, 2, 2, 1, 2, 1]

    // 文字配列
    let mojiRow1: [String] = ["i", "p", "a", "g", "x", "u"]
    let mojiRow2: [String] = ["c", "t", "e", "h", "r", "a"]
    let mojiRow3: [String] = ["g", "q", "i", "r", "n", "z"]
    let mojiRow4: [String] = ["r", "d", "g", "o", "e", "o"]
    let mojiRow5: [String] = ["v", "n", "o", "w", "y", "s"]
    let mojiRow6: [String] = ["b", "t", "r", "p", "w", "a"]
    let mojiRow7: [String] = ["g", "u", "i", "x", "q", "u"]
    let mojiRow8: [String] = ["e", "t", "s", "m", "x", "n"]
    func test001_爆弾位置特定 () {

        let sujiRowCollection = [sujiRow1, sujiRow2, sujiRow3, sujiRow4, sujiRow5, sujiRow6, sujiRow7, sujiRow8]
        let mojiRowCollection = [mojiRow1, mojiRow2, mojiRow3, mojiRow4, mojiRow5, mojiRow6, mojiRow7, mojiRow8]

        let target: SolveProblem = SolveProblem(sujiRows: sujiRowCollection, mojiRows: mojiRowCollection);
        target.exec()

        // 期待値の作成
        var expect: [(x: Int, y: Int)] = []
        expect.append((x: 1, y: 0))
        expect.append((x: 2, y: 1))
        expect.append((x: 5, y: 1))
        expect.append((x: 4, y: 2))
        expect.append((x: 0, y: 3))
        expect.append((x: 5, y: 3))
        expect.append((x: 1, y: 4))
        expect.append((x: 3, y: 4))
        expect.append((x: 5, y: 5))
        expect.append((x: 0, y: 6))
        expect.append((x: 1, y: 7))
        expect.append((x: 3, y: 7))
        expect.append((x: 5, y: 7))

        var counter = 0
        for row in target.cellCollection {
            for col in row {
                if(SolveProblem.STATUS.BOMB == col.status) {
                    XCTAssert(col.ichi == expect[counter])
                    counter += 1
                }
            }

        }
    }

    func test002_メッセージ確認 () {

        let sujiRowCollection = [sujiRow1, sujiRow2, sujiRow3, sujiRow4, sujiRow5, sujiRow6, sujiRow7, sujiRow8]
        let mojiRowCollection = [mojiRow1, mojiRow2, mojiRow3, mojiRow4, mojiRow5, mojiRow6, mojiRow7, mojiRow8]

        let target: SolveProblem = SolveProblem(sujiRows: sujiRowCollection, mojiRows: mojiRowCollection);
        target.exec()
        XCTAssertEqual(target.makeMassage(), "pregnantwoman")
    }

    func test003_kの総和() {

        let sujiRowCollection = [sujiRow1, sujiRow2, sujiRow3, sujiRow4, sujiRow5, sujiRow6, sujiRow7, sujiRow8]
        let mojiRowCollection = [mojiRow1, mojiRow2, mojiRow3, mojiRow4, mojiRow5, mojiRow6, mojiRow7, mojiRow8]

        let target: SolveProblem = SolveProblem(sujiRows: sujiRowCollection, mojiRows: mojiRowCollection);
        XCTAssertEqual(target.sumAllSeki(), 756)
    }

    func test004_爆弾位置特定_課題を差し替えても成功するか確認 () {

        let sujiRowT1: [Int] = [1, 1, 1, 1, 2, 1]
        let sujiRowT2: [Int] = [1, 1, 1, 2, 3, 2]
        let sujiRowT3: [Int] = [2, 3, 1, 2, 1, 1]
        let sujiRowT4: [Int] = [2, 3, 2, 2, 2, 2]
        let sujiRowT5: [Int] = [2, 3, 3, 3, 3, 2]
        let sujiRowT6: [Int] = [1, 1, 2, 2, 3, 2]

        let mojiRowT: [String] = ["a", "a", "a", "a", "a", "a"]

        let sujiRowCollection = [sujiRowT1, sujiRowT2, sujiRowT3, sujiRowT4, sujiRowT5, sujiRowT6]
        let mojiRowCollection = [mojiRowT, mojiRowT, mojiRowT, mojiRowT, mojiRowT, mojiRowT]

        let target: SolveProblem = SolveProblem(sujiRows: sujiRowCollection, mojiRows: mojiRowCollection);
        target.exec()

        // 期待値の作成
        var expect: [(x: Int, y: Int)] = []
        expect.append((x: 3, y: 0))
        expect.append((x: 5, y: 0))
        expect.append((x: 0, y: 1))
        expect.append((x: 4, y: 2))
        expect.append((x: 0, y: 3))
        expect.append((x: 2, y: 3))
        expect.append((x: 1, y: 4))
        expect.append((x: 5, y: 4))
        expect.append((x: 3, y: 5))
        expect.append((x: 4, y: 5))

        var counter = 0
        for row in target.cellCollection {
            for col in row {
                if(SolveProblem.STATUS.BOMB == col.status) {
                    XCTAssert(col.ichi == expect[counter])
                    counter += 1
                }
            }

        }
    }
}
