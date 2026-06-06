import SwiftUI

struct PhoneEntryView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var vm: AuthViewModel

    init() {
        // Workaround: EnvironmentObject not available in init, created in onAppear
        _vm = StateObject(wrappedValue: AuthViewModel(api: APIClient(), authManager: AuthManager(keychain: KeychainStore())))
    }

    var body: some View {
        ZStack {
            Color.mBackground.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                Spacer()

                Text("Who are\nyou?")
                    .font(.display(44))
                    .foregroundStyle(Color.mTextPrimary)
                    .padding(.bottom, 48)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Phone number")
                        .font(.mCaption())
                        .foregroundStyle(Color.mTextSecondary)

                    TextField("+1 555 000 0000", text: $vm.phoneNumber)
                        .font(.system(size: 28, weight: .regular, design: .default))
                        .foregroundStyle(Color.mTextPrimary)
                        .keyboardType(.phonePad)
                        .textContentType(.telephoneNumber)
                        .tint(.mPrimary)
                        .padding(.bottom, 8)

                    Divider().background(Color.mBorder)
                }
                .padding(.bottom, 40)

                if let dev = vm.devOTP {
                    Text("Dev OTP: \(dev)")
                        .font(.mCaption())
                        .foregroundStyle(Color.mTextSecondary)
                        .padding(.bottom, 12)
                }

                if let err = vm.errorMessage {
                    Text(err)
                        .font(.mCaption())
                        .foregroundStyle(Color.mDestructive)
                        .padding(.bottom, 12)
                }

                Button {
                    Task { await vm.requestOTP() }
                } label: {
                    ZStack {
                        if vm.isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text("Continue")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.mPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .disabled(vm.phoneNumber.count < 8 || vm.isLoading)
                .opacity(vm.phoneNumber.count < 8 ? 0.5 : 1)
                .contentShape(Rectangle())

                Spacer().frame(height: 40)
            }
            .padding(.horizontal, 28)
        }
        .sheet(isPresented: $vm.showOTPEntry) {
            OTPView(vm: vm)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .onAppear {
            vm.onAuthenticated = { user in
                appState.authManager.saveTokens(
                    access: appState.authManager.accessToken ?? "",
                    refresh: appState.authManager.refreshToken ?? ""
                )
                appState.signIn(user: user)
            }
        }
    }
}
