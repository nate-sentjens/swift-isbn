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

// MARK: FormatStyle

extension ISBN {

  /// Formats an ISBN as a hyphenated ISBN-13 string using the International
  /// ISBN Agency's registration group and registrant ranges.
  ///
  /// Use the ``FormatStyle`` through the static ``Foundation/FormatStyle/isbn``
  /// accessor or by calling ``formatted()`` on an ISBN value:
  ///
  /// ```swift
  /// let isbn = ISBN("9780201896831")!
  ///
  /// isbn.formatted()            // "978-0-201-89683-1"
  /// isbn.formatted(.isbn)       // "978-0-201-89683-1"
  ///
  /// Text(isbn, format: .isbn)
  /// ```
  public struct FormatStyle: Foundation.FormatStyle, Sendable {

    // MARK: Lifecycle

    public init() { }

    // MARK: Public

    public func format(_ value: ISBN) -> String {
      value.hyphenated
    }
  }
}

// MARK: ParseableFormatStyle

extension ISBN.FormatStyle: ParseableFormatStyle {

  public var parseStrategy: ISBN.ParseStrategy {
    ISBN.ParseStrategy()
  }
}

extension FormatStyle where Self == ISBN.FormatStyle {

  /// The ISBN hyphenation format style.
  public static var isbn: Self {
    Self()
  }
}

// MARK: ParseStrategy

extension ISBN {

  /// An error thrown when a string cannot be parsed as a valid ISBN.
  public struct ParseError: Error, Sendable {

    // MARK: Public

    /// The string that failed validation.
    public let input: String

  }

  /// Parses a string into an ``ISBN``, accepting hyphenated and bare forms
  /// in both ISBN-13 and ISBN-10 notation.
  public struct ParseStrategy: Foundation.ParseStrategy, Sendable {

    // MARK: Lifecycle

    public init() { }

    // MARK: Public

    public func parse(_ value: String) throws(ParseError) -> ISBN {
      guard let isbn = ISBN(value) else {
        throw ParseError(input: value)
      }

      return isbn
    }
  }
}

// MARK: Formatted

extension ISBN {

  /// Returns the canonical hyphenated ISBN-13 string.
  ///
  /// Equivalent to `formatted(.isbn)`.
  public func formatted() -> String {
    formatted(FormatStyle())
  }

  /// Formats this ISBN using the given style.
  public func formatted<F: Foundation.FormatStyle>(
    _ style: F
  ) -> F.FormatOutput where F.FormatInput == ISBN {
    style.format(self)
  }
}
