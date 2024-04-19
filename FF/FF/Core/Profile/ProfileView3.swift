//
//  ProfileView3.swift
//  FF
//
//

import SwiftUI

struct CalendarDayView: View {
    let day: Int
    let selection: Bool
    let isToday: Bool
    
    // void == indication of no action
    let action: () -> Void
    
    var body: some View {
        if day > 0 {
            Button(action: action) {
                Text("\(day)")
                    .frame(width: 30, height: 30)
                    .background(selection ? Color.blue : (isToday ? Color.yellow : Color.clear))
                    .clipShape(Circle())
                    .foregroundColor(selection ? .white : (isToday ? .black : .primary))
            }
        }
        // empty days
        else {
            Text("")
                .frame(width: 30, height: 30)
                .background(Color.clear)
        }
    }
}

struct StatusView: View {
    // immutatable for each specific user
    let username: String
    let timeAgo: String
    let status: String
    
    
    var body: some View {
        // what each individual update is going to follow [stacked bottom to top]
        VStack(alignment: .leading, spacing: 10) {
            // stacked left to right
            HStack(spacing: 10) {
                // profile image on the left
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.blue)
                
                // username text next to image
                Text(username)
                    .font(.headline)
                
                // space between
                Spacer()
                
                // time that message was 'created'
                Text(timeAgo)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            HStack {
                Text("Bubble 1")
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                    )
                    // experiment with font, [caption, none or body, subheadline, footnote, callout]
                    .font(.callout)
                
                Text("Bubble 2")
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                    )
                    // experiment with font, [caption, none or body, subheadline, footnote, callout]
                    .font(.callout)
                
                Text("Bubble 3")
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                    )
                    // experiment with font, [caption, none or body, subheadline, footnote, callout]
                    .font(.callout)
            }
            

            // below the left => right will be the actual status
            Text(status)
                .font(.body)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

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
    var planTitle: String
    @Binding var viewPlanFlag: Bool
    
    var body: some View {
        HStack  {
            Button(action: {
                self.viewPlanFlag = true
                print("This will represent the view when clicking on an established plan")
            }) {
                Image(systemName: "arrowshape.right.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                Text(planTitle)
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
    @State var planScreenFlag: Bool = false
    @State var viewPlanFlag: Bool = false
    
    var body: some View {
        // **** new implementation
        NavigationStack {
            ScrollView(showsIndicators: false) {
                LazyVStack {
                    createButton(text: "Create your plan", planScreenFlag: $planScreenFlag)
                    
                    ForEach(planManager.planList) { plan in
                        displayWorkoutButton(planTitle: plan.planTitle, viewPlanFlag: $viewPlanFlag)
                            .navigationDestination(isPresented: $viewPlanFlag) {
                                viewPlanView(plan: plan)
                            }
                    }
                    
                }
                .padding(.bottom, 250)
                .onAppear {
                    let currentUser = viewModel.currentSession
                    planManager.fetchPlan(userId: currentUser!.id)
                }
                .sheet(isPresented: $planScreenFlag) {
                    PlanScreenView(planScreenFlag: $planScreenFlag)
                }
//                .navigationDestination(isPresented: $viewPlanFlag) {
//                    viewPlanView()
//                }
            }
        }
    }
}

#Preview {
    ProfileView3()
}
