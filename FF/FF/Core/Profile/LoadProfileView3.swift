//
//  LoadProfileView3.swift
//  FF
//
//

import SwiftUI

struct LoadProfileView3: View {
    // keep track of current day
    @State private var currSelect: Int?
    
    // keep track of which day will be displayed
    @State private var currStatus: StatusView?
    
    // Toggle the month
    @State private var selectedMonth: String = DateFormatter().monthSymbols[Calendar.current.component(.month, from: Date()) - 1]
    
    // hashmap for months and days
    let monthData: [String: [Int]] =  [                     // Month Name: # of days in month
        "January": Array(1...31),
        "February": Array(1...28),                           // modify for leap years, every 4 == 29 days else 28
        "March": Array(1...31),
        "April": Array(1...30),
        "May": Array(1...31),
        "June": Array(1...30),
        "July": Array(1...31),
        "August": Array(1...31),
        "September": Array(1...30),
        "October": Array(1...31),
        "November": Array(1...30),
        "December": Array(1...31)
    ]
    
    let monthOrder = [
        "January",
        "February",
        "March",
        "April",
        "May",
        "June",
        "July",
        "August",
        "September",
        "October",
        "November",
        "December"
    ]
    
    @State private var currMonthName = DateFormatter().monthSymbols[Calendar.current.component(.month, from: Date()) - 1]
    @State private var today = Calendar.current.component(.day, from: Date())
    @State private var daysInMonth = Calendar.current.range(of: .day, in: .month, for: Date())!.count
    @State private var startDay = Calendar.current.component(.weekday, from: Date())
    @State private var empty: [Int] = []
    @State private var monthDays: [Int] = []
    
    var body: some View {
        let empty = Array(1..<startDay)
        let monthDays = Array(1...daysInMonth)
        
        ScrollView(showsIndicators: false) {
            VStack {
                HStack {
                    // The current month
                    Text(currMonthName)
                        .font(.title)
                    
                    // Month menu to toggle in between
                    Menu {
                        Picker(selection: $selectedMonth, label: Text("Choose your option")) {
                            ForEach(monthOrder, id: \.self) { month in
                                Text(month)
                                    .tag(month)
                            }
                        }
                    } label: {
                        Image(systemName: "chevron.down")
                    }
                    .onChange(of: selectedMonth) { _, newValue in
                        updateCalendar(newValue)
                    }
                }
                
                // Monday - Sunday [days of the week]
                LazyVGrid(columns: Array(repeating: GridItem(), count: 7)) {
                    // build the actual days
                    ForEach(1...7, id: \.self) { day in
                        Text(DateFormatter().veryShortWeekdaySymbols[day % 7])
                            .frame(width: 30, height: 30)
                            .background(Color.clear)
                            .foregroundStyle(.primary)
                    }
                }
                
                // Build the empty days with the actual days
                LazyVGrid(columns: Array(repeating: GridItem(), count: 7)) {
                    // build the empty days
                    ForEach(empty, id: \.self) { _ in
                        CalendarDayView(day: 0, selection: false, isToday: false, action: {
                            currStatus = nil
                            print("Tapped on empty day")
                        })
                    }
                    
                    // gets all of the days and marks which one is 'today'
                    ForEach(monthDays, id: \.self) { day in
                        let isToday = day == today
                        CalendarDayView(day: day, selection: currSelect == day, isToday: isToday, action: {
                            print("Tapped on this day \(day)")
                            currSelect = day
                            currStatus = StatusView(username: "User", timeAgo: "Now", status: "Status for day \(day)")
                        })
                    }
                }
            }
            .padding()
            Spacer()
            
            // display the status here
            if let status = currStatus {
                status
                    .padding()
            }
            
            else {
                Color.clear.frame(height: 150)
            }
        } // end of scrollView
    } // end of body
    
    private func updateCalendar(_ month: String) {
        if let days = monthData[month],
           let date = Calendar.current.date(from: DateComponents(year: Calendar.current.component(.year, from: Date()), month: monthOrder.firstIndex(of: month)! + 1, day: 1)) {
            
            startDay = Calendar.current.component(.weekday, from: date)
            currMonthName = month
            daysInMonth = days.count
            empty = Array(1..<startDay)
            monthDays = Array(1...days.count)
        }
    }
}

#Preview {
    LoadProfileView3()
}
