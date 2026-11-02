//
//  HomeView.swift
//  Cosmetic-Planning-App
//
//  Created by Siyu Liu on 10/18/26.
//


import SwiftUI

struct HomeView: View {
    @State private var viewModel = HomeViewModel()

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
                            NavigationLink {
                                RoutineDetailView(routine: routine)
                            } label: {
                                RoutineHomeCard(routine: routine)
                            }
                            .buttonStyle(.plain)
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

    var body: some View {
        HStack(spacing: 14) {
            Image(
                systemName: RoutineTheme.symbol(
                    for: routine.name
                )
            )
            .font(.system(size: 20))
            .foregroundStyle(
                RoutineTheme.symbolColor(
                    for: routine.name
                )
            )
            .frame(width: 50, height: 50)
            .background(
                RoutineTheme.symbolBackground(
                    for: routine.name
                )
            )
            .clipShape(
                RoundedRectangle(cornerRadius: 14)
            )

            VStack(alignment: .leading, spacing: 5) {
                Text(routine.name)
                    .font(.appSans(14, weight: .semibold))
                    .foregroundStyle(AppColor.ink)

                Text("View routine steps")
                    .font(.appSans(11))
                    .foregroundStyle(AppColor.muted)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(AppColor.muted)
        }
        .padding(16)
        .background(.white.opacity(0.85))
        .clipShape(
            RoundedRectangle(cornerRadius: 18)
        )
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
