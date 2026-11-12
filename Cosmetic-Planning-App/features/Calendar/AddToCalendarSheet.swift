//
//  AddToCalendarSheet.swift
//  Cosmetic-Planning-App
//
//  The sheet behind the calendar's + button. Step 1: choose Routine reminder
//  or Appointment. Step 2: a Google Calendar–style form for that model.
//

import SwiftUI

struct AddToCalendarSheet: View {
    enum Choice {
        case routineReminder
        case appointment
    }

    let viewModel: CalendarViewModel

    @Environment(\.dismiss) private var dismiss
    @State private var choice: Choice?
    @State private var detent: PresentationDetent = .medium

    var body: some View {
        Group {
            switch choice {
            case nil:
                optionsList

            case .routineReminder:
                RoutineReminderForm(
                    initialDate: viewModel.newReminderDefaultDate,
                    routines: viewModel.routines,
                    onClose: { dismiss() },
                    onSave: { reminder in
                        viewModel.addReminder(reminder)
                        dismiss()
                    }
                )

            case .appointment:
                AppointmentForm(
                    initialDate: viewModel.newReminderDefaultDate,
                    onClose: { dismiss() },
                    onSave: { appointment in
                        try await viewModel.addAppointment(appointment)
                        dismiss()
                    }
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(AppColor.cream)
        .presentationDetents([.medium, .large], selection: $detent)
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(28)
        .animation(.easeInOut(duration: 0.2), value: choice)
    }

    // MARK: - Step 1: Choose a type

    private var optionsList: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Add to calendar")
                .font(.appSerif(28))
                .foregroundStyle(AppColor.ink)

            Text("What would you like to schedule?")
                .font(.appSans(11))
                .foregroundStyle(AppColor.muted)
                .padding(.top, 6)
                .padding(.bottom, 18)

            optionRow(
                symbol: "sun.max",
                title: "Routine reminder",
                subtitle: "A nudge to do one of your routines"
            ) {
                pick(.routineReminder)
            }

            Divider().overlay(AppColor.line)

            optionRow(
                symbol: "sparkles",
                title: "Appointment",
                subtitle: "Hair, nails, facials and more"
            ) {
                pick(.appointment)
            }

            Divider().overlay(AppColor.line)
        }
        .padding(.horizontal, 22)
        .padding(.top, 30)
    }

    private func optionRow(
        symbol: String,
        title: String,
        subtitle: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: symbol)
                    .font(.system(size: 18))
                    .foregroundStyle(AppColor.accent)
                    .frame(width: 46, height: 46)
                    .background(Color(hex: 0xF7E8EA), in: RoundedRectangle(cornerRadius: 14))

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.appSans(13, weight: .semibold))
                        .foregroundStyle(AppColor.ink)

                    Text(subtitle)
                        .font(.appSans(10))
                        .foregroundStyle(AppColor.muted)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(AppColor.ink)
            }
            .padding(.vertical, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func pick(_ newChoice: Choice) {
        choice = newChoice
        detent = .large
    }
}

// MARK: - Routine Reminder Form

private struct RoutineReminderForm: View {
    let routines: [Routine]
    let onClose: () -> Void
    let onSave: (RoutineReminder) -> Void

    @State private var title = ""
    @State private var date: Date
    @State private var endDate: Date
    @State private var isAllDay = false
    @State private var recurrence: Recurrence?
    @State private var notifyMinutes: Int? = 0
    @State private var routineId: UUID?

    init(
        initialDate: Date,
        routines: [Routine],
        onClose: @escaping () -> Void,
        onSave: @escaping (RoutineReminder) -> Void
    ) {
        _date = State(initialValue: initialDate)
        _endDate = State(initialValue: initialDate.addingTimeInterval(30 * 60))
        self.routines = routines
        self.onClose = onClose
        self.onSave = onSave
    }

    private var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        VStack(spacing: 0) {
            FormTopBar(
                canSave: !trimmedTitle.isEmpty,
                isSaving: false,
                onClose: onClose
            ) {
                onSave(
                    RoutineReminder(
                        title: trimmedTitle,
                        date: isAllDay ? Calendar.current.startOfDay(for: date) : date,
                        routineId: routineId,
                        endDate: isAllDay ? nil : endDate,
                        isAllDay: isAllDay,
                        notifyMinutesBefore: notifyMinutes,
                        recurrence: recurrence
                    )
                )
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    FormTitleField(title: $title)

                    if !routines.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(routines) { routine in
                                    FormChip(
                                        title: routine.name,
                                        isSelected: routineId == routine.id
                                    ) {
                                        select(routine)
                                    }
                                }
                            }
                            .padding(.leading, FormLayout.contentInset)
                            .padding(.trailing, 22)
                        }
                        .padding(.bottom, 18)
                    }

                    FormDivider()

                    ScheduleRows(
                        isAllDay: $isAllDay,
                        start: $date,
                        end: $endDate,
                        recurrence: $recurrence,
                        notifyMinutes: $notifyMinutes
                    )

                    FormDivider()

                    FormRow(symbol: "sparkles") {
                        Text(selectedRoutineText)
                            .font(.appSans(12))
                            .foregroundStyle(routineId == nil ? AppColor.muted : AppColor.ink)
                    }
                }
            }
        }
    }

    private var selectedRoutineText: String {
        if let name = routines.first(where: { $0.id == routineId })?.name {
            return "Linked to \(name)"
        }
        return routines.isEmpty ? "No routines yet" : "Choose a routine above"
    }

    private func select(_ routine: Routine) {
        if routineId == routine.id {
            routineId = nil
            return
        }

        // Fill in the title with the routine's name if it's empty
        // or still matches the previously selected routine.
        let previousName = routines.first { $0.id == routineId }?.name
        if trimmedTitle.isEmpty || trimmedTitle == previousName {
            title = routine.name
        }
        routineId = routine.id
    }
}

// MARK: - Appointment Form

private struct AppointmentForm: View {
    let onClose: () -> Void
    let onSave: (Appointment) async throws -> Void

    @State private var title = ""
    @State private var date: Date
    @State private var endDate: Date
    @State private var isAllDay = false
    @State private var recurrence: Recurrence?
    @State private var notifyMinutes: Int? = 30
    @State private var location = ""
    @State private var notes = ""
    @State private var isSaving = false
    @State private var errorMessage: String?

    init(
        initialDate: Date,
        onClose: @escaping () -> Void,
        onSave: @escaping (Appointment) async throws -> Void
    ) {
        _date = State(initialValue: initialDate)
        _endDate = State(initialValue: initialDate.addingTimeInterval(60 * 60))
        self.onClose = onClose
        self.onSave = onSave
    }

    private var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        VStack(spacing: 0) {
            FormTopBar(
                canSave: !trimmedTitle.isEmpty,
                isSaving: isSaving,
                onClose: onClose,
                onSave: save
            )

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    FormTitleField(title: $title)
                        .padding(.bottom, 4)

                    FormDivider()

                    ScheduleRows(
                        isAllDay: $isAllDay,
                        start: $date,
                        end: $endDate,
                        recurrence: $recurrence,
                        notifyMinutes: $notifyMinutes
                    )

                    FormDivider()

                    FormRow(symbol: "mappin.and.ellipse") {
                        TextField("Add location", text: $location)
                            .font(.appSans(12))
                            .foregroundStyle(AppColor.ink)
                    }

                    FormDivider()

                    FormRow(symbol: "text.alignleft") {
                        TextField("Add notes", text: $notes, axis: .vertical)
                            .font(.appSans(12))
                            .foregroundStyle(AppColor.ink)
                            .lineLimit(3...6)
                    }

                    if let errorMessage {
                        Text(errorMessage)
                            .font(.appSans(10))
                            .foregroundStyle(.red)
                            .padding(.leading, FormLayout.contentInset)
                            .padding(.top, 8)
                    }
                }
            }
        }
    }

    private func save() {
        let appointment = Appointment(
            title: trimmedTitle,
            date: isAllDay ? Calendar.current.startOfDay(for: date) : date,
            location: location.nilIfBlank,
            notes: notes.nilIfBlank,
            endDate: isAllDay ? nil : endDate,
            isAllDay: isAllDay,
            notifyMinutesBefore: notifyMinutes,
            recurrence: recurrence
        )

        Task {
            isSaving = true
            errorMessage = nil
            defer { isSaving = false }

            do {
                try await onSave(appointment)
            } catch {
                errorMessage = "Couldn't save: \(error.localizedDescription)"
            }
        }
    }
}

private extension String {
    var nilIfBlank: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}

// MARK: - Shared Form Pieces

private enum FormLayout {
    static let iconWidth: CGFloat = 24
    static let iconSpacing: CGFloat = 16
    static let sidePadding: CGFloat = 22
    /// Where text lines up, to the right of the row icons.
    static var contentInset: CGFloat { sidePadding + iconWidth + iconSpacing }
}

/// X on the left, Save pill on the right.
private struct FormTopBar: View {
    let canSave: Bool
    let isSaving: Bool
    let onClose: () -> Void
    let onSave: () -> Void

    var body: some View {
        HStack {
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(AppColor.ink)
                    .frame(width: 40, height: 40)
                    .background(.white, in: Circle())
                    .overlay(Circle().stroke(AppColor.line))
            }
            .accessibilityLabel("Close")

            Spacer()

            Button(action: onSave) {
                Group {
                    if isSaving {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Save")
                    }
                }
                .font(.appSans(12, weight: .semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 22)
                .frame(height: 40)
                .background(AppColor.accent.opacity(canSave ? 1 : 0.4), in: Capsule())
            }
            .disabled(!canSave || isSaving)
        }
        .padding(.horizontal, FormLayout.sidePadding)
        .padding(.top, 22)
        .padding(.bottom, 6)
    }
}

private struct FormTitleField: View {
    @Binding var title: String

    var body: some View {
        TextField("Add title", text: $title)
            .font(.appSerif(28))
            .foregroundStyle(AppColor.ink)
            .padding(.leading, FormLayout.contentInset)
            .padding(.trailing, FormLayout.sidePadding)
            .padding(.vertical, 18)
            .accessibilityLabel("Title")
    }
}

private struct FormRow<Content: View>: View {
    /// nil = no icon, but content stays lined up with the rows above.
    let symbol: String?
    @ViewBuilder let content: () -> Content

    var body: some View {
        HStack(alignment: .center, spacing: FormLayout.iconSpacing) {
            Group {
                if let symbol {
                    Image(systemName: symbol)
                        .font(.system(size: 17))
                        .foregroundStyle(AppColor.muted)
                } else {
                    Color.clear.frame(height: 1)
                }
            }
            .frame(width: FormLayout.iconWidth)

            content()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, FormLayout.sidePadding)
        .padding(.vertical, 16)
    }
}

private struct FormDivider: View {
    var body: some View {
        Divider()
            .overlay(AppColor.line)
    }
}

/// "Wed, Nov 11 ............ 7:00 PM", like Google Calendar.
private struct DateTimeRow: View {
    @Binding var date: Date
    var showsTime = true
    /// Earliest allowed value (used so the end can't be before the start).
    var minimum: Date? = nil

    var body: some View {
        HStack {
            picker(.date, label: "Date")

            Spacer()

            if showsTime {
                picker(.hourAndMinute, label: "Time")
            }
        }
        .tint(AppColor.accent)
    }

    @ViewBuilder
    private func picker(_ components: DatePickerComponents, label: String) -> some View {
        if let minimum {
            DatePicker(label, selection: $date, in: minimum..., displayedComponents: components)
                .labelsHidden()
        } else {
            DatePicker(label, selection: $date, displayedComponents: components)
                .labelsHidden()
        }
    }
}

/// All-day toggle, start, end and notification rows, like Google Calendar.
private struct ScheduleRows: View {
    @Binding var isAllDay: Bool
    @Binding var start: Date
    @Binding var end: Date
    @Binding var recurrence: Recurrence?
    @Binding var notifyMinutes: Int?

    /// True after picking "Custom…", which shows the day circles.
    @State private var isCustom = false

    var body: some View {
        VStack(spacing: 0) {
            FormRow(symbol: "clock") {
                Toggle("All-day", isOn: $isAllDay.animation(.easeInOut(duration: 0.2)))
                    .font(.appSans(12))
                    .foregroundStyle(AppColor.ink)
                    .tint(AppColor.accent)
            }

            FormRow(symbol: nil) {
                DateTimeRow(date: $start, showsTime: !isAllDay)
            }
            .padding(.top, -10)

            if !isAllDay {
                FormRow(symbol: nil) {
                    DateTimeRow(date: $end, minimum: start)
                }
                .padding(.top, -10)
            }

            FormDivider()

            repeatRows

            FormDivider()

            FormRow(symbol: "bell") {
                Menu {
                    ForEach(NotifyOption.options(isAllDay: isAllDay)) { option in
                        Button(option.label) {
                            notifyMinutes = option.minutes
                        }
                    }
                } label: {
                    HStack {
                        Text(NotifyOption.label(for: notifyMinutes, isAllDay: isAllDay))
                            .font(.appSans(12))
                            .foregroundStyle(notifyMinutes == nil ? AppColor.muted : AppColor.ink)

                        Spacer()

                        Image(systemName: "chevron.up.chevron.down")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(AppColor.muted)
                    }
                    .contentShape(Rectangle())
                }
            }
        }
        // Moving the start keeps the same duration, like Google Calendar.
        .onChange(of: start) { oldValue, newValue in
            end = end.addingTimeInterval(newValue.timeIntervalSince(oldValue))

            if let until = recurrence?.until, until < newValue {
                recurrence?.until = newValue
            }
        }
        // All-day and timed items offer different notification choices.
        .onChange(of: isAllDay) { _, allDay in
            let valid = NotifyOption.options(isAllDay: allDay).map(\.minutes)
            if !valid.contains(notifyMinutes) {
                notifyMinutes = 0
            }
        }
    }

    // MARK: Repeat

    @ViewBuilder
    private var repeatRows: some View {
        FormRow(symbol: "repeat") {
            Menu {
                Button("Does not repeat") {
                    recurrence = nil
                    isCustom = false
                }

                ForEach(Recurrence.Frequency.allCases, id: \.self) { frequency in
                    Button(Recurrence(frequency: frequency).summary(for: start, includeEnd: false)) {
                        isCustom = false
                        setFrequency(frequency)
                    }
                }

                Divider()

                Button("Custom…") {
                    // Keep any days already picked; otherwise start from the start date's weekday.
                    if recurrence?.frequency != .weekly {
                        setFrequency(.weekly)
                    }
                    isCustom = true
                }
            } label: {
                menuLabel(
                    recurrence?.summary(for: start, includeEnd: false) ?? "Does not repeat",
                    isPlaceholder: recurrence == nil
                )
            }
        }

        // Shown for "Custom…", and kept visible once more than one day is picked.
        if recurrence?.frequency == .weekly && (isCustom || selectedWeekdays.count > 1) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Repeat on")
                    .font(.appSans(10, weight: .semibold))
                    .foregroundStyle(AppColor.muted)

                WeekdayPicker(selected: selectedWeekdays, toggle: toggleWeekday)
            }
            .padding(.leading, FormLayout.contentInset)
            .padding(.trailing, FormLayout.sidePadding)
            .padding(.bottom, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
        }

        if recurrence != nil {
            FormRow(symbol: "flag.checkered") {
                HStack {
                    Menu {
                        Button("Never") {
                            recurrence?.until = nil
                        }
                        Button("On a date") {
                            recurrence?.until = Calendar.current.date(byAdding: .month, value: 1, to: start)
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Text(recurrence?.until == nil ? "Ends never" : "Ends on")
                                .font(.appSans(12))
                                .foregroundStyle(AppColor.ink)

                            Image(systemName: "chevron.up.chevron.down")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(AppColor.muted)
                        }
                    }

                    Spacer()

                    if recurrence?.until != nil {
                        DatePicker("End date", selection: untilBinding, in: start..., displayedComponents: .date)
                            .labelsHidden()
                            .tint(AppColor.accent)
                    }
                }
            }
            .padding(.top, -10)
        }
    }

    private func menuLabel(_ text: String, isPlaceholder: Bool) -> some View {
        HStack {
            Text(text)
                .font(.appSans(12))
                .foregroundStyle(isPlaceholder ? AppColor.muted : AppColor.ink)
                .multilineTextAlignment(.leading)

            Spacer()

            Image(systemName: "chevron.up.chevron.down")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(AppColor.muted)
        }
        .contentShape(Rectangle())
    }

    private var startWeekday: Int {
        Calendar.current.component(.weekday, from: start)
    }

    private var selectedWeekdays: Set<Int> {
        guard let weekdays = recurrence?.weekdays, !weekdays.isEmpty else {
            return [startWeekday]
        }
        return Set(weekdays)
    }

    private var untilBinding: Binding<Date> {
        Binding(
            get: { recurrence?.until ?? start },
            set: { recurrence?.until = $0 }
        )
    }

    private func setFrequency(_ frequency: Recurrence.Frequency) {
        recurrence = Recurrence(
            frequency: frequency,
            weekdays: frequency == .weekly ? [startWeekday] : [],
            until: recurrence?.until
        )
    }

    /// Keeps at least one day selected.
    private func toggleWeekday(_ weekday: Int) {
        var days = selectedWeekdays

        if days.contains(weekday) {
            guard days.count > 1 else { return }
            days.remove(weekday)
        } else {
            days.insert(weekday)
        }
        recurrence?.weekdays = days.sorted()
    }
}

/// S M T W T F S circles for choosing which days a weekly item repeats.
private struct WeekdayPicker: View {
    let selected: Set<Int>
    let toggle: (Int) -> Void

    private let calendar = Calendar.current

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<7, id: \.self) { offset in
                let weekday = (calendar.firstWeekday - 1 + offset) % 7 + 1
                let isOn = selected.contains(weekday)

                Button {
                    toggle(weekday)
                } label: {
                    Text(calendar.veryShortWeekdaySymbols[weekday - 1])
                        .font(.appSans(10, weight: .semibold))
                        .foregroundStyle(isOn ? Color.white : AppColor.ink)
                        .frame(width: 30, height: 30)
                        .background(isOn ? AppColor.accent : Color.white, in: Circle())
                        .overlay {
                            Circle().stroke(isOn ? Color.clear : AppColor.line)
                        }
                }
                .buttonStyle(.plain)
                .accessibilityLabel(calendar.weekdaySymbols[weekday - 1])
                .accessibilityAddTraits(isOn ? .isSelected : [])
            }
        }
    }
}

private struct FormChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Circle()
                    .fill(isSelected ? Color.white : AppColor.accent.opacity(0.6))
                    .frame(width: 7, height: 7)

                Text(title)
                    .font(.appSans(11, weight: .medium))
                    .lineLimit(1)
            }
            .foregroundStyle(isSelected ? Color.white : AppColor.ink)
            .padding(.horizontal, 14)
            .frame(height: 34)
            .background(isSelected ? AppColor.accent : Color.white, in: Capsule())
            .overlay {
                Capsule().stroke(isSelected ? Color.clear : AppColor.line)
            }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            AddToCalendarSheet(viewModel: CalendarViewModel())
        }
}
