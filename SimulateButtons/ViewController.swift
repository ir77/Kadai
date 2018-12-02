//
//  ViewController.swift
//  SimulateButtons
//
//  Created by Miyuki Hirose on 2018/11/27.
//  Copyright © 2018 Miyuki Hirose. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let screenWidth: CGFloat = self.view.frame.width
        let screenHeight: CGFloat = self.view.frame.height

        makeMap(screenWidth: screenWidth, screenHeight: screenHeight)

    }

    /// ボタン作成
    ///
    /// - Parameters:
    ///   - screenWidth: 画面横幅
    ///   - screenHeight: 画面縦幅
    func makeMap(screenWidth: CGFloat, screenHeight: CGFloat) {

        let row1: [Int] = [1, 2, 2, 1, 1, 1]
        let row2: [Int] = [1, 2, 2, 2, 2, 2]
        let row3: [Int] = [1, 2, 1, 2, 3, 3]
        let row4: [Int] = [2, 2, 2, 2, 3, 2]
        let row5: [Int] = [2, 2, 2, 1, 3, 2]
        let row6: [Int] = [2, 2, 2, 1, 2, 1]
        let row7: [Int] = [2, 2, 2, 1, 3, 2]
        let row8: [Int] = [2, 2, 2, 1, 2, 1]
        let rowCollection: [[Int]] = [row1, row2, row3, row4, row5, row6, row7, row8]

        for(rowIndex, rowItem) in rowCollection.enumerated() {
            for (index, value) in rowItem.enumerated() {
                addAnimalButton(x: CGFloat(index), y: CGFloat(rowIndex), screenWidth: screenWidth, screenHeight: screenHeight, label: value)
            }
        }

    }

    /// ボタン追加
    ///
    /// - Parameters:
    ///   - x: 横位置
    ///   - y: 縦位置
    ///   - screenWidth: 画面横幅
    ///   - screenHeight: 画面縦幅
    ///   - label: ボタン表示ラベル
    func addAnimalButton(x: CGFloat, y: CGFloat, screenWidth: CGFloat, screenHeight: CGFloat, label: Int) {
        let button = UIButton()
        // 位置
        button.frame = CGRect(x: screenWidth / 6 * x, y: screenHeight / 10 * y + (screenHeight / 10),
            width: screenWidth / 6, height: screenHeight / 10)

        // ボタンの色
        button.backgroundColor = UIColor.accentColor2
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        button.setTitle(String(label), for: UIControl.State.normal)
        button.addTarget(self,
            action: #selector(ViewController.buttonPushed(sender:)),
            for: .touchUpInside)

        self.view.addSubview(button)

    }

    /// 背景色のスイッチング
    ///
    /// - Parameter sender: 切り替え対象のボタン
    @IBAction func buttonPushed(sender: UIButton) {
        if sender.backgroundColor == UIColor.accentColor2 {
            sender.backgroundColor = UIColor.subColor
        } else {
            sender.backgroundColor = UIColor.accentColor2
        }
    }

}

extension UIColor {
    // メインカラー・ベースカラー
    class var mainColor: UIColor {

        return UIColor.hex(string: "#f7e9e3", alpha: 1.0)
    }
    // サブカラー
    class var subColor: UIColor {
        return UIColor.hex(string: "#6dc9c8", alpha: 1.0)
    }
    // アクセントカラー１ピンク
    class var accentColor1: UIColor {
        return UIColor.hex(string: "#ffc0c2", alpha: 1.0)
    }
    // アクセントカラー２黒
    class var accentColor2: UIColor {
        return UIColor.hex(string: "#0e3150", alpha: 1.0)
    }

    // 16進数で受け取ったカラーをRGBに変換して返却する
    class func hex (string: String, alpha: CGFloat) -> UIColor {
        let string_ = string.replacingOccurrences(of: "#", with: "")
        let scanner = Scanner(string: string_ as String)
        var color: UInt32 = 0
        if scanner.scanHexInt32(&color) {
            let r = CGFloat((color & 0xFF0000) >> 16) / 255.0
            let g = CGFloat((color & 0x00FF00) >> 8) / 255.0
            let b = CGFloat(color & 0x0000FF) / 255.0
            return UIColor(red: r, green: g, blue: b, alpha: alpha)
        } else {
            return UIColor.white;
        }
    }
}
