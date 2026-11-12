//
//  CalendarView.swift
//  Cosmetic-Planning-App
//
//  Created by Siyu Liu on 10/19/26.
//

import SwiftUI

// MARK: - Main Calendar View

struct CalendarView: View {
    @State private var viewModel = CalendarViewModel()
    @State private var showsAdd = false

    var body: some View {
        GeometryReader { geometry in
            let gridWidth = max(0, geometry.size.width - 40)
            let monthCellHeight = (gridWidth / 7) * 1.3

            ZStack(alignment: .bottomTrailing) {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 12) {
                        header

                        calendarNavigation

                        Group {
                            switch viewModel.mode {
                            case .month:
                                MonthCalendar(
                                    viewModel: viewModel,
                                    cellHeight: monthCellHeight
                                )
                                .frame(
                                    height: CalendarLayout.monthHeaderHeight
                                        + CGFloat(viewModel.monthRowCount) * monthCellHeight
                                )

                            case .week:
                                WeekCalendar(viewModel: viewModel)
                                    .frame(height: CalendarLayout.timelineCardHeight)

                            case .day:
                                DayCalendar(viewModel: viewModel)
                                    .frame(height: CalendarLayout.timelineCardHeight)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(AppColor.line, lineWidth: 1)
                        }
                        .transition(.opacity)

                        remindersSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 96)
                }

                        Button {
                    showsAdd = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 19, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(width: 50, height: 50)
                        .background(AppColor.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: AppColor.accent.opacity(0.24), radius: 12, y: 7)
                }
                .accessibilityLabel("Add to calendar")
                .padding(22)
            }
        }
        .background(AppColor.cream)
        .animation(.easeInOut(duration: 0.2), value: viewModel.mode)
        .task {
            await viewModel.load()
        }
        .sheet(isPresented: $showsAdd) {
            AddToCalendarSheet(viewModel: viewModel)
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("YOUR BEAUTY RHYTHM")
                .font(.appSans(9, weight: .semibold))
                .tracking(2)
                .foregroundStyle(AppColor.muted)
                .padding(.top, 8)

            ScreenHeader(title: viewModel.monthTitle)
        }
    }

    // MARK: - Calendar Navigation

    private var calendarNavigation: some View {
        HStack(spacing: 8) {
            Button("Today") {
                viewModel.goToToday()
            }
            .font(.appSans(9, weight: .semibold))
            .foregroundStyle(AppColor.ink)
            .padding(.horizontal, 11)
            .padding(.vertical, 8)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(AppColor.line)
            }

            Button {
                viewModel.step(by: -1)
            } label: {
                Image(systemName: "chevron.left")
            }
            .accessibilityLabel("Previous \(viewModel.mode.rawValue.lowercased())")

            Button {
                viewModel.step(by: 1)
            } label: {
                Image(systemName: "chevron.right")
            }
            .accessibilityLabel("Next \(viewModel.mode.rawValue.lowercased())")

            Spacer()

            Picker("Calendar view", selection: $viewModel.mode) {
                ForEach(CalendarViewModel.Mode.allCases) { option in
                    Text(option.rawValue).tag(option)
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
        let reminders = viewModel.selectedDayReminders

        return VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center, spacing: 12) {
                Text(viewModel.remindersTitle)
                    .font(.appSerif(22))
                    .foregroundStyle(AppColor.ink)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: 0)
            }

            if reminders.isEmpty {
                Text("No reminders for this day. Tap + to add one.")
                    .font(.appSans(11))
                    .foregroundStyle(AppColor.muted)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            } else {
                VStack(spacing: 0) {
                    ForEach(reminders) { reminder in
                        reminderRow(reminder)

                        if reminder.id != reminders.last?.id {
                            Divider()
                                .overlay(AppColor.line)
                        }
                    }
                }
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
        .padding(.top, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func reminderRow(_ reminder: RoutineReminder) -> some View {
        HStack(spacing: 12) {
            Button {
                viewModel.toggleReminder(id: reminder.id)
            } label: {
                Image(systemName: reminder.isComplete ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundStyle(AppColor.accent)
            }
            .accessibilityLabel(reminder.isComplete ? "Mark incomplete" : "Mark complete")

            VStack(alignment: .leading, spacing: 5) {
                Text(reminder.title)
                    .font(.appSans(12, weight: .medium))
                    .foregroundStyle(AppColor.ink)
                    .strikethrough(reminder.isComplete)

                HStack(spacing: 4) {
                    if reminder.recurrence != nil {
                        Image(systemName: "repeat")
                            .font(.system(size: 9, weight: .semibold))
                    }

                    Text(reminder.timeText)
                        .font(.appSans(10))
                }
                .foregroundStyle(AppColor.muted)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
    }
}

// MARK: - Shared Layout

private enum CalendarLayout {
    static let monthHeaderHeight: CGFloat = 34
    static let timelineCardHeight: CGFloat = 520
    static let timelineHeaderHeight: CGFloat = 58

    static let timeWidth: CGFloat = 38
    static let hourHeight: CGFloat = 56
    /// Grid lines and labels every 2 hours, like the Figma.
    static let slotHours = 2
    static var slotHeight: CGFloat { hourHeight * CGFloat(slotHours) }
    static var slotCount: Int { 24 / slotHours }
    /// Slot to scroll to on appear (4 × 2h = 8 AM).
    static let initialSlot = 4

    /// Reminders have no end time, so draw them as 45 min blocks.
    static let defaultDuration: TimeInterval = 45 * 60

    static func hourLabel(_ hour: Int) -> String {
        let displayHour = hour % 12 == 0 ? 12 : hour % 12
        return "\(displayHour) \(hour < 12 ? "AM" : "PM")"
    }

    static func yOffset(for date: Date, calendar: Calendar) -> CGFloat {
        let parts = calendar.dateComponents([.hour, .minute], from: date)
        let hours = CGFloat(parts.hour ?? 0) + CGFloat(parts.minute ?? 0) / 60
        return hours * hourHeight
    }

    static func blockHeight(for event: CalendarEvent, minimum: CGFloat) -> CGFloat {
        let duration = event.end.map { $0.timeIntervalSince(event.start) } ?? defaultDuration
        return max(minimum, CGFloat(duration / 3600) * hourHeight - 4)
    }

    /// Lays out one day's events so overlapping blocks sit side by side.
    /// Events that visually overlap form a cluster; each event in a cluster
    /// gets the first free column, and the cluster's width is split evenly.
    static func positioned(
        _ events: [CalendarEvent],
        minimumHeight: CGFloat,
        calendar: Calendar
    ) -> [PositionedEvent] {
        typealias Placed = (event: CalendarEvent, y: CGFloat, height: CGFloat, column: Int)

        let items = events
            .filter { !$0.isAllDay }
            .sorted { $0.start < $1.start }
            .map { event in
                (
                    event: event,
                    y: yOffset(for: event.start, calendar: calendar) + 2,
                    height: blockHeight(for: event, minimum: minimumHeight)
                )
            }

        var result: [PositionedEvent] = []
        var cluster: [Placed] = []
        var columnEnds: [CGFloat] = []
        var clusterEnd: CGFloat = -1

        func flushCluster() {
            let count = columnEnds.count
            result += cluster.map {
                PositionedEvent(
                    event: $0.event,
                    y: $0.y,
                    height: $0.height,
                    column: $0.column,
                    columnCount: count
                )
            }
            cluster.removeAll()
            columnEnds.removeAll()
        }

        for item in items {
            // Starts after everything in the current cluster has ended.
            if item.y >= clusterEnd {
                flushCluster()
            }

            let column = columnEnds.firstIndex { $0 <= item.y } ?? columnEnds.count
            if column == columnEnds.count {
                columnEnds.append(0)
            }
            columnEnds[column] = item.y + item.height

            cluster.append((event: item.event, y: item.y, height: item.height, column: column))
            clusterEnd = max(clusterEnd, item.y + item.height)
        }
        flushCluster()

        return result
    }
}

private struct PositionedEvent: Identifiable {
    let event: CalendarEvent
    let y: CGFloat
    let height: CGFloat
    let column: Int
    let columnCount: Int

    var id: String { event.id }
}

/// Draws a day's events in their columns, splitting the width when they overlap.
private struct DayEventColumn: View {
    let events: [CalendarEvent]
    let compact: Bool
    let calendar: Calendar

    var body: some View {
        GeometryReader { geometry in
            let gap: CGFloat = compact ? 2 : 4
            let leading: CGFloat = compact ? 2 : 6
            let trailing: CGFloat = compact ? 2 : 24
            let usableWidth = max(0, geometry.size.width - leading - trailing)

            ZStack(alignment: .topLeading) {
                Color.clear

                ForEach(
                    CalendarLayout.positioned(
                        events,
                        minimumHeight: compact ? 44 : 56,
                        calendar: calendar
                    )
                ) { item in
                    let columnWidth = usableWidth / CGFloat(item.columnCount)

                    EventBlock(event: item.event, compact: compact || item.columnCount > 2)
                        .frame(
                            width: max(0, columnWidth - (item.columnCount > 1 ? gap : 0)),
                            height: item.height
                        )
                        .offset(
                            x: leading + columnWidth * CGFloat(item.column),
                            y: item.y
                        )
                }
            }
        }
    }
}

// MARK: - Month Calendar

private struct MonthCalendar: View {
    let viewModel: CalendarViewModel
    let cellHeight: CGFloat

    private let columns = Array(
        repeating: GridItem(.flexible(minimum: 0), spacing: 0),
        count: 7
    )

    var body: some View {
        let eventsByDay = viewModel.eventsByDay
        let cells = viewModel.monthGrid
        let calendar = viewModel.calendar

        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(viewModel.weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.appSans(7, weight: .semibold))
                        .foregroundStyle(AppColor.muted)
                        .frame(maxWidth: .infinity)
                }
            }
            .frame(height: CalendarLayout.monthHeaderHeight)
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(AppColor.line)
                    .frame(height: 0.5)
            }

            LazyVGrid(columns: columns, spacing: 0) {
                ForEach(cells.indices, id: \.self) { index in
                    Group {
                        if let day = cells[index] {
                            MonthDayCell(
                                date: day,
                                events: eventsByDay[calendar.startOfDay(for: day)] ?? [],
                                isSelected: viewModel.isSelected(day),
                                isToday: viewModel.isToday(day)
                            ) {
                                viewModel.select(day)
                            }
                        } else {
                            Color(hex: 0xFDFBF9)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: cellHeight)
                    .overlay {
                        Rectangle()
                            .stroke(AppColor.line, lineWidth: 0.5)
                            .allowsHitTesting(false)
                    }
                }
            }
        }
    }
}

private struct MonthDayCell: View {
    let date: Date
    let events: [CalendarEvent]
    let isSelected: Bool
    let isToday: Bool
    let action: () -> Void

    private let maxBars = 2

    var body: some View {
        Button(action: action) {
            VStack(spacing: 3) {
                Text(date.formatted(.dateTime.day()))
                    .font(.appSans(9, weight: isToday || isSelected ? .semibold : .medium))
                    .foregroundStyle(
                        isSelected ? Color.white : (isToday ? AppColor.accent : AppColor.ink)
                    )
                    .frame(width: 22, height: 22)
                    .background(isSelected ? AppColor.accent : Color.clear, in: Circle())

                ForEach(events.prefix(maxBars)) { event in
                    EventBar(event: event)
                }

                if events.count > maxBars {
                    Text("+\(events.count - maxBars) more")
                        .font(.appSans(6.5, weight: .medium))
                        .foregroundStyle(AppColor.muted)
                }

                Spacer(minLength: 0)
            }
            .padding(.top, 6)
            .padding(.horizontal, 2)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityText)
    }

    private var accessibilityText: String {
        let day = date.formatted(date: .complete, time: .omitted)
        guard !events.isEmpty else { return day }
        return "\(day), \(events.map(\.title).joined(separator: ", "))"
    }
}

/// The small colored pill used in Month view.
private struct EventBar: View {
    let event: CalendarEvent

    var body: some View {
        Text(event.title)
            .font(.appSans(7, weight: .semibold))
            .strikethrough(event.isComplete)
            .foregroundStyle(event.tint.text)
            .lineLimit(1)
            .padding(.horizontal, 4)
            .padding(.vertical, 3)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                event.tint.fill,
                in: RoundedRectangle(cornerRadius: 4, style: .continuous)
            )
            .opacity(event.isComplete ? 0.55 : 1)
    }
}

// MARK: - Week Calendar

private struct WeekCalendar: View {
    let viewModel: CalendarViewModel

    var body: some View {
        let eventsByDay = viewModel.eventsByDay
        let calendar = viewModel.calendar
        let days = viewModel.weekDates

        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Color.clear
                    .frame(width: CalendarLayout.timeWidth)

                ForEach(days, id: \.self) { day in
                    WeekDayHeader(
                        date: day,
                        isSelected: viewModel.isSelected(day)
                    ) {
                        viewModel.select(day)
                    }
                    .overlay(alignment: .leading) {
                        Rectangle()
                            .fill(AppColor.line)
                            .frame(width: 0.5)
                    }
                }
            }
            .frame(height: CalendarLayout.timelineHeaderHeight)

            Divider()
                .overlay(AppColor.line)

            let allDayByDay = days.map { day in
                (eventsByDay[calendar.startOfDay(for: day)] ?? []).filter(\.isAllDay)
            }

            if allDayByDay.contains(where: { !$0.isEmpty }) {
                HStack(alignment: .top, spacing: 0) {
                    Text("all-day")
                        .font(.appSans(6.5))
                        .foregroundStyle(AppColor.muted)
                        .padding(.trailing, 6)
                        .padding(.top, 4)
                        .frame(width: CalendarLayout.timeWidth, alignment: .topTrailing)

                    ForEach(days.indices, id: \.self) { index in
                        VStack(spacing: 2) {
                            ForEach(allDayByDay[index].prefix(2)) { event in
                                EventBar(event: event)
                            }
                            if allDayByDay[index].count > 2 {
                                Text("+\(allDayByDay[index].count - 2)")
                                    .font(.appSans(6.5, weight: .medium))
                                    .foregroundStyle(AppColor.muted)
                            }
                        }
                        .padding(2)
                        .frame(maxWidth: .infinity, alignment: .top)
                    }
                }
                .padding(.vertical, 3)

                Divider()
                    .overlay(AppColor.line)
            }

            TimelineScroll {
                HStack(spacing: 0) {
                    ForEach(days, id: \.self) { day in
                        DayEventColumn(
                            events: eventsByDay[calendar.startOfDay(for: day)] ?? [],
                            compact: true,
                            calendar: calendar
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .overlay(alignment: .leading) {
                            Rectangle()
                                .fill(AppColor.line)
                                .frame(width: 0.5)
                        }
                    }
                }
            }
        }
    }
}

private struct WeekDayHeader: View {
    let date: Date
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(date.formatted(.dateTime.weekday(.abbreviated)).uppercased())
                    .font(.appSans(7))
                    .foregroundStyle(AppColor.muted)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)

                Text(date.formatted(.dateTime.day()))
                    .font(.appSerif(13))
                    .foregroundStyle(isSelected ? Color.white : AppColor.ink)
                    .frame(width: 26, height: 26)
                    .background(isSelected ? AppColor.accent : Color.clear, in: Circle())
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(date.formatted(date: .complete, time: .omitted))
    }
}

// MARK: - Day Calendar

private struct DayCalendar: View {
    let viewModel: CalendarViewModel

    var body: some View {
        let events = viewModel.selectedDayEvents
        let calendar = viewModel.calendar

        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                if viewModel.isToday(viewModel.selectedDate) {
                    Text("TODAY")
                        .font(.appSans(7, weight: .semibold))
                        .tracking(1.5)
                        .foregroundStyle(Color(hex: 0x9A5B6E))
                        .padding(.horizontal, 9)
                        .padding(.vertical, 5)
                        .background(Color(hex: 0xF7E4E8), in: Capsule())
                }

                Text(viewModel.dayTitle)
                    .font(.appSerif(21))
                    .foregroundStyle(AppColor.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                let allDay = events.filter(\.isAllDay)
                if !allDay.isEmpty {
                    VStack(spacing: 4) {
                        ForEach(allDay) { event in
                            Text("\(event.title) · All day")
                                .font(.appSans(9, weight: .semibold))
                                .strikethrough(event.isComplete)
                                .foregroundStyle(event.tint.text)
                                .lineLimit(1)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    event.tint.fill,
                                    in: RoundedRectangle(cornerRadius: 8, style: .continuous)
                                )
                                .opacity(event.isComplete ? 0.6 : 1)
                        }
                    }
                    .padding(.top, 2)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 18)
            .padding(.vertical, 16)

            Divider()
                .overlay(AppColor.line)

            TimelineScroll {
                DayEventColumn(
                    events: events,
                    compact: false,
                    calendar: calendar
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay(alignment: .leading) {
                    Rectangle()
                        .fill(AppColor.line)
                        .frame(width: 0.5)
                }
            }
        }
    }
}

// MARK: - Timeline Building Blocks

/// Scrollable 24h timeline: time labels on the left, a line every 2 hours,
/// and whatever event columns you pass in on the right. Opens at 8 AM.
private struct TimelineScroll<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                HStack(alignment: .top, spacing: 0) {
                    VStack(spacing: 0) {
                        ForEach(0..<CalendarLayout.slotCount, id: \.self) { slot in
                            Text(CalendarLayout.hourLabel(slot * CalendarLayout.slotHours))
                                .font(.appSans(7))
                                .foregroundStyle(AppColor.muted)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                                .padding(.top, 6)
                                .padding(.trailing, 6)
                                .frame(
                                    width: CalendarLayout.timeWidth,
                                    height: CalendarLayout.slotHeight,
                                    alignment: .topTrailing
                                )
                                .id(slot)
                        }
                    }

                    content()
                        .frame(maxWidth: .infinity)
                        .frame(height: CalendarLayout.hourHeight * 24, alignment: .top)
                        .background(alignment: .top) {
                            VStack(spacing: 0) {
                                ForEach(0..<CalendarLayout.slotCount, id: \.self) { _ in
                                    Color.clear
                                        .frame(height: CalendarLayout.slotHeight)
                                        .overlay(alignment: .top) {
                                            Rectangle()
                                                .fill(AppColor.line)
                                                .frame(height: 0.5)
                                        }
                                }
                            }
                        }
                }
            }
            .onAppear {
                proxy.scrollTo(CalendarLayout.initialSlot, anchor: .top)
            }
        }
    }
}

/// The timed block used in Week (compact) and Day views.
private struct EventBlock: View {
    let event: CalendarEvent
    let compact: Bool

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: compact ? 6 : 10, style: .continuous)

        VStack(alignment: .leading, spacing: compact ? 2 : 8) {
            Text(event.title)
                .font(.appSans(compact ? 7.5 : 11, weight: .semibold))
                .strikethrough(event.isComplete)
                .lineLimit(compact ? 2 : 1)

            HStack(spacing: 3) {
                if event.isRepeating {
                    Image(systemName: "repeat")
                        .font(.system(size: compact ? 6 : 8, weight: .semibold))
                }

                Text(compact ? event.startTimeText : event.subtitleText)
                    .font(.appSans(compact ? 6.5 : 8.5))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .foregroundStyle(event.tint.text)
        .padding(compact ? 5 : 11)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(event.tint.fill, in: shape)
        .overlay {
            shape.stroke(event.tint.text.opacity(0.18), lineWidth: 1)
        }
        .opacity(event.isComplete ? 0.6 : 1)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Preview

#Preview {
    CalendarView()
}
