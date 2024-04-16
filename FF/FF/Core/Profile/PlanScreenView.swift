//
//  PlanScreenView.swift
//  FF
//
//

import SwiftUI

struct createButton: View {
    var text: String
    @Binding var planScreenFlag: Bool
    
    var body: some View {
        HStack {
            Button(action: {
                self.planScreenFlag = true
                print("[DEBUG]: You pressed the creation button")
            }) {
                Image(systemName: "plus.app.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                Text("Create your plan")
                    .font(.system(size: 20))
            }
            .foregroundStyle(Color.blue)
            .padding()
            
            Spacer()
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(Color.white)
        )
    }
}

// Titling the different categories
struct planButton: View {
    var title: String
    @Binding var selectedCategory: String?
    
    var body: some View {
        HStack {
            Button(action: {
                selectedCategory = title
                print("[DEBUG]: You pressed one of the \(title) button")
            }) {
                Image(systemName: "arrowshape.right.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                Text(title)
                    .font(.system(size: 20))
            }
            .foregroundStyle(Color.blue)
            .padding()
            
            Spacer()
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(Color.white)
        )
    }
}

// The different type of workouts
struct Workout: View {
    @State private var reps: [String: Int] = [:]
    var areaTarget: String
    
    // this should represent the key within the dictionary
    var book: [String: [String]] = [
        "Arms": ["Bicep Curl", "Hammer Curl", "Isolation Curl"],
        "Back": ["Deadlift", "Seated Rows", "Cable Rows"],
        "Chest": ["Bench Press", "Dumbell Press", "Incline Bench"],
        "Legs": ["Squats", "Seated Leg Extensions", "Calf Raises"],
    ]
    
    // workout name : amount of reps
    var finalPlan: [String: Int] = [:]
    
    var body: some View {
        LazyVStack {
            ForEach(book[areaTarget] ?? [], id: \.self) { workout in
                HStack {
                    Stepper(value: Binding(
                            get: { reps[workout] ?? 0 },
                            set: { reps[workout] = $0 }
                        ), in: 0...50, label: { Text("Reps: \(reps[workout] ?? 0)") })
                            .padding()
                    
                    Text(workout)
                        .padding()
                }
            }
        }
    }
}

struct PlanScreenView: View {
    // Categories
    // Legs || Arms || Chest || Back ||
    private var categories: [String] = ["Arms", "Back", "Chest", "Legs"]
    @State private var selectedCategory: String?
    
    var body: some View {
        RoundedRectangle(cornerRadius: 10) // Adjust corner radius as needed
            .fill(Color.gray)
            .overlay(
                ScrollView(showsIndicators: false) {
                    VStack {
                        ForEach(categories.indices, id: \.self) { index in
                            planButton(title: categories[index], selectedCategory: $selectedCategory)
                            
                            if selectedCategory == categories[index] {
                                Workout(areaTarget: categories[index])
                            }
                            
                        }
                        
                        // pushes button towards the top
                        Spacer()
                    }
                    .padding()
                }
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
    }
}

#Preview {
    PlanScreenView()
}
