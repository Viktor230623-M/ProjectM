import SwiftUI
import ProjectMShared

struct MessageBubbleView: View {
    let message: MessageDTO
    let isOwn: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        HStack {
            if isOwn { Spacer(minLength: 60) }

            VStack(alignment: isOwn ? .trailing : .leading, spacing: 3) {
                bubbleContent
                Text(message.createdAt.formatted(.dateTime.hour().minute()))
                    .font(.mCaption())
                    .foregroundStyle(Color.mTextSecondary)
                    .padding(.horizontal, 4)
            }

            if !isOwn { Spacer(minLength: 60) }
        }
        .padding(.horizontal, 12)
        .transition(
            reduceMotion ? .opacity :
                .asymmetric(
                    insertion: .offset(x: isOwn ? 20 : -20).combined(with: .opacity),
                    removal: .opacity
                )
        )
    }

    @ViewBuilder
    private var bubbleContent: some View {
        switch message.contentType {
        case .text:
            Text(message.content)
                .font(.mBody())
                .foregroundStyle(isOwn ? .white : Color.mTextPrimary)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(isOwn ? Color.mPrimary : Color.mSurface2)
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 18,
                        bottomLeadingRadius: isOwn ? 18 : 4,
                        bottomTrailingRadius: isOwn ? 4 : 18,
                        topTrailingRadius: 18
                    )
                )
        default:
            Text(message.content)
                .font(.mCallout())
                .foregroundStyle(Color.mTextSecondary)
                .italic()
                .padding(10)
                .background(Color.mSurface2)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

struct TypingIndicatorView: View {
    @State private var phase = 0

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .fill(Color.mTextSecondary)
                    .frame(width: 6, height: 6)
                    .scaleEffect(phase == i ? 1.4 : 1.0)
                    .animation(
                        .easeInOut(duration: 0.4).repeatForever(autoreverses: true).delay(Double(i) * 0.15),
                        value: phase
                    )
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color.mSurface2)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .onAppear { phase = 1 }
    }
}
