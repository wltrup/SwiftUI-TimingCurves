import SwiftUI

struct BoxedBezierPath: View {

    @Binding var unitStartControlPoint: CGPoint
    @Binding var unitEndControlPoint: CGPoint

    static let initialUnitStartControlPoint = CGPoint(x: 1.0, y: 0.0)
    static let initialUnitEndControlPoint = CGPoint(x: 0.0, y: 1.0)

    init(
        unitStartControlPoint: Binding<CGPoint>,
        unitEndControlPoint: Binding<CGPoint>
    ) {
        self._unitStartControlPoint = unitStartControlPoint
        self._unitEndControlPoint = unitEndControlPoint
    }

    var body: some View {
        VStack {
            Spacer()
            GeometryReader { g in
                self.rectangle(with: g)
                self.bezierPath(with: g)
                self.controlLines(with: g)
                self.corners(with: g)
                self.controlPointHandles(with: g)
            }
            .frame(
                width: geometryReaderSize.width,
                height: geometryReaderSize.height
            )
            .border(Color.red)
            .padding(.bottom, verticalPadding)
            infoArea()
            Button(action: {
                self.unitStartControlPoint = Self.initialUnitStartControlPoint
                self.unitEndControlPoint = Self.initialUnitEndControlPoint
            }) { Text("Reset") }
            Spacer()
        }
    }

    private let geometryReaderSize = CGSize(width: 300, height: 300)
    private let rectangleSizeFraction: CGFloat = 0.35
    private let rectangleLineWidth: CGFloat = 2
    private let curveLineWidth: CGFloat = 3
    private let innerCircleSize: CGFloat = 10
    private let outerCircleSize: CGFloat = 16
    private let circleLineWidth: CGFloat = 2
    private let verticalPadding: CGFloat = 15

}

private extension BoxedBezierPath {

    func rectangleSize(_ g: GeometryProxy) -> CGFloat {
        rectangleSizeFraction * min(g.size.width, g.size.height)
    }

    func center(_ g: GeometryProxy) -> CGPoint {
        let x = g.size.width / 2.0
        let y = g.size.height / 2.0
        return CGPoint(x: x, y: y)
    }

    func topLeft(_ g: GeometryProxy) -> CGPoint {
        let c = center(g)
        let s = rectangleSize(g) / 2.0
        let x = c.x - s
        let y = c.y - s
        return CGPoint(x: x, y: y)
    }

    func topRight(_ g: GeometryProxy) -> CGPoint {
        let c = center(g)
        let s = rectangleSize(g) / 2.0
        let x = c.x + s
        let y = c.y - s
        return CGPoint(x: x, y: y)
    }

    func bottomLeft(_ g: GeometryProxy) -> CGPoint {
        let c = center(g)
        let s = rectangleSize(g) / 2.0
        let x = c.x - s
        let y = c.y + s
        return CGPoint(x: x, y: y)
    }

    func bottomRight(_ g: GeometryProxy) -> CGPoint {
        let c = center(g)
        let s = rectangleSize(g) / 2.0
        let x = c.x + s
        let y = c.y + s
        return CGPoint(x: x, y: y)
    }

    func actualCP(_ unitCP: CGPoint, _ g: GeometryProxy) -> CGPoint {
        let s = rectangleSize(g)
        let bl = bottomLeft(g)
        let x = bl.x + unitCP.x * s
        let y = bl.y - unitCP.y * s
        return CGPoint(x: x, y: y)
    }

    func unitCP(_ actualCP: CGPoint, _ g: GeometryProxy) -> CGPoint {
        let s = rectangleSize(g)
        let bl = bottomLeft(g)
        let x = (actualCP.x - bl.x) / s
        let y = (bl.y - actualCP.y) / s
        return CGPoint(x: x, y: y)
    }

    func rectangle(with g: GeometryProxy) -> some View {
        Rectangle()
            .stroke(lineWidth: rectangleLineWidth)
            .foregroundColor(Color(UIColor.systemGray))
            .aspectRatio(1.0, contentMode: .fit)
            .frame(
                width: rectangleSizeFraction * g.size.width,
                height: rectangleSizeFraction * g.size.height
        )
        .position(center(g))
    }

    func bezierPath(with g: GeometryProxy) -> some View {
        Path { path in
            path.move(to: self.bottomLeft(g))
            path.addCurve(
                to: self.topRight(g),
                control1: self.actualCP(self.unitStartControlPoint, g),
                control2: self.actualCP(self.unitEndControlPoint, g)
            )
        }
        .stroke(lineWidth: self.curveLineWidth)
        .foregroundColor(Color(UIColor.systemGreen))
    }

    func controlLines(with g: GeometryProxy) -> some View {
        Path { path in
            path.move(to: self.bottomLeft(g))
            path.addLine(to: self.actualCP(self.unitStartControlPoint, g))
            path.move(to: self.topRight(g))
            path.addLine(to: self.actualCP(self.unitEndControlPoint, g))
        }
        .stroke(lineWidth: self.rectangleLineWidth)
        .foregroundColor(Color.black)
    }

    @ViewBuilder
    func corners(with g: GeometryProxy) -> some View {
        Circle()
            .foregroundColor(Color.black)
            .frame(width: self.innerCircleSize, height: self.innerCircleSize)
            .position(self.bottomLeft(g))
        Circle()
            .foregroundColor(Color.black)
            .frame(width: self.innerCircleSize, height: self.innerCircleSize)
            .position(self.topRight(g))
    }

    @ViewBuilder
    func controlPointHandles(with g: GeometryProxy) -> some View {
        Circle()
            .foregroundColor(Color.black)
            .frame(width: innerCircleSize, height: innerCircleSize)
            .position(actualCP(unitStartControlPoint, g))
        Circle()
            .foregroundColor(Color.black)
            .frame(width: innerCircleSize, height: innerCircleSize)
            .position(actualCP(unitEndControlPoint, g))
        Circle()
            .stroke(lineWidth: circleLineWidth)
            .foregroundColor(Color(UIColor.systemBlue))
            .frame(width: outerCircleSize, height: outerCircleSize)
            .position(actualCP(unitStartControlPoint, g))
            .gesture(
                DragGesture()
                    .onChanged({ value in
                        self.unitStartControlPoint = self.unitCP(value.location, g)
                    })
            )
        Circle()
            .stroke(lineWidth: circleLineWidth)
            .foregroundColor(Color(UIColor.systemBlue))
            .frame(width: outerCircleSize, height: outerCircleSize)
            .position(actualCP(unitEndControlPoint, g))
            .gesture(
                DragGesture()
                    .onChanged({ value in
                        self.unitEndControlPoint = self.unitCP(value.location, g)
                    })
            )
    }


    func infoArea() -> some View {
        VStack {
            Text("start.x: \(unitStartControlPoint.x)")
            Text("start.y: \(unitStartControlPoint.y)")
                .padding(.bottom, verticalPadding)
            Text("end.x: \(unitEndControlPoint.x)")
            Text("end.y: \(unitEndControlPoint.y)")
        }
        .padding(.bottom, verticalPadding)
    }

}
