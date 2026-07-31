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

import RegexBuilder

// MARK: ISBNRegexComponent

/// A regex component that matches and validates ISBN-10 or ISBN-13 strings
/// in free text, with or without hyphens and spaces.
///
/// ```swift
/// let text = "See ISBN 978-0-201-89683-1 and 0201896834."
/// for match in text.matches(of: ISBN.regex) {
///   print(match.output)  // ISBN values
/// }
/// ```
///
/// The component consumes the longest valid ISBN at each position,
/// preferring ISBN-13 over ISBN-10 when both could match. Only
/// checksum-validated ISBNs are returned.
@available(iOS 16, macOS 13, tvOS 16, watchOS 9, *)
public struct ISBNRegexComponent: CustomConsumingRegexComponent {

  // MARK: Public

  public typealias RegexOutput = ISBN

  public func consuming(
    _ input: String,
    startingAt index: String.Index,
    in bounds: Range<String.Index>
  ) throws -> (upperBound: String.Index, output: ISBN)? {
    var current = index
    var significant: [(Character, String.Index)] = []

    while current < bounds.upperBound, significant.count < 13 {
      let char = input[current]

      if char.isASCII, char.isNumber {
        significant.append((char, current))
      } else if (char == "X" || char == "x"), significant.count == 9 {
        significant.append((char, current))
      } else if char == "-" || char == " " {
        current = input.index(after: current)
        continue
      } else {
        break
      }

      current = input.index(after: current)
    }

    if significant.count == 13 {
      let candidate = String(significant.map(\.0))

      if let isbn = ISBN(candidate) {
        return (input.index(after: significant[12].1), isbn)
      }
    }

    if significant.count >= 10 {
      let candidate = String(significant.prefix(10).map(\.0))

      if let isbn = ISBN(candidate) {
        return (input.index(after: significant[9].1), isbn)
      }
    }

    return nil
  }
}

// MARK: ISBN Regex

@available(iOS 16, macOS 13, tvOS 16, watchOS 9, *)
extension ISBN {

  /// A regex component that matches validated ISBNs in free text.
  ///
  /// Matches both ISBN-10 and ISBN-13, with or without hyphens and
  /// spaces. Only strings that pass checksum validation are matched.
  ///
  /// ```swift
  /// let matches = text.matches(of: ISBN.regex)
  /// let isbns = matches.map(\.output)
  /// ```
  public static var regex: ISBNRegexComponent {
    ISBNRegexComponent()
  }
}
