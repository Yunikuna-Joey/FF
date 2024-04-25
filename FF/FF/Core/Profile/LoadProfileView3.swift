//
//  LoadProfileView3.swift
//  FF
//
//

import SwiftUI

struct LoadProfileView3: View {
    @EnvironmentObject var statusProcess: StatusProcessView
    @EnvironmentObject var planManager: PlanManager
    @EnvironmentObject var viewModel: AuthView

    @State var planScreenFlag: Bool = false
    @State var viewPlanFlag: Bool = false
    
    let resultUser: User
    let screenSize = UIScreen.main.bounds.size
    
    var body: some View {
        // **** new implementation
        NavigationStack {
            ScrollView(showsIndicators: false) {
                LazyVStack {
//                    Text("Workout Plans!")
//                        .padding()
//                        .foregroundStyle(Color.orange)
//                        .font(.headline)
                    
                    // If there is no plans underneath a user, display a message
                    if planManager.planList.isEmpty {
                        Text("\(resultUser.username) has not made any workout plans yet!")
                            .foregroundStyle(Color.black)
                            .padding()
                    }
                    
                    // Assume normal situation where they do have plans
                    else {
                        ForEach(planManager.planList) { plan in
                            displayWorkoutButton(planTitle: plan.planTitle, viewPlanFlag: $viewPlanFlag)
                                .navigationDestination(isPresented: $viewPlanFlag) {
                                    viewPlanView(plan: plan)
                                }
                        }
                    }
                    Spacer()
                }
                .onAppear {
                    planManager.fetchPlan(userId: resultUser.id)
                }
                .sheet(isPresented: $planScreenFlag) {
                    PlanScreenView(planScreenFlag: $planScreenFlag)
                }
                // this removes the empty space created by the NavigationView || NavigationStack || NavigationLink
                .navigationBarHidden(true)
            } // end of scrollView
        } // end of navigationView
    } // end of body
    
    
}

//#Preview {
//    LoadProfileView3()
//}

struct LoadProfileView3_Previews: PreviewProvider {
    static var previews: some View {
        let user = User(id: "testString", username: "TesterE", databaseUsername: "testere", firstName: "Tester", lastName: "E", email: "e@email.com", imageArray: ["Car", "car2", "car3"], profilePicture: "")
        LoadProfileView3(resultUser: user)
    }
}
