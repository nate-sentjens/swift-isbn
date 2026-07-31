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

// MARK: TenDigitForm

extension ISBN {

  /// The ISBN-10 representation of an ISBN, available only for
  /// 978-prefixed registrations.
  ///
  /// Access the bare digit string via ``digits``, or the canonical
  /// hyphenated form via ``hyphenated``:
  ///
  /// ```swift
  /// let isbn = ISBN("9780201896831")!
  /// isbn.isbn10?.digits      // "0201896834"
  /// isbn.isbn10?.hyphenated  // "0-201-89683-4"
  /// String(isbn.isbn10!)     // "0201896834"
  /// ```
  public struct TenDigitForm: Hashable, Sendable, CustomStringConvertible {

    // MARK: Public

    /// The bare 10-character ISBN-10 string (e.g., "0201896834").
    public let digits: String

    /// The canonical hyphenated ISBN-10 string (e.g., "0-201-89683-4").
    ///
    /// When the registration group or registrant range is not in the
    /// embedded range table, falls back to the bare digit string.
    public let hyphenated: String

    public var description: String { digits }

  }
}

// MARK: ISBN-10

extension ISBN {

  /// The ISBN-10 representation, or `nil` for 979-prefixed registrations
  /// which have no ISBN-10 form.
  ///
  /// ```swift
  /// let isbn = ISBN("9780201896831")!
  /// isbn.isbn10?.digits      // "0201896834"
  /// isbn.isbn10?.hyphenated  // "0-201-89683-4"
  /// ```
  public var isbn10: TenDigitForm? {
    guard digits.hasPrefix(GS1Prefix.isbn10Compatible) else {
      return nil
    }

    let payload = digits.dropFirst(3).dropLast()
    let remainder = (11 - Checksum.weightedISBN10Sum(ofPayload: payload) % 11) % 11
    let checkCharacter = remainder == 10 ? "X" : String(remainder)
    let isbn10Digits = payload + checkCharacter

    let hyphenated: String

    if let components {
      let groupDigits = String(components.registrationGroup.prefix.dropFirst(4))

      hyphenated = [groupDigits, components.registrant, components.publication, checkCharacter]
        .joined(separator: "-")
    } else {
      hyphenated = String(isbn10Digits)
    }

    return TenDigitForm(digits: String(isbn10Digits), hyphenated: hyphenated)
  }

  /// The legacy ISBN-10 serialization, or `nil` for 979-prefixed registrations, which have no ISBN-10 form.
  ///
  /// - Complexity: O(1) — recomputes one mod-11 check digit.
  @available(*, deprecated, message: "Use isbn10?.digits instead.")
  public var isbn10String: String? {
    isbn10?.digits
  }
}
