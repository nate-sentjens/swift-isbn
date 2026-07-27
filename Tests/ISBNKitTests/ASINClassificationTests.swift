// MIT License
//
// Copyright (c) 2026 Nate Sentjens
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Testing

@testable
import ISBNKit

// MARK: - ASINClassificationTests

@Suite
struct ASINClassificationTests {

  @Test
  func printBookASINClassifies() {
    let expected = ISBN("9781400033416")!
    #expect(ASINClassification(of: "1400033411") == .printBook(expected))
  }

  @Test
  func kindleASINFallsThrough() {
    #expect(ASINClassification(of: "B0C1XYZ123") == .kindleOrOther(asin: "B0C1XYZ123"))
  }

  @Test
  func checksumInvalidTenCharTokenFallsThrough() {
    #expect(ASINClassification(of: "1400033412") == .kindleOrOther(asin: "1400033412"))
  }

  @Test
  func thirteenDigitStringIsNotAnASIN() {
    // ASINs are exactly 10 characters; a pasted ISBN-13 must not classify.
    #expect(
      ASINClassification(of: "9781400033416") == .kindleOrOther(asin: "9781400033416"))
  }
}
