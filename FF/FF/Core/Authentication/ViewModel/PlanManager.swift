//
//  PlanManager.swift
//  FF
//
//

import Foundation
import FirebaseFirestoreSwift
import Firebase

// This will hold functions related to the workout plans
class PlanManager: NSObject, ObservableObject {
    @Published var planList: [Plan] = []
    private let db = Firestore.firestore()
    
    func savePlan(userId: String, planTitle: String, workoutType: [String: WorkoutDetail]) async {
        do {
            // pack the variables into an object newPlan
            let newPlan = Plan(id: UUID().uuidString, userId: userId, planTitle: planTitle, workoutType: workoutType)
            
            try await db.collection("Plans").document(newPlan.id).setData(from: newPlan)
        }
        
        catch {
            print("[DEBUG]: Error saving plan to database \(error.localizedDescription)")
        }
    }
    
    func fetchPlan(userId: String) {
        db.collection("Plans")
            .whereField("userId", isEqualTo: userId)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("[DEBUG]: Error fetching plans \(error.localizedDescription)")
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    print("[DEBUG]: No documents found")
                    return
                }
                
                self.planList = documents.compactMap { document in
                    do {
                        let plan = try document.data(as: Plan.self)
                        return plan
                    }
                    
                    catch {
                        print("[DEBUG]: Error decoding plans: \(error.localizedDescription)")
                        return nil
                    }
                }
            }
    }
}
