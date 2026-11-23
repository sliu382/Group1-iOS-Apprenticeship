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
                    ScreenHeader(title: "My Routines") {
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

    private var emptyState: some View {
        VStack(spacing: 11) {
            Image(systemName: "list.bullet.clipboard") 
                .font(.system(size: 30))
                .foregroundStyle(RoutineTheme.rose)
            Text("No routines yet")
                .font(.appSerif(23))
                .foregroundStyle(RoutineTheme.ink)
            Text("Add your first routine to begin.")
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
                Text("Add a new routine ✨")
                    .font(.appSerif(27))
                    .foregroundStyle(RoutineTheme.ink)

                Text("Give your routine a name. You can add its steps next!")
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
    RoutinesView(usesLiveData: false)
}
