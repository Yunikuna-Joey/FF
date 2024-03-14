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

struct StatusView: View {
    // immutatable for each specific user
    let username: String
    let timeAgo: String
    let status: String
    
    
    var body: some View {
        // what each individual update is going to follow [stacked bottom to top]
        VStack(alignment: .leading, spacing: 10) {
            // stacked left to right
            HStack(spacing: 10) {
                // profile image on the left
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.blue)
                
                // username text next to image
                Text(username)
                    .font(.headline)
                
                // space between
                Spacer()
                
                // time that message was 'created'
                Text(timeAgo)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            HStack {
                Text("Bubble 1")
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                    )
                    // experiment with font, [caption, none or body, subheadline, footnote, callout]
                    .font(.callout)
                
                Text("Bubble 2")
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                    )
                    // experiment with font, [caption, none or body, subheadline, footnote, callout]
                    .font(.callout)
                
                Text("Bubble 3")
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                    )
                    // experiment with font, [caption, none or body, subheadline, footnote, callout]
                    .font(.callout)
            }
            

            // below the left => right will be the actual status
            Text(status)
                .font(.body)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

struct ProfileView3: View {
    // keep track of which day is currently selected
    @State private var currSelect: Int?
    // keep track of which status will be displayed
    @State private var currStatus: StatusView?

    
    // Hashmap for months and days
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
    
    let currMonthName = DateFormatter().monthSymbols[Calendar.current.component(.month, from: Date()) - 1]
    let today = Calendar.current.component(.day, from: Date())
    let daysInMonth = Calendar.current.range(of: .day, in: .month, for: Date())!.count
    let startDay = Calendar.current.component(.weekday, from: Date())
    
    var body: some View {
        let empty = Array(1..<startDay)
        let monthDays = Array(1...daysInMonth)
        
        VStack {
            // Add in the dynamic month
            Text(currMonthName)
                .font(.title)
                .padding(.top, 100)
            
            // Mon - Sun
            LazyVGrid(columns: Array(repeating: GridItem(), count: 7)) {
                // gets the days of the week
                ForEach(1...7, id: \.self) { day in
                    Text(DateFormatter().veryShortWeekdaySymbols[day % 7])
                        .frame(width: 30, height: 30)
                        .background(Color.clear)
                        .foregroundColor(.primary)
                }
            }
            // Builds the empty days and the actual days of the month
            LazyVGrid(columns: Array(repeating: GridItem(), count: 7)) {
                // gets us the empty days of the month
                ForEach(empty, id: \.self) { _ in
                    CalendarDayView(day: 0, selection: false, isToday: false, action: {
                        print("Tapped on empty day")
                        currStatus = nil
                    })
                }
                // gets all of the days and marks which one is 'today'
                ForEach(monthDays, id: \.self) { day in
                    let isToday = day == today
                    CalendarDayView(day: day, selection: currSelect == day, isToday: isToday, action: {
                        // when the day is pressed, it should display the workouts that were done that day
                        print("Tapped on this day \(day)")
                        currSelect = day
                        currStatus = StatusView(username: "User", timeAgo: "Now", status: "Status for day \(day)")
                    })
                }
                
            }
        }
        .padding()
        Spacer()
        
        // display status here
        ScrollView {
            if let status = currStatus {
                status
            }
        }
        .frame(height: 150)
        .padding(.horizontal, 5)
        .padding(.vertical, 5)
        
        
        
    } // end of body
} // end of struct

#Preview {
    ProfileView3()
}
