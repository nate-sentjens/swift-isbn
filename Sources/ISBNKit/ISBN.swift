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

// MARK: - ISBN

/// A checksum-validated International Standard Book Number, held in its
/// canonical 13-digit form.
///
/// Under ISO 2108, the 2007 transition from ten to thirteen digits did not
/// create a second identifier — it re-serialized the existing one. An
/// ISBN-10 and its 978-prefixed ISBN-13 denote the *same registration*:
/// same registrant, same publication, same nine-digit payload. `ISBN`
/// therefore models the registration, not the serialization: parsing
/// accepts either written form, identity and equality are defined over the
/// canonical 13 digits, and two forms of the same registration compare
/// equal.
///
/// ```swift
/// ISBN("0201896834") == ISBN("9780201896831")   // true — same book
/// ```
///
/// The legacy form is recoverable via ``isbn10`` where one exists.
/// 979-prefixed registrations (issued since the 978 space began
/// exhausting; common for self-published print books) have *no* ISBN-10
/// form — that partiality is confined to a single optional rather than
/// leaking into signatures that carry the identifier.
///
/// `Codable` uses a single-value container: an `ISBN` encodes as the bare
/// canonical string (like `UUID` and `URL`), and decoding routes through
/// the same validating parser as ``init(_:)``&mdash;so the invariant below
/// holds for decoded values too, and legacy ISBN-10 strings in external
/// JSON normalize on decode.
public struct ISBN: Hashable, Sendable {

  // MARK: Lifecycle

  public init?(_ string: String) {
    guard case .success(let isbn) = Self.validate(string) else {
      return nil
    }

    self = isbn
  }

  init(uncheckedDigits: String) {
    digits = uncheckedDigits
  }

  // MARK: Internal

  static func normalized(_ string: String) -> String {
    string
      .filter { $0 != "-" && $0 != " " }
      .uppercased()
  }

  /// The canonical ISBN-13 digits, without separators.
  let digits: String

}

// MARK: Codable

extension ISBN: Codable {

  /// Creates an ISBN by decoding a bare string through the validating parser.
  ///
  /// - Throws: `DecodingError.dataCorrupted` when the string is not a
  ///   valid ISBN in either written form.
  public init(from decoder: any Decoder) throws {
    let container = try decoder.singleValueContainer()
    let candidate = try container.decode(String.self)

    guard let isbn = ISBN(candidate) else {
      throw DecodingError.dataCorruptedError(
        in: container,
        debugDescription: "Not a valid ISBN: \(candidate)")
    }

    self = isbn
  }

  /// Encodes the canonical 13-digit string as a single value.
  public func encode(to encoder: any Encoder) throws {
    var container = encoder.singleValueContainer()

    try container.encode(digits)
  }
}

// MARK: CodingKeyRepresentable

extension ISBN: CodingKeyRepresentable {

  /// Creates an ISBN from a dictionary coding key, validating as usual.
  public init?<Key: CodingKey>(codingKey: Key) {
    self.init(codingKey.stringValue)
  }

  /// A coding key carrying the canonical digits, so `[ISBN: Value]`
  /// dictionaries encode as keyed objects rather than flat
  /// key-value arrays.
  public var codingKey: any CodingKey {
    DigitsCodingKey(stringValue: digits)
  }
}

// MARK: Comparable

extension ISBN: Comparable {

  public static func <(lhs: ISBN, rhs: ISBN) -> Bool {
    lhs.digits < rhs.digits
  }
}

// MARK: LosslessStringConvertible

extension ISBN: LosslessStringConvertible {

  public var description: String {
    digits
  }
}

// MARK: Identifiable

extension ISBN: Identifiable {

  public var id: Self { self }
}

// MARK: CustomDebugStringConvertible

extension ISBN: CustomDebugStringConvertible {

  public var debugDescription: String {
    "ISBN(\(hyphenated))"
  }
}

// MARK: - DigitsCodingKey

private struct DigitsCodingKey: CodingKey {

  // MARK: Lifecycle

  init(stringValue: String) {
    self.stringValue = stringValue
  }

  init?(intValue: Int) {
    nil
  }

  // MARK: Internal

  let stringValue: String

  var intValue: Int? {
    nil
  }
}

// MARK: Character

extension Character {

  var isASCIIDigit: Bool {
    isASCII && isNumber
  }
}
