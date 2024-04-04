//
//  SettingView.swift
//  FF
//
//  Created by Joey Truong on 4/4/24.
//

import SwiftUI

struct SettingView: View {
    var body: some View {
        Button(action: {
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
