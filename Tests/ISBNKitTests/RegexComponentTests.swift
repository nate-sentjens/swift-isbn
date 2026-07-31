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

import ISBNKit
import Testing

// MARK: - RegexComponentTests

@Suite
struct RegexComponentTests {

  @Test
  func matchesBareISBN13() {
    guard #available(iOS 16, macOS 13, tvOS 16, watchOS 9, *) else { return }

    let matches = "9780201896831".matches(of: ISBN.regex)

    #expect(matches.count == 1)
    #expect(matches.first?.output == ISBN("9780201896831"))
  }

  @Test
  func matchesHyphenatedISBN13() {
    guard #available(iOS 16, macOS 13, tvOS 16, watchOS 9, *) else { return }

    let matches = "978-0-201-89683-1".matches(of: ISBN.regex)

    #expect(matches.count == 1)
    #expect(matches.first?.output == ISBN("9780201896831"))
  }

  @Test
  func matchesBareISBN10() {
    guard #available(iOS 16, macOS 13, tvOS 16, watchOS 9, *) else { return }

    let matches = "0201896834".matches(of: ISBN.regex)

    #expect(matches.count == 1)
    #expect(matches.first?.output == ISBN("9780201896831"))
  }

  @Test
  func matchesISBN10WithX() {
    guard #available(iOS 16, macOS 13, tvOS 16, watchOS 9, *) else { return }

    let matches = "043942089X".matches(of: ISBN.regex)

    #expect(matches.count == 1)
    #expect(matches.first?.output == ISBN("043942089X"))
  }

  @Test
  func matchesLowercaseX() {
    guard #available(iOS 16, macOS 13, tvOS 16, watchOS 9, *) else { return }

    let matches = "043942089x".matches(of: ISBN.regex)

    #expect(matches.count == 1)
    #expect(matches.first?.output == ISBN("043942089X"))
  }

  @Test
  func findsISBNInSurroundingText() {
    guard #available(iOS 16, macOS 13, tvOS 16, watchOS 9, *) else { return }

    let text = "See ISBN 978-0-201-89683-1 for details."
    let matches = text.matches(of: ISBN.regex)

    #expect(matches.count == 1)
    #expect(matches.first?.output == ISBN("9780201896831"))
  }

  @Test
  func findsMultipleISBNs() {
    guard #available(iOS 16, macOS 13, tvOS 16, watchOS 9, *) else { return }

    let text = "Books: 9780201896831 and 9783161484100"
    let matches = text.matches(of: ISBN.regex)

    #expect(matches.count == 2)
    #expect(matches.map(\.output) == [ISBN("9780201896831"), ISBN("9783161484100")])
  }

  @Test
  func skipsInvalidCheckDigit() {
    guard #available(iOS 16, macOS 13, tvOS 16, watchOS 9, *) else { return }

    let matches = "9780201896830".matches(of: ISBN.regex)

    #expect(matches.isEmpty)
  }

  @Test
  func skipsNonBooklandEAN() {
    guard #available(iOS 16, macOS 13, tvOS 16, watchOS 9, *) else { return }

    let matches = "4006381333931".matches(of: ISBN.regex)

    #expect(matches.isEmpty)
  }

  @Test
  func matchesISBN10FollowedByNonDigit() {
    guard #available(iOS 16, macOS 13, tvOS 16, watchOS 9, *) else { return }

    let text = "ISBN 0201896834, published 1999"
    let matches = text.matches(of: ISBN.regex)

    #expect(matches.count == 1)
    #expect(matches.first?.output == ISBN("9780201896831"))
  }

  @Test
  func matches979Prefix() {
    guard #available(iOS 16, macOS 13, tvOS 16, watchOS 9, *) else { return }

    let matches = "9798601570022".matches(of: ISBN.regex)

    #expect(matches.count == 1)
    #expect(matches.first?.output == ISBN("9798601570022"))
  }

  @Test
  func matchesSpaceSeparatedISBN() {
    guard #available(iOS 16, macOS 13, tvOS 16, watchOS 9, *) else { return }

    let matches = "978 0 201 89683 1".matches(of: ISBN.regex)

    #expect(matches.count == 1)
    #expect(matches.first?.output == ISBN("9780201896831"))
  }

  @Test
  func emptyStringMatchesNothing() {
    guard #available(iOS 16, macOS 13, tvOS 16, watchOS 9, *) else { return }

    let matches = "".matches(of: ISBN.regex)

    #expect(matches.isEmpty)
  }

  @Test
  func noFalsePositivesInProseText() {
    guard #available(iOS 16, macOS 13, tvOS 16, watchOS 9, *) else { return }

    let text = "Chapter 12 discusses 45 topics across 300 pages."
    let matches = text.matches(of: ISBN.regex)

    #expect(matches.isEmpty)
  }
}
