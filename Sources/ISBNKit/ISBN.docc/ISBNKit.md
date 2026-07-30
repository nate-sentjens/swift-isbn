# ``ISBNKit``
A single, checksum-validated `ISBN` value type, along with deterministic Amazon
ASIN classification.

## Overview
`ISBNKit` models the ISBN as **one identifier
with two written forms**, of which the 13-digit form is canonical. Parsing
accepts either form; identity, equality, and serialization are always the
canonical 13 digits. The reasoning, and why a two-type `ISBN10`/`ISBN13`
design was rejected, is in <doc:OneIdentifierOneType>.

```swift
let isbn = ISBN("0201896834")!    // legacy form in

String(describing: isbn)          // "9780201896831" — canonical out
isbn == ISBN("9780201896831")     // true: same registration
```

For Amazon integration, ``ASINClassification(of:)`` reflects the fact that
print-book ASINs are ISBN-10s, turning a checksum pass into a deterministic
identity.

## Topics

### Design
- <doc:OneIdentifierOneType>

### Core
- ``ISBN``

### Amazon ASIN classification
- ``ASINClassification``
