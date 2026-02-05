//
//  CustomTextField.swift
//  Planly
//
//  Custom styled text field with baby pink accents
//

import SwiftUI

struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var icon: String?
    
    var body: some View {
        HStack(spacing: 12) {
            if let icon = icon {
                Image(systemName: icon)
                    .foregroundColor(ColorTheme.babyPinkDark)
                    .font(.system(size: 20))
            }
            
            if isSecure {
                SecureField(placeholder, text: $text)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            } else {
                TextField(placeholder, text: $text)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }
        }
        .padding()
        .background(ColorTheme.offWhite)
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(ColorTheme.babyPink, lineWidth: 1.5)
        )
        .shadow(color: ColorTheme.babyPink.opacity(0.2), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    VStack {
        CustomTextField(placeholder: "Email", text: .constant(""), icon: "envelope.fill")
        CustomTextField(placeholder: "Password", text: .constant(""), isSecure: true, icon: "lock.fill")
    }
    .padding()
}
