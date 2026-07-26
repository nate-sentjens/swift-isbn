# ISBNKit
A single, checksum-validated `ISBN` value type for Swift, plus deterministic Amazon ASIN classification.

[![Swift Package Manager compatible](https://img.shields.io/badge/SPM-compatible-4BC51D.svg?style=flat)](https://github.com/apple/swift-package-manager)

## Motivation
Under ISO 2108, the 2007 ten→thirteen digit transition re-serialized the identifier rather than replacing it: an ISBN-10 and its 978-prefixed ISBN-13 are the same registration. So, `ISBNKit` models registrations:

- **One type:** `ISBN` parses either written form (hyphen/space-tolerant, `X` check character) and holds canonical 13 digits. `ISBN("1400033411") == ISBN("9781400033416")`.
- **Partiality contained:** 979-prefixed registrations have no ISBN-10 form; that's expressed and reflected in one optional (`isbn10String: String?`).
- **ASIN classification:** For most print books, Amazon's ASIN *is* the ISBN-10; `classification(ofASIN:)` turns a passing mod-11 checksum into a deterministic identity. 979-registered print books carry opaque `B0…` ASINs, so `kindleOrOther` means "identity not derivable," not "not a book."

```swift
if case .printBook(let isbn) = classification(ofASIN: "1400033411") {
    isbn.digits        // "9780201896831"
    isbn.isbn10String  // "1400033411"
}
```
