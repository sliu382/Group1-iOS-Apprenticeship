//
//  RoutineDetailView.swift
//  Cosmetic-Planning-App
//
//  Created by Siyu Liu on 10/25/26.
//

import SwiftUI

struct RoutineDetailView: View {
    let routine: Routine
    
    @State private var steps: [RoutineStep] = []
    @State private var isLoading = false
    @State private var isDeleting = false
    @State private var errorMessage: String?
    @State private var showsAddStep = false
    @State private var stepToDelete: RoutineStep?
    
    private let stepService = RoutineStepService()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerCard
                
                HStack {
                    Text("Your steps")
                        .font(.appSerif(24))
                        .foregroundStyle(RoutineTheme.ink)
                    Spacer()
                    Text("\(steps.count) total")
                        .font(.appSans(11, weight: .semibold))
                        .foregroundStyle(RoutineTheme.rose)
                        .padding(.horizontal, 11)
                        .padding(.vertical, 6)
                        .background(RoutineTheme.blush, in: Capsule())
                }
                
                if isLoading {
                    ProgressView("Loading your steps...")
                        .tint(RoutineTheme.rose)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 25)
                }
                
                if let errorMessage {
                    Text(errorMessage)
                        .font(.appSans(12))
                        .foregroundStyle(.red)
                }
                
                if !isLoading && steps.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: "drop.circle")
                            .font(.system(size: 28))
                            .foregroundStyle(RoutineTheme.rose)
                        Text("Your routine is a blank canvas")
                            .font(.appSerif(20))
                            .foregroundStyle(RoutineTheme.ink)
                        Text("Add a step, then add an item or a little how-to note.")
                            .font(.appSans(12))
                            .foregroundStyle(RoutineTheme.muted)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(24)
                    .routinePastelCard()
                }
                
                if !steps.isEmpty {
                    VStack(spacing: 0) {
                        ForEach(Array(steps.enumerated()), id: \.element.id) { index, step in
                            stepRow(step, number: index + 1)
                            if index < steps.count - 1 {
                                Rectangle()
                                    .fill(RoutineTheme.line)
                                    .frame(height: 1)
                                    .padding(.leading, 62)
                                    .padding(.trailing, 16)
                            }
                        }
                    }
                    .routinePastelCard()
                }
                
                Button {
                    showsAddStep = true
                } label: {
                    Label("Add another little step", systemImage: "plus.circle.fill")
                        .font(.appSans(13, weight: .semibold))
                        .foregroundStyle(RoutineTheme.rose)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(RoutineTheme.blush.opacity(0.45), in: RoundedRectangle(cornerRadius: 18))
                        .overlay {
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(RoutineTheme.rose.opacity(0.40), style: StrokeStyle(lineWidth: 1, dash: [5]))
                        }
                }
                .buttonStyle(.plain)
                .disabled(isLoading || isDeleting)
            }
            .padding(.horizontal, 20)
            .padding(.top, 14)
            .padding(.bottom, 30)
        }
        .background(RoutineTheme.cream.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Your ritual ✨")
                    .font(.appSerif(18))
                    .foregroundStyle(RoutineTheme.ink)
            }
        }
        .tint(RoutineTheme.rose)
        .task(id: routine.id) {
            await loadSteps()
        }
        .confirmationDialog(
            "Delete step?",
            isPresented: Binding(
                get: { stepToDelete != nil },
                set: { if !$0 { stepToDelete = nil } }
            ),
            presenting: stepToDelete
        ) { step in
            Button("Delete step", role: .destructive) {
                stepToDelete = nil
                Task { await deleteStep(id: step.id) }
            }
            Button("Cancel", role: .cancel) {
                stepToDelete = nil
            }
        } message: { step in
            Text("Remove \"\(step.title)\" from this routine? This cannot be undone.")
        }
        .sheet(isPresented: $showsAddStep) {
            AddRoutineStepSheet { title, item, note in
                try await saveStep(title: title, itemName: item, description: note)
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(28)
        }
    }
    private var headerCard: some View {
        HStack(alignment: .center, spacing: 15) {
            Image(systemName: RoutineTheme.symbol(for: routine.name))
                .font(.system(size: 27))
                .foregroundStyle(RoutineTheme.symbolColor(for: routine.name))
                .frame(width: 64, height: 64)
                .background(RoutineTheme.paper.opacity(0.8), in: RoundedRectangle(cornerRadius: 19))
            
            VStack(alignment: .leading, spacing: 6) {
                Text("YOUR SELF-CARE RITUAL")
                    .font(.appSans(9, weight: .semibold))
                    .tracking(1.1)
                    .foregroundStyle(RoutineTheme.rose)
                
                Text(routine.name)
                    .font(.appSerif(26))
                    .foregroundStyle(RoutineTheme.ink)
                
                Text("One lovely step at a time ♡")
                    .font(.appSans(11))
                    .foregroundStyle(RoutineTheme.muted)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(17)
        .background(
            LinearGradient(
                colors: [RoutineTheme.blush, RoutineTheme.lavender],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 23)
        )
    }
    
    private func stepRow(_ step: RoutineStep, number: Int) -> some View {
        HStack(alignment: .top, spacing: 13) {
            Text("\(number)")
                .font(.appSerif(15))
                .foregroundStyle(RoutineTheme.rose)
                .frame(width: 32, height: 32)
                .background(RoutineTheme.blush, in: Circle())
            
            VStack(alignment: .leading, spacing: 5) {
                Text(step.title)
                    .font(.appSans(14, weight: .semibold))
                    .foregroundStyle(RoutineTheme.ink)
                
                if let item = step.itemName, !item.isEmpty {
                    Label(item, systemImage: "sparkle")
                        .font(.appSans(11))
                        .foregroundStyle(RoutineTheme.rose)
                }
                
                if let note = step.description, !note.isEmpty {
                    Text(note)
                        .font(.appSans(11))
                        .foregroundStyle(RoutineTheme.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            
            Spacer(minLength: 4)
            
            Button {
                stepToDelete = step
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 13))
                    .foregroundStyle(RoutineTheme.rose)
                    .frame(width: 34, height: 40)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .disabled(isDeleting || isLoading)
            .accessibilityLabel("Delete \(step.title)")
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 17)
    }
    
    @MainActor
    private func loadSteps() async {
        isLoading = true
        defer { isLoading = false }
        do {
            steps = try await stepService.fetchSteps(routineId: routine.id)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    @MainActor
    private func deleteStep(id: UUID) async {
        guard !isDeleting else { return }
        isDeleting = true
        defer { isDeleting = false }
        do {
            try await stepService.deleteStep(id: id)
            steps = try await stepService.fetchSteps(routineId: routine.id)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    @MainActor
    private func saveStep(
        title: String,
        itemName: String?,
        description: String?
    ) async throws {
        try await stepService.addStep(
            routineId: routine.id,
            title: title,
            itemName: itemName,
            description: description,
            order: (steps.map(\.stepOrder).max() ?? -1) + 1
        )
        steps = try await stepService.fetchSteps(routineId: routine.id)
        errorMessage = nil
    }
}

private struct AddRoutineStepSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var itemName = ""
    @State private var note = ""
    @State private var isSaving = false
    @State private var errorMessage: String?

    let onSave: @MainActor (String, String?, String?) async throws -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    Text("Add a little step ✨")
                        .font(.appSerif(27))
                        .foregroundStyle(RoutineTheme.ink)

                    Text("An item and description are optional.")
                        .font(.appSans(12))
                        .foregroundStyle(RoutineTheme.muted)

                    fieldLabel("STEP TITLE")
                    TextField("e.g. Cleanser", text: $title)
                        .font(.appSans(13))
                        .padding(14)
                        .background(RoutineTheme.paper, in: RoundedRectangle(cornerRadius: 14))

                    fieldLabel("ITEM / PRODUCT (OPTIONAL)")
                    TextField("e.g. CeraVe Hydrating Cleanser", text: $itemName)
                        .font(.appSans(13))
                        .padding(14)
                        .background(RoutineTheme.paper, in: RoundedRectangle(cornerRadius: 14))

                    fieldLabel("DESCRIPTION (OPTIONAL)")
                    TextField("e.g. Massage gently and rinse", text: $note, axis: .vertical)
                        .lineLimit(2...4)
                        .font(.appSans(13))
                        .padding(14)
                        .background(RoutineTheme.paper, in: RoundedRectangle(cornerRadius: 14))

                    if let errorMessage {
                        Text(errorMessage)
                            .font(.appSans(11))
                            .foregroundStyle(.red)
                    }

                    Button {
                        Task { await save() }
                    } label: {
                        HStack(spacing: 8) {
                            if isSaving { ProgressView().tint(.white) }
                            Text("Save step")
                                .font(.appSans(14, weight: .semibold))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(RoutineTheme.rose, in: RoundedRectangle(cornerRadius: 14))
                    }
                    .disabled(isSaving || title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(24)
            }
            .background(RoutineTheme.cream.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(RoutineTheme.rose)
                        .disabled(isSaving)
                }
            }
        }
    }

    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(.appSans(10, weight: .semibold))
            .tracking(0.8)
            .foregroundStyle(RoutineTheme.rose)
    }

    @MainActor
    private func save() async {
        guard !isSaving else { return }
        isSaving = true
        defer { isSaving = false }
        errorMessage = nil
        do {
            let cleanedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
            let cleanedItem = itemName.trimmingCharacters(in: .whitespacesAndNewlines)
            let cleanedNote = note.trimmingCharacters(in: .whitespacesAndNewlines)
            try await onSave(
                cleanedTitle,
                cleanedItem.isEmpty ? nil : cleanedItem,
                cleanedNote.isEmpty ? nil : cleanedNote
            )
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

