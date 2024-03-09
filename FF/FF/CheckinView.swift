//
//  CheckinView.swift
//  FF
//
//

import SwiftUI

struct CheckinView: View {
    // this is going to hold status Content
    @State private var statusField: String = ""
    @State private var bubbleChoice: String?
    
    let username = "Testing User"
    let timestamp = "5m ago"
    let bubbles = ["Bubble 1", "Bubble 2", "Bubble 3"]
    
    var body: some View {
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
                
            }
            HStack {
                // I want bubbles to go into here when the bottom bubble buttons are pressed
                if let bubbleChoice = bubbleChoice {
                    Text("Selected Bubble: \(bubbleChoice)")
                }
                else {
                    Text("No Bubble Selected")
                }
                
            }
                        
            TextField("What are you up to today?", text: $statusField)
                .padding(.top)
                .padding(.bottom, 25)
            
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)

        // different colors for the different workouts
        HStack {
            ForEach(bubbles, id: \.self) { bubble in
                Button(action: {
                    bubbleChoice = bubble
                }) {
                    Text(bubble)
                        .foregroundStyle(Color.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .foregroundStyle(Color.orange)
                        )
                        .font(.callout)
                }
            }
        }
        Spacer()
    }
    
}

#Preview {
    CheckinView()
}
