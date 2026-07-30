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
/// The legacy form is recoverable via ``isbn10String`` where one exists.
/// 979-prefixed registrations (issued since the 978 space began
/// exhausting; common for self-published print books) have *no* ISBN-10
/// form — that partiality is confined to a single optional rather than
/// leaking into signatures that carry the identifier.
///
/// `Codable` uses a single-value container: an `ISBN` encodes as the bare
/// canonical string (like `UUID` and `URL`), and decoding routes through
/// the same validating parser as ``init(_:)`` — so the invariant below
/// holds for decoded values too, and legacy ISBN-10 strings in external
/// JSON normalize on decode.
public struct ISBN: Hashable, Sendable {

  // MARK: Lifecycle

  public init?(_ string: String) {
    let normalized = Self.normalized(string)

    switch normalized.count {
    case 13:
      guard
        normalized.hasPrefix("978") || normalized.hasPrefix("979"),
        normalized.allSatisfy(\.isASCIIDigit),
        Checksum.isValidEAN13(normalized)
      else {
        return nil
      }

      digits = normalized
    case 10:
      guard Checksum.isValidISBN10(normalized) else {
        return nil
      }

      let first12 = "978" + normalized.dropLast()
      digits = first12 + String(Checksum.ean13CheckDigit(forFirst12: first12))
    default:
      return nil
    }
  }

  // MARK: Public

  /// The legacy ISBN-10 serialization, or `nil` for 979-prefixed registrations, which have no ISBN-10 form.
  ///
  /// - Complexity: O(1) — recomputes one mod-11 check digit.
  public var isbn10String: String? {
    guard digits.hasPrefix("978") else {
      return nil
    }

    let payload = digits
      .dropFirst(3)
      .dropLast()

    let remainder = (11 - Checksum.weightedISBN10Sum(ofPayload: payload) % 11) % 11

    return payload + (remainder == 10 ? "X" : String(remainder))
  }

  // MARK: Internal

  /// The canonical ISBN-13 digits, without separators.
  let digits: String

  // MARK: Private

  private static func normalized(_ string: String) ->String {
    string
      .filter { $0 != "-" && $0 != " " }
      .uppercased()
  }
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

// MARK: CustomStringConvertible

extension ISBN: CustomStringConvertible {

  public var description: String {
    digits
  }
}

// MARK: - Checksum

private enum Checksum {

  // MARK: Internal

  /// Returns `true` if the 13-digit string carries a valid EAN-13 check
  /// digit (weights alternate 1, 3; total divisible by 10).
  static func isValidEAN13(_ digits: String) -> Bool {
    weightedEAN13Sum(of: digits)
      .isMultiple(of: 10)
  }

  /// Returns the EAN-13 check digit for the first 12 characters of `digits`.
  static func ean13CheckDigit(forFirst12 digits: some StringProtocol) -> Int {
    let sum = digits
      .prefix(12)
      .enumerated()
      .reduce(into: 0) { partial, element in
        let digit = element.element.wholeNumberValue ?? 0

        partial += digit * (element.offset.isMultiple(of: 2) ? 1 : 3)
      }

    return (10 - sum % 10) % 10
  }

  /// Returns whether a 10-character string is a valid ISBN-10 (weights 10 down
  /// to 2 over the payload, check character worth its face value or 10 for `X`; total
  /// divisible by 11).
  static func isValidISBN10(_ characters: String) -> Bool {
    var sum = 0

    for (offset, character) in characters.enumerated() {
      let position = offset + 1
      let contribution: Int

      if character.isASCIIDigit {
        contribution = character.wholeNumberValue ?? 0
      } else if character == "X", position == 10 {
        contribution = 10
      } else {
        return false
      }

      sum += contribution * (11 - position)
    }

    return sum.isMultiple(of: 11)
  }

  /// Returns the weighted sum of a nine-digit ISBN-10 payload (weights 10 down
  /// to 2), from which the check digit is derived.
  static func weightedISBN10Sum(ofPayload payload: some StringProtocol) -> Int {
    payload
      .enumerated()
      .reduce(into: 0) { partial, element in
        partial += (element.element.wholeNumberValue ?? 0) * (10 - element.offset)
      }
  }

  // MARK: Private

  private static func weightedEAN13Sum(of digits: String) -> Int {
    digits
      .enumerated()
      .reduce(into: 0) { partial, element in
        let digit = element.element.wholeNumberValue ?? 0

        partial += digit * (element.offset.isMultiple(of: 2) ? 1 : 3)
      }
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

  fileprivate var isASCIIDigit: Bool {
    isASCII && isNumber
  }
}
