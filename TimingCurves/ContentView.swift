import SwiftUI

struct ContentView: View {

    @State private var unitStartControlPoint = BoxedBezierPath.initialUnitStartControlPoint
    @State private var unitEndControlPoint = BoxedBezierPath.initialUnitEndControlPoint

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
