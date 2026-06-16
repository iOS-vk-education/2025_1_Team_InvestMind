
import SwiftUI

struct InvestTextField: View {
    enum Style {
        case text
        case secure
        case email
    }

    var title: String
    var placeholder: String
    @Binding var text: String
    var style: Style = .text
    var error: String? = nil

    @State private var isSecureVisible = false

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(title)
                .font(AppTypography.caption())
                .foregroundStyle(AppColors.textSecondary)

            HStack {
                if style == .secure && !isSecureVisible {
                    SecureField(placeholder, text: $text)
                        .textContentType(.password)
                        .autocapitalization(.none)
                } else {
                    TextField(placeholder, text: $text)
                        .keyboardType(style == .email ? .emailAddress : .default)
                        .textInputAutocapitalization(style == .email ? .never : .sentences)
                        .textContentType(style == .email ? .emailAddress : .none)
                }

                if style == .secure {
                    Button {
                        isSecureVisible.toggle()
                    } label: {
                        Image(systemName: isSecureVisible ? "eye.slash" : "eye")
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }
            }
            .padding()
            .background(AppColors.backgroundSecondary)
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(error == nil ? AppColors.border : AppColors.danger, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            if let error {
                Text(error)
                    .font(AppTypography.caption(weight: .regular))
                    .foregroundStyle(AppColors.danger)
            }
        }
    }
}


