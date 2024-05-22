//
//  viewPlanView.swift
//  FF
//
//

import SwiftUI

struct viewPlanCell: View {
    var plan: Plan
    
    var body: some View {
        VStack(alignment: .leading) {
            
            ForEach(Array(plan.workoutType.keys), id: \.self) { workoutName in
                
                if let workoutDetail = plan.workoutType[workoutName] {
                    
                    HStack {
                        Text(workoutName)
                            .font(.system(size: 20, weight: .regular))
                            .foregroundStyle(Color.purple)
                        
                        Spacer()
                        
                        VStack {
                            Text("Sets")
                            
                            ZStack {
                                Circle()
                                    .fill(Color.purple)
                                    .frame(width: 70, height: 70)
                                
                                Text("\(workoutDetail.sets)")
                                    .font(.system(size: 32, weight: .medium))
                                    .foregroundColor(.white)
                            }
                            
                            Spacer()
                        }
                        
                        VStack {
                            Text("Reps")
                            
                            ZStack {
                                Circle()
                                    .fill(Color.purple)
                                    .frame(width: 70, height: 70)
                                
                                Text("\(workoutDetail.reps)")
                                    .font(.system(size: 32, weight: .medium))
                                    .foregroundColor(.white)
                            }
                            
                            Spacer()
                        }
                        
                    } // end of hstack
                    .padding()
                    
                    Divider()
                    
                } // end of variable unwrapping
                
            } // end of for-loop
            
        } // end of vstack
        
    }
    
}

struct viewPlanView: View {
    @EnvironmentObject var planManager: PlanManager
    @State private var deleteNavigationFlag: Bool = false
    @State private var editNavigationFlag: Bool = false
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
                HStack {
                    Text("\(plan.planTitle)")
                        .foregroundStyle(Color.orange)
                    
                    Button(action: {
                        editNavigationFlag = true
                    }) {
                        Image(systemName: "pencil.and.ellipsis.rectangle")
                            .foregroundStyle(Color.blue.opacity(0.8))
                            .font(.system(size: 25))
                    }
                }
                
                ScrollView {
                    HStack {
                        //                    Text("\(formattedWorkoutType)")
                        //                        .padding()
                        //                        .foregroundStyle(Color.purple)
                        viewPlanCell(plan: plan)
                        
                        Spacer()
                    }
                    
                    Spacer()
                    
                    HStack {
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
