//
//  RoutinesView.swift
//  Cosmetic-Planning-App
//
//  Created by Siyu Liu on 10/19/26.
//

import SwiftUI

struct RoutinesView: View {
    @State private var viewModel = RoutineViewModel()
    @State private var showsCreateRoutine = false
    @State private var newRoutineName = ""
    @State private var routineToDelete: Routine?

    // Set to false only in previews to avoid Supabase's "Auth session missing".
    private let usesLiveData: Bool

    init(usesLiveData: Bool = true) {
        self.usesLiveData = usesLiveData
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ScreenHeader(title: "My Routines")

                    Text("Little rituals, lovely days ✨")
                        .font(.appSans(12))
                        .foregroundStyle(RoutineTheme.muted)
                        .padding(.top, -10)

                    welcomeCard

                    HStack {
                        Text("Your rituals")
                            .font(.appSerif(24))
                            .foregroundStyle(RoutineTheme.ink)

                        Spacer()

                        Text("\(viewModel.routines.count) total")
                            .font(.appSans(11, weight: .semibold))
                            .foregroundStyle(RoutineTheme.rose)
                            .padding(.horizontal, 11)
                            .padding(.vertical, 6)
                            .background(RoutineTheme.blush, in: Capsule())
                    }

                    if viewModel.isLoading && viewModel.routines.isEmpty {
                        ProgressView("Loading routines...")
                            .tint(RoutineTheme.rose)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 30)
                    }

                    if let message = viewModel.errorMessage {
                        Text(message)
                            .font(.appSans(12))
                            .foregroundStyle(Color.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    if !viewModel.isLoading && viewModel.routines.isEmpty {
                        emptyState
                    }

                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.routines) { routine in
                            routineRow(routine)
                        }
                    }

                    Button {
                        newRoutineName = ""
                        showsCreateRoutine = true
                    } label: {
                        Label("Create a new routine", systemImage: "plus.circle.fill")
                            .font(.appSans(13, weight: .semibold))
                            .foregroundStyle(RoutineTheme.rose)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 17)
                            .background(RoutineTheme.blush.opacity(0.45), in: RoundedRectangle(cornerRadius: 18))
                            .overlay {
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(RoutineTheme.rose.opacity(0.40), style: StrokeStyle(lineWidth: 1, dash: [5]))
                            }
                    }
                    .buttonStyle(.plain)
                    .disabled(viewModel.isLoading || !usesLiveData)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 30)
            }
            .background(RoutineTheme.cream.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
            .task {
                guard usesLiveData else { return }
                await viewModel.loadRoutines()
            }
            .refreshable {
                guard usesLiveData else { return }
                await viewModel.loadRoutines()
            }
            .confirmationDialog(
                "Delete routine?",
                isPresented: Binding(
                    get: { routineToDelete != nil },
                    set: { if !$0 { routineToDelete = nil } }
                ),
                presenting: routineToDelete
            ) { routine in
                Button("Delete routine and its steps", role: .destructive) {
                    routineToDelete = nil
                    Task { await viewModel.deleteRoutine(id: routine.id) }
                }
                Button("Cancel", role: .cancel) {
                    routineToDelete = nil
                }
            } message: { routine in
                Text("\"\(routine.name)\" and all of its steps will be permanently deleted.")
            }
            .sheet(isPresented: $showsCreateRoutine) {
                createRoutineSheet
                    .presentationDetents([.height(350)])
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(28)
            }
        }
    }

    private var welcomeCard: some View {
        HStack(spacing: 14) {
            Image(systemName: "heart.text.square.fill")
                .font(.system(size: 28))
                .foregroundStyle(RoutineTheme.rose)
                .frame(width: 60, height: 60)
                .background(RoutineTheme.paper.opacity(0.8), in: RoundedRectangle(cornerRadius: 18))

            VStack(alignment: .leading, spacing: 6) {
                Text("MADE WITH A LITTLE LOVE")
                    .font(.appSans(9, weight: .semibold))
                    .tracking(1.2)
                    .foregroundStyle(RoutineTheme.rose)

                Text("Your daily glow-up, one step at a time.")
                    .font(.appSerif(19))
                    .foregroundStyle(RoutineTheme.ink)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(
            LinearGradient(
                colors: [RoutineTheme.blush, RoutineTheme.lavender],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 22)
        )
    }

    private var emptyState: some View {
        VStack(spacing: 11) {
            Image(systemName: "sparkles.rectangle.stack")
                .font(.system(size: 30))
                .foregroundStyle(RoutineTheme.rose)
            Text("A fresh start 🌷")
                .font(.appSerif(23))
                .foregroundStyle(RoutineTheme.ink)
            Text("Create your first routine to begin your self-care shelf.")
                .font(.appSans(12))
                .foregroundStyle(RoutineTheme.muted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .padding(.horizontal, 18)
        .routinePastelCard()
    }

    private func routineRow(_ routine: Routine) -> some View {
        HStack(spacing: 0) {
            NavigationLink {
                RoutineDetailView(routine: routine)
            } label: {
                HStack(spacing: 13) {
                    Image(systemName: RoutineTheme.symbol(for: routine.name))
                        .font(.system(size: 20))
                        .foregroundStyle(RoutineTheme.symbolColor(for: routine.name))
                        .frame(width: 50, height: 50)
                        .background(
                            RoutineTheme.symbolBackground(for: routine.name),
                            in: RoundedRectangle(cornerRadius: 15)
                        )

                    VStack(alignment: .leading, spacing: 5) {
                        Text(routine.name)
                            .font(.appSerif(20))
                            .foregroundStyle(RoutineTheme.ink)
                            .multilineTextAlignment(.leading)

                        Text("Tap to see your steps")
                            .font(.appSans(10))
                            .foregroundStyle(RoutineTheme.muted)
                    }

                    Spacer(minLength: 5)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(RoutineTheme.muted)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Button {
                routineToDelete = routine
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 14))
                    .foregroundStyle(RoutineTheme.rose)
                    .frame(width: 38, height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .disabled(viewModel.isLoading)
            .accessibilityLabel("Delete \(routine.name)")
        }
        .padding(.leading, 14)
        .padding(.trailing, 8)
        .padding(.vertical, 12)
        .routinePastelCard()
    }

    private var createRoutineSheet: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 18) {
                Text("A new little ritual ✨")
                    .font(.appSerif(27))
                    .foregroundStyle(RoutineTheme.ink)

                Text("Give your routine a cute name. You can add its steps next!")
                    .font(.appSans(12))
                    .foregroundStyle(RoutineTheme.muted)

                TextField("e.g. Morning Skincare", text: $newRoutineName)
                    .font(.appSans(14))
                    .padding(15)
                    .background(RoutineTheme.paper, in: RoundedRectangle(cornerRadius: 14))
                    .textInputAutocapitalization(.words)

                Button {
                    let name = newRoutineName.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !name.isEmpty else { return }
                    showsCreateRoutine = false
                    Task { await viewModel.addRoutine(name: name) }
                } label: {
                    Text("Create routine")
                        .font(.appSans(14, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(RoutineTheme.rose, in: RoundedRectangle(cornerRadius: 14))
                }
                .disabled(newRoutineName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                Spacer(minLength: 0)
            }
            .padding(24)
            .background(RoutineTheme.cream.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") { showsCreateRoutine = false }
                        .foregroundStyle(RoutineTheme.rose)
                }
            }
        }
        
    }
}

#Preview {
    // Layout preview only; launch the simulator to test Supabase data.
    RoutinesView(usesLiveData: false)
}





//import SwiftUI
//
//struct RoutinesView: View {
//    @State private var selectedPeriod = "Morning"
//    @State private var isEditing = false
//    @State private var showsAddStep = false
//    @State private var steps = [
//        "Gentle cream cleanser",
//        "Barrier Bloom Serum",
//        "Daily Dew Cream",
//        "Mineral SPF 40"
//    ]
//
//    var body: some View {
//        ScrollView {
//            VStack(spacing: 12) {
//                ScreenHeader(title: "My Routines")
//
//                Picker("Routine period", selection: $selectedPeriod) {
//                    ForEach(["Morning", "Evening", "Weekly"], id: \.self, content: Text.init)
//                }
//                .pickerStyle(.segmented)
//
//                // MARK: - Routine Card
//                VStack(spacing: 0) {
//                    HStack(spacing: 11) {
//                        Image(systemName: "sun.max")
//                            .font(.system(size: 21))
//                            .foregroundStyle(Color(hex: 0xA9624F))
//                            .frame(width: 44, height: 44)
//                            .background(Color(hex: 0xF9E8DD))
//                            .clipShape(RoundedRectangle(cornerRadius: 14))
//
//                        VStack(alignment: .leading, spacing: 3) {
//                            PillShapedButton(
//                                text: "EVERY DAY · 8:00 AM",
//                                background: Color(hex: 0xF8E5DA),
//                                foreground: Color(hex: 0xA65F49)
//                            )
//
//                            Text("Glow & protect")
//                                .font(.appSerif(22))
//
//                            Text("\(steps.count) steps · About 8 minutes")
//                                .font(.appSans(9))
//                                .foregroundStyle(AppColor.muted)
//                        }
//
//                        Spacer()
//
//                        Button(isEditing ? "Done" : "Edit") {
//                            isEditing.toggle()
//                        }
//                        .font(.appSans(10, weight: .semibold))
//                        .foregroundStyle(Color(hex: 0x8E657A))
//                    }
//                    .padding(16)
//
//                    Divider()
//                        .padding(.horizontal, 16)
//
//                    // MARK: - Routine Steps
//                    ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
//                        SwipeToDeleteRow(
//                            onDelete: {
//                                steps.remove(at: index)
//                            },
//                            content: {
//                                HStack(spacing: 11) {
//                                    Text("\(index + 1)")
//                                        .font(.appSerif(13))
//                                        .frame(width: 29, height: 29)
//                                        .overlay {
//                                            Circle()
//                                                .stroke(Color(hex: 0xE7DEDD))
//                                        }
//
//                                    VStack(alignment: .leading, spacing: 4) {
//                                        Text(step)
//                                            .font(.appSans(11, weight: .semibold))
//
//                                        Text(stepMeta(index))
//                                            .font(.appSans(9))
//                                            .foregroundStyle(AppColor.muted)
//                                    }
//
//                                    Spacer()
//
//                                    if isEditing {
//                                        HStack(spacing: 4) {
//                                            ReorderButton(
//                                                symbol: "arrow.up",
//                                                disabled: index == 0
//                                            ) {
//                                                steps.swapAt(index, index - 1)
//                                            }
//
//                                            ReorderButton(
//                                                symbol: "arrow.down",
//                                                disabled: index == steps.count - 1
//                                            ) {
//                                                steps.swapAt(index, index + 1)
//                                            }
//                                        }
//                                    } else {
//                                        Image(
//                                            systemName: index == steps.count - 1
//                                                ? "sun.max" : "drop"
//                                        )
//                                        .foregroundStyle(AppColor.muted)
//                                    }
//                                }
//                                .frame(minHeight: 66)
//                                .padding(.horizontal, 16)
//                            }
//                        )
//
//                        if index < steps.count - 1 {
//                            Divider()
//                                .padding(.leading, 56)
//                        }
//                    }
//
//
//                    // MARK: - Add Product
//                    Button {
//                        showsAddStep = true
//                    } label: {
//                        Label("Add a product", systemImage: "plus")
//                            .font(.appSans(10, weight: .semibold))
//                            .foregroundStyle(Color(hex: 0x855F72))
//                            .frame(maxWidth: .infinity)
//                            .padding(.vertical, 15)
//                    }
//                }
//                .modifier(RectangularCard(radius: 23))
//
//                // MARK: - Routine Schedule
//                Button {} label: {
//                    HStack {
//                        Image(systemName: "clock")
//                            .frame(width: 40, height: 40)
//                            .background(Color(hex: 0xEDE8F3))
//                            .clipShape(RoundedRectangle(cornerRadius: 12))
//
//                        VStack(alignment: .leading, spacing: 3) {
//                            Text("Routine schedule")
//                                .font(.appSans(11, weight: .semibold))
//
//                            Text("Every day at 8:00 AM")
//                                .font(.appSans(9))
//                                .foregroundStyle(AppColor.muted)
//                        }
//
//                        Spacer()
//
//                        Image(systemName: "chevron.right")
//                            .foregroundStyle(AppColor.muted)
//                    }
//                    .padding(13)
//                    .modifier(RectangularCard(radius: 17))
//                }
//                .buttonStyle(EmptyButtonStyle())
//
//                // MARK: - Create Routine
//                Button {
//                    showsAddStep = true
//                } label: {
//                    Label("Create a new routine", systemImage: "plus")
//                        .font(.appSans(10, weight: .semibold))
//                        .foregroundStyle(Color(hex: 0x815F70))
//                        .frame(maxWidth: .infinity)
//                        .padding(.vertical, 15)
//                        .overlay {
//                            RoundedRectangle(cornerRadius: 16)
//                                .stroke(
//                                    Color(hex: 0xCFC2C7),
//                                    style: StrokeStyle(lineWidth: 1, dash: [5])
//                                )
//                        }
//                }
//                .buttonStyle(.plain)
//            }
//            .padding(.horizontal, 20)
//            .padding(.bottom, 28)
//        }
//        .background(AppColor.cream)
//        .sheet(isPresented: $showsAddStep) {
//            AddStepSheet(steps: $steps)
//                .presentationDetents([.height(390)])
//                .presentationDragIndicator(.visible)
//                .presentationCornerRadius(28)
//        }
//    }
//
//    // MARK: - Step Descriptions
//    private func stepMeta(_ index: Int) -> String {
//        if index == 0 {
//            return "Cleanse · 60 sec"
//        }
//
//        if index == steps.count - 1 {
//            return "Protect · 2 fingers"
//        }
//
//        return "Apply · 2–3 drops"
//    }
//}
//
//// MARK: - Reorder Button
//private struct ReorderButton: View {
//    let symbol: String
//    let disabled: Bool
//    let action: () -> Void
//
//    var body: some View {
//        Button(action: action) {
//            Image(systemName: symbol)
//                .font(.system(size: 10, weight: .semibold))
//                .frame(width: 26, height: 26)
//                .background(.white)
//                .clipShape(RoundedRectangle(cornerRadius: 7))
//                .overlay {
//                    RoundedRectangle(cornerRadius: 7)
//                        .stroke(AppColor.line)
//                }
//        }
//        .disabled(disabled)
//        .opacity(disabled ? 0.35 : 1)
//    }
//}
//
//// MARK: - Add Step Sheet
//private struct AddStepSheet: View {
//    @Environment(\.dismiss) private var dismiss
//    @Binding var steps: [String]
//
//    private let products = [
//        "Rosewater face mist",
//        "Petal Tint Balm",
//        "Nourishing face oil"
//    ]
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 4) {
//            Text("Add a step")
//                .font(.appSerif(28))
//
//            Text("Choose a product from your shelf.")
//                .font(.appSans(11))
//                .foregroundStyle(AppColor.muted)
//                .padding(.bottom, 8)
//
//            ForEach(products, id: \.self) { product in
//                Button {
//                    steps.append(product)
//                    dismiss()
//                } label: {
//                    HStack {
//                        Image(systemName: "drop")
//                            .frame(width: 40, height: 40)
//                            .background(Color(hex: 0xF6E8E4))
//                            .clipShape(RoundedRectangle(cornerRadius: 12))
//
//                        Text(product)
//                            .font(.appSans(12, weight: .semibold))
//
//                        Spacer()
//
//                        Image(systemName: "plus")
//                    }
//                    .padding(.vertical, 7)
//                }
//                .buttonStyle(.plain)
//
//                Divider()
//            }
//
//            Spacer()
//        }
//        .padding(22)
//        .background(AppColor.paper)
//    }
//}
//
//
///**Deleting Rows*/
//private struct SwipeToDeleteRow<Content: View>: View {
//    let onDelete: () -> Void
//    @ViewBuilder let content: Content
//
//    @State private var offset: CGFloat = 0
//
//    private let deleteWidth: CGFloat = 80
//
//    var body: some View {
//        ZStack(alignment: .trailing) {
//            Button(role: .destructive) {
//                withAnimation(.easeInOut) {
//                    offset = 0
//                    onDelete()
//                }
//            } label: {
//                Label("Delete", systemImage: "trash")
//                    .labelStyle(.iconOnly)
//                    .foregroundStyle(.white)
//                    .frame(width: deleteWidth)
//                    .frame(maxHeight: .infinity)
//            }
//            .background(Color.red)
//
//            content
//                .frame(maxWidth: .infinity)
//                .background(AppColor.paper)
//                .offset(x: offset)
//                .gesture(
//                    DragGesture(minimumDistance: 20)
//                        .onChanged { gesture in
//                            if gesture.translation.width < 0 {
//                                offset = max(
//                                    -deleteWidth,
//                                    gesture.translation.width
//                                )
//                            }
//                        }
//                        .onEnded { gesture in
//                            withAnimation(.easeOut(duration: 0.2)) {
//                                offset = gesture.translation.width < -40
//                                    ? -deleteWidth
//                                    : 0
//                            }
//                        }
//                )
//        }
//        .clipped()
//    }
//}
//
//#Preview {
//    RoutinesView()
//}
