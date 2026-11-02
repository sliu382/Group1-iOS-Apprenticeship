//
//  BeautyPicker.swift
//  Cosmetic-Planning-App
//
//  Created by Siyu Liu on 11/1/26.
//

import SwiftUI

struct BeautyPicker: View {
    let title: String
    @Binding var selection: String
    let options: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.appSans(15, weight: .semibold))
                .foregroundStyle(Color(hex: 0x615761))

            Menu {
                Button("None") {
                    selection = ""
                }

                ForEach(options, id: \.self) { option in
                    Button(option) {
                        selection = option
                    }
                }
            } label: {
                HStack {
                    Text(
                        selection.isEmpty
                            ? "Select \(title.lowercased())"
                            : selection
                    )
                    .foregroundStyle(
                        selection.isEmpty
                            ? Color.gray
                            : Color(hex: 0x615761)
                    )

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.system(size: 12))
                        .foregroundStyle(AppColor.muted)
                }
                .font(.appSans(13))
                .padding(.horizontal, 14)
                .frame(height: 46)
                .background(.white.opacity(0.75))
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 12,
                        style: .continuous
                    )
                )
                .overlay {
                    RoundedRectangle(
                        cornerRadius: 12,
                        style: .continuous
                    )
                    .stroke(
                        Color(hex: 0xE7DDDC),
                        lineWidth: 1
                    )
                }
            }
        }
    }
}

