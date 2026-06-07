import SwiftUI

struct OTPView: View {
    @ObservedObject var vm: AuthViewModel
    @FocusState private var focused: Bool

    var body: some View {
        ZStack {
            Color.mBackground.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                Text("Enter code")
                    .font(.display(28))
                    .foregroundStyle(Color.mTextPrimary)
                    .padding(.top, 32)
                    .padding(.bottom, 8)

                Text("Sent to \(vm.phoneNumber)")
                    .font(.mCallout())
                    .foregroundStyle(Color.mTextSecondary)
                    .padding(.bottom, vm.devOTP == nil ? 40 : 8)

                if let otp = vm.devOTP {
                    Text("Dev code: \(otp)")
                        .font(.mCaption())
                        .foregroundStyle(Color.mPrimary)
                        .padding(.bottom, 32)
                }

                // 6-digit display boxes backed by hidden field
                HStack(spacing: 12) {
                    ForEach(0..<6, id: \.self) { i in
                        let char = vm.otpCode.count > i ? String(vm.otpCode[vm.otpCode.index(vm.otpCode.startIndex, offsetBy: i)]) : ""
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.mSurface2)
                                .frame(width: 48, height: 60)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(i == vm.otpCode.count ? Color.mPrimary : Color.mBorder, lineWidth: 1.5)
                                )
                            Text(char)
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundStyle(Color.mTextPrimary)
                        }
                    }
                }
                .overlay(
                    TextField("", text: $vm.otpCode)
                        .keyboardType(.numberPad)
                        .textContentType(.oneTimeCode)
                        .focused($focused)
                        .opacity(0.01)
                        .onChange(of: vm.otpCode) { _, v in
                            vm.otpCode = String(v.filter(\.isNumber).prefix(6))
                            if vm.otpCode.count == 6 {
                                Task { await vm.verifyOTP() }
                            }
                        }
                )
                .onTapGesture { focused = true }
                .padding(.bottom, 32)

                if let err = vm.errorMessage {
                    Text(err)
                        .font(.mCaption())
                        .foregroundStyle(Color.mDestructive)
                        .padding(.bottom, 16)
                }

                Button {
                    Task { await vm.verifyOTP() }
                } label: {
                    ZStack {
                        if vm.isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text("Verify")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(vm.otpCode.count == 6 ? Color.mPrimary : Color.mSurface2)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .animation(.easeInOut(duration: 0.2), value: vm.otpCode.count)
                }
                .disabled(vm.otpCode.count < 6 || vm.isLoading)
                .contentShape(Rectangle())

                Spacer()
            }
            .padding(.horizontal, 28)
        }
        .onAppear { focused = true }
    }
}
