//
//  RoutinesView.swift
//  Cosmetic-Planning-App
//
//  Created by Siyu Liu on 10/19/26.
//


import SwiftUI

struct RoutinesView: View {
    @State private var selectedPeriod = "Morning"
    @State private var isEditing = false
    @State private var showsAddStep = false
    @State private var steps = [
        "Gentle cream cleanser",
        "Barrier Bloom Serum",
        "Daily Dew Cream",
        "Mineral SPF 40"
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ScreenHeader(title: "My Routines")

                Picker("Routine period", selection: $selectedPeriod) {
                    ForEach(["Morning", "Evening", "Weekly"], id: \.self, content: Text.init)
                }
                .pickerStyle(.segmented)

                // MARK: - Routine Card
                VStack(spacing: 0) {
                    HStack(spacing: 11) {
                        Image(systemName: "sun.max")
                            .font(.system(size: 21))
                            .foregroundStyle(Color(hex: 0xA9624F))
                            .frame(width: 44, height: 44)
                            .background(Color(hex: 0xF9E8DD))
                            .clipShape(RoundedRectangle(cornerRadius: 14))

                        VStack(alignment: .leading, spacing: 3) {
                            PillShapedButton(
                                text: "EVERY DAY · 8:00 AM",
                                background: Color(hex: 0xF8E5DA),
                                foreground: Color(hex: 0xA65F49)
                            )

                            Text("Glow & protect")
                                .font(.appSerif(22))

                            Text("\(steps.count) steps · About 8 minutes")
                                .font(.appSans(9))
                                .foregroundStyle(AppColor.muted)
                        }

                        Spacer()

                        Button(isEditing ? "Done" : "Edit") {
                            isEditing.toggle()
                        }
                        .font(.appSans(10, weight: .semibold))
                        .foregroundStyle(Color(hex: 0x8E657A))
                    }
                    .padding(16)

                    Divider()
                        .padding(.horizontal, 16)

                    // MARK: - Routine Steps
                    ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                        SwipeToDeleteRow(
                            onDelete: {
                                steps.remove(at: index)
                            },
                            content: {
                                HStack(spacing: 11) {
                                    Text("\(index + 1)")
                                        .font(.appSerif(13))
                                        .frame(width: 29, height: 29)
                                        .overlay {
                                            Circle()
                                                .stroke(Color(hex: 0xE7DEDD))
                                        }

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(step)
                                            .font(.appSans(11, weight: .semibold))

                                        Text(stepMeta(index))
                                            .font(.appSans(9))
                                            .foregroundStyle(AppColor.muted)
                                    }

                                    Spacer()

                                    if isEditing {
                                        HStack(spacing: 4) {
                                            ReorderButton(
                                                symbol: "arrow.up",
                                                disabled: index == 0
                                            ) {
                                                steps.swapAt(index, index - 1)
                                            }

                                            ReorderButton(
                                                symbol: "arrow.down",
                                                disabled: index == steps.count - 1
                                            ) {
                                                steps.swapAt(index, index + 1)
                                            }
                                        }
                                    } else {
                                        Image(
                                            systemName: index == steps.count - 1
                                                ? "sun.max" : "drop"
                                        )
                                        .foregroundStyle(AppColor.muted)
                                    }
                                }
                                .frame(minHeight: 66)
                                .padding(.horizontal, 16)
                            }
                        )

                        if index < steps.count - 1 {
                            Divider()
                                .padding(.leading, 56)
                        }
                    }


                    // MARK: - Add Product
                    Button {
                        showsAddStep = true
                    } label: {
                        Label("Add a product", systemImage: "plus")
                            .font(.appSans(10, weight: .semibold))
                            .foregroundStyle(Color(hex: 0x855F72))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                    }
                }
                .modifier(RectangularCard(radius: 23))

                // MARK: - Routine Schedule
                Button {} label: {
                    HStack {
                        Image(systemName: "clock")
                            .frame(width: 40, height: 40)
                            .background(Color(hex: 0xEDE8F3))
                            .clipShape(RoundedRectangle(cornerRadius: 12))

                        VStack(alignment: .leading, spacing: 3) {
                            Text("Routine schedule")
                                .font(.appSans(11, weight: .semibold))

                            Text("Every day at 8:00 AM")
                                .font(.appSans(9))
                                .foregroundStyle(AppColor.muted)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .foregroundStyle(AppColor.muted)
                    }
                    .padding(13)
                    .modifier(RectangularCard(radius: 17))
                }
                .buttonStyle(EmptyButtonStyle())

                // MARK: - Create Routine
                Button {
                    showsAddStep = true
                } label: {
                    Label("Create a new routine", systemImage: "plus")
                        .font(.appSans(10, weight: .semibold))
                        .foregroundStyle(Color(hex: 0x815F70))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .overlay {
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    Color(hex: 0xCFC2C7),
                                    style: StrokeStyle(lineWidth: 1, dash: [5])
                                )
                        }
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 28)
        }
        .background(AppColor.cream)
        .sheet(isPresented: $showsAddStep) {
            AddStepSheet(steps: $steps)
                .presentationDetents([.height(390)])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(28)
        }
    }

    // MARK: - Step Descriptions
    private func stepMeta(_ index: Int) -> String {
        if index == 0 {
            return "Cleanse · 60 sec"
        }

        if index == steps.count - 1 {
            return "Protect · 2 fingers"
        }

        return "Apply · 2–3 drops"
    }
}

// MARK: - Reorder Button
private struct ReorderButton: View {
    let symbol: String
    let disabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 10, weight: .semibold))
                .frame(width: 26, height: 26)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 7))
                .overlay {
                    RoundedRectangle(cornerRadius: 7)
                        .stroke(AppColor.line)
                }
        }
        .disabled(disabled)
        .opacity(disabled ? 0.35 : 1)
    }
}

// MARK: - Add Step Sheet
private struct AddStepSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var steps: [String]

    private let products = [
        "Rosewater face mist",
        "Petal Tint Balm",
        "Nourishing face oil"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Add a step")
                .font(.appSerif(28))

            Text("Choose a product from your shelf.")
                .font(.appSans(11))
                .foregroundStyle(AppColor.muted)
                .padding(.bottom, 8)

            ForEach(products, id: \.self) { product in
                Button {
                    steps.append(product)
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: "drop")
                            .frame(width: 40, height: 40)
                            .background(Color(hex: 0xF6E8E4))
                            .clipShape(RoundedRectangle(cornerRadius: 12))

                        Text(product)
                            .font(.appSans(12, weight: .semibold))

                        Spacer()

                        Image(systemName: "plus")
                    }
                    .padding(.vertical, 7)
                }
                .buttonStyle(.plain)

                Divider()
            }

            Spacer()
        }
        .padding(22)
        .background(AppColor.paper)
    }
}


/**Deleting Rows*/
private struct SwipeToDeleteRow<Content: View>: View {
    let onDelete: () -> Void
    @ViewBuilder let content: Content

    @State private var offset: CGFloat = 0

    private let deleteWidth: CGFloat = 80

    var body: some View {
        ZStack(alignment: .trailing) {
            Button(role: .destructive) {
                withAnimation(.easeInOut) {
                    offset = 0
                    onDelete()
                }
            } label: {
                Label("Delete", systemImage: "trash")
                    .labelStyle(.iconOnly)
                    .foregroundStyle(.white)
                    .frame(width: deleteWidth)
                    .frame(maxHeight: .infinity)
            }
            .background(Color.red)

            content
                .frame(maxWidth: .infinity)
                .background(AppColor.paper)
                .offset(x: offset)
                .gesture(
                    DragGesture(minimumDistance: 20)
                        .onChanged { gesture in
                            if gesture.translation.width < 0 {
                                offset = max(
                                    -deleteWidth,
                                    gesture.translation.width
                                )
                            }
                        }
                        .onEnded { gesture in
                            withAnimation(.easeOut(duration: 0.2)) {
                                offset = gesture.translation.width < -40
                                    ? -deleteWidth
                                    : 0
                            }
                        }
                )
        }
        .clipped()
    }
}

#Preview {
    RoutinesView()
}
