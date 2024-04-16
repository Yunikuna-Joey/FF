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

//struct ProfileView3: View {
//    // keep track of which day is currently selected
//    @State private var currSelect: Int?
//    // keep track of which status will be displayed
//    @State private var currStatus: StatusView?
//    // toggle the month
//    @State private var selectedMonth: String = DateFormatter().monthSymbols[Calendar.current.component(.month, from: Date()) - 1]
//    
//    // Hashmap for months and days
//    let monthData: [String: [Int]] =  [                     // Month Name: # of days in month
//        "January": Array(1...31),
//        "February": Array(1...28),                           // modify for leap years, every 4 == 29 days else 28
//        "March": Array(1...31),
//        "April": Array(1...30),
//        "May": Array(1...31),
//        "June": Array(1...30),
//        "July": Array(1...31),
//        "August": Array(1...31),
//        "September": Array(1...30),
//        "October": Array(1...31),
//        "November": Array(1...30),
//        "December": Array(1...31)
//    ]
//    
//    let monthOrder = [
//        "January",
//        "February",
//        "March",
//        "April",
//        "May",
//        "June",
//        "July",
//        "August",
//        "September",
//        "October",
//        "November",
//        "December"
//    ]
//    
//    @State private var currMonthName = DateFormatter().monthSymbols[Calendar.current.component(.month, from: Date()) - 1]
//    @State private var today = Calendar.current.component(.day, from: Date())
//    @State private var daysInMonth = Calendar.current.range(of: .day, in: .month, for: Date())!.count
//    @State private var startDay = Calendar.current.component(.weekday, from: Date())
//    @State private var empty: [Int] = []
//    @State private var monthDays: [Int] = []
//    
//    var body: some View {
//        let empty = Array(1..<startDay)
//        let monthDays = Array(1...daysInMonth)
//        
//        ScrollView(showsIndicators: false) {
//            VStack {
//                // Add in the dynamic month
//                HStack {
//                    Text(currMonthName)
//                        .font(.title)
//                    Menu {
//                        Picker(selection: $selectedMonth, label: Text("Choose your option")) {
//                            ForEach(monthOrder, id: \.self) { month in
//                                Text(month)
//                                    .tag(month)
//                            }
//                        }
//                    } label: {
//                        Image(systemName: "chevron.down")
//                    }
//                    .onChange(of: selectedMonth) { _, newValue in
//                        updateCalendar(newValue)
//                    }
//                }
//                
//                // Mon - Sun
//                LazyVGrid(columns: Array(repeating: GridItem(), count: 7)) {
//                    // gets the days of the week
//                    ForEach(1...7, id: \.self) { day in
//                        Text(DateFormatter().veryShortWeekdaySymbols[day % 7])
//                            .frame(width: 30, height: 30)
//                            .background(Color.clear)
//                            .foregroundColor(.primary)
//                    }
//                }
//                // Builds the empty days and the actual days of the month
//                LazyVGrid(columns: Array(repeating: GridItem(), count: 7)) {
//                    // gets us the empty days of the month
//                    ForEach(empty, id: \.self) { _ in
//                        CalendarDayView(day: 0, selection: false, isToday: false, action: {
//                            print("Tapped on empty day")
//                            currStatus = nil
//                        })
//                    }
//                    // gets all of the days and marks which one is 'today'
//                    ForEach(monthDays, id: \.self) { day in
//                        let isToday = day == today
//                        CalendarDayView(day: day, selection: currSelect == day, isToday: isToday, action: {
//                            // when the day is pressed, it should display the workouts that were done that day
//                            print("Tapped on this day \(day)")
//                            currSelect = day
//                            currStatus = StatusView(username: "User", timeAgo: "Now", status: "Status for day \(day)")
//                        })
//                    }
//                    
//                }
//            }
//            .padding()
//            Spacer()
//            
//            // display status here
//            if let status = currStatus {
//                status
//                    .padding()
//                
//            }
//            else {
//                Color.clear.frame(height: 150)
//            }
//            
//        } // scrollview
//       
//        
//    } // end of body
//    private func updateCalendar(_ month: String) {
//        if let days = monthData[month],
//           let date = Calendar.current.date(from: DateComponents(year: Calendar.current.component(.year, from: Date()), month: monthOrder.firstIndex(of: month)! + 1, day: 1)) {
//            
//            startDay = Calendar.current.component(.weekday, from: date)
//            currMonthName = month
//            daysInMonth = days.count
//            empty = Array(1..<startDay)
//            monthDays = Array(1...days.count)
//        }
//    }
//} // end of struct

struct ProfileView3: View {
    let screenSize = UIScreen.main.bounds.size
    @State var planScreenFlag: Bool = false
    
    var body: some View {
        // *** Old implementation
//        NavigationStack {
//            RoundedRectangle(cornerRadius: 10) // Adjust corner radius as needed
//                .fill(Color.gray)
//                .overlay(
//                    VStack {
//                        // button to add plan
//                        createButton(text: "Create your plan", planScreenFlag: $planScreenFlag)
//                        
//                        // pushes button towards the top
//                        Spacer()
//                    }
//                        .padding()
//                )
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                .padding()
//                .navigationDestination(isPresented: $planScreenFlag) {
//                    PlanScreenView()
//                }
//        }
        
        // **** new implementation
        LazyVStack {
            createButton(text: "Create your plan", planScreenFlag: $planScreenFlag)
            Spacer()
        }
        .padding()
        .sheet(isPresented: $planScreenFlag) {
            PlanScreenView()
        }
        
    }
}

#Preview {
    ProfileView3()
}
