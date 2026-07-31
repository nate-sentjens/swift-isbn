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

// MARK: - KnownISBN

/// A corpus entry pairing an ISBN string with a readable label for
/// parameterized test output.
struct KnownISBN: Sendable, CustomTestStringConvertible {

  // MARK: Internal

  let input: String
  let label: String

  var testDescription: String {
    label
  }
}

// MARK: - Corpora

private let isbn978Corpus: [KnownISBN] = [
  .init(input: "9780201896831", label: "English 978-0, registrant 201"),
  .init(input: "9780060112080", label: "English 978-0, registrant 06"),
  .init(input: "9780306406157", label: "English 978-0, registrant 306"),
  .init(input: "9780201633610", label: "English 978-0, registrant 201 (alt title)"),
  .init(input: "9781400033416", label: "English 978-1"),
  .init(input: "9783161484100", label: "German 978-3"),
  .init(input: "9784101092058", label: "Japan 978-4"),
  .init(input: "9786555550559", label: "Brazil 978-65"),
]

private let isbn979Corpus: [KnownISBN] = [
  .init(input: "9798601570022", label: "US 979-8"),
]

private let isbn10Corpus: [KnownISBN] = [
  .init(input: "0201896834", label: "ISBN-10 check=4"),
  .init(input: "1400033411", label: "ISBN-10 check=1"),
  .init(input: "043942089X", label: "ISBN-10 check=X"),
  .init(input: "0060112085", label: "ISBN-10 check=5"),
  .init(input: "0306406152", label: "ISBN-10 check=2"),
]

private let fullCorpus = isbn978Corpus + isbn979Corpus + isbn10Corpus

// MARK: - CanonicalFormInvariants

@Suite("Canonical Form")
struct CanonicalFormInvariants {

  @Test("Always exactly 13 ASCII digits", arguments: fullCorpus)
  func digitsAre13ASCIIDigits(_ known: KnownISBN) throws {
    let isbn = try #require(ISBN(known.input))
    let digits = String(isbn)

    #expect(digits.count == 13)
    #expect(digits.allSatisfy { $0.isASCII && $0.isNumber })
  }

  @Test("Always starts with 978 or 979", arguments: fullCorpus)
  func startsWithBooklandPrefix(_ known: KnownISBN) throws {
    let isbn = try #require(ISBN(known.input))
    let digits = String(isbn)

    #expect(digits.hasPrefix("978") || digits.hasPrefix("979"))
  }

  @Test("LosslessStringConvertible round-trips", arguments: fullCorpus)
  func losslessRoundTrip(_ known: KnownISBN) throws {
    let isbn = try #require(ISBN(known.input))

    #expect(ISBN(String(isbn)) == isbn)
  }

  @Test("Codable round-trips through JSON", arguments: fullCorpus)
  func codableRoundTrip(_ known: KnownISBN) throws {
    let isbn = try #require(ISBN(known.input))
    let data = try JSONEncoder().encode(isbn)

    #expect(try JSONDecoder().decode(ISBN.self, from: data) == isbn)
  }

  @Test("JSON-encoded form is the bare canonical string", arguments: fullCorpus)
  func codableEncodesAsBareDigits(_ known: KnownISBN) throws {
    let isbn = try #require(ISBN(known.input))
    let json = try JSONEncoder().encode(isbn)
    let raw = String(decoding: json, as: UTF8.self)

    #expect(raw == "\"\(String(isbn))\"")
  }
}

// MARK: - HyphenationInvariants

@Suite("Hyphenation Invariants")
struct HyphenationInvariants {

  @Test("Stripping hyphens yields canonical digits", arguments: fullCorpus)
  func strippedHyphenatedEqualsDigits(_ known: KnownISBN) throws {
    let isbn = try #require(ISBN(known.input))
    let stripped = isbn.hyphenated.filter { $0 != "-" }

    #expect(stripped == String(isbn))
  }

  @Test("Parsing hyphenated output is idempotent", arguments: fullCorpus)
  func reparsingHyphenatedIsIdempotent(_ known: KnownISBN) throws {
    let isbn = try #require(ISBN(known.input))
    let reparsed = try #require(ISBN(isbn.hyphenated))

    #expect(reparsed == isbn)
    #expect(reparsed.hyphenated == isbn.hyphenated)
  }

  @Test("Has exactly four hyphens (fully decomposed) or zero (fallback)", arguments: fullCorpus)
  func fourOrZeroHyphens(_ known: KnownISBN) throws {
    let isbn = try #require(ISBN(known.input))
    let count = isbn.hyphenated.filter { $0 == "-" }.count

    #expect(count == 4 || count == 0)
  }

  @Test("formatted() matches hyphenated", arguments: fullCorpus)
  func formattedMatchesHyphenated(_ known: KnownISBN) throws {
    let isbn = try #require(ISBN(known.input))

    #expect(isbn.formatted() == isbn.hyphenated)
  }
}

// MARK: - IdentityInvariants

@Suite("One Identifier, Two Forms")
struct IdentityInvariants {

  @Test("ISBN-10 and ISBN-13 of the same book are equal", arguments: isbn10Corpus)
  func twoFormsAreEqual(_ known: KnownISBN) throws {
    let fromLegacy = try #require(ISBN(known.input))
    let fromCanonical = try #require(ISBN(String(fromLegacy)))

    #expect(fromLegacy == fromCanonical)
    #expect(fromLegacy.hashValue == fromCanonical.hashValue)
  }

  @Test("isbn10.digits round-trips back to the same ISBN", arguments: isbn978Corpus)
  func isbn10DigitsRoundTrip(_ known: KnownISBN) throws {
    let isbn = try #require(ISBN(known.input))
    let form = try #require(isbn.isbn10)

    #expect(ISBN(form.digits) == isbn)
  }

  @Test("isbn10.hyphenated round-trips back to the same ISBN", arguments: isbn978Corpus)
  func isbn10HyphenatedRoundTrip(_ known: KnownISBN) throws {
    let isbn = try #require(ISBN(known.input))
    let form = try #require(isbn.isbn10)

    #expect(ISBN(form.hyphenated) == isbn)
  }

  @Test("979 registrations have no ISBN-10 form", arguments: isbn979Corpus)
  func isbn979HasNoISBN10(_ known: KnownISBN) throws {
    let isbn = try #require(ISBN(known.input))

    #expect(isbn.isbn10 == nil)
  }

  @Test(
    "Two ISBNs from the same registrant share a publisher prefix",
    arguments: zip(
      [KnownISBN(input: "9780201896831", label: "Addison-Wesley A"), KnownISBN(input: "9780060112080", label: "Harper A")],
      [KnownISBN(input: "9780201633610", label: "Addison-Wesley B"), KnownISBN(input: "9780061120084", label: "Harper B")]))
  func sameRegistrantSharesPrefix(_ a: KnownISBN, _ b: KnownISBN) throws {
    let isbnA = try #require(ISBN(a.input))
    let isbnB = try #require(ISBN(b.input))

    #expect(isbnA.publisherPrefix == isbnB.publisherPrefix)
  }
}

// MARK: - ComponentsInvariants

@Suite("Components Consistency")
struct ComponentsInvariants {

  @Test("Components reconstruct the hyphenated form", arguments: isbn978Corpus + isbn979Corpus)
  func componentsReconstructHyphenated(_ known: KnownISBN) throws {
    let isbn = try #require(ISBN(known.input))
    let c = try #require(isbn.components)
    let checkDigit = String(String(isbn).suffix(1))

    let reconstructed = [c.registrationGroup.prefix, c.registrant, c.publication, checkDigit]
      .joined(separator: "-")

    #expect(reconstructed == isbn.hyphenated)
  }

  @Test("Registration group is never nil when components decompose", arguments: fullCorpus)
  func groupPresentWhenComponentsPresent(_ known: KnownISBN) throws {
    let isbn = try #require(ISBN(known.input))

    if isbn.components != nil {
      #expect(isbn.registrationGroup != nil)
    }
  }

  @Test("Publisher prefix matches components when both present", arguments: fullCorpus)
  func publisherPrefixMatchesComponents(_ known: KnownISBN) throws {
    let isbn = try #require(ISBN(known.input))

    guard let c = isbn.components, let prefix = isbn.publisherPrefix else { return }

    #expect(prefix.registrationGroup == c.registrationGroup)
    #expect(prefix.registrant == c.registrant)
  }

  @Test("URN is always urn:isbn: plus canonical digits", arguments: fullCorpus)
  func urnStructure(_ known: KnownISBN) throws {
    let isbn = try #require(ISBN(known.input))

    #expect(isbn.urn == "urn:isbn:\(String(isbn))")
  }
}

// MARK: - ValidationConsistency

@Suite("Validation Consistency")
struct ValidationConsistency {

  @Test("validate returns .success for all known valid ISBNs", arguments: fullCorpus)
  func validateSucceedsForValidInput(_ known: KnownISBN) throws {
    let result = ISBN.validate(known.input)

    guard case .success(let isbn) = result else {
      Issue.record("Expected .success for \(known.input), got \(result)")
      return
    }

    #expect(isbn == ISBN(known.input))
  }

  @Test(
    "validate and init? always agree",
    arguments: [
      "9780201896831", "0201896834", "043942089X", "9798601570022",
      "978-0-201-89683-1", "0-201-89683-4",
      "9780201896830", "978020189683X", "1234567890128",
      "978020189", "97802018968311", "",
      "0201896835", "hello", "978 0201 89683 1",
    ])
  func validateAndInitAgree(_ input: String) {
    let validateResult = ISBN.validate(input)
    let initResult = ISBN(input)

    switch validateResult {
    case .success(let isbn):
      #expect(initResult == isbn, "init? returned nil but validate returned .success")
    case .failure:
      #expect(initResult == nil, "init? returned non-nil but validate returned .failure")
    }
  }

  @Test(
    "validate returns .success with same ISBN regardless of input form",
    arguments: zip(
      ["0201896834", "043942089X", "1400033411"],
      ["9780201896831", "9780439420891", "9781400033416"]))
  func validateNormalizesToSameISBN(_ isbn10: String, _ isbn13: String) {
    guard
      case .success(let from10) = ISBN.validate(isbn10),
      case .success(let from13) = ISBN.validate(isbn13) else
    {
      Issue.record("Both inputs should be valid")
      return
    }

    #expect(from10 == from13)
  }
}

// MARK: - NormalizationEdgeCases

@Suite("Normalization Edge Cases")
struct NormalizationEdgeCases {

  @Test(
    "Multiple consecutive separators are stripped",
    arguments: ["978--0--201--89683--1", "978  0  201  89683  1", "978- 0- 201- 89683- 1"])
  func multipleConsecutiveSeparators(_ input: String) {
    #expect(ISBN(input) == ISBN("9780201896831"))
  }

  @Test(
    "Non-hyphen/space whitespace is NOT stripped and causes rejection",
    arguments: ["978\t0201896831", "978\n0201896831", "9780201896831\r"])
  func tabsAndNewlinesNotStripped(_ input: String) {
    #expect(ISBN(input) == nil)
  }

  @Test("Leading and trailing spaces are stripped")
  func leadingTrailingSpaces() {
    #expect(ISBN(" 9780201896831 ") == ISBN("9780201896831"))
  }

  @Test("Input is pure separators")
  func pureSeparators() {
    #expect(ISBN("---") == nil)
    #expect(ISBN("   ") == nil)
  }

  @Test("Lowercase x in ISBN-10 is normalized to uppercase")
  func lowercaseXNormalized() {
    #expect(ISBN("043942089x") == ISBN("043942089X"))
  }
}

// MARK: - CorrectionInvariants

@Suite("Correction Invariants")
struct CorrectionInvariants {

  @Test(
    "Every correction is a valid ISBN",
    arguments: ["9780201896830", "9780210896831", "978020189683X", "0201896835", "0439420891"])
  func correctionsAreAllValid(_ input: String) {
    for correction in ISBN.corrections(for: input) {
      #expect(ISBN(String(correction)) == correction)
    }
  }

  @Test(
    "Corrections are always sorted by canonical digits",
    arguments: ["9780201896830", "9780210896831", "0201896835"])
  func correctionsAreSorted(_ input: String) {
    let corrections = ISBN.corrections(for: input)
    let sorted = corrections.sorted { String($0) < String($1) }

    #expect(corrections == sorted)
  }

  @Test(
    "Correcting a valid ISBN returns empty",
    arguments: ["9780201896831", "043942089X", "9798601570022"])
  func validInputReturnsNoCorrections(_ input: String) {
    #expect(ISBN.corrections(for: input).isEmpty)
  }
}
