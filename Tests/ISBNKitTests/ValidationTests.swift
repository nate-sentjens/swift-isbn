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

// MARK: - ValidationTests

@Suite
struct ValidationTests {

  @Test
  func validISBN13() {
    let result = ISBN.validate("9780201896831")

    #expect(result == .success(ISBN("9780201896831")!))
  }

  @Test
  func validISBN10() {
    let result = ISBN.validate("0201896834")

    #expect(result == .success(ISBN("9780201896831")!))
  }

  @Test
  func validHyphenatedInput() {
    let result = ISBN.validate("978-0-201-89683-1")

    #expect(result == .success(ISBN("9780201896831")!))
  }

  @Test
  func invalidCheckDigitISBN13() {
    let result = ISBN.validate("9780201896830")

    #expect(result == .failure(.invalidCheckDigit(expected: "1")))
  }

  @Test
  func invalidCheckDigitISBN10() {
    let result = ISBN.validate("0201896835")

    #expect(result == .failure(.invalidCheckDigit(expected: "4")))
  }

  @Test
  func invalidCheckDigitExpectsX() {
    let result = ISBN.validate("0439420890")

    #expect(result == .failure(.invalidCheckDigit(expected: "X")))
  }

  @Test
  func invalidLengthTooShort() {
    let result = ISBN.validate("978020189")

    #expect(result == .failure(.invalidLength(9)))
  }

  @Test
  func invalidLengthTooLong() {
    let result = ISBN.validate("97802018968311")

    #expect(result == .failure(.invalidLength(14)))
  }

  @Test
  func invalidLengthEmpty() {
    let result = ISBN.validate("")

    #expect(result == .failure(.invalidLength(0)))
  }

  @Test
  func invalidCharactersISBN13() {
    let result = ISBN.validate("978020189683X")

    #expect(result == .failure(.invalidCharacters))
  }

  @Test
  func invalidCharactersNonDigit() {
    let result = ISBN.validate("978020189683A")

    #expect(result == .failure(.invalidCharacters))
  }

  @Test
  func invalidPrefix() {
    let result = ISBN.validate("1234567890128")

    #expect(result == .failure(.invalidPrefix))
  }

  @Test
  func lowercaseXNormalized() {
    let result = ISBN.validate("043942089x")

    #expect(result == .success(ISBN("043942089X")!))
  }

  @Test
  func hyphenatedInvalidCheckDigit() {
    let result = ISBN.validate("978-0-201-89683-0")

    #expect(result == .failure(.invalidCheckDigit(expected: "1")))
  }
}
