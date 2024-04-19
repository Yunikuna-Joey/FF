//
//  viewPlanView.swift
//  FF
//
//

import SwiftUI

struct viewPlanView: View {
    @EnvironmentObject var planManager: PlanManager
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
                    print("This will act as the edit button")
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
                    print("This will act as the delete button")
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
        }
    }
}

//
//#Preview {
//    viewPlanView()
//}
