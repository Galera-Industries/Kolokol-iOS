import SwiftUI

struct NumericTextView: View {
    let value: Int
    var body: some View {
        Text("\(value)")
            .font(.system(size: 24, weight: .semibold, design: .default))
            .contentTransition(.numericText())
            .animation(.default, value: value)
            .padding(.horizontal, 2)
    }
}
