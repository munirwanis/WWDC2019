//
//  UIColor+Extension.swift
//  WWDC2019
//
//  Created by Munir Wanis on 2019-03-23.
//  Copyright © 2019 Wanis Co. All rights reserved.
//

import UIKit

extension UIColor {
    static let wine    = #colorLiteral(red: 0.3450980392, green: 0.09411764706, blue: 0.2705882353, alpha: 1)
    static let darkRed = #colorLiteral(red: 0.5647058824, green: 0.04705882353, blue: 0.2470588235, alpha: 1)
    static let red     = #colorLiteral(red: 0.7803921569, green: 0, blue: 0.2235294118, alpha: 1)
    static let orange  = #colorLiteral(red: 1, green: 0.3411764706, blue: 0.2, alpha: 1)
    static let yellow  = #colorLiteral(red: 1, green: 0.7647058824, blue: 0.05882352941, alpha: 1)
    
    /// An Array with all the colors of the game
    /// also used to calculate the game hit points
    static let palette = [wine, darkRed, red, orange, yellow]
    
    /// Returns a random color from the games palette
    static var random: UIColor {
        let index = Int.random(in: 0..<palette.count)
        return palette[index]
    }
}
