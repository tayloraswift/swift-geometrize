import XCTest
@testable import Geometrize

final class CoreTests: XCTestCase {

    func testDifferenceFull() throws {
        let blackBitmap = Bitmap(width: 10, height: 10, color: .black)

        // Difference with itself is 0
        XCTAssertEqual(differenceFull(first: blackBitmap, second: blackBitmap), 0)

        var blackBitmapOnePixelChanged = blackBitmap
        blackBitmapOnePixelChanged[0, 0] = .white
        var blackBitmapTwoPixelsChanged = blackBitmapOnePixelChanged
        blackBitmapTwoPixelsChanged[0, 1] = .white

        // Changing two pixels means there's more difference than changing one.
        XCTAssertTrue(differenceFull(first: blackBitmap, second: blackBitmapTwoPixelsChanged) > differenceFull(first: blackBitmap, second: blackBitmapOnePixelChanged))

        // Now the same for white image
        let whiteBitmap = Bitmap(width: 10, height: 10, color: .white)

        // Difference with itself is 0
        XCTAssertEqual(differenceFull(first: whiteBitmap, second: whiteBitmap), 0)

        var whiteBitmapOnePixelChanged = whiteBitmap
        whiteBitmapOnePixelChanged[0, 0] = .black
        var whiteBitmapTwoPixelsChanged = whiteBitmapOnePixelChanged
        whiteBitmapTwoPixelsChanged[0, 1] = .black

        // Changing two pixels means there's more difference than changing one.
        XCTAssertTrue(differenceFull(first: whiteBitmap, second: whiteBitmapTwoPixelsChanged) > differenceFull(first: whiteBitmap, second: whiteBitmapOnePixelChanged))
    }

    func testDifferenceFullComparingResultWithCPlusPlus() throws {
        let firstUrl = Bundle.module.url(forResource: "differenceFull bitmap first", withExtension: "txt")!
        let bitmapFirst = Bitmap(stringLiteral: try String(contentsOf: firstUrl))
        let secondUrl = Bundle.module.url(forResource: "differenceFull bitmap second", withExtension: "txt")!
        let bitmapSecond = Bitmap(stringLiteral: try String(contentsOf: secondUrl))
        XCTAssertEqual(differenceFull(first: bitmapFirst, second: bitmapSecond), 0.170819, accuracy: 0.000001)
    }

    func testDifferencePartialComparingResultWithCPlusPlus() throws {
        let bitmapTarget = Bitmap(stringLiteral: try String(contentsOf: Bundle.module.url(forResource: "differencePartial bitmap target", withExtension: "txt")!))
        let bitmapBefore = Bitmap(stringLiteral: try String(contentsOf: Bundle.module.url(forResource: "differencePartial bitmap before", withExtension: "txt")!))
        let bitmapAfter = Bitmap(stringLiteral: try String(contentsOf: Bundle.module.url(forResource: "differencePartial bitmap after", withExtension: "txt")!))

        let scanlinesString = try String(contentsOf: Bundle.module.url(forResource: "differencePartial scanlines", withExtension: "txt")!)
        var components = scanlinesString.components(separatedBy: "),")
        for i in components.indices.dropLast() {
            components[i] += ")"
        }
        let scanlines = components.map(Scanline.init)

        XCTAssertEqual(
            differencePartial(
                target: bitmapTarget,
                before: bitmapBefore,
                after: bitmapAfter,
                score: 0.170819,
                lines: scanlines
            ),
            0.170800,
            accuracy: 0.000001
        )
    }

    func testDefaultEnergyFunctionComparingResultWithCPlusPlus() throws {
        let scanlinesString = try String(contentsOf: Bundle.module.url(forResource: "defaultEnergyFunction scanlines", withExtension: "txt")!)
        var components = scanlinesString.components(separatedBy: "),")
        for i in components.indices.dropLast() {
            components[i] += ")"
        }
        let scanlines = components.map(Scanline.init)

        let bitmapTarget = Bitmap(stringLiteral: try String(contentsOf: Bundle.module.url(forResource: "defaultEnergyFunction target bitmap", withExtension: "txt")!))
        let bitmapCurrent = Bitmap(stringLiteral: try String(contentsOf: Bundle.module.url(forResource: "defaultEnergyFunction current bitmap", withExtension: "txt")!))
        var bitmapBuffer = Bitmap(stringLiteral: try String(contentsOf: Bundle.module.url(forResource: "defaultEnergyFunction buffer bitmap", withExtension: "txt")!))
        let bitmapBufferOnExit = Bitmap(stringLiteral: try String(contentsOf: Bundle.module.url(forResource: "defaultEnergyFunction buffer bitmap on exit", withExtension: "txt")!))

        XCTAssertEqual(
            defaultEnergyFunction(
                scanlines,
                128 /* alpha */,
                bitmapTarget,
                bitmapCurrent,
                &bitmapBuffer,
                0.162824
            ),
            0.162776,
            accuracy: 0.000001
        )

        XCTAssertEqual(bitmapBuffer, bitmapBufferOnExit)
    }

    // swiftlint:disable:next function_body_length
    func testHillClimbComparingResultWithCPlusPlus() throws {
        let randomNumbersString = try String(contentsOf: Bundle.module.url(forResource: "hillClimb randomRange", withExtension: "txt")!)
        let lines = randomNumbersString.components(separatedBy: .newlines)
        var counter = 0
        func randomRangeFromFile(min: Int, max: Int) -> Int {
            defer { counter += 1 }
            let line = lines[counter]
            let scanner = Scanner(string: line)
            scanner.charactersToBeSkipped = .whitespacesAndNewlines
            guard
                let random = scanner.scanInt(),
                scanner.scanString("(min:") != nil,
                let theMin = scanner.scanInt(),
                scanner.scanString(",max:") != nil,
                let theMax = scanner.scanInt(),
                min == theMin, max == theMax
            else {
                fatalError()
            }
            print("randomRange(\(min),\(max)) returns \(random)")
            return random
        }
        randomRangeImplementationReference = randomRangeFromFile

        let bitmapTarget = Bitmap(stringLiteral: try String(contentsOf: Bundle.module.url(forResource: "hillClimb target bitmap", withExtension: "txt")!))
        let bitmapCurrent = Bitmap(stringLiteral: try String(contentsOf: Bundle.module.url(forResource: "hillClimb current bitmap", withExtension: "txt")!))
        var bitmapBuffer = Bitmap(stringLiteral: try String(contentsOf: Bundle.module.url(forResource: "hillClimb buffer bitmap", withExtension: "txt")!))
        let bitmapBufferOnExit = Bitmap(stringLiteral: try String(contentsOf: Bundle.module.url(forResource: "hillClimb buffer bitmap on exit", withExtension: "txt")!))

        let canvasBoundsProvider = { Bounds(xMin: 0, xMax: bitmapTarget.width, yMin: 0, yMax: bitmapTarget.height) }

        let rectangle = Rectangle(canvasBoundsProvider: canvasBoundsProvider, x1: 281, y1: 193, x2: 309, y2: 225)
        // rectangle.setupImplementation = { r in
        //     r.setup(xMin: 0, yMin: 0, xMax: bitmapTarget.width, yMax: bitmapTarget.height)
        // }
        // rectangle.mutateImplementation = { r in
        //     r.mutate(xMin: 0, yMin: 0, xMax: bitmapTarget.width, yMax: bitmapTarget.height)
        // }
        // rectangle.rasterizeImplementation = { r in
        //     rectangle.rasterize(xMin: 0, yMin: 0, xMax: bitmapTarget.width, yMax: bitmapTarget.height)
        // }
        let state = State(score: 0.169823, alpha: 128, shape: rectangle)

        // hillClimb return state State(score: 0.162824, alpha: 128, shape: Rectangle(x1=272,y1=113,x2=355,y2=237))

        let rectangleOnExit = Rectangle(canvasBoundsProvider: canvasBoundsProvider, x1: 272, y1: 113, x2: 355, y2: 237)
        // rectangleOnExit.setupImplementation = { r in
        //     r.setup(xMin: 0, yMin: 0, xMax: bitmapTarget.width, yMax: bitmapTarget.height)
        // }
        // rectangleOnExit.mutateImplementation = { r in
        //     r.mutate(xMin: 0, yMin: 0, xMax: bitmapTarget.width, yMax: bitmapTarget.height)
        // }
        // rectangleOnExit.rasterizeImplementation = { r in
        //     r.rasterize(xMin: 0, yMin: 0, xMax: bitmapTarget.width, yMax: bitmapTarget.height)
        // }
        let stateOnExitSample = State(score: 0.162824, alpha: 128, shape: rectangleOnExit)

        let stateOnExit = hillClimb(
            state: state,
            maxAge: 100,
            target: bitmapTarget,
            current: bitmapCurrent,
            buffer: &bitmapBuffer,
            lastScore: 0.170819,
            energyFunction: defaultEnergyFunction
        )

        XCTAssertEqual(stateOnExit.score, stateOnExitSample.score, accuracy: 0.000001)
        XCTAssertEqual(stateOnExit.alpha, stateOnExitSample.alpha)
        XCTAssertTrue(stateOnExit.shape == stateOnExitSample.shape)

        XCTAssertEqual(bitmapBuffer, bitmapBufferOnExit)
    }

}
