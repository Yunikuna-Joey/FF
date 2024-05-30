//
//  LoadviewPlanView.swift
//  FF
//
//

import SwiftUI

struct LoadviewPlanView: View {
    @EnvironmentObject var planManager: PlanManager
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

        VStack {
            //** Plan title || Share/Grab button?
            HStack {
                Text("\(plan.planTitle)")
                    .foregroundStyle(Color.orange)
            }
            .padding(.top, 10)
            
            // Workout content
            ScrollView(showsIndicators: false) {
                HStack {
                    viewPlanCell(plan: plan)
                    
                    Spacer()
                }
                
                Spacer()
            }
            
            Spacer()
        } // end of vstack
        
        .onAppear {
            print("This is the value of loadSelectedPlan \(plan)")
        }
        
    } // end of body
}
//
//#Preview {
//    LoadviewPlanView()
//}
