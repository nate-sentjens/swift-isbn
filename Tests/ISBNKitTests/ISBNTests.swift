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

// MARK: - Parsing

@Suite
struct Parsing {

  @Test
  func acceptsISBN13Input() {
    #expect(ISBN("9781400033416") != nil)
    #expect(ISBN("978-0-306-40615-7") != nil)
  }

  @Test
  func acceptsISBN10Input() throws {
    let parsed = try #require(ISBN("1400033411"))

    #expect(String(parsed) == "9781400033416")
  }

  @Test
  func acceptsXCheckCharacter() throws {
    let parsed = try #require(ISBN("043942089X"))

    #expect(String(parsed).hasPrefix("978043942089"))
    #expect(ISBN("043942089x") == parsed)
  }

  @Test
  func accepts979Registration() {
    #expect(ISBN("9798601570022") != nil)
  }

  @Test
  func rejectsBadCheckDigits() {
    #expect(ISBN("9781400033417") == nil)
    #expect(ISBN("1400033412") == nil)
  }

  @Test
  func rejectsXInWrongPosition() {
    #expect(ISBN("04394208X9") == nil)
  }

  @Test
  func rejectsNonBooklandEAN() {
    #expect(ISBN("4006381333931") == nil)
  }

  @Test func rejectsWrongLengths() {
    #expect(ISBN("97814000334") == nil)
    #expect(ISBN("978140003341612") == nil)
  }
}

// MARK: - RegistrationIdentity

@Suite
struct RegistrationIdentity {

  @Test
  func bothFormsOfOneRegistrationAreEqual() {
    #expect(ISBN("1400033411") == ISBN("9781400033416"))
  }

  @Test
  func distinctRegistrationsAreNotEqual() {
    #expect(ISBN("9781400033416") != ISBN("9780306406157"))
  }
}

// MARK: - LegacySerialization

@Suite
struct LegacySerialization {

  @Test
  func rendersISBN10For978Registrations() throws {
    let isbn = try #require(ISBN("9780201896831"))

    #expect(isbn.isbn10String == "0201896834")
  }

  @Test
  func roundTripsXCheckCharacter() throws {
    let isbn = try #require(ISBN("043942089X"))

    #expect(isbn.isbn10String == "043942089X")
  }

  @Test
  func has979RegistrationsRenderNoISBN10() throws {
    let isbn = try #require(ISBN("9798601570022"))

    #expect(isbn.isbn10String == nil)
  }
}

// MARK: - CodableRepresentation

@Suite
struct CodableRepresentation {

  @Test
  func encodesAsBareString() throws {
    let encoded = try JSONEncoder().encode(ISBN("9781400033416")!)

    #expect(String(decoding: encoded, as: UTF8.self) == "\"9781400033416\"")
  }

  @Test
  func decodesBareString() throws {
    let decoded = try JSONDecoder().decode(ISBN.self, from: Data("\"9781400033416\"".utf8))

    #expect(String(decoded) == "9781400033416")
  }

  @Test
  func decodeNormalizesLegacyForm() throws {
    let decoded = try JSONDecoder().decode(ISBN.self, from: Data("\"1400033411\"".utf8))

    #expect(String(decoded) == "9781400033416")
  }

  @Test
  func decodeRejectsInvalidStrings() {
    #expect(throws: DecodingError.self) {
      try JSONDecoder().decode(ISBN.self, from: Data("\"9781400033417\"".utf8))
    }
  }

  @Test
  func roundTripsThroughJSON() throws {
    let original = ISBN("043942089X")!
    let decoded = try JSONDecoder().decode(ISBN.self, from: JSONEncoder().encode(original))

    #expect(decoded == original)
  }

  @Test
  func dictionaryKeysEncodeAsObjectKeys() throws {
    let shelf: [ISBN: Int] = [ISBN("9781400033416")!: 1]
    let encoded = try JSONEncoder().encode(shelf)
    let object = try JSONDecoder().decode([String: Int].self, from: encoded)

    #expect(object == ["9781400033416": 1])
  }
}
