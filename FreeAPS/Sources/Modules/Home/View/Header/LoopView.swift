import SwiftDate
import SwiftUI
import UIKit

struct LoopView: View {
    private enum Config {
        static let lag: TimeInterval = 30
    }

    @Binding var suggestion: Suggestion?
    @Binding var enactedSuggestion: Suggestion?
    @Binding var closedLoop: Bool
    @Binding var timerDate: Date
    @Binding var isLooping: Bool

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }

    private let rect = CGRect(x: 0, y: 0, width: 38, height: 38)
    var body: some View {
        VStack(alignment: .center) {
            ZStack {
                Circle()
                    .strokeBorder(color, lineWidth: 6)
                    .frame(width: rect.width, height: rect.height)
                    .mask(mask(in: rect).fill(style: FillStyle(eoFill: true)))
                if isLooping {
                    ProgressView()
                }
            }

            Spacer()
            if isLooping {
                Text("looping").font(.caption2)
            } else if let date = actualSuggestion?.timestamp {
                Text("\(Int((timerDate.timeIntervalSince(date) - Config.lag) / 60) + 1) min").font(.caption)
            } else {
                Text("--").font(.caption)
            }
        }
    }

    private var color: Color {
        guard let lastDate = actualSuggestion?.timestamp else {
            return Color(UIColor(named: "LoopGray")!)
        }
        let delta = timerDate.timeIntervalSince(lastDate) - Config.lag

        if delta <= 5.minutes.timeInterval {
            return Color(UIColor(named: "LoopGreen")!)
        } else if delta <= 10.minutes.timeInterval {
            return Color(UIColor(named: "LoopYellow")!)
        } else {
            return Color(UIColor(named: "LoopRed")!)
        }
    }

    func mask(in rect: CGRect) -> Path {
        var path = Rectangle().path(in: rect)
        if !closedLoop {
            path.addPath(Rectangle().path(in: CGRect(x: rect.minX, y: rect.midY - 5, width: rect.width, height: 10)))
        }
        return path
    }

    private var actualSuggestion: Suggestion? {
        if closedLoop, suggestion?.rate != nil || suggestion?.units != nil {
            return enactedSuggestion
        } else {
            return suggestion
        }
    }
}

extension View {
    func animateForever(
        using animation: Animation = Animation.easeInOut(duration: 1),
        autoreverses: Bool = false,
        _ action: @escaping () -> Void
    ) -> some View {
        let repeated = animation.repeatForever(autoreverses: autoreverses)

        return onAppear {
            withAnimation(repeated) {
                action()
            }
        }
    }
}