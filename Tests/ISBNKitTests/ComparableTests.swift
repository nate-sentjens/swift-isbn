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

// MARK: - ComparableTests

@Suite
struct ComparableTests {

  @Test
  func smallerDigitsPrecedeLarger() throws {
    let a = try #require(ISBN("9780060112080"))
    let b = try #require(ISBN("9780201896831"))

    #expect(a < b)
    #expect(!(b < a))
  }

  @Test
  func equalISBNsAreNotLessThan() throws {
    let a = try #require(ISBN("9780201896831"))
    let b = try #require(ISBN("0201896834"))

    #expect(!(a < b))
    #expect(!(b < a))
  }

  @Test
  func isbn978PrecedesISBN979() throws {
    let a = try #require(ISBN("9780201896831"))
    let b = try #require(ISBN("9798601570022"))

    #expect(a < b)
  }

  @Test
  func sortedArrayMatchesDigitOrder() throws {
    let isbns = try [
      #require(ISBN("9798601570022")),
      #require(ISBN("9780060112080")),
      #require(ISBN("9783161484100")),
      #require(ISBN("9780201896831")),
    ]

    let sorted = isbns.sorted()

    #expect(sorted.map(String.init) == [
      "9780060112080",
      "9780201896831",
      "9783161484100",
      "9798601570022",
    ])
  }

  @Test
  func isbn10InputSortsByCanonicalForm() throws {
    let fromISBN10 = try #require(ISBN("0201896834"))
    let isbn13 = try #require(ISBN("9783161484100"))

    #expect(fromISBN10 < isbn13)
  }
}
