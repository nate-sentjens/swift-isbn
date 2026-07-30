# One Identifier, One Type
Why `ISBNKit` has a single `ISBN` value type instead of `ISBN10` and `ISBN13`.

## Overview
When ISO 2108 moved to 13 digits in 2007, it did not create a second
identifier, it re-serialized the existing one. An ISBN-10 and its
978-prefixed ISBN-13 are the same registration: same registrant, same
publication, same nine-digit payload. The prefix and check digit are
envelope, not identity, which is why the check digits differ between
forms (different checksum algorithms over the same payload).

The litmus test for splitting a concept into two types: do the two
candidates ever denote the identical real-world referent, such that the
domain requires them to compare equal? `1400033411` and `9781400033416`
refer to the same edition of the same book — not similar things, the
*same* thing. "ISBN-10 vs ISBN-13" is an encoding joint, like
UTF-8 vs UTF-16 for one string, not a semantic joint.

### Where the partiality lives
ISBN-10 → ISBN-13 is total; the reverse is partial. 979-prefixed
registrations (common for self-published print books on 979-8) have no
ISBN-10 form at all. That asymmetry is exactly why ISBN-13 is canonical, 
and in this API the partiality is confined to a single optional,
``ISBN/isbn10String``.

### The serialization contract
`Codable` uses a single-value container: an ``ISBN`` encodes as the bare
canonical string (like `UUID` and `URL`), and decoding routes through the
same validating parser as ``ISBN/init(_:)`` — external JSON carrying a
legacy ISBN-10 string normalizes on decode, and invalid strings fail with
`DecodingError.dataCorrupted`. `CodingKeyRepresentable` makes
`[ISBN: Value]` dictionaries encode as keyed objects.

### When the split *is* right
Systems where the representation itself carries meaning — bibliographic
provenance (which form appeared in a MARC record), or agency tools that
assign check digits — genuinely operate per-format and deserve distinct
types. A consumer product that resolves books and builds links never does:
every downstream system speaks ISBN-13, and the only form-specific
operation is the boundary parse inside ``ASINClassification``.
