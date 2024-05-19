//
//  LoadProfileView1.swift
//  FF
//
//

import SwiftUI

struct LoadProfileView1: View {
    @EnvironmentObject var viewModel: AuthView
    @EnvironmentObject var statusProcess: StatusProcessView
    
    @State private var colors: [String: Color] = [
        "🦵Legs": .red,
        "🫸Push": .orange,
        "Pull": .yellow,
        "Upper": .green,
        "Lower": .blue
    ]
    
    let resultUser: User
    
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                ForEach(statusProcess.statusList) { status in
                    LoadProfileStatusUpdateView(resultUser: resultUser, status: status, colors: colors)
                }
            }
            .padding()
        }
    }
}

struct LoadProfileStatusUpdateView: View {
    let resultUser: User
    let status: Status
    
    let colors: [String: Color]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                if resultUser.profilePicture.isEmpty {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundStyle(Color.blue)
                }
                
                else {
                    Image(resultUser.profilePicture)
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundStyle(Color.blue)
                }
                
                Text(resultUser.username)
                    .font(.headline)
                
                Spacer()
                
                Text(formatTime(from: status.timestamp))
                    .font(.caption)
                    .foregroundStyle(.gray)
            } // end of HStack
            
            HStack {
                ForEach(status.bubbleChoice, id: \.self) { bubble in
                    let color = colors[bubble] ?? .gray
                    Text(bubble)
                        .foregroundStyle(Color.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(color)
                        )
                        .font(.callout)
                }
            } // end of HStack
            
            Text(status.content)
                .font(.body)
        } // end of VStack
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 2)
    } // end of body
    
    // helper function to achieve time stamps associated with statuses
    func formatTime(from date: Date) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.year, .month, .weekOfMonth, .day, .hour, .minute, .second]
        formatter.unitsStyle = .full
        formatter.maximumUnitCount = 1
        
        guard let formattedString = formatter.string(from: date, to: Date()) else {
            return "Unknown"
        }
        
        // Debugging statement
        print("\(formattedString) + ago")
        return formattedString + " ago"
    }
}
//
//#Preview {
//    LoadProfileView1()
//}

struct LoadProfileView1_Previews: PreviewProvider {
    static var previews: some View {
        let user = User(id: "testString", username: "TesterE", databaseUsername: "testere", firstName: "Tester", lastName: "E", email: "e@email.com", imageArray: ["Car", "car2", "car3"], profilePicture: "", coverPicture: "")
        LoadProfileView1(resultUser: user)
    }
}
