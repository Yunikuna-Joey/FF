//
//  CheckinView.swift
//  FF
//
//

import SwiftUI

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
    
    let username = "Testing User"
//    let timestamp = "5m ago"
    
    
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
            }
                        
            TextField("What are you up to today?", text: $statusField)
                .padding(.top)
                .padding(.bottom, 25)
            
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)

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
//                            // create a delay before removing
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
//                                bubbles.remove(at: indexToRemove)
//                            }
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
        }

        
        Spacer()
        
        // need to implement post button somewhere in this area
        // [maybe big for easy, towards bottom half of screen]
    }
    
}

#Preview {
    CheckinView()
}
