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

import ISBNKit
import Testing

// MARK: - CorrectionsTests

@Suite
struct CorrectionsTests {

  @Test
  func correctsCheckDigit() {
    let corrections = ISBN.corrections(for: "9780201896830")

    #expect(corrections.contains(ISBN("9780201896831")!))
  }

  @Test
  func correctsTransposition() {
    let corrections = ISBN.corrections(for: "9780210896831")

    #expect(corrections.contains(ISBN("9780201896831")!))
  }

  @Test
  func alreadyValidReturnsEmpty() {
    let corrections = ISBN.corrections(for: "9780201896831")

    #expect(corrections.isEmpty)
  }

  @Test
  func wrongLengthReturnsEmpty() {
    let corrections = ISBN.corrections(for: "978020189683")

    #expect(corrections.isEmpty)
  }

  @Test
  func correctsISBN10CheckDigit() {
    let corrections = ISBN.corrections(for: "0201896835")

    #expect(corrections.contains(ISBN("9780201896831")!))
  }

  @Test
  func correctsISBN10WithX() {
    let corrections = ISBN.corrections(for: "0439420891")

    #expect(corrections.contains(ISBN("043942089X")!))
  }

  @Test
  func correctsInvalidCharacterBySubstitution() {
    let corrections = ISBN.corrections(for: "978020189683X")

    #expect(corrections.contains(ISBN("9780201896831")!))
  }

  @Test
  func resultsAreSorted() {
    let corrections = ISBN.corrections(for: "9780201896830")

    #expect(corrections == corrections.sorted { String($0) < String($1) })
  }

  @Test
  func normalizesHyphenatedInput() {
    let corrections = ISBN.corrections(for: "978-0-201-89683-0")

    #expect(corrections.contains(ISBN("9780201896831")!))
  }

  @Test
  func multipleCorrectionsForInteriorDigitCorruption() {
    let corrections = ISBN.corrections(for: "9780301896831")

    #expect(corrections.count > 1)
    #expect(corrections.contains(ISBN("9780201896831")!))
    #expect(corrections.contains(ISBN("9780301896830")!))
  }
}
