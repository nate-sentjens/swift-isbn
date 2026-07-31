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

// MARK: Corrections

extension ISBN {

  /// Suggests likely corrections for an invalid ISBN string.
  ///
  /// Attempts single-digit substitutions and adjacent-digit transpositions
  /// to find valid ISBNs within one edit of the input. Returns an empty
  /// array when the input is already valid, has the wrong length, or no
  /// single correction produces a valid ISBN.
  ///
  /// ```swift
  /// ISBN.corrections(for: "9780201896830")
  /// // [ISBN("9780201896831")!] — check digit should be 1
  ///
  /// ISBN.corrections(for: "9780210896831")
  /// // [ISBN("9780201896831")!] — transposed digits
  /// ```
  public static func corrections(for string: String) -> [ISBN] {
    let normalized = Self.normalized(string)

    guard normalized.count == 10 || normalized.count == 13 else {
      return []
    }

    guard ISBN(normalized) == nil else {
      return []
    }

    var candidates = Set<ISBN>()
    var characters = Array(normalized)

    let replacements: [Character] = normalized.count == 10
      ? ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "X"]
      : ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]

    for position in characters.indices {
      let original = characters[position]

      for replacement in replacements {
        if replacement == original { continue }
        if normalized.count == 10, replacement == "X", position != 9 { continue }

        characters[position] = replacement

        if let isbn = ISBN(String(characters)) {
          candidates.insert(isbn)
        }

        characters[position] = original
      }
    }

    for position in 0..<(characters.count - 1) {
      if characters[position] == characters[position + 1] { continue }

      characters.swapAt(position, position + 1)

      if let isbn = ISBN(String(characters)) {
        candidates.insert(isbn)
      }

      characters.swapAt(position, position + 1)
    }

    return candidates.sorted { $0.digits < $1.digits }
  }
}
