// Kevin Li - 11:30 PM - 6/6/20

import SwiftUI

struct DayView: View, MonthlyCalendarManagerDirectAccess {

    @Environment(\.calendarTheme) var theme: CalendarTheme

    @ObservedObject var calendarManager: MonthlyCalendarManager

    let week: Date
    let day: Date

    private var isDayWithinDateRange: Bool {
        day >= calendar.startOfDay(for: startDate) && day <= endDate
    }

    private var isDayWithinWeekMonthAndYear: Bool {
        calendar.isDate(week, equalTo: day, toGranularities: [.month, .year])
    }

    private var canSelectDay: Bool {
        datasource?.calendar(canSelectDate: day) ?? true
    }

    private var isDaySelectableAndInRange: Bool {
        isDayWithinDateRange && isDayWithinWeekMonthAndYear && canSelectDay
    }

    private var isDayToday: Bool {
        calendar.isDateInToday(day)
    }

    private var isSelected: Bool {
        guard let selectedDate = selectedDate else { return false }
        return calendar.isDate(selectedDate, equalTo: day, toGranularities: [.day, .month, .year])
    }

    var body: some View {
        
        let dotColor : [Color] = datasource?.calendar(dotColorForDate: day) ?? [Color.clear]
        
        Text(numericDay)
            .font(.footnote)
            .foregroundColor(foregroundColor)
            .frame(width: CalendarConstants.Monthly.dayWidth, height: CalendarConstants.Monthly.dayWidth)
            .background(backgroundColor)
            .clipShape(Circle())
            .opacity(opacity)
            .overlay(
                HStack{
                    ForEach (dotColor, id: \.self){ c in
                        Circle()
                            .fill(c)
                                .frame(width: 6, height: 6)
                                .offset(y: 15)
                                .opacity(datasource?.calendar(backgroundColorOpacityForDate: day) ?? 0) // For displaying color in dots
                                .opacity(isDaySelectableAndInRange ? 1 : 0) // Hide dot when date is not in range
                    }
                }
                
            )  // Customised: show dot when there is a class
            .overlay(isSelected ? CircularSelectionView() : nil)
            .onTapGesture(perform: notifyManager)
    }

    private var numericDay: String {
        String(calendar.component(.day, from: day))
    }

    private var foregroundColor: Color {
        if isDayToday {
            //return theme.primary
            return Color.white  // Customised: white text for when date = today
        } else {
            return .primary
        }
    }

    private var backgroundColor: some View {
        Group {
            if isDayToday {
                Color.primary
            } else if isDaySelectableAndInRange {
                /*
                // Original
                theme.primary
                    .opacity(datasource?.calendar(backgroundColorOpacityForDate: day) ?? 1)
                */
                // Customised: background color
                if isSelected {
                    Color("overlay")
                } else {
                    Color.clear
                }
            } else {
                Color.clear
            }
        }
    }

    private var opacity: Double {
        guard !isDayToday else { return 1 }
        return isDaySelectableAndInRange ? 1 : 0.15
    }

    private func notifyManager() {
        guard isDayWithinDateRange && canSelectDay else { return }

        if isDayToday || isDayWithinWeekMonthAndYear {
            calendarManager.dayTapped(day: day, withHaptic: true)
        }
    }

}

private struct CircularSelectionView: View {

    @State private var startBounce = false

    var body: some View {
        /*
        Circle()
            //.stroke(Color.primary, lineWidth: 2)
            .stroke(Color("highlight"), lineWidth: 2) // Customised: overlay circle when selected
            .frame(width: radius, height: radius)
            .opacity(startBounce ? 1 : 0)
            .animation(.interpolatingSpring(stiffness: 150, damping: 10))
            .onAppear(perform: startBounceAnimation)
        */
        VStack{
            Circle()
                .stroke(Color("highlight"), lineWidth: 2) // Customised: overlay circle when selected
                .frame(width: radius, height: radius)
                .opacity(startBounce ? 1 : 0)
                .animation(.interpolatingSpring(stiffness: 150, damping: 10))
                .onAppear(perform: startBounceAnimation)
        }.frame(width: CalendarConstants.Monthly.dayWidth+50, height: CalendarConstants.Monthly.dayWidth+60)
    }

    private var radius: CGFloat {
        startBounce ? CalendarConstants.Monthly.dayWidth + 6 : CalendarConstants.Monthly.dayWidth + 25
        //startBounce ? CalendarConstants.Monthly.dayWidth - 6 : CalendarConstants.Monthly.dayWidth - 25
    }

    private func startBounceAnimation() {
        startBounce = true
    }

}

struct DayView_Previews: PreviewProvider {
    static var previews: some View {
        LightDarkThemePreview {
            DayView(calendarManager: .mock, week: Date(), day: Date())

            DayView(calendarManager: .mock, week: Date(), day: .daysFromToday(3))
        }
    }
}
