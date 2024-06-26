//
//  ProfileView3.swift
//  FF
//
//

import SwiftUI

struct createButton: View {
    var text: String
    @Binding var planScreenFlag: Bool
    @Environment(\.colorScheme) var colorScheme
    
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
//            .foregroundStyle(Color(#colorLiteral(red: 0, green: 0, blue: 128, alpha: 1)).opacity(0.6))
            .foregroundStyle(colorScheme == .dark ? Color.white : Color.black.opacity(0.95))
            .padding()
            
            Spacer()
        }
//        .background(
//            RoundedRectangle(cornerRadius: 10)
//                .foregroundStyle(Color.white)
//        )
//        .overlay(
//            RoundedRectangle(cornerRadius: 10)
//                .stroke(Color.gray, lineWidth: 2)
//        )
    }
}

struct displayWorkoutButton: View {
    @Binding var viewPlanFlag: Bool
    var selectedPlan: Plan
    var onTap: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
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
//            .foregroundStyle(Color(#colorLiteral(red: 0, green: 0, blue: 128, alpha: 1)).opacity(0.6))
            .foregroundStyle(colorScheme == .dark ? Color.white : Color.black.opacity(0.95))
            .padding()
            
            Spacer()
        }
//        .background(
//            RoundedRectangle(cornerRadius: 50)
//                .foregroundStyle(Color.white)
//        )
//        .overlay(
//            RoundedRectangle(cornerRadius: 50)
//                .stroke(Color.gray, lineWidth: 2)
//        )
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
                    // Create a workout button here
                    createButton(text: "Create your plan", planScreenFlag: $planScreenFlag)
//                        .padding(.horizontal)
                    
                    Divider()
                    
                    // Various other workout plan buttons here
                    ForEach(planManager.planList) { plan in
                        displayWorkoutButton(
                            viewPlanFlag: $viewPlanFlag,
                            selectedPlan: plan,
                            onTap: {
                                selectedPlan = plan
                            }
                        )
//                        .padding(.horizontal)
                        Divider()
                    }
                    
                }
                .onAppear {
                    let currentUser = viewModel.currentSession
                    planManager.planList.removeAll()
                    planManager.fetchPlan(userId: currentUser!.id)
                }
            }
        }
    }
}


//#Preview {
//    ProfileView3()
//}
