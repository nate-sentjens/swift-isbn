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

// MARK: - TenDigitFormTests

@Suite
struct TenDigitFormTests {

  @Test
  func digitsFor978Registration() throws {
    let isbn = try #require(ISBN("9780201896831"))
    let form = try #require(isbn.isbn10)

    #expect(form.digits == "0201896834")
  }

  @Test
  func xCheckCharacter() throws {
    let isbn = try #require(ISBN("043942089X"))
    let form = try #require(isbn.isbn10)

    #expect(form.digits == "043942089X")
  }

  @Test
  func nilFor979Registration() throws {
    let isbn = try #require(ISBN("9798601570022"))

    #expect(isbn.isbn10 == nil)
  }

  @Test
  func hyphenatedEnglish() throws {
    let isbn = try #require(ISBN("9780201896831"))
    let form = try #require(isbn.isbn10)

    #expect(form.hyphenated == "0-201-89683-4")
  }

  @Test
  func hyphenatedGerman() throws {
    let isbn = try #require(ISBN("9783161484100"))
    let form = try #require(isbn.isbn10)

    #expect(form.hyphenated == "3-16-148410-X")
  }

  @Test
  func hyphenatedJapan() throws {
    let isbn = try #require(ISBN("9784101092058"))
    let form = try #require(isbn.isbn10)

    #expect(form.hyphenated == "4-10-109205-2")
  }

  @Test
  func hyphenatedBrazil() throws {
    let isbn = try #require(ISBN("9786555550559"))
    let form = try #require(isbn.isbn10)

    #expect(form.hyphenated == "65-5555-055-4")
  }

  @Test
  func hyphenatedTwoDigitRegistrant() throws {
    let isbn = try #require(ISBN("9780060112080"))
    let form = try #require(isbn.isbn10)

    #expect(form.hyphenated == "0-06-011208-5")
  }

  @Test
  func descriptionMatchesDigits() throws {
    let isbn = try #require(ISBN("9780201896831"))
    let form = try #require(isbn.isbn10)

    #expect(String(describing: form) == "0201896834")
  }

  @Test
  func equalityAcrossConstruction() throws {
    let isbn1 = try #require(ISBN("9780201896831"))
    let isbn2 = try #require(ISBN("0201896834"))

    #expect(isbn1.isbn10 == isbn2.isbn10)
  }

  @Test
  func isbn10FromISBN10Input() throws {
    let isbn = try #require(ISBN("0201896834"))
    let form = try #require(isbn.isbn10)

    #expect(form.digits == "0201896834")
    #expect(form.hyphenated == "0-201-89683-4")
  }
}
