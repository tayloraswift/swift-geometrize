import Foundation

public final class Ellipse: Shape {
    
    var x: Double // x-coordinate.
    var y: Double // y-coordinate.
    var rx: Double // x-radius.
    var ry: Double // y-radius.

    public init() {
        x = 0.0
        y = 0.0
        rx = 0.0
        ry = 0.0
    }
    
    public init(x: Double, y: Double, rx: Double, ry: Double) {
        self.x = x
        self.y = y
        self.rx = rx
        self.ry = ry
    }
    
    public func copy() -> Ellipse {
        Ellipse(x: x, y: y, rx: rx, ry: ry)
    }

    public func setup(xMin: Int, yMin: Int, xMax: Int, yMax: Int) {
        x = Double(randomRange(min: xMin, max: xMax - 1))
        y = Double(randomRange(min: yMin, max: yMax - 1))
        rx = Double(randomRange(min: 1, max: 32))
        ry = Double(randomRange(min: 1, max: 32))
    }

    public func mutate(xMin: Int, yMin: Int, xMax: Int, yMax: Int) {
        switch randomRange(min: 0, max: 2) {
        case 0:
            x = Double((Int(x) + randomRange(min: -16, max: 16)).clamped(to: xMin...xMax - 1))
            y = Double((Int(y) + randomRange(min: -16, max: 16)).clamped(to: yMin...yMax - 1))
        case 1:
            rx = Double((Int(rx) + randomRange(min: -16, max: 16)).clamped(to: 1...xMax - 1)) // clamp incorect
        case 2:
            ry = Double((Int(ry) + randomRange(min: -16, max: 16)).clamped(to: 1...yMax - 1)) // clamp incorect
        default:
            fatalError()
        }
    }

    public func rasterize(xMin: Int, yMin: Int, xMax: Int, yMax: Int) -> [Scanline] {
        var lines: [Scanline] = []
        let aspect = rx / ry
        for dy in 0..<Int(ry) {
            let y1 = Int(y) - dy
            let y2 = Int(y) + dy
            if ((y1 < yMin || y1 >= yMax) && (y2 < yMin || y2 >= yMax)) {
                continue
            }
            let v = sqrt(ry * ry - Double(dy * dy)) * aspect
            var x1 = Int(x - v)
            if x1 < xMin {
                x1 = xMin
            }
            var x2 = Int(x + v)
            if x2 >= xMax {
                x2 = xMax - 1
            }
            if let line = Scanline(y: y1, x1: x1, x2: x2).trimmed(minX: xMin, minY: yMin, maxX: xMax, maxY: yMax),
               y1 >= xMin && y1 < yMax || y2 >= yMin && y2 < yMax && dy > 0
            {
                lines.append(line)
            }
        }
        return lines
    }

    public func type() -> ShapeType {
        .ellipse
    }
    
    public var description: String {
        "Ellipse(x=\(x), y=\(y), rx=\(rx), ry=\(ry))"
    }

}