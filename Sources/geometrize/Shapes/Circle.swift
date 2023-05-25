import Foundation

public final class Circle: Shape {
    public var canvasBoundsProvider: CanvasBoundsProvider

    public var x: Double // x-coordinate.
    public var y: Double // y-coordinate.
    public var r: Double // Radius.

    public init(canvasBoundsProvider: @escaping CanvasBoundsProvider) {
        self.canvasBoundsProvider = canvasBoundsProvider
        x = 0.0
        y = 0.0
        r = 0.0
    }

    public init(canvasBoundsProvider: @escaping CanvasBoundsProvider, x: Double, y: Double, r: Double) {
        self.canvasBoundsProvider = canvasBoundsProvider
        self.x = x
        self.y = y
        self.r = r
    }

    public func copy() -> Circle {
        Circle(canvasBoundsProvider: canvasBoundsProvider, x: x, y: y, r: r)
    }

    public func setup(xMin: Int, yMin: Int, xMax: Int, yMax: Int) {
        x = Double(randomRange(min: xMin, max: xMax))
        y = Double(randomRange(min: yMin, max: yMax))
        r = Double(randomRange(min: 1, max: 32))
    }

    public func mutate(xMin: Int, yMin: Int, xMax: Int, yMax: Int) {
        switch randomRange(min: 0, max: 1) {
        case 0:
            x = Double((Int(x) + randomRange(min: -16, max: 16)).clamped(to: xMin...xMax))
            y = Double((Int(y) + randomRange(min: -16, max: 16)).clamped(to: yMin...yMax))
        case 1:
            r = Double((Int(r) + randomRange(min: -16, max: 16)).clamped(to: 1...xMax))
        default:
            fatalError()
        }
    }

    public func rasterize(xMin: Int, yMin: Int, xMax: Int, yMax: Int) -> [Scanline] {
        var lines: [Scanline] = []
        let r = Int(r)
        let r² = r * r
        let rRange = -r...r
        for y in rRange {
            var xScan: [Int] = []
            let y² = y * y
            for x in rRange where x * x + y² <= r² {
                xScan.append(x)
            }
            guard let xScanFirst = xScan.first, let xScanLast = xScan.last else { continue }
            let fy = Int(self.y) + y
            let xRange = xMin...xMax
            let intX = Int(x)
            let x1 = (intX + xScanFirst).clamped(to: xRange)
            let x2 = (intX + xScanLast).clamped(to: xRange)
            if let line = Scanline(y: fy, x1: x1, x2: x2).trimmed(minX: xMin, minY: yMin, maxX: xMax, maxY: yMax) {
                lines.append(line)
            }
        }
        if lines.isEmpty {
            print("Warning: \(#function) produced no scanlines")
        }
        return lines
    }

    public func type() -> ShapeType {
        .circle
    }

    public var isDegenerate: Bool {
        r == 0.0
    }

    public var description: String {
        "Circle(x=\(x), y=\(y), r=\(r))"
    }

}
