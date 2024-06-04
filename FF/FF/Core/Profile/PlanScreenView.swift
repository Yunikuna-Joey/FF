//
//  PlanScreenView.swift
//  FF
//
//

import SwiftUI

// Titling the different categories
struct planButton: View {
    var title: String
    @Binding var selectedCategory: String?
    
    var body: some View {
        HStack {
            Button(action: {
                if selectedCategory == title {
                    selectedCategory = nil
                }
                else {
                    selectedCategory = title
                }
                print("[DEBUG]: You pressed one of the \(title) button")
            }) {
                Image(systemName: "arrowshape.right.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .foregroundStyle(Color.blue.opacity(0.85))
                Text(title)
                    .font(.system(size: 20))
                    .foregroundStyle(Color.primary)
            }
            .foregroundStyle(Color.blue)
            .padding()
            
            
            Spacer()
        }
//        .background(
//            RoundedRectangle(cornerRadius: 10)
//                .foregroundStyle(Color.white)
//        )
        .background(
            ZStack {
                Color.white.opacity(0.2)
                BlurView(style: .systemMaterial)
            }
                .clipShape(RoundedRectangle(cornerRadius: 50))
                .shadow(radius: 5)
        )
    }
}

// The different type of workouts
struct Workout: View {
    @Environment(\.colorScheme) var colorScheme
    var areaTarget: String
    @Binding var reps: [String: Int]
    @Binding var sets: [String: Int]
    @Binding var finalPlan: [String: WorkoutDetail]
    
    // This should represent the key within the dictionary
    var book: [String: [String]] = [
        "Arms": ["Bicep Curl", "Hammer Curl", "Isolation Curl"],
        "Back": ["Deadlift", "Seated Rows", "Cable Rows"],
        "Chest": ["Bench Press", "Dumbell Press", "Incline Bench"],
        "Legs": ["Squats", "Seated Leg Extensions", "Calf Raises"],
    ]
    
    var body: some View {
        LazyVStack {
            ForEach(book[areaTarget] ?? [], id: \.self) { workout in
                HStack {
                    //* Categories
                    Text(workout)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(colorScheme == .dark ? Color.white : Color.black.opacity(0.95))
                        .padding()
                    
                    Spacer()
                    
                    //* Individual Workouts
                    HStack {
                        
                        VStack {
//                            Spacer()
                            
                            Text("Sets")
                                .font(.system(size: 15, weight: .medium))
                            
                            Picker("", selection: Binding(
                                get: { sets[workout] ?? 0 },
                                set: { newValue in
                                    sets[workout] = newValue
                                    finalPlan[workout] = WorkoutDetail(sets: newValue, reps: reps[workout] ?? 0)
                                }
                            )) {
                                ForEach(0...10, id: \.self) { value in
                                    Text("\(value)")
                                        .font(.system(size: 20, weight: .medium))
                                        .foregroundStyle(colorScheme == .dark ? Color.white : Color.black.opacity(0.95))
                                }
                            }
                            .pickerStyle(WheelPickerStyle())
                            .frame(width: 50, height: 50)
                            .clipped()
                            .background(
                                Circle()
                                    .frame(width: 50, height: 75)
                                    // here
                                    .foregroundStyle(colorScheme == .dark ? Color.gray.opacity(0.90) : Color.black.opacity(0.25))
                            )
                            
                            Spacer()
                        }
                        
                        VStack {
//                            Spacer()
                            
                            Text("Reps")
                                .font(.system(size: 15, weight: .medium))
                            
                            Picker("", selection: Binding(
                                get: { reps[workout] ?? 0 },
                                set: { newValue in
                                    reps[workout] = newValue
                                    finalPlan[workout] = WorkoutDetail(sets: sets[workout] ?? 0, reps: newValue)
                                }
                            )) {
                                ForEach(0...50, id: \.self) { value in
                                    Text("\(value)")
                                        .font(.system(size: 20, weight: .medium))
                                        .foregroundStyle(colorScheme == .dark ? Color.white : Color.black.opacity(0.95))
                                }
                            }
                            .pickerStyle(WheelPickerStyle())
                            .frame(width: 50, height: 50)
                            .clipped()
                            .background(
                                Circle()
                                    .frame(width: 50, height: 75)
                                    .foregroundStyle(colorScheme == .dark ? Color.gray.opacity(0.90) : Color.black.opacity(0.25))
                            )
                            
                            Spacer()
                        }
                    } // end of Hstack for reps and sets
                    .padding(.horizontal)
                    
                } // end of HStack
                
            } // end of ForEach
            
        } // end of LazyVStack
        
    } // end of body
    
}

// ** Initial Creation of a plan
struct PlanScreenView: View {
    // Categories
    // Legs || Arms || Chest || Back ||
    private var categories: [String] = ["Arms", "Back", "Chest", "Legs"]
    @State private var currentReps: [String: Int] = [:]
    @State private var currentSets: [String: Int] = [:]
    @State private var selectedCategory: String?
    @State private var planTitle: String = ""
    @State private var finalPlan: [String: WorkoutDetail] = [:]
    @EnvironmentObject var planManager: PlanManager
    @EnvironmentObject var viewModel: AuthView
    @Environment(\.colorScheme) var colorScheme
    @Binding var planScreenFlag: Bool
    
    init(planScreenFlag: Binding<Bool>) {
        _planScreenFlag = planScreenFlag
    }
    
    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                LazyVStack {
                    ForEach(categories.indices, id: \.self) { index in
                        planButton(title: categories[index], selectedCategory: $selectedCategory)
                        
                        
                        if selectedCategory == categories[index] {
                            Workout(areaTarget: categories[index], reps: $currentReps, sets: $currentSets, finalPlan: $finalPlan)
                        }
                    }
                    
                    Spacer()
                    
                } // end of VStack
                .padding()
            }
            
            VStack {
                Spacer()
                
                HStack {
                    TextField("Plan Name?", text: $planTitle)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 20)
                        .background(colorScheme == .dark ? Color.gray.opacity(0.33) : Color.white.opacity(0.90))
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .padding(.bottom)
                    
                    Button(action: {
                        let userId = viewModel.queryCurrentUserId()
                        Task {
                            do {
                                // implement trying to save the sets alongside with reps and workout
                                await planManager.savePlan(userId: userId ?? "", planTitle: planTitle, workoutType: finalPlan)
                                
                                // This flag's purpose is to dismiss the sheet when there is a successful save
                                planScreenFlag = false
                            }
                            
//                            catch {
//                                print("[DEBUG]: There was an error processing or saving your plan \(error.localizedDescription)")
//                            }
                        }
                        print("[DEBUG]: This will act as the save button (execute backend functionality)")
                    }) {
                        Text("Save Plan!")
                            .foregroundStyle(Color.green)
                            .font(.headline)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 10)
                    .background(colorScheme == .dark ? Color.gray.opacity(0.33) : Color.white.opacity(0.90))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
        } // end of zstack
        .background(
            BackgroundView()
        )
    }
}

//#Preview {
//    @Binding var flag = true
//    PlanScreenView(planScreenFlag: flag)
//}
