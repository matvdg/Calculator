//
//  NumberFormatter.swift
//  Calculator
//
//  Created by Mathieu Vandeginste on 16/05/2016.
//  Copyright © 2016 Mathieu Vandeginste. All rights reserved.
//

import Foundation

extension Double {
    
    var stringFromDouble: String {
        get {
            let formatter = NSNumberFormatter()
            formatter.alwaysShowsDecimalSeparator = true
            formatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
            formatter.maximumFractionDigits = 6
            formatter.alwaysShowsDecimalSeparator = false
            return formatter.stringFromNumber(self)!
        }
    }
}