//
//  viewPlanView.swift
//  FF
//
//

import SwiftUI

struct viewPlanView: View {
    @EnvironmentObject var planManager: PlanManager
    @State private var deleteNavigationFlag: Bool = false
    @State private var editNavigationFlag: Bool = false
    var plan: Plan
    
    var formattedWorkoutType: String {
            var formattedString = ""
            for (workoutName, workoutDetail) in plan.workoutType {
//                formattedString += "\(workoutName): Sets - \(workoutDetail.sets), Reps - \(workoutDetail.reps)\n"
                formattedString += "Sets: \(workoutDetail.sets) Reps: \(workoutDetail.reps) - \(workoutName)\n"
            }
            return formattedString
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("\(plan.planTitle)")
                    .padding()
                    .foregroundStyle(Color.orange)
                
                
                HStack {
                    Text("\(formattedWorkoutType)")
                        .padding()
                        .foregroundStyle(Color.purple)
                    
                    Spacer()
                }
                
                Spacer()
                
                HStack {
                    // Edit button Here
                    Button(action: {
                        editNavigationFlag = true
                    }) {
                        Text("Edit Plan")
                            .padding()
                            .foregroundStyle(Color.white)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundStyle(Color.purple)
                            )
                        
                    }
                    
                    
                    
                    // Delete button here
                    Button(action: {
                        Task {
                            do {
                                try await planManager.deletePlan(id: plan.id)
                                deleteNavigationFlag = true
                            }
                            catch {
                                print("[DEBUG]: There was an error deleting the workout plan \(error.localizedDescription)")
                            }
                        }
                    }) {
                        Text("Delete button")
                            .padding()
                            .foregroundStyle(Color.white)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundStyle(Color.red)
                            )
                        
                    }
                    
                    
                } // end of HStack
            } // end of vstack
            .navigationDestination(isPresented: $deleteNavigationFlag) {
                ProfileView()
                    .navigationBarBackButtonHidden(true)
            }
            .navigationDestination(isPresented: $editNavigationFlag) {
                editPlanView(plan: plan, planScreenFlag: $editNavigationFlag)
            }
        }
    }
}

//
//#Preview {
//    viewPlanView()
//}
