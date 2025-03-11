//
//  Constants.swift
//  Umuriro
//
//  Created by Cédric Bahirwe on 11/03/2025.
//

import Foundation

enum Constants {
#if os(watchOS)
    static let gridItemSpacing: CGFloat = 3
#else
    static let gridItemSpacing: CGFloat = 16
#endif
    static let deleteButton = "X"
    static let conversionRate: Double = 294.117647059
}
