import SwiftUI

struct GraphView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 12) {
                Image(systemName: "point.3.connected.trianglepath.dotted")
                    .font(.system(size: 48))
                    .foregroundStyle(Color.mPrimary)
                Text("Your Network")
                    .font(.display(28))
                    .foregroundStyle(.white)
                Text("Coming in Phase 2")
                    .font(.mCallout())
                    .foregroundStyle(Color.mTextSecondary)
            }
        }
    }
}
