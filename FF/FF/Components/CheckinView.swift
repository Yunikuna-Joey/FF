//
//  CheckinView.swift
//  FF
//
//

import SwiftUI
import CoreLocation

struct CheckinView: View {
    // this is going to hold status Content
    @State private var statusField: String = ""
    // no duplicates within a set
    @State private var bubbleChoice: [(String, Color)] = []
    // Available options to choose from [needed state to bind objects to view... to mutate them from off the bottom => top and <=>]
    @State private var bubbles = ["🦵Legs", "🫸Push", "Pull", "Upper", "Lower"]
    // Hashmap to map the caption to its color
    @State private var colors: [String: Color] = [
        "🦵Legs": .red,
        "🫸Push": .orange,
        "Pull": .yellow,
        "Upper": .green,
        "Lower": .blue
    ]
    // Checkin menu option here [recent]
    @State private var selectedOption: String = "Select an option here"
    
    @State private var location: String = ""
    @State private var locationManager = CLLocation()
    
    // This will dynamically hold the locations based on user location
    let options = [
        "Option 1",
        "Option 2",
        "Option 3"
    ]
    
    let username = "Testing User"
    
    
    var body: some View {
        ZStack {
            VStack {
                HStack(spacing: 10) {
                    // profile image on the left
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.blue)
                    
                    // Username
                    Text(username)
                        .font(.headline)
                    
                    Spacer()
                    
                } // end of HStack
                
                // bubbles for the status
                HStack {
                    ForEach(bubbleChoice.indices, id: \.self) { i in
                        let (bubble, _) = bubbleChoice[i]
                        let color = colors[bubble] ?? .black
                        Button(action: {
                            // Remove from status
                            bubbleChoice.remove(at: i)
                            // Add back to bottom row
                            bubbles.append(bubble)
                        }) {
                            Text(bubble)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 5)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .foregroundColor(color)
                                )
                                .font(.callout)
                        }
                    }
                } // end of HStack
                
                // User enters their status
                TextField("What are you up to today?", text: $statusField)
                    .padding(.top)
                    .padding(.bottom, 25)
                    
                
                // Checkin Field option.... need to determine what UI element to use [recent]
                HStack {
                    Text("Select your option")
                    Spacer()
                    Picker(selection: $selectedOption, label: Text("Choose your option")) {
                        ForEach(options, id: \.self) { option in
                            Text(option)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                } // end of hstack
                
            } // end of vstack
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 2)
            // adjust this for pushing up or down the status box
            .padding(.bottom, 350)
            
            // bubbles at the bottom row
            HStack {
                ForEach(bubbles.indices, id: \.self) { i in
                    let bubble = bubbles[i]
                    let color = colors[bubble] ?? .black
                    Button(action: {
                        // $0.0 is a method of referring to tupple (bubble, color) $0.0 == bubble $0.1 == color
                        if bubbleChoice.contains(where: { $0.0 == bubble }) {
                            bubbleChoice.removeAll(where: { $0.0 == bubble })
                        }
                        else {
                            bubbleChoice.append((bubble, color))
                            if let indexToRemove = bubbles.firstIndex(of: bubble) {
                                bubbles.remove(at: indexToRemove)
                            }
                        }
                    }) {
                        Text(bubble)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 5)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .foregroundColor(color)
                            )
                            .font(.callout)
                    }
                }
            } // end of HStack
            .padding(.bottom, 100)
            
            
            
            
            VStack {
                // need to implement post button somewhere in this area
                // [maybe big for easy, towards bottom half of screen]
                Button(action: {
                    print("Circle button")
                }) {
                    Circle()
                        .foregroundStyle(Color.blue)
                        .frame(width: 100, height: 100)
                        .overlay(
                            Text("Check-In")
                                .foregroundStyle(Color.white)
                        )
                }
            }
            // adjust this for the button position
            .padding(.top, 450)
            
        } // end of zstack
        
    } // end of var body
    
} // end of structure declaration

#Preview {
    CheckinView()
}
