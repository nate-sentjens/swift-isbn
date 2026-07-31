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

String(isbn)                      // "9780201896831" — canonical out
isbn.formatted()                  // "978-0-201-89683-1" — hyphenated
isbn == ISBN("9780201896831")     // true: same registration
```

For Amazon integration, ``ASINClassification`` reflects the fact that
print-book ASINs are ISBN-10s, turning a checksum pass into a deterministic
identity.

## Topics

### Design
- <doc:OneIdentifierOneType>

### Core
- ``ISBN``

### Structure
- ``ISBN/RegistrationGroup``
- ``ISBN/Components``
- ``ISBN/PublisherPrefix``
- ``ISBN/registrationGroup``
- ``ISBN/components``
- ``ISBN/publisherPrefix``

### ISBN-10
- ``ISBN/TenDigitForm``
- ``ISBN/isbn10``

### Formatting
- ``ISBN/FormatStyle``
- ``ISBN/ParseStrategy``
- ``ISBN/ParseError``
- ``ISBN/formatted()``
- ``ISBN/formatted(_:)``
- ``ISBN/hyphenated``
- ``ISBN/urn``

### Validation
- ``ISBN/ValidationError``
- ``ISBN/validate(_:)``
- ``ISBN/corrections(for:)``

### Text Extraction
- ``ISBNRegexComponent``
- ``ISBN/regex``

### Amazon ASIN classification
- ``ASINClassification``
