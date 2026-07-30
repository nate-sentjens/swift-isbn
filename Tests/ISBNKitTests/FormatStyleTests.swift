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

import Foundation
import ISBNKit
import Testing

// MARK: - Hyphenation

@Suite
struct Hyphenation {

  @Test
  func englishRegistration() throws {
    let isbn = try #require(ISBN("9780201896831"))

    #expect(isbn.hyphenated == "978-0-201-89683-1")
  }

  @Test
  func englishTwoDigitRegistrant() throws {
    let isbn = try #require(ISBN("9780060112080"))

    #expect(isbn.hyphenated == "978-0-06-011208-0")
  }

  @Test
  func germanRegistration() throws {
    let isbn = try #require(ISBN("9783161484100"))

    #expect(isbn.hyphenated == "978-3-16-148410-0")
  }

  @Test
  func japanRegistration() throws {
    let isbn = try #require(ISBN("9784101092058"))

    #expect(isbn.hyphenated == "978-4-10-109205-8")
  }

  @Test
  func brazilRegistration() throws {
    let isbn = try #require(ISBN("9786555550559"))

    #expect(isbn.hyphenated == "978-65-5555-055-9")
  }

  @Test
  func us979Registration() throws {
    let isbn = try #require(ISBN("9798601570022"))

    #expect(isbn.hyphenated == "979-8-6015-7002-2")
  }

  @Test
  func hyphenatedInputProducesSameResult() throws {
    let isbn = try #require(ISBN("978-0-306-40615-7"))

    #expect(isbn.hyphenated == "978-0-306-40615-7")
  }

  @Test
  func isbn10InputHyphenatesAsISBN13() throws {
    let isbn = try #require(ISBN("0201896834"))

    #expect(isbn.hyphenated == "978-0-201-89683-1")
  }
}

// MARK: - FormattedOutput

@Suite
struct FormattedOutput {

  @Test
  func formattedReturnsHyphenated() throws {
    let isbn = try #require(ISBN("9780201896831"))

    #expect(isbn.formatted() == "978-0-201-89683-1")
  }

  @Test
  func formattedWithStyleReturnsHyphenated() throws {
    let isbn = try #require(ISBN("9780201896831"))

    #expect(isbn.formatted(.isbn) == "978-0-201-89683-1")
  }

  @Test
  func formatStyleFormatMatchesHyphenated() throws {
    let isbn = try #require(ISBN("9780201896831"))

    #expect(ISBN.FormatStyle().format(isbn) == isbn.hyphenated)
  }
}

// MARK: - ISBNParseStrategy

@Suite
struct ISBNParseStrategy {

  @Test
  func parsesHyphenatedInput() throws {
    let isbn = try ISBN.ParseStrategy().parse("978-0-201-89683-1")

    #expect(isbn == ISBN("9780201896831"))
  }

  @Test
  func parsesBareDigits() throws {
    let isbn = try ISBN.ParseStrategy().parse("9780201896831")

    #expect(isbn == ISBN("9780201896831"))
  }

  @Test
  func parsesISBN10() throws {
    let isbn = try ISBN.ParseStrategy().parse("0201896834")

    #expect(isbn == ISBN("9780201896831"))
  }

  @Test
  func rejectsInvalidInput() {
    #expect(throws: ISBN.ParseError.self) {
      try ISBN.ParseStrategy().parse("not-an-isbn")
    }
  }

  @Test
  func parseableFormatStyleIntegration() throws {
    let isbn = try ISBN.FormatStyle().parseStrategy.parse("978-0-201-89683-1")

    #expect(isbn == ISBN("9780201896831"))
  }
}

// MARK: - StringAccess

@Suite
struct StringAccess {

  @Test
  func stringInitReturnsCanonicalDigits() throws {
    let isbn = try #require(ISBN("9780201896831"))

    #expect(String(isbn) == "9780201896831")
  }

  @Test
  func losslessRoundTrip() throws {
    let isbn = try #require(ISBN("9780201896831"))

    #expect(ISBN(String(isbn)) == isbn)
  }

  @Test
  func stringInitDistinctFromFormatted() throws {
    let isbn = try #require(ISBN("9780201896831"))

    #expect(String(isbn) != isbn.formatted())
  }
}
