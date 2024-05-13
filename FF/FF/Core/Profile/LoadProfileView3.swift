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

//    @State var planScreenFlag: Bool = false
    let resultUser: User
    @Binding var loadViewPlanFlag: Bool
    @Binding var loadSelectedPlan: Plan
    
    let screenSize = UIScreen.main.bounds.size
    
    var body: some View {
        // **** new implementation
        NavigationStack {
            ScrollView(showsIndicators: false) {
                LazyVStack {                    
                    // If there is no plans underneath a user, display a message
                    if planManager.planList.isEmpty {
                        Text("\(resultUser.username) has not made any workout plans yet!")
                            .foregroundStyle(Color.black)
                            .padding()
                    }
                    
                    // Assume normal situation where they do have plans
                    else {
                        ForEach(planManager.planList) { plan in
                            displayWorkoutButton(
                                viewPlanFlag: $loadViewPlanFlag,
                                selectedPlan: plan,
                                onTap: {
                                    loadSelectedPlan = plan
                                }
                            )
                        }
                    }
                    Spacer()
                } // end of LazyVStack
                .onAppear {
                    planManager.fetchPlan(userId: resultUser.id)
                }
                
            } // end of scrollView
            
        } // end of navigationView
        
    } // end of body
}

//#Preview {
//    LoadProfileView3()
//}

//struct LoadProfileView3_Previews: PreviewProvider {
//    static var previews: some View {
//        let user = User(id: "testString", username: "TesterE", databaseUsername: "testere", firstName: "Tester", lastName: "E", email: "e@email.com", imageArray: ["Car", "car2", "car3"], profilePicture: "")
//        LoadProfileView3(resultUser: user)
//    }
//}
