//
//  CustomTextField.swift
//  Planly
//
/* Reusable input component with Planly styling (baby pink accents, rounded shape). Keeps auth / forms consistent and avoids duplicating padding, borders, and shadows across multiple screens.
*/

import SwiftUI

struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var icon: String?
    
    var body: some View {
        HStack(spacing: 12) {
            /* Optional SF Symbol shown on the left to hint what the field is for (email, lock, etc.). Making it optional keeps the field usable in places where an icon would be visual noise.*/
            if let icon = icon {
                Image(systemName: icon)
                    .foregroundColor(ColorTheme.babyPinkDark)
                    .font(.system(size: 20))
            }
            /* The two branches are intentionally separate because SecureField and TextField don’t share a common type. The modifiers are kept identical so both variants behave the same (no autocorrect, no caps). */
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
