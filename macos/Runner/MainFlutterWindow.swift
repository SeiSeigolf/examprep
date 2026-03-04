import Cocoa
import FlutterMacOS
import Quartz
import Vision

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)
    configureVisionOcrChannel(messenger: flutterViewController.engine.binaryMessenger)

    super.awakeFromNib()
  }

  private func configureVisionOcrChannel(messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(
      name: "exam_os/vision_ocr",
      binaryMessenger: messenger
    )

    channel.setMethodCallHandler { call, result in
      guard call.method == "ocrPdf" else {
        result(FlutterMethodNotImplemented)
        return
      }
      guard
        let args = call.arguments as? [String: Any],
        let pdfPath = args["pdfPath"] as? String
      else {
        result(
          FlutterError(
            code: "invalid_args",
            message: "pdfPath is required",
            details: nil
          )
        )
        return
      }

      do {
        let output = try Self.ocrPdf(path: pdfPath)
        result(output)
      } catch {
        result(
          FlutterError(
            code: "ocr_failed",
            message: error.localizedDescription,
            details: nil
          )
        )
      }
    }
  }

  private static func ocrPdf(path: String) throws -> [String: Any] {
    let url = URL(fileURLWithPath: path)
    guard let doc = CGPDFDocument(url as CFURL) else {
      throw NSError(domain: "OCR", code: 1, userInfo: [NSLocalizedDescriptionKey: "Cannot open PDF"])
    }

    var pageTexts: [String] = []
    var confidences: [Double] = []

    let pageCount = doc.numberOfPages
    for index in 1...pageCount {
      guard let page = doc.page(at: index) else {
        pageTexts.append("")
        confidences.append(0)
        continue
      }

      guard let cgImage = renderPageToImage(page: page) else {
        pageTexts.append("")
        confidences.append(0)
        continue
      }

      let (text, conf) = try recognizeText(cgImage: cgImage)
      pageTexts.append(text)
      confidences.append(conf)
    }

    return [
      "pageTexts": pageTexts,
      "confidences": confidences
    ]
  }

  private static func renderPageToImage(page: CGPDFPage) -> CGImage? {
    let mediaBox = page.getBoxRect(.mediaBox)
    let scale: CGFloat = 2.0
    let width = max(1, Int(mediaBox.width * scale))
    let height = max(1, Int(mediaBox.height * scale))
    let colorSpace = CGColorSpaceCreateDeviceRGB()

    guard
      let context = CGContext(
        data: nil,
        width: width,
        height: height,
        bitsPerComponent: 8,
        bytesPerRow: 0,
        space: colorSpace,
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
      )
    else {
      return nil
    }

    context.setFillColor(NSColor.white.cgColor)
    context.fill(CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height)))
    context.saveGState()
    context.translateBy(x: 0, y: CGFloat(height))
    context.scaleBy(x: scale, y: -scale)
    context.drawPDFPage(page)
    context.restoreGState()
    return context.makeImage()
  }

  private static func recognizeText(cgImage: CGImage) throws -> (String, Double) {
    let request = VNRecognizeTextRequest()
    request.recognitionLevel = .accurate
    request.usesLanguageCorrection = true
    request.recognitionLanguages = ["ja-JP", "en-US"]

    let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
    try handler.perform([request])

    let observations = request.results ?? []
    if observations.isEmpty {
      return ("", 0)
    }

    var lines: [String] = []
    var confidenceSum: Double = 0
    var confidenceCount: Int = 0
    for observation in observations {
      guard let top = observation.topCandidates(1).first else { continue }
      lines.append(top.string)
      confidenceSum += Double(top.confidence)
      confidenceCount += 1
    }

    let avgConfidence = confidenceCount > 0 ? confidenceSum / Double(confidenceCount) : 0
    return (lines.joined(separator: "\n"), avgConfidence)
  }
}
