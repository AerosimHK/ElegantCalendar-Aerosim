// Kevin Li - 5:25 PM - 6/10/20

import Combine
import SwiftUI

class PagerState: ObservableObject {

    @Published var activeIndex: Int = 1
    @Published var translation: CGFloat = .zero

    let pagerWidth: CGFloat

    init(pagerWidth: CGFloat) {
        self.pagerWidth = pagerWidth
    }

}

protocol PagerStateDirectAccess {

    var pagerState: PagerState { get }

}

extension PagerStateDirectAccess {

    var pagerWidth: CGFloat {
        pagerState.pagerWidth
    }

    var activeIndex: Int {
        pagerState.activeIndex
    }

    var translation: CGFloat {
        pagerState.translation
    }

}

public class ElegantCalendarManager: ObservableObject {

    public var currentMonth: Date {
        monthlyManager.currentMonth
    }

    public var selectedDate: Date? {
        monthlyManager.selectedDate
    }

    public var datasource: ElegantCalendarDataSource?
    public var delegate: ElegantCalendarDelegate?

    public let configuration: CalendarConfiguration

    @Published var yearlyManager: YearlyCalendarManager
    @Published var monthlyManager: MonthlyCalendarManager

    @Published var pagerState: PagerState = .init(pagerWidth: CalendarConstants.cellWidth)

    private var anyCancellable = Set<AnyCancellable>()

    init(configuration: CalendarConfiguration) {
        self.configuration = configuration

        yearlyManager = YearlyCalendarManager(configuration: configuration)
        monthlyManager = MonthlyCalendarManager(configuration: configuration)

        yearlyManager.parent = self
        monthlyManager.parent = self

        yearlyManager.objectWillChange.sink {
            self.objectWillChange.send()
        }.store(in: &anyCancellable)

        monthlyManager.objectWillChange.sink {
            self.objectWillChange.send()
        }.store(in: &anyCancellable)

        pagerState.objectWillChange.sink {
            self.objectWillChange.send()
        }.store(in: &anyCancellable)
    }

    public func scrollToMonth(_ month: Date) {
        monthlyManager.scrollToMonth(month)
    }

}

extension ElegantCalendarManager {

    func scrollToMonthAndShowMonthlyView(_ month: Date) {
        pagerState.activeIndex = 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.scrollToMonth(month)
        }
    }

    func willDisplay(month: Date) {
        delegate?.elegantCalendar(willDisplay: currentMonth)
        yearlyManager.scrollToYear(month)
    }

    func showYearlyView() {
        pagerState.activeIndex = 0
    }

}

protocol ElegantCalendarDirectAccess {

    var parent: ElegantCalendarManager? { get }

}

extension ElegantCalendarDirectAccess {

    var datasource: ElegantCalendarDataSource? {
        parent?.datasource
    }

    var delegate: ElegantCalendarDelegate? {
        parent?.delegate
    }

}