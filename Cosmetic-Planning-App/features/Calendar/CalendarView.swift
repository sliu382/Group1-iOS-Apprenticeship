//
//  CalendarView.swift
//  Cosmetic-Planning-App
//
//  Created by Siyu Liu on 10/19/26.
//


import SwiftUI

// MARK: - Calendar Mode

private enum CalendarMode: String, CaseIterable {
    case month = "Month"
    case week = "Week"
    case day = "Day"
}

// MARK: - Main Calendar View

struct CalendarView: View {
    @State private var mode: CalendarMode = .month
    @State private var selectedDate = Date()
    @State private var showsAdd = false

    private let calendar = Calendar.current

    var body: some View {
        ZStack(alignment: .bottomTrailing) {

            VStack(spacing: 12) {

                // MARK: Header
                ScreenHeader(
                    title: selectedDate.formatted(
                        .dateTime.month(.wide).year()
                    )
                )

                // MARK: Calendar Navigation
                HStack(spacing: 8) {
                    Button("Today") {
                        selectedDate = Date()
                    }
                    .font(.appSans(9, weight: .semibold))
                    .foregroundStyle(AppColor.ink)
                    .padding(.horizontal, 11)
                    .padding(.vertical, 8)
                    .background(.white)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 10)
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(AppColor.line)
                    }

                    Button {
                        changeDate(by: -1)
                    } label: {
                        Image(systemName: "chevron.left")
                    }

                    Button {
                        changeDate(by: 1)
                    } label: {
                        Image(systemName: "chevron.right")
                    }

                    Spacer()

                    Picker("Calendar view", selection: $mode) {
                        ForEach(CalendarMode.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 190)
                }
                .foregroundStyle(AppColor.ink)
                .font(.appSans(9))

                // MARK: Calendar Content
                Group {
                    switch mode {
                    case .month:
                        MonthCalendar(date: selectedDate)

                    case .week:
                        WeekCalendar(date: selectedDate)

                    case .day:
                        DayCalendar(date: selectedDate)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: CalendarLayout.monthHeight(for: selectedDate, calendar: calendar))
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .transition(.opacity)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 12)

            // MARK: Floating Add Button
            Button {
                showsAdd = true
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 19, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 50, height: 50)
                    .background(AppColor.accent)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 16)
                    )
                    .shadow(
                        color: AppColor.accent.opacity(0.24),
                        radius: 12,
                        y: 7
                    )
            }
            .padding(22)
        }
        .background(AppColor.cream)
        .animation(.easeInOut(duration: 0.2), value: mode)
        .sheet(isPresented: $showsAdd) {
            AddCalendarSheet()
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(28)
        }
    }

    // MARK: - Date Navigation

    private func changeDate(by amount: Int) {
        let component: Calendar.Component

        switch mode {
        case .month:
            component = .month
        case .week:
            component = .weekOfYear
        case .day:
            component = .day
        }

        if let newDate = calendar.date(
            byAdding: component,
            value: amount,
            to: selectedDate
        ) {
            selectedDate = newDate
        }
    }
}

// MARK: - Shared Layout

private enum CalendarLayout {
    static let monthRowHeight: CGFloat = 64
    static let monthHeaderHeight: CGFloat = 32
    static let timeWidth: CGFloat = 42
    static let hourHeight: CGFloat = 56

    static func monthStart(for date: Date, calendar: Calendar) -> Date {
        calendar.dateInterval(of: .month, for: date)?.start ?? date
    }

    static func leadingDays(for date: Date, calendar: Calendar) -> Int {
        let start = monthStart(for: date, calendar: calendar)
        return (calendar.component(.weekday, from: start) - calendar.firstWeekday + 7) % 7
    }

    static func monthCellCount(for date: Date, calendar: Calendar) -> Int {
        let days = calendar.range(of: .day, in: .month, for: date)?.count ?? 0
        return ((leadingDays(for: date, calendar: calendar) + days + 6) / 7) * 7
    }

    static func monthHeight(for date: Date, calendar: Calendar) -> CGFloat {
        monthHeaderHeight + CGFloat(monthCellCount(for: date, calendar: calendar) / 7) * monthRowHeight
    }

    static func hourLabel(_ hour: Int) -> String {
        let displayHour = hour % 12 == 0 ? 12 : hour % 12
        return "\(displayHour) \(hour < 12 ? "AM" : "PM")"
    }
}

// MARK: - Month Calendar

private struct MonthCalendar: View {
    let date: Date
    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(minimum: 0), spacing: 0), count: 7)

    var body: some View {
        VStack(spacing: 0) {
            LazyVGrid(columns: columns, spacing: 0) {
                ForEach(0..<7, id: \.self) { index in
                    let weekdayIndex = (calendar.firstWeekday - 1 + index) % 7
                    Text(calendar.veryShortStandaloneWeekdaySymbols[weekdayIndex])
                        .font(.appSans(7, weight: .semibold))
                        .foregroundStyle(AppColor.muted)
                        .frame(maxWidth: .infinity)
                        .frame(height: CalendarLayout.monthHeaderHeight)
                }
            }
            .overlay(alignment: .bottom) {
                Rectangle().fill(AppColor.line).frame(height: 0.5)
            }

            LazyVGrid(columns: columns, spacing: 0) {
                ForEach(0..<CalendarLayout.monthCellCount(for: date, calendar: calendar), id: \.self) { index in
                    let dayOffset = index - CalendarLayout.leadingDays(for: date, calendar: calendar)
                    let dayCount = calendar.range(of: .day, in: .month, for: date)?.count ?? 0
                    let isInMonth = dayOffset >= 0 && dayOffset < dayCount

                    VStack(spacing: 2) {
                        if isInMonth {
                            Text("\(dayOffset + 1)")
                                .font(.appSans(8, weight: .medium))
                                .foregroundStyle(AppColor.ink)
                                .frame(width: 21, height: 21)
                        }
                        Spacer(minLength: 0)
                    }
                    .padding(4)
                    .frame(maxWidth: .infinity)
                    .frame(height: CalendarLayout.monthRowHeight)
                    .background(isInMonth ? Color.white : Color(hex: 0xFDFBF9))
                    .overlay {
                        Rectangle().stroke(AppColor.line, lineWidth: 0.5)
                    }
                }
            }
        }
    }
}

// MARK: - Week Calendar

private struct WeekCalendar: View {
    let date: Date
    private let calendar = Calendar.current

    private var weekDates: [Date] {
        let start = calendar.dateInterval(
            of: .weekOfYear,
            for: date
        )?.start ?? calendar.startOfDay(for: date)

        return (0..<7).compactMap {
            calendar.date(byAdding: .day, value: $0, to: start)
        }
    }

    var body: some View {
        GeometryReader { geometry in
            let timeWidth = min(
                CalendarLayout.timeWidth,
                geometry.size.width * 0.16
            )
            let dayWidth = max(
                0,
                geometry.size.width - timeWidth
            ) / 7

            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Color.clear
                        .frame(width: timeWidth, height: 54)

                    ForEach(weekDates, id: \.self) { day in
                        VStack(spacing: 3) {
                            Text(
                                day.formatted(
                                    .dateTime.weekday(.abbreviated)
                                )
                            )
                            .font(.appSans(8))
                            .foregroundStyle(AppColor.muted)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)

                            Text(day.formatted(.dateTime.day()))
                                .font(.appSerif(13))
                                .foregroundStyle(AppColor.ink)
                                .frame(width: 28, height: 28)
                        }
                        .frame(width: dayWidth, height: 54)
                    }
                }
                .frame(height: 54)

                Divider()

                ScrollView(.vertical, showsIndicators: true) {
                    LazyVStack(spacing: 0) {
                        ForEach(0..<24, id: \.self) { hour in
                            HStack(spacing: 0) {
                                TimeLabel(
                                    hour: hour,
                                    width: timeWidth
                                )

                                ForEach(0..<7, id: \.self) { _ in
                                    Rectangle()
                                        .fill(Color.clear)
                                        .frame(
                                            width: dayWidth,
                                            height: CalendarLayout.hourHeight
                                        )
                                        .overlay {
                                            Rectangle()
                                                .stroke(
                                                    AppColor.line,
                                                    lineWidth: 0.5
                                                )
                                        }
                                }
                            }
                        }
                    }
                    .frame(width: geometry.size.width)
                }
                .frame(maxHeight: .infinity)
            }
            .frame(
                width: geometry.size.width,
                height: geometry.size.height,
                alignment: .top
            )
        }
    }
}

// MARK: - Day Calendar

private struct DayCalendar: View {
    let date: Date

    var body: some View {
        VStack(spacing: 0) {
            Text(date.formatted(.dateTime.weekday(.wide).month(.wide).day()))
                .font(.appSerif(21))
                .foregroundStyle(AppColor.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .frame(height: 54)
            Divider()
            ScrollView(.vertical, showsIndicators: true) {
                LazyVStack(spacing: 0) {
                    ForEach(0..<24, id: \.self) { hour in
                        HStack(spacing: 0) {
                            TimeLabel(hour: hour, width: CalendarLayout.timeWidth)
                            Rectangle()
                                .fill(Color.clear)
                                .frame(maxWidth: .infinity)
                                .frame(height: CalendarLayout.hourHeight)
                                .overlay {
                                    Rectangle().stroke(AppColor.line, lineWidth: 0.5)
                                }
                        }
                    }
                }
            }
        }
    }
}

private struct TimeLabel: View {
    let hour: Int
    let width: CGFloat

    var body: some View {
        Text(CalendarLayout.hourLabel(hour))
            .font(.appSans(8))
            .foregroundStyle(AppColor.muted)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .padding(.top, 5)
            .padding(.trailing, 5)
            .frame(width: width, height: CalendarLayout.hourHeight, alignment: .topTrailing)
    }
}

// MARK: - Add Calendar Sheet

private struct AddCalendarSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            Text("Add to calendar")
                .font(.appSerif(28))
                .foregroundStyle(AppColor.ink)

            Text("What would you like to schedule?")
                .font(.appSans(11))
                .foregroundStyle(AppColor.muted)

            Spacer()

            Button("Close") {
                dismiss()
            }
            .font(.appSans(10, weight: .semibold))
            .foregroundStyle(AppColor.accent)
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColor.cream)
    }
}

// MARK: - Preview

#Preview {
    CalendarView()
}



