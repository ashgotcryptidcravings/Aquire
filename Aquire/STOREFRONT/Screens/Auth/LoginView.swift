import SwiftUI

@available(macOS 12.0, iOS 15.0, *)
struct LoginView: View {
    @Binding var isLoggedIn: Bool
    @Binding var storedEmail: String

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showError: Bool = false

    // 🔐 Super simple validation:
    //  - email must contain "@"
    //  - password must not be empty
    private var isFormValid: Bool {
        email.trimmingCharacters(in: .whitespacesAndNewlines).contains("@")
        && !password.isEmpty
    }

    var body: some View {
        ZStack {
            // Use the same global background as the rest of the app if you like,
            // or leave this gradient for a standalone login scene.
            AquireBackgroundView()

            VStack {
                Spacer()

                VStack(spacing: 18) {
                    // Title
                    VStack(spacing: 6) {
                        Text("Welcome to Aquire")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(.white)

                        Text("Sign in to manage your Foundation stack.")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.6))
                    }

                    // Email
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Email")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.white.opacity(0.7))

                        TextField("you@foundation.dev", text: $email)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(Color.white.opacity(0.06))
                            )
                            .foregroundColor(.white)
                        #if os(iOS)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                        #endif
                    }

                    // Password
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Password")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.white.opacity(0.7))

                        SecureField("••••••••", text: $password)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(Color.white.opacity(0.06))
                            )
                            .foregroundColor(.white)
                    }

                    if showError {
                        Text("Enter a valid email (with @) and a non-empty password.")
                            .font(.system(size: 11))
                            .foregroundColor(.red.opacity(0.9))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .transition(.opacity)
                    }

                    Button(action: handleLogin) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size: 18, weight: .semibold))
                            Text("Sign In")
                                .font(.system(size: 15, weight: .semibold))
                        }
                        .padding(.horizontal, 22)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color.purple,
                                    Color(red: 0.9, green: 0.35, blue: 1.0)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            .opacity(isFormValid ? 1.0 : 0.5)
                        )
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                    }
                    .disabled(!isFormValid)
                    .pressable()

                    Text("Demo mode only · any valid email + password works")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.5))
                        .padding(.top, 4)
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                )
                .shadow(color: .black.opacity(0.6), radius: 30, x: 0, y: 18)
                .padding(.horizontal, 40)
                .padding(.bottom, 40)

                Spacer()
            }
        }
    }

    private func handleLogin() {
        guard isFormValid else {
            withAnimation { showError = true }
            return
        }

        storedEmail = email
        isLoggedIn = true
    }
}
