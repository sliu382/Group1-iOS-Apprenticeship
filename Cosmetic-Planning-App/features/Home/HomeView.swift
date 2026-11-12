//
//  HomeView.swift
//  Cosmetic-Planning-App
//
//  Created by Siyu Liu on 10/18/26.
//


import SwiftUI

struct HomeView: View {
    @State private var viewModel = HomeViewModel()
    /// Ids of cards whose steps are showing.
    @State private var expandedCards: Set<UUID> = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // MARK: - Greeting
                ScreenHeader(title: viewModel.greeting)

                // MARK: - Today's Routines
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(
                        title: "Today's Routines"
                    )

                    if viewModel.isLoading &&
                        viewModel.todayRoutines.isEmpty {
                        ProgressView("Loading routines...")
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else if viewModel.todayRoutines.isEmpty {
                        homeEmptyCard(
                            symbol: "sparkles",
                            title: "No routines yet",
                            message: "Create a routine to start your beauty journey."
                        )
                    } else {
                        ForEach(viewModel.todayRoutines) { routine in
                            RoutineHomeCard(
                                routine: routine,
                                isExpanded: expandedCards.contains(routine.id),
                                steps: viewModel.stepsByRoutine[routine.id]
                            ) {
                                toggleSteps(cardId: routine.id, routineId: routine.id)
                            }
                        }
                    }
                }

                // MARK: - Today's Routine Reminders
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(
                        title: "Routine Reminders"
                    )

                    if viewModel.todayRoutineReminders.isEmpty {
                        homeEmptyCard(
                            symbol: "bell",
                            title: "No reminders today",
                            message: "Add a routine reminder from the Calendar tab."
                        )
                    } else {
                        ForEach(viewModel.todayRoutineReminders) { reminder in
                            let routine = viewModel.routine(for: reminder)

                            RoutineReminderHomeCard(
                                reminder: reminder,
                                routine: routine,
                                isExpanded: expandedCards.contains(reminder.id),
                                steps: routine.flatMap { viewModel.stepsByRoutine[$0.id] },
                                onToggleComplete: {
                                    viewModel.toggleReminder(id: reminder.id)
                                },
                                onToggleSteps: {
                                    if let routine {
                                        toggleSteps(cardId: reminder.id, routineId: routine.id)
                                    }
                                }
                            )
                        }
                    }
                }

                // MARK: - Today's Appointments
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(
                        title: "Today's Appointments"
                    )

                    if viewModel.isLoading &&
                        viewModel.todayAppointments.isEmpty {
                        ProgressView("Loading appointments...")
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else if viewModel.todayAppointments.isEmpty {
                        homeEmptyCard(
                            symbol: "calendar",
                            title: "No appointments today",
                            message: "Your schedule is clear for today!"
                        )
                    } else {
                        ForEach(viewModel.todayAppointments) { appointment in
                            AppointmentHomeCard(
                                appointment: appointment,
                                showsDate: false
                            )
                        }
                    }
                }

                // MARK: - Coming Up
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(title: "Coming Up")

                    if viewModel.isLoading &&
                        viewModel.upcomingAppointments.isEmpty {
                        ProgressView("Loading schedule...")
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else if viewModel.upcomingAppointments.isEmpty {
                        homeEmptyCard(
                            symbol: "calendar.badge.clock",
                            title: "Nothing coming up",
                            message: "Your upcoming appointments will appear here."
                        )
                    } else {
                        ForEach(
                            viewModel.upcomingAppointments.prefix(5)
                        ) { appointment in
                            AppointmentHomeCard(
                                appointment: appointment,
                                showsDate: true
                            )
                        }
                    }
                }

                // MARK: - Error Message
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.appSans(11))
                        .foregroundStyle(.red)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            .padding(.bottom, 28)
        }
        .background(AppColor.cream)
        .task {
            await viewModel.loadDashboard()
        }
        .refreshable {
            await viewModel.loadDashboard()
        }
    }

    // MARK: - Expand Steps

    private func toggleSteps(cardId: UUID, routineId: UUID) {
        let opening = !expandedCards.contains(cardId)

        withAnimation(.easeInOut(duration: 0.2)) {
            if opening {
                expandedCards.insert(cardId)
            } else {
                expandedCards.remove(cardId)
            }
        }

        if opening {
            Task { await viewModel.loadSteps(for: routineId) }
        }
    }

    // MARK: - Empty State
    private func homeEmptyCard(
        symbol: String,
        title: String,
        message: String
    ) -> some View {
        VStack(spacing: 10) {
            Image(systemName: symbol)
                .font(.system(size: 22))
                .foregroundStyle(AppColor.accent)
                .frame(width: 48, height: 48)
                .background(Color(hex: 0xF7EEEC))
                .clipShape(
                    RoundedRectangle(cornerRadius: 14)
                )

            Text(title)
                .font(.appSans(13, weight: .semibold))
                .foregroundStyle(AppColor.ink)

            Text(message)
                .font(.appSans(11))
                .foregroundStyle(AppColor.muted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(.white.opacity(0.8))
        .clipShape(
            RoundedRectangle(cornerRadius: 18)
        )
    }
}

// MARK: - Routine Card
private struct RoutineHomeCard: View {
    let routine: Routine
    let isExpanded: Bool
    let steps: [RoutineStep]?
    let onToggleSteps: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 14) {
                NavigationLink {
                    RoutineDetailView(routine: routine)
                } label: {
                    HStack(spacing: 14) {
                        Image(systemName: RoutineTheme.symbol(for: routine.name))
                            .font(.system(size: 20))
                            .foregroundStyle(RoutineTheme.symbolColor(for: routine.name))
                            .frame(width: 50, height: 50)
                            .background(RoutineTheme.symbolBackground(for: routine.name))
                            .clipShape(RoundedRectangle(cornerRadius: 14))

                        VStack(alignment: .leading, spacing: 5) {
                            Text(routine.name)
                                .font(.appSans(14, weight: .semibold))
                                .foregroundStyle(AppColor.ink)

                            Text("View routine steps")
                                .font(.appSans(11))
                                .foregroundStyle(AppColor.muted)
                        }

                        Spacer()
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                StepsChevron(isExpanded: isExpanded, action: onToggleSteps)
            }

            if isExpanded {
                RoutineStepList(steps: steps)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(16)
        .background(.white.opacity(0.85))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

// MARK: - Routine Reminder Card
private struct RoutineReminderHomeCard: View {
    let reminder: RoutineReminder
    let routine: Routine?
    let isExpanded: Bool
    let steps: [RoutineStep]?
    let onToggleComplete: () -> Void
    let onToggleSteps: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 14) {
                Button(action: onToggleComplete) {
                    Image(systemName: reminder.isComplete ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 22))
                        .foregroundStyle(AppColor.accent)
                        .frame(width: 50, height: 50)
                        .background(Color(hex: 0xF7EEEC))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(reminder.isComplete ? "Mark incomplete" : "Mark complete")

                if let routine {
                    NavigationLink {
                        RoutineDetailView(routine: routine)
                    } label: {
                        details
                    }
                    .buttonStyle(.plain)

                    StepsChevron(isExpanded: isExpanded, action: onToggleSteps)
                } else {
                    details
                }
            }

            if isExpanded, routine != nil {
                RoutineStepList(steps: steps)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(16)
        .background(.white.opacity(0.85))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private var details: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(reminder.title)
                    .font(.appSans(14, weight: .semibold))
                    .foregroundStyle(AppColor.ink)
                    .strikethrough(reminder.isComplete)

                Text(
                    [reminder.timeText, routine?.name]
                        .compactMap { $0 }
                        .joined(separator: " · ")
                )
                .font(.appSans(11))
                .foregroundStyle(AppColor.muted)
            }

            Spacer()
        }
        .contentShape(Rectangle())
    }
}

// MARK: - Steps Dropdown

/// Chevron that points right when closed and down when open.
private struct StepsChevron: View {
    let isExpanded: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(AppColor.muted)
                .rotationEffect(.degrees(isExpanded ? 90 : 0))
                .frame(width: 36, height: 36)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isExpanded ? "Hide steps" : "Show steps")
    }
}

/// Numbered list of a routine's steps. `nil` means still loading.
private struct RoutineStepList: View {
    let steps: [RoutineStep]?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Divider()
                .overlay(AppColor.line)

            if let steps {
                if steps.isEmpty {
                    Text("No steps yet. Tap the routine to add some.")
                        .font(.appSans(11))
                        .foregroundStyle(AppColor.muted)
                } else {
                    ForEach(Array(steps.enumerated()), id: \.element.id) { index, step in
                        HStack(alignment: .top, spacing: 10) {
                            Text("\(index + 1)")
                                .font(.appSerif(11))
                                .foregroundStyle(AppColor.accent)
                                .frame(width: 22, height: 22)
                                .background(AppColor.rose.opacity(0.6), in: Circle())

                            VStack(alignment: .leading, spacing: 2) {
                                Text(step.title)
                                    .font(.appSans(12, weight: .medium))
                                    .foregroundStyle(AppColor.ink)

                                if let item = step.itemName, !item.isEmpty {
                                    Text(item)
                                        .font(.appSans(10))
                                        .foregroundStyle(AppColor.muted)
                                }
                            }
                        }
                    }
                }
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.top, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Appointment Card
private struct AppointmentHomeCard: View {
    let appointment: Appointment
    let showsDate: Bool

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "calendar")
                .font(.system(size: 20))
                .foregroundStyle(Color(hex: 0x9A7185))
                .frame(width: 50, height: 50)
                .background(Color(hex: 0xF1E4E6))
                .clipShape(
                    RoundedRectangle(cornerRadius: 14)
                )

            VStack(alignment: .leading, spacing: 5) {
                Text(appointment.title)
                    .font(.appSans(14, weight: .semibold))
                    .foregroundStyle(AppColor.ink)

                Text(
                    showsDate
                        ? "\(appointment.dateText) · \(appointment.timeText)"
                        : appointment.timeText
                )
                .font(.appSans(11))
                .foregroundStyle(AppColor.muted)
            }

            Spacer()

            Image(systemName: "clock")
                .font(.system(size: 14))
                .foregroundStyle(AppColor.muted)
        }
        .padding(16)
        .background(.white.opacity(0.85))
        .clipShape(
            RoundedRectangle(cornerRadius: 18)
        )
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
}
