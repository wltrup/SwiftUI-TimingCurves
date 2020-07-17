import SwiftUI

struct BoxedBezierPath: View {

    @Binding var unitStartControlPoint: CGPoint
    @Binding var unitEndControlPoint: CGPoint

    static let initialUnitStartControlPoint = CGPoint(x: 0, y: 1)
    static let initialUnitEndControlPoint = CGPoint(x: 1, y: 0)

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
                self.animatedDot(with: g)
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
            .padding(.bottom, verticalPadding)
            infoArea()
            Button(action: {
                self.animatedDotX = .zero
                withAnimation(self.dotAnimation) {
                    self.animatedDotX = self.rectangleFrame.size.width
                }
            }) { Text("Animate Dot").foregroundColor(Color(UIColor.systemGreen)) }
            Text("duration: \(durationStr(animationDuration)) seconds")
            Slider(
                value: $animationDuration,
                in: minDuration ... maxDuration,
                step: durationStep,
                minimumValueLabel: Text(durationStr(minDuration)),
                maximumValueLabel: Text(durationStr(maxDuration)),
                label: { EmptyView() }
            )
            .frame(width: sliderWidth)
            Spacer()
            Button(action: {
                withAnimation {
                    self.unitStartControlPoint = Self.initialUnitStartControlPoint
                    self.unitEndControlPoint = Self.initialUnitEndControlPoint
                }
            }) { Text("Reset Curve").foregroundColor(Color(UIColor.systemGreen)) }
            Spacer()
        }
    }

    @State private var animatedDotX: CGFloat = .zero
    @State private var animationDuration: Double = 2

    @State private var rectangleFrame: CGRect = .zero
    @Environment(\.colorScheme) var colorScheme

    private let geometryReaderSize = CGSize(width: 300, height: 300)
    private let rectangleSizeFraction: CGFloat = 0.35
    private let rectangleLineWidth: CGFloat = 2
    private let curveLineWidth: CGFloat = 3
    private let innerCircleSize: CGFloat = 10
    private let outerCircleSize: CGFloat = 16
    private let circleLineWidth: CGFloat = 2
    private let verticalPadding: CGFloat = 15

    private let dotSize: CGFloat = 44
    private let animatedDotSize: CGFloat = 28

    private let sliderWidth: CGFloat = 300
    private let durationStep: Double = 0.1
    private let minDuration: Double = 0.1
    private let maxDuration: Double = 10

    private static var numberFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.minimumIntegerDigits = 1
        f.minimumFractionDigits = 1
        f.maximumFractionDigits = 1
        return f
    }()

}

private extension BoxedBezierPath {

    func rectangleSize(_ g: GeometryProxy) -> CGFloat {
        rectangleSizeFraction * min(g.size.width, g.size.height)
    }

    func center(_ g: GeometryProxy) -> CGPoint {
        let x = g.size.width / 2
        let y = g.size.height / 2
        return CGPoint(x: x, y: y)
    }

    func topLeft(_ g: GeometryProxy) -> CGPoint {
        let c = center(g)
        let s = rectangleSize(g) / 2
        let x = c.x - s
        let y = c.y - s
        return CGPoint(x: x, y: y)
    }

    func topRight(_ g: GeometryProxy) -> CGPoint {
        let c = center(g)
        let s = rectangleSize(g) / 2
        let x = c.x + s
        let y = c.y - s
        return CGPoint(x: x, y: y)
    }

    func bottomLeft(_ g: GeometryProxy) -> CGPoint {
        let c = center(g)
        let s = rectangleSize(g) / 2
        let x = c.x - s
        let y = c.y + s
        return CGPoint(x: x, y: y)
    }

    func bottomRight(_ g: GeometryProxy) -> CGPoint {
        let c = center(g)
        let s = rectangleSize(g) / 2
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

    @ViewBuilder
    func animatedDot(with g: GeometryProxy) -> some View {
        ZStack {
            Circle()
                .foregroundColor(Color.white)
                .frame(width: dotSize, height: dotSize)
            Circle()
                .foregroundColor(Color.black)
                .frame(width: dotSize-4, height: dotSize-4)
            Circle()
                .foregroundColor(Color(UIColor.systemRed))
                .frame(width: dotSize-6, height: dotSize-6)
        }
        .position(.zero)
        ZStack {
            Circle()
                .foregroundColor(Color.white)
                .frame(width: dotSize, height: dotSize)
            Circle()
                .foregroundColor(Color.black)
                .frame(width: dotSize-4, height: dotSize-4)
            Circle()
                .foregroundColor(Color(UIColor.systemBlue))
                .frame(width: dotSize-6, height: dotSize-6)
        }
        .position(CGPoint(x: rectangleFrame.size.width, y: 0))
        ZStack {
            Circle()
                .foregroundColor(Color.white)
                .frame(width: animatedDotSize, height: animatedDotSize)
            Circle()
                .foregroundColor(Color.black)
                .frame(width: animatedDotSize-4, height: animatedDotSize-4)
            Circle()
                .foregroundColor(Color(UIColor.systemGreen))
                .frame(width: animatedDotSize-6, height: animatedDotSize-6)
        }
        .position(CGPoint(x: animatedDotX, y: 0))
    }

    func rectangle(with g: GeometryProxy) -> some View {
        DispatchQueue.main.async {
            self.rectangleFrame = g.frame(in: .global)
        }
        return Rectangle()
            .stroke(lineWidth: rectangleLineWidth)
            .foregroundColor(Color(UIColor.systemGray))
            .aspectRatio(1, contentMode: .fit)
            .frame(
                width: rectangleSizeFraction * g.size.width,
                height: rectangleSizeFraction * g.size.height
        )
        .position(center(g))
    }

    struct BezierPath: Shape {

        var bottomLeft: CGPoint
        var topRight: CGPoint
        var actualStartCP: CGPoint
        var actualEndCP: CGPoint

        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: bottomLeft)
            path.addCurve(
                to: topRight,
                control1: actualStartCP,
                control2: actualEndCP
            )
            return path
        }

        var animatableData: AnimatablePair<AnimatablePair<CGFloat, CGFloat>, AnimatablePair<CGFloat, CGFloat>> {
            get {
                .init(
                    .init(actualStartCP.x, actualStartCP.y),
                    .init(actualEndCP.x, actualEndCP.y)
                )
            }
            set {
                actualStartCP = CGPoint(
                    x: newValue.first.first,
                    y: newValue.first.second
                )
                actualEndCP = CGPoint(
                    x: newValue.second.first,
                    y: newValue.second.second
                )
            }
        }

    }

    func bezierPath(with g: GeometryProxy) -> some View {
        BezierPath(
            bottomLeft: bottomLeft(g),
            topRight: topRight(g),
            actualStartCP: actualCP(unitStartControlPoint, g),
            actualEndCP: actualCP(unitEndControlPoint, g)
        )
            .stroke(lineWidth: self.curveLineWidth)
            .foregroundColor(Color(UIColor.systemGreen))
    }

    struct ControlLinesPath: Shape {

        var bottomLeft: CGPoint
        var topRight: CGPoint
        var actualStartCP: CGPoint
        var actualEndCP: CGPoint

        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: bottomLeft)
            path.addLine(to: actualStartCP)
            path.move(to: topRight)
            path.addLine(to: actualEndCP)
            return path
        }

        var animatableData: AnimatablePair<AnimatablePair<CGFloat, CGFloat>, AnimatablePair<CGFloat, CGFloat>> {
            get {
                .init(
                    .init(actualStartCP.x, actualStartCP.y),
                    .init(actualEndCP.x, actualEndCP.y)
                )
            }
            set {
                actualStartCP = CGPoint(
                    x: newValue.first.first,
                    y: newValue.first.second
                )
                actualEndCP = CGPoint(
                    x: newValue.second.first,
                    y: newValue.second.second
                )
            }
        }

    }

    func controlLines(with g: GeometryProxy) -> some View {
        ControlLinesPath(
            bottomLeft: bottomLeft(g),
            topRight: topRight(g),
            actualStartCP: actualCP(unitStartControlPoint, g),
            actualEndCP: actualCP(unitEndControlPoint, g)
        )
        .stroke(lineWidth: self.rectangleLineWidth)
        .foregroundColor(black)
    }

    @ViewBuilder
    func corners(with g: GeometryProxy) -> some View {
        Circle()
            .foregroundColor(black)
            .frame(width: self.innerCircleSize, height: self.innerCircleSize)
            .position(self.bottomLeft(g))
        Circle()
            .foregroundColor(black)
            .frame(width: self.innerCircleSize, height: self.innerCircleSize)
            .position(self.topRight(g))
    }

    func controlPointHandles(with g: GeometryProxy) -> some View {
        Group {
            Circle()
                .foregroundColor(Color(UIColor.systemRed))
                .frame(width: innerCircleSize, height: innerCircleSize)
                .position(actualCP(unitStartControlPoint, g))
            Circle()
                .foregroundColor(Color(UIColor.systemBlue))
                .frame(width: innerCircleSize, height: innerCircleSize)
                .position(actualCP(unitEndControlPoint, g))
            Circle()
                .stroke(lineWidth: circleLineWidth)
                .foregroundColor(Color(UIColor.systemRed))
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
    }

    func infoArea() -> some View {
        VStack {
            Text("start.x: \(unitStartControlPoint.x)")
                .foregroundColor(Color(UIColor.systemRed))
            Text("start.y: \(unitStartControlPoint.y)")
                .foregroundColor(Color(UIColor.systemRed))
                .padding(.bottom, verticalPadding)
            Text("end.x: \(unitEndControlPoint.x)")
                .foregroundColor(Color(UIColor.systemBlue))
            Text("end.y: \(unitEndControlPoint.y)")
                .foregroundColor(Color(UIColor.systemBlue))
        }
        .padding(.bottom, verticalPadding)
    }

    var dotAnimation: Animation {
        Animation.timingCurve(
            Double(unitStartControlPoint.x),
            Double(unitStartControlPoint.y),
            Double(unitEndControlPoint.x),
            Double(unitEndControlPoint.y),
            duration: animationDuration
        )
    }

    func durationStr(_ duration: Double) -> String {
        "\(Self.numberFormatter.string(for: duration)!)"
    }

    var black: Color {
        switch colorScheme {
            case .dark:
                return Color.white
            default:
                return Color.black
        }
    }

    var white: Color {
        switch colorScheme {
            case .dark:
                return Color.black
            default:
                return Color.white
        }
    }

}
