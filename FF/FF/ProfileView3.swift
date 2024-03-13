//
//  ProfileView3.swift
//  FF
//
//

import SwiftUI

struct CalendarDayView: View {
    let day: Int
    let selection: Bool
    let isToday: Bool
    
    var body: some View {
        if day > 0 {
            Text("\(day)")
                .frame(width: 30, height: 30)
                .background(selection ? Color.blue : (isToday ? Color.yellow : Color.clear))
                .clipShape(Circle())
                .foregroundColor(selection ? .white : (isToday ? .black : .primary))
        }
        else {
            Text("")
                .frame(width: 30, height: 30)
                .background(Color.clear)
        }
    }

}

struct ProfileView3: View {
    let total = 31
    // [hardcoded for March,,, revise]
    let start = 5
    let today = Calendar.current.component(.day, from: Date())
    
    var body: some View {
        // [entire portion hardcoded,,, revise]
        let empty = Array(1..<start)
        let monthDays = Array(1...total)
        
        VStack {
            LazyVGrid(columns: Array(repeating: GridItem(), count: 7)) {
                // gets the days of the week
                ForEach(1...7, id: \.self) { day in
                    Text(DateFormatter().shortWeekdaySymbols[day % 7])
                        .frame(width: 30, height: 30)
                        .background(Color.clear)
                        .foregroundColor(.primary)
                }
            }

            LazyVGrid(columns: Array(repeating: GridItem(), count: 7)) {
                // gets us the empty days of the month
                ForEach(empty, id: \.self) { _ in
                   CalendarDayView(day: 0, selection: false, isToday: false)
                }
                // gets all of the days and marks which one is 'today'
                ForEach(monthDays, id: \.self) { day in
                    let isToday = day == today
                    CalendarDayView(day: day, selection: false, isToday: isToday)
                }
           }
        }
        
    }
}

#Preview {
    ProfileView3()
}
