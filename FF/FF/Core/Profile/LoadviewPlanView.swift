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
                Spacer()
                
                Text("\(plan.planTitle)")
                    .foregroundStyle(Color.orange)
                    .font(.title)
                
                Spacer()
                
//                Button(action: {
//                    print("steal button [need a better name for this]")
//                }) {
//                    Image(systemName: "list.clipboard.fill")
//                }
//                .padding(.trailing, 20)
                    
            }
            .padding(.top, 20)
            
            // Workout content
            ScrollView(showsIndicators: false) {
                HStack {
                    loadViewPlanCell(plan: plan)
                    
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

struct loadViewPlanCell: View {
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
                                            .frame(width: 50, height: 50)
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
                                            .frame(width: 50, height: 50)
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

//
//#Preview {
//    LoadviewPlanView()
//}
