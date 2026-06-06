import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        ZStack {
            Color.mBackground.ignoresSafeArea()
            VStack(spacing: 20) {
                Circle()
                    .fill(Color.mSurface2)
                    .frame(width: 80, height: 80)
                    .overlay(
                        Text(appState.currentUser?.displayName.prefix(1).uppercased() ?? "?")
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundStyle(Color.mTextPrimary)
                    )

                VStack(spacing: 4) {
                    Text(appState.currentUser?.displayName ?? "")
                        .font(.mTitle2())
                        .foregroundStyle(Color.mTextPrimary)
                    Text("@\(appState.currentUser?.username ?? "")")
                        .font(.mCallout())
                        .foregroundStyle(Color.mTextSecondary)
                }

                Spacer()

                Button("Sign Out") {
                    appState.signOut()
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color.mDestructive)
                .padding(.bottom, 40)
            }
            .padding(.top, 60)
        }
    }
}
