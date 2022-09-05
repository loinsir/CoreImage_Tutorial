/// Copyright (c) 2021 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import CoreImage

enum ProcessEffect {
  case builtIn
  case colorKernel
  case warpKernel
  case blendKernel
}

class ImageProcessor {
  static let shared = ImageProcessor()
  @Published var output = UIImage()
  
  let context = CIContext()
  
  private func applyBuiltInEffect(input: CIImage) {
    let noir = CIFilter(
      name: "CIPhotoEffectNoir",
      parameters: ["inputImage": input]
    )?.outputImage
    let sunGenerate = CIFilter(
      name: "CISunbeamsGenerator",
      parameters: [
        "inputStriationStrength": 1,
        "inputSunRadius": 300,
        "inputCenter": CIVector(
          x: input.extent.width - input.extent.width / 5,
          y: input.extent.height - input.extent.height / 10)
      ])?
      .outputImage
    let compositeImage = input.applyingFilter(
      "CIBlendWithMask",
      parameters: [
        kCIInputBackgroundImageKey: noir as Any,
        kCIInputMaskImageKey: sunGenerate as Any
      ])
    if let outputImage = renderAsUIImage(compositeImage) {
      output = outputImage
    }
  }
  
  private func renderAsUIImage(_ image: CIImage) -> UIImage? {
    if let cgImage = context.createCGImage(image, from: image.extent) {
      return UIImage(cgImage: cgImage)
    }
    return nil
  }
  
  func process(painting: Painting, effect: ProcessEffect) {
    guard let paintImage = UIImage(named: painting.image),
          let input = CIImage(image: paintImage)
    else {
      print("Invalid input image")
      return
    }
    
    switch effect {
    case .builtIn:
      applyBuiltInEffect(input: input)
    case .colorKernel:
      applyColorKernel(input: input)
    case .warpKernel:
      applyWarpKernel(input: input)
    default:
      print("Unsupported Effect")
    }
  }
  
  private func applyColorKernel(input: CIImage) {
    let filter = ColorFilter()
    filter.inputImage = input
    if let outputImage = filter.outputImage,
       let renderImage = renderAsUIImage(outputImage) {
      output = renderImage
    }
  }
  
  private func applyWarpKernel(input: CIImage) {
    let filter = WarpFilter()
    filter.inputImage = input
    if let outputImage = filter.outputImage,
       let renderImage = renderAsUIImage(outputImage) {
      output = renderImage
    }
  }
}
