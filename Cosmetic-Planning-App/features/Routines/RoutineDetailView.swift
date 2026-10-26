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
    @State private var isSaving = false
    @State private var errorMessage: String?
    @State private var showsAddStep = false
    @State private var stepTitle = ""
    @State private var itemName = ""
    @State private var stepDescription = ""

    private let stepService = RoutineStepService()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(routine.name)
                    .font(.appSerif(30))
                    .foregroundStyle(Color(hex: 0x4C3C48))
                    .padding(.bottom, 4)

                if isLoading {
                    ProgressView("Loading steps...")
                }

                if let errorMessage {
                    Text(errorMessage)
                        .font(.appSans(12))
                        .foregroundStyle(.red)
                }

                if !isLoading && steps.isEmpty && errorMessage == nil {
                    Text("No steps yet. Add your first step!")
                        .font(.appSans(12))
                        .foregroundStyle(AppColor.muted)
                }

                VStack(spacing: 0) {
                    ForEach(Array(steps.enumerated()), id: \.element.id) { index, step in
                        HStack(alignment: .top, spacing: 12) {
                            Text("\(index + 1)")
                                .font(.appSerif(14))
                                .frame(width: 30, height: 30)
                                .overlay(Circle().stroke(Color(hex: 0xE7DEDD)))

                            VStack(alignment: .leading, spacing: 5) {
                                Text(step.title)
                                    .font(.appSans(13, weight: .semibold))
                                if let item = step.itemName, !item.isEmpty {
                                    Text(item)
                                        .font(.appSans(11))
                                        .foregroundStyle(AppColor.muted)
                                }
                                if let description = step.description, !description.isEmpty {
                                    Text(description)
                                        .font(.appSans(11))
                                        .foregroundStyle(AppColor.muted)
                                }
                            }
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)

                        if index < steps.count - 1 {
                            Divider().padding(.horizontal, 16)
                        }
                    }
                }
                .modifier(RectangularCard(radius: 23))

                Button {
                    showsAddStep = true
                } label: {
                    Label("Add a step", systemImage: "plus")
                        .font(.appSans(11, weight: .semibold))
                        .foregroundStyle(Color(hex: 0x815F70))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .overlay {
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color(hex: 0xCFC2C7), style: StrokeStyle(lineWidth: 1, dash: [5]))
                        }
                }
                .buttonStyle(.plain)
            }
            .padding(20)
        }
        .background(AppColor.cream)
        .navigationBarTitleDisplayMode(.inline)
        .task(id: routine.id) { await loadSteps() }
        .sheet(isPresented: $showsAddStep) {
            NavigationStack {
                Form {
                    TextField("Step title (e.g. Cleanser)", text: $stepTitle)
                    TextField("Product/item (optional)", text: $itemName)
                    TextField("Description (optional)", text: $stepDescription, axis: .vertical)
                        .lineLimit(2...4)
                }
                .navigationTitle("Add Step")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { showsAddStep = false }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            Task { await addStep() }
                        }
                        .disabled(stepTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSaving)
                    }
                }
            }
        }
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
    private func addStep() async {
        guard !isSaving else { return }
        isSaving = true
        defer { isSaving = false }

        do {
            try await stepService.addStep(
                routineId: routine.id,
                title: stepTitle.trimmingCharacters(in: .whitespacesAndNewlines),
                itemName: itemName.isEmpty ? nil : itemName,
                description: stepDescription.isEmpty ? nil : stepDescription,
                order: (steps.map(\.stepOrder).max() ?? -1) + 1
            )
            steps = try await stepService.fetchSteps(routineId: routine.id)
            stepTitle = ""
            itemName = ""
            stepDescription = ""
            errorMessage = nil
            showsAddStep = false
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

