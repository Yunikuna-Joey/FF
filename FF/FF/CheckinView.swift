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
    @State private var bubbleChoice: Set<String> = []
    // Available options to choose from [needed state to bind objects to view... to mutate them from off the bottom => top and <=>]
    @State private var bubbles = ["🦵Legs", "🫸Push", "Pull", "Upper", "Lower"]
    
    let username = "Testing User"
    let timestamp = "5m ago"
    
    
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
                // Bubbles selected for status
                ForEach(bubbleChoice.sorted(), id: \.self) { bubble in
                    Button(action: {
                        // Remove bubble from status
                        bubbleChoice.remove(bubble)
                        // place it back into the original array
                        bubbles.append(bubble)
                    }) {
                        Text("\(bubble)")
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
                   // Conditional statement that will handle adding / removing from view
                   if bubbleChoice.contains(bubble) {
                       // Remove bubble from status
                       bubbleChoice.remove(bubble)
                       bubbles.append(bubble)
                   } else {
                       // Add bubble to status
                       bubbleChoice.insert(bubble)
                       
                       // 'selects' the bubble choice from the bottom
                       if let index = bubbles.firstIndex(of: bubble) {
                           bubbles.remove(at: index)
                       }
                   }
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
