//
//  ProfileView3.swift
//  FF
//
//

import SwiftUI

struct CalendarDayView: View {
    let day: Int
    
    var body: some View {
        Text("\(day)")
            .frame(width: 30, height: 30)
            .background(Color.clear)
            .clipShape(Circle())
            .foregroundStyle(.primary)
    }

}

struct ProfileView3: View {
    let total = 31
    let start = 5
    
    var body: some View {
        let empty = Array(1..<start)
        let monthDays = Array(1...total)
        
        VStack {
            LazyVGrid(columns: Array(repeating: GridItem(), count: 7)) {
                ForEach(1...7, id: \.self) { day in
                    Text(DateFormatter().shortWeekdaySymbols[day % 7])
                        .frame(width: 30, height: 30)
                        .background(Color.clear)
                        .foregroundColor(.primary)
                }
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(), count: 7)) {
                   ForEach(empty, id: \.self) { _ in
                       CalendarDayView(day: 0)
                   }

                   ForEach(monthDays, id: \.self) { day in
                       CalendarDayView(day: day)
                   }
               }
        }
        
    }
}

#Preview {
    ProfileView3()
}
