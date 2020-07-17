import SwiftUI

struct ContentView: View {

    @State private var unitStartControlPoint: CGPoint = CGPoint(x: 1.0, y: 0.0)
    @State private var unitEndControlPoint: CGPoint = CGPoint(x: 0.0, y: 1.0)

    var body: some View {
        BoxedBezierPath(
            unitStartControlPoint: $unitStartControlPoint,
            unitEndControlPoint: $unitEndControlPoint
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
