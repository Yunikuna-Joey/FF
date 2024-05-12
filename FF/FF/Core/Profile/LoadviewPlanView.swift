//
//  LoadviewPlanView.swift
//  FF
//
//

import SwiftUI

struct LoadviewPlanView: View {
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
            } // end of vstack
//            .navigationDestination(isPresented: $deleteNavigationFlag) {
//                ProfileView3(planScreenFlag: , viewPlanFlag: )
//                    .navigationBarBackButtonHidden(true)
//            }
            .navigationDestination(isPresented: $editNavigationFlag) {
                editPlanView(plan: plan, planScreenFlag: $editNavigationFlag)
            }
            
            // This will close the gap provided by the navigation stack
            .navigationBarTitle(Text(""), displayMode: .inline)
        }
    }
}
//
//#Preview {
//    LoadviewPlanView()
//}
