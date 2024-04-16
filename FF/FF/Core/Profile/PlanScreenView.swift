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
    var areaTarget: String
    @Binding var reps: [String: Int]
    
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
    @State private var currentReps: [String: Int] = [:]
    @State private var selectedCategory: String?
    @State private var planTitle: String = ""
    
    var body: some View {
//        RoundedRectangle(cornerRadius: 10) // Adjust corner radius as needed
//            .fill(Color.gray.opacity(0.50))
//            .overlay(
//                ScrollView(showsIndicators: false) {
//                    VStack {
//                        ForEach(categories.indices, id: \.self) { index in
//                            planButton(title: categories[index], selectedCategory: $selectedCategory)
//                            
//                            if selectedCategory == categories[index] {
//                                Workout(areaTarget: categories[index], reps: $currentReps)
//                            }
//                            
//                        }
//                        
//                        // pushes button towards the top
//                        Spacer()
//                        
////                        TextField("What's the name of your plan?", text: $planTitle)
////                            .padding(.vertical, 8)
////                            .padding(.horizontal, 20)
////                            .background(Color.gray.opacity(0.33))
////                            .cornerRadius(10)
////                            .padding(.bottom)
//                            
//                    }
//                    .padding()
//                }
//            )
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//            .padding()
        
        ZStack {
            ScrollView(showsIndicators: false) {
                LazyVStack {
                    ForEach(categories.indices, id: \.self) { index in
                        planButton(title: categories[index], selectedCategory: $selectedCategory)
                        
                        if selectedCategory == categories[index] {
                            Workout(areaTarget: categories[index], reps: $currentReps)
                        }
                    }
                    
                    Spacer()
                    
                } // end of Vstack
                .padding()
            }
            
            VStack {
                Spacer()
                
                TextField("Plan Name?", text: $planTitle)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 20)
                    .background(Color.gray.opacity(0.33))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.bottom)
            }
        }
    }
}

#Preview {
    PlanScreenView()
}
