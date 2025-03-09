//
//  CalculatorView.swift
//  Umuriro
//
//  Created by Cédric Bahirwe on 09/03/2025.
//

import SwiftUI

enum Constants {
#if os(watchOS)
    static let gridItemSpacing: CGFloat = 3
#else
    static let gridItemSpacing: CGFloat = 16
#endif
    static let deleteButton = "X"
    static let conversionRate: Double = 294.117647059
}

enum ConversionType {
    case rwfToKWh
    case kWhToRwf
}

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

    func calculateKWhToRWF() -> Int {
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
struct CalculatorView: View {
    @State private var conversion = Conversion()
    let digitsPad = [
        "7", "8", "9",
        "4", "5", "6",
        "1", "2", "3",
        Constants.deleteButton, "0",  "."
    ]

    let columns: [GridItem] = Array(
        repeating: GridItem(
            .flexible(),
            spacing: Constants.gridItemSpacing
        ),
        count: 3
    )

    var isWatchOS: Bool {
#if os(watchOS)
        return true
#else
        return false
#endif
    }

#if os(watchOS)
    @State private var showResult = false
#else
    private let showResult = true
#endif

    var converionSwitchBtn: some View {
        Button {
            conversion.switchType()
        } label: {
            Label("Switch Converion", systemImage: "arrow.up.arrow.down")
                .labelStyle(.iconOnly)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(Color.accentColor)
        }
        .buttonStyle(.plain)
    }

    var sbody: some View {
        Color.green
    }
    var body: some View {
        VStack {
            if !isWatchOS {
                ConversionRateLabel()
            }

            HStack {
                if !isWatchOS {
                    converionSwitchBtn
                }

                VStack(alignment: .trailing) {
                    if !isWatchOS || !showResult {
                        HStack(alignment: .center) {
                            Text(conversion.rwf, format: .number)
                                .font(.system(size: isWatchOS ? 26 : 60, weight: .bold))
                                .minimumScaleFactor(0.2)
                                .foregroundStyle(conversion.type == .rwfToKWh ? .primary : .secondary)


                            UnitLabel("RWF")
                        }
#if !os(watchOS)
                        .frame(height: 100)
                        .onTapGesture {
                            conversion.setType(.rwfToKWh)
                        }
#endif
                    }

                    if !isWatchOS {
                        Color.gray
                            .frame(height: 1)
                    }

                    if !isWatchOS || showResult {
                        HStack(alignment: .center) {
                            Group {
                                Text(
                                    conversion.kWh,
                                    format: .number
                                )

                                if let lastDot = conversion.kWhInputString.last, lastDot == "." {
                                    Text(conversion.kWhInputString.last == "." ? "." : "")
                                }
                            }
                            .font(.system(size: isWatchOS ? 26 : 60, weight: .bold))
                            .minimumScaleFactor(0.2)
                            .foregroundStyle((isWatchOS || conversion.type == .kWhToRwf) ? .primary : .secondary)

                            UnitLabel("Kwh")
                        }
#if !os(watchOS)
                        .frame(height: 100)
                        .onTapGesture {
                            conversion.setType(.kWhToRwf)
                        }
#endif
                    }

                }
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
#if os(watchOS)
            .frame(maxHeight: 30, alignment: .bottom)
#endif

            GeometryReader { geometry in
#if !os(watchOS)
                let availHeight = geometry.size.height - (3 * Constants.gridItemSpacing)
                #endif
                LazyVGrid(
                    columns: columns,
                    spacing: Constants.gridItemSpacing
                ) {
                    ForEach(digitsPad, id: \.self) { digit in
                        if digit == Constants.deleteButton {
                            Button {
#if os(watchOS)
                                if showResult {
                                    conversion.clearInput()
                                    conversion.setType(.rwfToKWh)
                                    showResult = false
                                }
#endif
                                conversion.removeLastInput()
                            } label: {
                                Label("Delete last digit", systemImage: "delete.backward")
                                    .labelStyle(.iconOnly)
                                    .font(
                                        .system(
                                            size: isWatchOS ? 14 : 40,
                                            weight: .medium
                                        )
                                    )
                                    .minimumScaleFactor(0.6)
                                    .padding(4)
                                    .frame(maxWidth: .infinity)
#if !os(watchOS)
                                    .frame(height: availHeight / 4)
                                    .background(.black.opacity(0.85))
                                    .background(.regularMaterial)
                                    .clipShape(.circle)
#else
                                    .background(.gray.opacity(0.3))
                                    .clipShape(.capsule)
#endif
                            }
                            .buttonStyle(.plain)
                        } else {
                            Button {
                                if isWatchOS && digit == "." {
#if os(watchOS)
                                    showResult = true
#endif
                                } else {
#if os(watchOS)
                                    if showResult {
                                        conversion.clearInput()
                                        conversion.setType(.rwfToKWh)
                                        showResult = false
                                    }
#endif
                                    conversion.addInput(digit)
                                }
                            } label: {
                                Text((isWatchOS && digit == ".") ? "=" : digit)
                                    .font(
                                        .system(
                                            size: isWatchOS ? 12 : 40,
                                            weight: .heavy
                                        )
                                    )
                                    .minimumScaleFactor(0.6)
                                    .padding(4)
                                    .frame(maxWidth: .infinity)
#if os(watchOS)
                                    .background(
                                        digit == "." ? Color.accentColor : Color .gray.opacity(0.3)
                                    )
                                    .clipShape(.capsule)

#else
                                    .frame(height: availHeight / 4)
                                    .background(.black.opacity(0.85))
                                    .background(.regularMaterial)
                                    .clipShape(.circle)
#endif
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
        .padding([.horizontal, .bottom] , isWatchOS ? 2 : 12)
        .frame(maxWidth: .infinity)
        .background(.black)
        .foregroundStyle(.white)
        .preferredColorScheme(.light)
    }
}

#Preview {
    CalculatorView()
}

struct UnitLabel: View {
    private let text: String
    init(_ text: String) {
        self.text = text
    }
    var body: some View {
        Text(text)
#if os(watchOS)
            .font(.headline.weight(.medium))
#else
            .font(.title3.weight(.medium))
#endif
            .foregroundStyle(.gray)
    }
}


struct ConversionRateLabel: View {
    var body: some View {
        Text("1 RWF = \((1/Constants.conversionRate).formatted(.number.precision(.fractionLength(...6)))) Kwh")
            .fontWeight(.semibold)
            .foregroundStyle(Color.accentColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.accentColor.opacity(0.2))
            .clipShape(.rect(cornerRadius: 6))
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
