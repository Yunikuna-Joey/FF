//
//  SettingView.swift
//  FF
//
//

import SwiftUI

struct SettingView: View {
    @EnvironmentObject var viewModel: AuthView
    
    var body: some View {
        Button(action: {
            viewModel.signOut()
            print("Settings page sign out button")
        }) {
            HStack {
                Text("Sign out!")
                    .foregroundStyle(Color.black)
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .foregroundStyle(Color.red)
                    .padding()
            }
        }
    }
}

#Preview {
    SettingView()
}
