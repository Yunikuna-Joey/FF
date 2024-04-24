//
//  editPlanView.swift
//  FF
//
//

import SwiftUI

// we need this one to take in a plan object and manipulate it from there
struct editPlanView: View {
    // Categories
    // Legs || Arms || Chest || Back ||
    private var categories: [String] = ["Arms", "Back", "Chest", "Legs"]
    @State private var currentReps: [String: Int] = [:]
    @State private var currentSets: [String: Int] = [:]
    @State private var selectedCategory: String?
    @State private var planTitle: String
    @State private var finalPlan: [String: WorkoutDetail] = [:]
    @EnvironmentObject var planManager: PlanManager
    @EnvironmentObject var viewModel: AuthView
    @Binding var planScreenFlag: Bool
    let plan: Plan
    
    init(plan: Plan, planScreenFlag: Binding<Bool>) {
        self.plan = plan
        self._planScreenFlag = planScreenFlag
        _currentReps = State(initialValue: plan.workoutType.mapValues { $0.reps })
        _currentSets = State(initialValue: plan.workoutType.mapValues { $0.sets })
        _planTitle = State(initialValue: plan.planTitle)
        _finalPlan = State(initialValue: plan.workoutType)
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
                    
                } // end of Vstack
                .padding()
                
                HStack {
                    TextField("Plan Name?", text: $planTitle)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 20)
                        .background(Color.gray.opacity(0.33))
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .padding(.bottom)
                    
                    Button(action: {
                        let userId = viewModel.queryCurrentUserId()
                        Task {
                            do {
                                // implement trying to save the sets alongside with reps and workout
                                try await planManager.savePlan(userId: userId ?? "", planTitle: planTitle, workoutType: finalPlan)
                                
                                // This flag's purpose is to dismiss the sheet when there is a successful save
                                planScreenFlag = false
                            }
                            
                            catch {
                                print("[DEBUG]: There was an error processing or saving your plan \(error.localizedDescription)")
                            }
                        }
                        print("[DEBUG]: This will act as the save button (execute backend functionality)")
                    }) {
                        Text("Save Plan!")
                            .foregroundStyle(Color.green)
                            .font(.headline)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 10)
                    .background(Color.gray.opacity(0.33))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.bottom)
                } // end of Hstack
            }
            
//            VStack {
//                Spacer()
//                
//                HStack {
//                    TextField("Plan Name?", text: $planTitle)
//                        .padding(.vertical, 8)
//                        .padding(.horizontal, 20)
//                        .background(Color.gray.opacity(0.33))
//                        .cornerRadius(10)
//                        .padding(.horizontal)
//                        .padding(.bottom)
//                    
//                    Button(action: {
//                        let userId = viewModel.queryCurrentUserId()
//                        Task {
//                            do {
//                                // implement trying to save the sets alongside with reps and workout
//                                try await planManager.savePlan(userId: userId ?? "", planTitle: planTitle, workoutType: finalPlan)
//                                
//                                // This flag's purpose is to dismiss the sheet when there is a successful save
//                                planScreenFlag = false
//                            }
//                            
//                            catch {
//                                print("[DEBUG]: There was an error processing or saving your plan \(error.localizedDescription)")
//                            }
//                        }
//                        print("[DEBUG]: This will act as the save button (execute backend functionality)")
//                    }) {
//                        Text("Save Plan!")
//                            .foregroundStyle(Color.green)
//                            .font(.headline)
//                    }
//                    .padding(.vertical, 8)
//                    .padding(.horizontal, 10)
//                    .background(Color.gray.opacity(0.33))
//                    .cornerRadius(10)
//                    .padding(.horizontal)
//                    .padding(.bottom)
//                } // end of Hstack
//            } // end of vstack
        } // end of ZStack
    }
}

//#Preview {
//    editPlanView()
//}
