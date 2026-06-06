import SwiftUI

struct FeedView: View {
    var body: some View {
        ZStack {
            Color.mBackground.ignoresSafeArea()
            VStack(spacing: 12) {
                Image(systemName: "sparkles")
                    .font(.system(size: 48))
                    .foregroundStyle(Color.mPrimary)
                Text("Feed")
                    .font(.display(28))
                    .foregroundStyle(Color.mTextPrimary)
                Text("Coming in Phase 2")
                    .font(.mCallout())
                    .foregroundStyle(Color.mTextSecondary)
            }
        }
    }
}
