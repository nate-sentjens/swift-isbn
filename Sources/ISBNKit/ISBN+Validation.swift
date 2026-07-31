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

// MARK: ValidationError

extension ISBN {

  /// Describes why a string failed ISBN validation.
  ///
  /// Returned as the `Failure` type of the `Result` from
  /// ``ISBN/validate(_:)``:
  ///
  /// ```swift
  /// switch ISBN.validate("9780201896830") {
  /// case .success(let isbn):
  ///   print(isbn.formatted())
  /// case .failure(.invalidCheckDigit(let expected)):
  ///   print("Check digit should be \(expected)")
  /// case .failure(.invalidLength(let count)):
  ///   print("Expected 10 or 13 characters, got \(count)")
  /// case .failure(.invalidCharacters):
  ///   print("Contains non-digit characters")
  /// case .failure(.invalidPrefix):
  ///   print("Must start with 978 or 979")
  /// }
  /// ```
  public enum ValidationError: Error, Sendable, Equatable {

    /// The normalized string is neither 10 nor 13 characters long.
    case invalidLength(Int)

    /// The string contains characters not permitted in an ISBN
    /// (digits only for ISBN-13; digits and trailing X for ISBN-10).
    case invalidCharacters

    /// The check digit does not match; `expected` is the correct value
    /// (a digit, or "X" for ISBN-10).
    case invalidCheckDigit(expected: String)

    /// A 13-digit string whose GS1 prefix is not 978 or 979.
    case invalidPrefix
  }
}

// MARK: Validation

extension ISBN {

  /// Validates a string as an ISBN and returns a diagnostic result.
  ///
  /// The input is normalized (hyphens and spaces removed, uppercased)
  /// before validation, matching the behaviour of ``init(_:)``.
  ///
  /// ```swift
  /// ISBN.validate("9780201896830")  // .failure(.invalidCheckDigit(expected: "1"))
  /// ISBN.validate("9780201896831")  // .success(ISBN("9780201896831"))
  /// ```
  public static func validate(_ string: String) -> Result<ISBN, ValidationError> {
    let normalized = Self.normalized(string)

    switch normalized.count {
    case 13:
      guard normalized.allSatisfy(\.isASCIIDigit) else {
        return .failure(.invalidCharacters)
      }

      guard normalized.hasPrefix(GS1Prefix.isbn10Compatible) || normalized.hasPrefix(GS1Prefix.isbn13Only) else {
        return .failure(.invalidPrefix)
      }

      let expected = Checksum.ean13CheckDigit(forFirst12: normalized)
      let actual = normalized.last?.wholeNumberValue

      guard actual == expected else {
        return .failure(.invalidCheckDigit(expected: String(expected)))
      }

      return .success(ISBN(uncheckedDigits: normalized))
    case 10:
      for (offset, character) in normalized.enumerated() {
        if character.isASCIIDigit { continue }
        if character == "X", offset == 9 { continue }

        return .failure(.invalidCharacters)
      }

      let payload = normalized.dropLast()
      let remainder = (11 - Checksum.weightedISBN10Sum(ofPayload: payload) % 11) % 11
      let expected = remainder == 10 ? "X" : String(remainder)
      let actual = String(normalized.last!)

      guard actual == expected else {
        return .failure(.invalidCheckDigit(expected: expected))
      }

      let first12 = GS1Prefix.isbn10Compatible + payload
      let canonicalDigits = first12 + String(Checksum.ean13CheckDigit(forFirst12: first12))

      return .success(ISBN(uncheckedDigits: canonicalDigits))
    default:
      return .failure(.invalidLength(normalized.count))
    }
  }
}
