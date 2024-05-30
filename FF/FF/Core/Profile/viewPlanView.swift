//
//  viewPlanView.swift
//  FF
//
//

import SwiftUI

struct viewPlanCell: View {
    var plan: Plan
    
    // sort the current plan by alphabetically order of workoutNames
    var orderedWorkouts: [(key: String, value: WorkoutDetail)] {
        plan.workoutType.sorted { $0.key < $1.key }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            
            ForEach(orderedWorkouts, id: \.key) { workoutName, workoutDetail in
                HStack {
                    // Workout Name
                    Text(workoutName)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Color.purple)
                        .padding()
                    
                    Spacer()
                    
                    HStack {
                        // Workout Sets
                        VStack {
                            Spacer()
                            Text("Sets")
                                .font(.system(size: 15, weight: .medium))
                            ZStack {
                                Circle()
                                    .fill(Color.purple)
                                    .frame(width: 35, height: 35)
                                Text("\(workoutDetail.sets)")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.white)
                            }
                            Spacer()
                        }
                        
                        // Workout Reps
                        VStack {
                            Spacer()
                            Text("Reps")
                                .font(.system(size: 15, weight: .medium))
                            ZStack {
                                Circle()
                                    .fill(Color.purple)
                                    .frame(width: 35, height: 35)
                                Text("\(workoutDetail.reps)")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.white)
                            }
                            Spacer()
                        }
                    }
                    .padding(.horizontal)
                }
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 50)
                        .stroke(Color.gray, lineWidth: 1)
                        .padding()
                )
                Divider()
            }
            
        } // end of vstack
        
    }
    
}

struct viewPlanView: View {
    @EnvironmentObject var planManager: PlanManager
    @State private var deleteNavigationFlag: Bool = false
    @State private var editNavigationFlag: Bool = false
    @State private var deleteAlertFlag: Bool = false
    var plan: Plan
    
//    var formattedWorkoutType: String {
//            var formattedString = ""
//            for (workoutName, workoutDetail) in plan.workoutType {
////                formattedString += "\(workoutName): Sets - \(workoutDetail.sets), Reps - \(workoutDetail.reps)\n"
//                formattedString += "Sets: \(workoutDetail.sets) Reps: \(workoutDetail.reps) - \(workoutName)\n"
//            }
//            return formattedString
//    }
    
    var body: some View {
        NavigationStack {
            VStack {
                // Holds the title | Edit Button | Trash Button
                HStack {
                    //** Title
                    Text("\(plan.planTitle)")
                        .foregroundStyle(Color.orange)
                    
                    //** Edit Button
                    Button(action: {
                        editNavigationFlag = true
                    }) {
                        Image(systemName: "pencil.and.ellipsis.rectangle")
                            .foregroundStyle(Color.blue.opacity(0.8))
                            .font(.system(size: 25))
                    }
                    
                    //** Delete Button
                    Button(action: {
                        deleteAlertFlag = true
                    }) {
                        Image(systemName: "trash")
                            .foregroundStyle(Color.red.opacity(0.70))
                            .font(.system(size: 25))
                    }
                    .alert(isPresented: $deleteAlertFlag) {
                        Alert(
                            title: Text("Delete Plan?"),
                            message: Text("Are you sure you want to delete this plan?"),
                            primaryButton: .destructive(Text("Delete")) {
                                Task {
                                    do {
                                        try await planManager.deletePlan(id: plan.id)
                                        deleteNavigationFlag = true
                                    }
                                    catch {
                                        print("[DEBUG]: There was an error deleting the workout plan \(error.localizedDescription)")
                                    }
                                }
                            },
                            secondaryButton: .cancel()
                        )
                    }
                    
                } // end of hstack
                
                //** Each individual workout: Workout Type | Sets <-> Reps
                ScrollView {
                    HStack {
                        viewPlanCell(plan: plan)
                        
                        Spacer()
                    }
                    
                    Spacer()
                    
                } // end of scrollView
                
                
            } // end of vstack
            .navigationDestination(isPresented: $deleteNavigationFlag) {
                ProfileView()
                    .navigationBarBackButtonHidden(true)
            }
            .navigationDestination(isPresented: $editNavigationFlag) {
                editPlanView(plan: plan, planScreenFlag: $editNavigationFlag)
            }
        }
        
    } // end of body
    
} // end of struct

//
//#Preview {
//    viewPlanView()
//}
