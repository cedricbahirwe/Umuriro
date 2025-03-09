//
//  CalculatorView.swift
//  Umuriro
//
//  Created by Cédric Bahirwe on 09/03/2025.
//

import SwiftUI


enum ConversionType {
    case rwfToKWh
    case kWhToRwf
}

struct Conversion {
    private(set) var rwf: Int = 0
    private(set) var kWh: Double = 0
    private let conversionRate: Double = 294.117647059
    private var shouldClearInputOnNextDigit: Bool = false

    var type: ConversionType = .rwfToKWh

    mutating func switchValue() {
        (rwf, kWh) = (Int(kWh), Double(rwf))
    }

    mutating func switchType() {
        switch type {
        case .rwfToKWh:
            kWh = Double(rwf)
            rwf = calculateKWhToRWF()
        case .kWhToRwf:
            rwf = Int(kWh)
            kWh = calculateRWFToKWh()
        }
        type = (type == .rwfToKWh) ? .kWhToRwf : .rwfToKWh
        shouldClearInputOnNextDigit = true
    }

    mutating func addInput(_ digit: String) {
        if shouldClearInputOnNextDigit {
            clearInput()
            shouldClearInputOnNextDigit = false
        }

        switch type {
        case .rwfToKWh:
            let newRwfString = String(rwf).appending(digit)
            rwf = Int(newRwfString) ?? 0
            kWh = calculateRWFToKWh()
        case .kWhToRwf:
            print(kWh)
            var kWhString = String(format: "%.0f", kWh)
            // Remove decimal point if it's the last character
            if kWhString.hasSuffix(".") {
                kWhString.removeLast()
            }
            let newKWhString = kWhString.appending(digit)
            kWh = Double(newKWhString) ?? 0
            rwf = calculateKWhToRWF()
        }
    }

    mutating func clearInput() {
        rwf = 0
        kWh = 0
    }

    mutating func removeLastInput() {
        switch type {
        case .rwfToKWh:
            guard rwf != 0 else { return }
            var rwfString = String(rwf)
            rwfString.removeLast()
            rwf = Int(rwfString) ?? 0
            kWh = calculateRWFToKWh()
        case .kWhToRwf:
            guard kWh != 0 else { return }
            var kWhString = String(format: "%.2f", kWh)
            // Handle removal properly with decimal values
            kWhString.removeLast()
            if kWhString.hasSuffix(".") {
                kWhString.removeLast()
            }
            kWh = Double(kWhString) ?? 0
            rwf = calculateKWhToRWF()
        }
    }

    func calculateRWFToKWh() -> Double {
        return Double(rwf) / conversionRate
    }

    func calculateKWhToRWF() -> Int {
        return Int(kWh * conversionRate)
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
//    @State private var input = ""
//    var inputNumber: Double {
//        conversion.rwf
////        Double(input) ?? 0
//    }

//    private var calculatedKWh: CGFloat {
//        conversion.kWh
////        calulateRWFToKWh()
//    }

    let digitsPad = [
        "7", "8", "9",
        "4", "5", "6",
        "1", "2", "3",
        Constants.deleteButton, "0",  "."
    ]

    enum Constants {
        static let gridItemSpacing: CGFloat = 16
        static let deleteButton = "X"

    }
    let columns: [GridItem] = Array(
        repeating: GridItem(
            .flexible(),
            spacing: Constants.gridItemSpacing
        ),
        count: 3
    )

    var body: some View {
        VStack {
            HStack {
                Button {
                    conversion.switchType()
                } label: {
                    Label("Switch Converion", systemImage: "arrow.up.arrow.down")
                        .labelStyle(.iconOnly)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.accent)
                }

                VStack(alignment: .trailing) {
                    HStack(alignment: .center) {
                        Text(conversion.rwf, format: .number)
                            .font(.system(size: 60, weight: .bold))
                            .minimumScaleFactor(0.5)
                            .foregroundStyle(conversion.type == .rwfToKWh ? .primary : .secondary)


                        UnitLabel("RWF")


                    }
                    .frame(height: 100)

                    Color.gray
                        .frame(height: 1)

                    HStack(alignment: .center) {
                        Text(
                            conversion.kWh,
                            format: .number.precision(.fractionLength(0...2))
                        )
                        .font(.system(size: 60, weight: .bold))
                        .minimumScaleFactor(0.5)
                        .foregroundStyle(conversion.type == .rwfToKWh ? .secondary : .primary)

                        UnitLabel("Kwh")
                    }
                    .frame(height: 100)

                }
                .lineLimit(1)

            }

            .padding(.horizontal)

            LazyVGrid(
                columns: columns,
                spacing: Constants.gridItemSpacing
            ) {
                ForEach(digitsPad, id: \.self) { digit in
                    if digit.isEmpty {
                        Text("")
                    } else if digit == Constants.deleteButton {
                        Button {
                            conversion.removeLastInput()
                        } label: {
                            Label("Delete last digit", systemImage: "delete.backward")
                                .labelStyle(.iconOnly)
                                .font(.system(size: 40, weight: .medium))
                                .padding()
                                .frame(
                                    maxWidth: .infinity,
                                    maxHeight: .infinity
                                )
                                .background(.black.opacity(0.8))
                                .background(.regularMaterial)
                                .clipShape(.circle)
                                .aspectRatio(1, contentMode: .fill)
                        }

                    } else {
                        Button {
                            conversion.addInput(digit)
                        } label: {
                            Text(digit)
                                .font(.system(size: 40, weight: .heavy))
                                .padding()
                                .frame(
                                    maxWidth: .infinity,
                                    maxHeight: .infinity
                                )
                                .background(.black.opacity(0.8))
                                .background(.regularMaterial)
                                .clipShape(.circle)
                                .aspectRatio(1, contentMode: .fill)
                        }
                    }
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black)
        .foregroundStyle(.white)
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
            .font(.title3.weight(.medium))
            .foregroundStyle(.gray)
    }
}
