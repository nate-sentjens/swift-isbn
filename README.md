# ISBNKit
A checksum-validated `ISBN` value type for Swift with canonical hyphenation,
`FormatStyle` support, and Amazon ASIN classification.

[![Swift Package Manager compatible](https://img.shields.io/badge/SPM-compatible-4BC51D.svg?style=flat)](https://github.com/apple/swift-package-manager)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fnate-sentjens%2Fswift-isbn%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/nate-sentjens/swift-isbn)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fnate-sentjens%2Fswift-isbn%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/nate-sentjens/swift-isbn)

## Usage
```swift
import ISBNKit

let isbn = ISBN("0201896834")!    // parses ISBN-10 or ISBN-13

isbn.formatted()      // "978-0-201-89683-1"
isbn.hyphenated       // "978-0-201-89683-1"
String(isbn)          // "9780201896831"
isbn.isbn10String     // Optional("0201896834")
```

### FormatStyle
`ISBN.FormatStyle` conforms to `Foundation.FormatStyle` and
`ParseableFormatStyle`, so it works anywhere format styles are accepted:

```swift
Text(isbn, format: .isbn)                       // SwiftUI
TextField("ISBN", value: $isbn, format: .isbn)  // SwiftUI input

isbn.formatted(.isbn)                           // explicit style
```

### Parsing
`ISBN` accepts both written forms (ISBN-10 and ISBN-13) with or without
hyphens and spaces. Both forms of the same registration compare equal:

```swift
ISBN("0201896834") == ISBN("978-0-201-89683-1")  // true — same book
```

### ASIN classification
For most print books, Amazon's 10-character ASIN is the ISBN-10.
`ASINClassification` turns a passing checksum into a deterministic identity:

```swift
switch ASINClassification(of: asin) {
case .printBook(let isbn):
  // valid ISBN-10; isbn holds the canonical ISBN-13
case .kindleOrOther(let asin):
  // Kindle edition, non-book product, or 979-registered print book
}
```

## Installation
Add ISBNKit to your `Package.swift`:

```swift
dependencies: [
  .package(url: "https://github.com/nate-sentjens/swift-isbn", from: "2.0.0"),
]
```

Then add `"ISBNKit"` to your target's dependencies.

## Design
Under ISO 2108, the 2007 ten-to-thirteen digit transition re-serialized the
identifier rather than replacing it: an ISBN-10 and its 978-prefixed ISBN-13
denote the same registration. `ISBNKit` models the registration, not the
serialization — a single `ISBN` type, not `ISBN10` and `ISBN13`. See the
DocC article for the full rationale.

979-prefixed registrations have no ISBN-10 form. That partiality is confined
to a single optional (`isbn10String: String?`) rather than leaking into
every signature that carries the identifier.

Hyphenation uses the International ISBN Agency's range table to place hyphens
at the correct positions for each registration group and registrant. ISBNs
whose group is not in the embedded table fall back to bare digits.
