//
//  ProfileView3.swift
//  FF
//
//

import SwiftUI

struct createButton: View {
    var text: String
    @Binding var planScreenFlag: Bool
    
    var body: some View {
        HStack {
            Button(action: {
                self.planScreenFlag = true
                print("[DEBUG]: You pressed the creation button")
            }) {
                Image(systemName: "plus.app.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                Text("Create your plan")
                    .font(.system(size: 20))
            }
            .foregroundStyle(Color.blue)
            .padding()
            
            Spacer()
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(Color.white)
        )
    }
}

struct displayWorkoutButton: View {
    @Binding var viewPlanFlag: Bool
    var selectedPlan: Plan
    var onTap: () -> Void
    
    var body: some View {
        HStack  {
            Button(action: {
                self.viewPlanFlag = true
                onTap()
                print("This will represent the view when clicking on an established plan")
            }) {
                Image(systemName: "arrowshape.right.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                
                Text(selectedPlan.planTitle)
                    .font(.system(size: 20))
            }
            .foregroundStyle(Color.blue)
            .padding()
            
            Spacer()
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(Color.white)
        )
    }
}

struct ProfileView3: View {
    @EnvironmentObject var planManager: PlanManager
    @EnvironmentObject var viewModel: AuthView
    let screenSize = UIScreen.main.bounds.size
    @Binding var planScreenFlag: Bool
    @Binding var viewPlanFlag: Bool
    @Binding var selectedPlan: Plan
    
    var body: some View {
        // **** new implementation
        NavigationStack {
            ScrollView(showsIndicators: false) {
                LazyVStack {
                    createButton(text: "Create your plan", planScreenFlag: $planScreenFlag)
                    
                    ForEach(planManager.planList) { plan in
                        displayWorkoutButton(
                            viewPlanFlag: $viewPlanFlag,
                            selectedPlan: plan,
                            onTap: {
                                selectedPlan = plan
                            }
                        )
                    }
                    
                }
                .onAppear {
                    let currentUser = viewModel.currentSession
                    planManager.fetchPlan(userId: currentUser!.id)
                }
            }
        }
    }
}


//#Preview {
//    ProfileView3()
//}
