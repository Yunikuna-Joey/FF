//
//  LoadviewPlanView.swift
//  FF
//
//

import SwiftUI

struct LoadviewPlanView: View {
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
        ScrollView(showsIndicators: false) {
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
            } // end of vstack
        } // end of scrollView
        
        
    } // end of body
}
//
//#Preview {
//    LoadviewPlanView()
//}
