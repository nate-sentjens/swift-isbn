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

// MARK: - ASINClassification

public enum ASINClassification: Hashable, Sendable {

  /// The ASIN is a valid ISBN-10; the book's identity is known deterministically.
  ///
  /// - Parameter isbn: The registration in canonical form.
  case printBook(ISBN)

  /// The ASIN is not an ISBN-10. It's a Kindle edition, a non-book produce,
  /// or a 979-registered print book (which has no ISBN-10 and therefore an
  /// opaque `B0...` ASIN.
  ///
  /// - Parameter asin: The original token, unmodified.
  case kindleOrOther(asin: String)

  // MARK: Lifecycle

  /// Classifies an ASIN by ISBN-10 checksum validation.
  ///
  /// For most physical books, Amazon reuses the ISBN-10 as the ASIN, so a
  /// passing mod-11 checksum is a deterministic print-book signal; the
  /// checksum makes accidental false positives from non-book ASINs
  /// statistically negligible.
  ///
  /// ```swift
  /// classification(ofASIN: "1400033411")   // .printBook(9781400033416)
  /// classification(ofASIN: "B0C1XYZ123")   // .kindleOrOther
  /// ```
  ///
  /// - Warning: A `kindleOrOther` classification does not imply the product
  ///   is not a print book; 979-registered print books (common for
  ///   self-published titles since 979-8 assignment began) carry opaque
  ///   ASINs. Treat `kindleOrOther` as "identity not derivable from the
  ///   ASIN," not "not a book."
  ///
  /// - Parameter asin: The 10-character ASIN token.
  /// - Returns: Returns `ASINClassification/printBook(_:)` when the token is a
  ///   valid ISBN-10; otherwise, returns `ASINClassification/kindleOrOther(asin:)`.
  public init(classifying asin: String) {
    if asin.count == 10, let isbn = ISBN(asin) {
      self = .printBook(isbn)
    } else {
      self = .kindleOrOther(asin: asin)
    }
  }
}
