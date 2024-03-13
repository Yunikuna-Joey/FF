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
    
    // void == indication of no action
    let action: () -> Void
    
    var body: some View {
        if day > 0 {
            Button(action: action) {
                Text("\(day)")
                    .frame(width: 30, height: 30)
                    .background(selection ? Color.blue : (isToday ? Color.yellow : Color.clear))
                    .clipShape(Circle())
                    .foregroundColor(selection ? .white : (isToday ? .black : .primary))
            }
        }
        // empty days
        else {
            Text("")
                .frame(width: 30, height: 30)
                .background(Color.clear)
        }
    }

}

struct ProfileView3: View {
    // keep track of which day is currently selected
    @State private var currSelect: Int?
    
    // [hardcoded for March,,, revise]
    let total = 31
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
                    CalendarDayView(day: 0, selection: false, isToday: false, action: {
                        print("Tapped on empty day")
                    })
                }
                // gets all of the days and marks which one is 'today'
                ForEach(monthDays, id: \.self) { day in
                    let isToday = day == today
                    CalendarDayView(day: day, selection: currSelect == day, isToday: isToday, action: {
                        // when the day is pressed, it should display the workouts that were done that day
                        print("Tapped on this day \(day)")
                        currSelect = day
                    })
                }
           }
        }
        .padding()
        Spacer()
    }
}

#Preview {
    ProfileView3()
}
