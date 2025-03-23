//
//  ConverterView.swift
//  Umuriro
//
//  Created by Cédric Bahirwe on 09/03/2025.
//

import SwiftUI

struct ConverterView: View {
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

    var conversionSwitchBtn: some View {
        Button {
            conversion.switchType()
        } label: {
            Label("Switch Conversion", systemImage: "arrow.up.arrow.down")
                .labelStyle(.iconOnly)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(Color.accentColor)
        }
        .buttonStyle(.plain)
    }

    var body: some View {
        VStack {
            if !isWatchOS {
                ConversionRateLabel()
            }

            HStack {
                if !isWatchOS {
                    conversionSwitchBtn
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
								Text(conversion.kWhInputString.last == "." ? "." : "")
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
            .applyShadow()

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
    ConverterView()
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

extension View {
    @ViewBuilder
    func applyShadow() -> some View {
        if #available(iOS 16.0, *) {
            self.padding()
                .background(
                    Gradient(colors: [.black, .white.opacity(0.1)])
                        .shadow(.inner(color: .white, radius: 5))
                )
                .cornerRadius(24)
        } else {
            self
        }
    }
}
