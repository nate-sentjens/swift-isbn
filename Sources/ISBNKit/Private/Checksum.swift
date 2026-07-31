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

// MARK: - Checksum

enum Checksum {

  // MARK: Internal

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

  /// Returns the weighted sum of a nine-digit ISBN-10 payload (weights 10 down
  /// to 2), from which the check digit is derived.
  static func weightedISBN10Sum(ofPayload payload: some StringProtocol) -> Int {
    payload
      .enumerated()
      .reduce(into: 0) { partial, element in
        partial += (element.element.wholeNumberValue ?? 0) * (10 - element.offset)
      }
  }
}
