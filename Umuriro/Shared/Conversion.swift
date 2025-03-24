//
//  Conversion.swift
//  Umuriro
//
//  Created by Cédric Bahirwe on 11/03/2025.
//

import Foundation

struct Conversion {
    private(set) var rwf: Int = 0
    private(set) var kWh: Double = 0
    private var shouldClearInputOnNextDigit: Bool = false

    var type: ConversionType = .rwfToKWh
    var kWhInputString: String = "0"

    mutating func setType(_ newType: ConversionType) {
        guard type != newType else { return }
        switchType(shouldSwitchValues: false)
        return
    }

    mutating func switchType(shouldSwitchValues: Bool = true) {
        if shouldSwitchValues {
            switchValues()
        }
        type = (type == .rwfToKWh) ? .kWhToRwf : .rwfToKWh
        shouldClearInputOnNextDigit = true
    }

    mutating func switchValues() {
        switch type {
        case .rwfToKWh:
            // When switching from RWF→kWh to kWh→RWF
            // Set current rwf to kWh as the new input base
            kWh = Double(rwf)
            kWhInputString = String(format: "%.2f", kWh)
            // Remove trailing zeros and decimal if needed
            if kWhInputString.contains(".") {
                while kWhInputString.hasSuffix("0") {
                    kWhInputString.removeLast()
                }
                if kWhInputString.hasSuffix(".") {
                    kWhInputString.removeLast()
                }
            }

            rwf = calculateKWhToRWF()
        case .kWhToRwf:
            // When switching from kWh→RWF to RWF→kWh
            // Set current kWh to rwf as the new input base
            rwf = Int(kWh)

            kWh = calculateRWFToKWh()
            kWhInputString = String(kWh)
        }
    }


    mutating func addInput(_ digit: String) {
        if shouldClearInputOnNextDigit {
            clearInput()
            shouldClearInputOnNextDigit = false
        }

        switch type {
        case .rwfToKWh:
            guard digit != "." else { return }
            let newRwfString = String(rwf).appending(digit)
            rwf = Int(newRwfString) ?? 0
            kWh = calculateRWFToKWh()
        case .kWhToRwf:
            // Handle decimal point specially
            if digit == "." && !kWhInputString.contains(".") {
                kWhInputString = kWhInputString.appending(digit)
            } else if digit != "." {  // Only append non-decimal digits
                // If we're at "0", replace it rather than appending (unless it's a decimal point)
                if kWhInputString == "0" {
                    kWhInputString = digit
                } else {
                    kWhInputString = kWhInputString.appending(digit)
                }
            }

            kWh = Double(kWhInputString) ?? 0
            rwf = calculateKWhToRWF()
        }
    }

    mutating func clearInput() {
        rwf = 0
        kWh = 0
        shouldClearInputOnNextDigit = false
    }

    mutating func removeLastInput() {
        switch type {
        case .rwfToKWh:
            guard rwf != 0 else { return }
            var rwfString = String(rwf)
            rwfString.removeLast()
            rwf = Int(rwfString) ?? 0
            kWh = calculateRWFToKWh()

            // Update kWhInputString to match the new kWh value
            kWhInputString = String(kWh)
        case .kWhToRwf:
            guard kWhInputString.count > 1 else {
                kWhInputString = "0"
                kWh = 0
                rwf = 0
                return
            }

            kWhInputString.removeLast()

            // If we deleted everything or just a decimal point remains, reset to zero
            if kWhInputString.isEmpty || kWhInputString == "." {
                kWhInputString = "0"
            }

            kWh = Double(kWhInputString) ?? 0
            rwf = calculateKWhToRWF()
        }
    }

    func calculateRWFToKWh() -> Double {
        return Double(rwf) / Constants.conversionRate
    }

    mutating func calculateKWhToRWF() -> Int {
        let result = kWh * Constants.conversionRate
        if result > Double(Int.max) {
            // Reset values
            kWh = 0
            kWhInputString = "0"
            return 0
        }
        return Int(kWh * Constants.conversionRate)
    }

    // Helper method to get the current primary value as a string
    func currentInputString() -> String {
        switch type {
        case .rwfToKWh:
            return String(rwf)
        case .kWhToRwf:
            return String(format: "%.2f", kWh)
        }
    }
}
