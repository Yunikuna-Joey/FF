//
//  viewPlanView.swift
//  FF
//
//

import SwiftUI

struct viewPlanCell: View {
    var plan: Plan
    @State private var isMarked: [String: Bool] = [:]
    
    // sort the current plan by alphabetically order of workoutNames
    var orderedWorkouts: [(key: String, value: WorkoutDetail)] {
        plan.workoutType.sorted { $0.key < $1.key }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            
            ForEach(orderedWorkouts, id: \.key) { workoutName, workoutDetail in
                HStack {
                    CheckBox(isMarked: Binding(
                        get: { isMarked[workoutName] ?? false },
                        set: { isMarked[workoutName] = $0 }
                    ))
                    .padding(.leading, 15)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 50)
                            .fill(Color.clear) // Clear fill so the background can be seen
                            .background(
                                ZStack {
                                    Color.white.opacity(0.2)
                                    BlurView(style: .systemMaterial)
                                }
                                    .clipShape(RoundedRectangle(cornerRadius: 50))
                            )
                            .padding()
                            .shadow(radius: 5)
                        
                        HStack {
                            // Workout Name
                            Text(workoutName)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(isMarked[workoutName] == true ? Color.gray : Color.purple)
                                .padding()
                            
                            Spacer()
                            
                            //*** Holds the sets and reps
                            HStack {
                                // Workout Sets
                                VStack {
                                    Spacer()
                                    Text("Sets")
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundStyle(isMarked[workoutName] == true ? Color.gray : Color.primary)
                                    ZStack {
                                        Circle()
                                            .fill(isMarked[workoutName] == true ? Color.gray : Color.purple)
                                            .frame(width: 50, height: 75)
                                        Text("\(workoutDetail.sets)")
                                            .font(.system(size: 20, weight: .medium))
                                            .foregroundColor(.white)
                                    }
                                    Spacer()
                                }
                                .padding(.bottom, 10)
                                
                                // Workout Reps
                                VStack {
                                    Spacer()
                                    Text("Reps")
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundStyle(isMarked[workoutName] == true ? Color.gray : Color.primary)
                                    ZStack {
                                        Circle()
                                            .fill(isMarked[workoutName] == true ? Color.gray : Color.purple)
                                            .frame(width: 50, height: 75)
                                        Text("\(workoutDetail.reps)")
                                            .font(.system(size: 20, weight: .medium))
                                            .foregroundColor(.white)
                                    }
                                    Spacer()
                                }
                                .padding(.bottom, 10)
                                .padding(.horizontal, 10)
                                
                            }
                            .padding(.horizontal)
                            
                            
                            
                        } // entire hstack cell holding all information
                        .padding()
                        
                    } // end of ZStack
                }
                
                Divider()
                
            } // end of for loop
            
        } // end of vstack
        
    }
    
}

struct CheckBox: View {
    @Binding var isMarked: Bool
    
    var body: some View {
        Button(action: {
            isMarked.toggle()
        }) {
            Image(systemName: isMarked ? "checkmark.square" : "square")
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundStyle(isMarked ? Color.blue : Color.gray)
        }
    }
}

struct viewPlanView: View {
    @EnvironmentObject var planManager: PlanManager
    @State private var deleteNavigationFlag: Bool = false
    @State private var editNavigationFlag: Bool = false
    @State private var deleteAlertFlag: Bool = false
    var plan: Plan
    
    var body: some View {
        NavigationStack {
            VStack {
                // Holds the title | Edit Button | Trash Button
                HStack {
                    //** Title
                    Text("\(plan.planTitle)")
                        .foregroundStyle(Color.orange)
                        .font(.headline)
                    
                    //** Edit Button
                    Button(action: {
                        editNavigationFlag = true
                    }) {
                        Image(systemName: "pencil.and.ellipsis.rectangle")
                            .foregroundStyle(Color.blue.opacity(0.8))
                            .font(.system(size: 20))
                    }
                    
                    //** Delete Button
                    Button(action: {
                        deleteAlertFlag = true
                    }) {
                        Image(systemName: "trash")
                            .foregroundStyle(Color.red.opacity(0.70))
                            .font(.system(size: 20))
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
            .background(
                BackgroundView()
            )
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
