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
    @State private var showsReminderEditor = false

    @AppStorage("calendar.reminders.v1")
    private var storedReminders = "[]"

    private let calendar = Calendar.current

    private var reminders: [CalendarReminder] {
        guard
            let data = storedReminders.data(using: .utf8),
            let items = try? JSONDecoder().decode(
                [CalendarReminder].self,
                from: data
            )
        else {
            return []
        }

        return items
    }

    private var selectedReminders: [CalendarReminder] {
        reminders
            .filter {
                calendar.isDate($0.date, inSameDayAs: selectedDate)
            }
            .sorted {
                $0.date < $1.date
            }
    }

    private var remindersTitle: String {
        if calendar.isDateInToday(selectedDate) {
            return "Today’s Reminders"
        }

        return "\(selectedDate.formatted(.dateTime.month(.abbreviated).day()))’s Reminders"
    }

    var body: some View {
        GeometryReader { geometry in
            let cellSize = max(0, geometry.size.width - 40) / 7
            let monthRows = CalendarLayout.monthCellCount(
                for: selectedDate,
                calendar: calendar
            ) / 7

            let calendarHeight =
                CalendarLayout.monthHeaderHeight
                + CGFloat(monthRows) * cellSize

            ZStack(alignment: .bottomTrailing) {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 12) {
                        ScreenHeader(
                            title: selectedDate.formatted(
                                .dateTime.month(.wide).year()
                            )
                        )

                        calendarNavigation

                        Group {
                            switch mode {
                            case .month:
                                MonthCalendar(
                                    date: $selectedDate,
                                    cellSize: cellSize
                                )

                            case .week:
                                WeekCalendar(date: $selectedDate)

                            case .day:
                                DayCalendar(date: selectedDate)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: calendarHeight)
                        .background(.white)
                        .clipShape(
                            RoundedRectangle(cornerRadius: 18)
                        )
                        .transition(.opacity)

                        remindersSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 96)
                }

                // Preserves the original add-calendar sheet.
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
                .accessibilityLabel("Add to calendar")
                .padding(22)
            }
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

    // MARK: - Calendar Navigation

    private var calendarNavigation: some View {
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
            .accessibilityLabel("Previous \(mode.rawValue.lowercased())")

            Button {
                changeDate(by: 1)
            } label: {
                Image(systemName: "chevron.right")
            }
            .accessibilityLabel("Next \(mode.rawValue.lowercased())")

            Spacer()

            Picker("Calendar view", selection: $mode) {
                ForEach(CalendarMode.allCases, id: \.self) { option in
                    Text(option.rawValue)
                        .tag(option)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 190)
        }
        .foregroundStyle(AppColor.ink)
        .font(.appSans(9))
    }

    // MARK: - Reminders Section

    private var remindersSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center, spacing: 12) {
                Text(remindersTitle)
                    .font(.appSerif(22))
                    .foregroundStyle(AppColor.ink)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: 0)

                Button {
                    showsReminderEditor = true
                } label: {
                    Label("Add", systemImage: "plus")
                        .font(.appSans(10, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(AppColor.accent)
                        .clipShape(
                            RoundedRectangle(cornerRadius: 10)
                        )
                }
                .accessibilityLabel("Create reminder")
            }

            if selectedReminders.isEmpty {
                Text("No reminders for this day. Tap Add to create one.")
                    .font(.appSans(11))
                    .foregroundStyle(AppColor.muted)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(.white)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 14)
                    )
            } else {
                VStack(spacing: 0) {
                    ForEach(selectedReminders) { reminder in
                        reminderRow(reminder)

                        if reminder.id != selectedReminders.last?.id {
                            Divider()
                                .overlay(AppColor.line)
                        }
                    }
                }
                .background(.white)
                .clipShape(
                    RoundedRectangle(cornerRadius: 14)
                )
            }
        }
        .padding(.top, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .sheet(isPresented: $showsReminderEditor) {
            CalendarReminderEditor(initialDate: selectedDate) { reminder in
                saveReminders(reminders + [reminder])
                selectedDate = reminder.date
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(28)
        }
    }

    private func reminderRow(_ reminder: CalendarReminder) -> some View {
        HStack(spacing: 12) {
            Button {
                var items = reminders

                if let index = items.firstIndex(
                    where: { $0.id == reminder.id }
                ) {
                    items[index].isComplete.toggle()
                    saveReminders(items)
                }
            } label: {
                Image(
                    systemName: reminder.isComplete
                        ? "checkmark.circle.fill"
                        : "circle"
                )
                .font(.system(size: 20))
                .foregroundStyle(AppColor.accent)
            }
            .accessibilityLabel(
                reminder.isComplete
                    ? "Mark incomplete"
                    : "Mark complete"
            )

            VStack(alignment: .leading, spacing: 5) {
                Text(reminder.title)
                    .font(.appSans(12, weight: .medium))
                    .foregroundStyle(AppColor.ink)
                    .strikethrough(reminder.isComplete)

                Text(
                    reminder.date.formatted(
                        date: .omitted,
                        time: .shortened
                    )
                )
                .font(.appSans(10))
                .foregroundStyle(AppColor.muted)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
    }

    // MARK: - Reminder Storage

    private func saveReminders(_ items: [CalendarReminder]) {
        guard
            let data = try? JSONEncoder().encode(items),
            let value = String(data: data, encoding: .utf8)
        else {
            return
        }

        storedReminders = value
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
    static let monthHeaderHeight: CGFloat = 32
    static let timeWidth: CGFloat = 42
    static let hourHeight: CGFloat = 56

    static func monthStart(
        for date: Date,
        calendar: Calendar
    ) -> Date {
        calendar.dateInterval(of: .month, for: date)?.start ?? date
    }

    static func leadingDays(
        for date: Date,
        calendar: Calendar
    ) -> Int {
        let start = monthStart(for: date, calendar: calendar)
        let weekday = calendar.component(.weekday, from: start)

        return (weekday - calendar.firstWeekday + 7) % 7
    }

    static func monthCellCount(
        for date: Date,
        calendar: Calendar
    ) -> Int {
        let days = calendar.range(
            of: .day,
            in: .month,
            for: date
        )?.count ?? 0

        let offset = leadingDays(for: date, calendar: calendar)

        return ((offset + days + 6) / 7) * 7
    }

    static func hourLabel(_ hour: Int) -> String {
        let displayHour = hour % 12 == 0 ? 12 : hour % 12
        return "\(displayHour) \(hour < 12 ? "AM" : "PM")"
    }
}

// MARK: - Month Calendar

private struct MonthCalendar: View {
    @Binding var date: Date
    let cellSize: CGFloat

    private let calendar = Calendar.current

    private let columns = Array(
        repeating: GridItem(.flexible(minimum: 0), spacing: 0),
        count: 7
    )

    var body: some View {
        VStack(spacing: 0) {
            LazyVGrid(columns: columns, spacing: 0) {
                ForEach(0..<7, id: \.self) { index in
                    let weekdayIndex =
                        (calendar.firstWeekday - 1 + index) % 7

                    Text(
                        calendar.veryShortStandaloneWeekdaySymbols[
                            weekdayIndex
                        ]
                    )
                    .font(.appSans(7, weight: .semibold))
                    .foregroundStyle(AppColor.muted)
                    .frame(maxWidth: .infinity)
                    .frame(height: CalendarLayout.monthHeaderHeight)
                }
            }
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(AppColor.line)
                    .frame(height: 0.5)
            }

            LazyVGrid(columns: columns, spacing: 0) {
                ForEach(
                    0..<CalendarLayout.monthCellCount(
                        for: date,
                        calendar: calendar
                    ),
                    id: \.self
                ) { index in
                    monthCell(at: index)
                }
            }
        }
    }

    private func monthCell(at index: Int) -> some View {
        let dayOffset = index - CalendarLayout.leadingDays(
            for: date,
            calendar: calendar
        )

        let dayCount = calendar.range(
            of: .day,
            in: .month,
            for: date
        )?.count ?? 0

        let isInMonth = dayOffset >= 0 && dayOffset < dayCount

        let cellDate = calendar.date(
            byAdding: .day,
            value: dayOffset,
            to: CalendarLayout.monthStart(
                for: date,
                calendar: calendar
            )
        ) ?? date

        let isSelected = calendar.isDate(
            cellDate,
            inSameDayAs: date
        )

        return Group {
            if isInMonth {
                Button {
                    date = cellDate
                } label: {
                    Text("\(dayOffset + 1)")
                        .font(.appSans(8, weight: .medium))
                        .foregroundStyle(
                            isSelected ? Color.white : AppColor.ink
                        )
                        .frame(width: 21, height: 21)
                        .background(
                            isSelected ? AppColor.accent : Color.clear
                        )
                        .clipShape(Circle())
                        .frame(
                            maxWidth: .infinity,
                            maxHeight: .infinity,
                            alignment: .top
                        )
                        .padding(4)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(
                    cellDate.formatted(
                        date: .complete,
                        time: .omitted
                    )
                )
            } else {
                Color(hex: 0xFDFBF9)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: cellSize)
        .background(.white)
        .overlay {
            Rectangle()
                .stroke(AppColor.line, lineWidth: 0.5)
                .allowsHitTesting(false)
        }
    }
}

// MARK: - Week Calendar

private struct WeekCalendar: View {
    @Binding var date: Date

    private let calendar = Calendar.current

    private var weekDates: [Date] {
        let start = calendar.dateInterval(
            of: .weekOfYear,
            for: date
        )?.start ?? calendar.startOfDay(for: date)

        return (0..<7).compactMap {
            calendar.date(
                byAdding: .day,
                value: $0,
                to: start
            )
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
                        Button {
                            date = day
                        } label: {
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

                                Text(
                                    day.formatted(.dateTime.day())
                                )
                                .font(.appSerif(13))
                                .foregroundStyle(AppColor.ink)
                                .frame(width: 28, height: 28)
                            }
                            .frame(width: dayWidth, height: 54)
                            .background(
                                calendar.isDate(
                                    day,
                                    inSameDayAs: date
                                )
                                ? AppColor.accent.opacity(0.12)
                                : Color.clear
                            )
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(
                            day.formatted(
                                date: .complete,
                                time: .omitted
                            )
                        )
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
            Text(
                date.formatted(
                    .dateTime.weekday(.wide).month(.wide).day()
                )
            )
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
                            TimeLabel(
                                hour: hour,
                                width: CalendarLayout.timeWidth
                            )

                            Rectangle()
                                .fill(Color.clear)
                                .frame(maxWidth: .infinity)
                                .frame(height: CalendarLayout.hourHeight)
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
        }
    }
}

// MARK: - Time Label

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
            .frame(
                width: width,
                height: CalendarLayout.hourHeight,
                alignment: .topTrailing
            )
    }
}

// MARK: - Reminder Model

private struct CalendarReminder: Identifiable, Codable {
    var id = UUID()
    var title: String
    var date: Date
    var isComplete = false
}

// MARK: - Create Reminder Sheet

private struct CalendarReminderEditor: View {
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var reminderDate: Date

    let onSave: (CalendarReminder) -> Void

    init(
        initialDate: Date,
        onSave: @escaping (CalendarReminder) -> Void
    ) {
        _reminderDate = State(initialValue: initialDate)
        self.onSave = onSave
    }

    private var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("New reminder")
                    .font(.appSerif(28))
                    .foregroundStyle(AppColor.ink)

                TextField(
                    "What would you like to remember?",
                    text: $title
                )
                .font(.appSans(12))
                .foregroundStyle(AppColor.ink)
                .padding(14)
                .background(.white)
                .clipShape(
                    RoundedRectangle(cornerRadius: 12)
                )
                .accessibilityLabel("Reminder title")

                DatePicker(
                    "Date and time",
                    selection: $reminderDate
                )
                .font(.appSans(11))
                .foregroundStyle(AppColor.ink)
                .tint(AppColor.accent)

                HStack {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(AppColor.muted)

                    Spacer()

                    Button("Save reminder") {
                        onSave(
                            CalendarReminder(
                                title: trimmedTitle,
                                date: reminderDate
                            )
                        )
                        dismiss()
                    }
                    .foregroundStyle(AppColor.accent)
                    .disabled(trimmedTitle.isEmpty)
                }
                .font(.appSans(11, weight: .semibold))
            }
            .padding(22)
        }
        .background(AppColor.cream)
    }
}

// MARK: - Existing Add Calendar Sheet

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


