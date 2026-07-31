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

// MARK: Components

extension ISBN {

  /// The structural elements of an ISBN as defined by ISO 2108:
  /// registration group, registrant, and publication.
  ///
  /// An ISBN-13 is composed of five elements: a GS1 prefix, a registration
  /// group, a registrant (publisher), a publication (title/edition), and a
  /// check digit. The ``Components`` type exposes the three variable-length
  /// elements that carry semantic meaning.
  ///
  /// ```swift
  /// let isbn = ISBN("9780201896831")!
  /// let components = isbn.components!
  ///
  /// components.registrationGroup.name   // "English language"
  /// components.registrant               // "201"
  /// components.publication              // "89683"
  /// ```
  public struct Components: Hashable, Sendable {

    // MARK: Public

    /// The registration group that issued this ISBN.
    public let registrationGroup: RegistrationGroup

    /// The registrant element, identifying the publisher within
    /// the registration group (e.g., "201" for Addison-Wesley).
    public let registrant: String

    /// The publication element, identifying the specific title
    /// or edition (e.g., "89683").
    public let publication: String

  }
}

// MARK: RegistrationGroup

extension ISBN {

  /// A registration group as defined by the International ISBN Agency,
  /// identifying a country, geographical region, or language area.
  ///
  /// Each registration group is uniquely identified by its ``prefix``,
  /// which combines the GS1 prefix and the group identifier
  /// (e.g., "978-0" for the English language group, "978-65" for Brazil).
  ///
  /// ```swift
  /// let isbn = ISBN("9780201896831")!
  /// isbn.registrationGroup?.name    // "English language"
  /// isbn.registrationGroup?.prefix  // "978-0"
  /// ```
  ///
  /// Use ``allGroups`` or ``groups(withGS1Prefix:)`` to browse the
  /// embedded catalog of registration groups.
  public struct RegistrationGroup: Hashable, Sendable {

    // MARK: Public

    /// The group's full prefix as published by the ISBN Agency
    /// (e.g., "978-0", "979-8", "978-65").
    public let prefix: String

    /// The canonical name of the registration group as published by the
    /// International ISBN Agency (e.g., "English language", "Japan").
    public let name: String

  }
}

// MARK: RegistrationGroup Catalog

extension ISBN.RegistrationGroup {

  /// All registration groups in the embedded range table, sorted by prefix.
  ///
  /// ```swift
  /// for group in ISBN.RegistrationGroup.allGroups {
  ///   print("\(group.prefix): \(group.name)")
  /// }
  /// // "978-0: English language"
  /// // "978-1: English language"
  /// // ...
  /// ```
  public static var allGroups: [ISBN.RegistrationGroup] {
    RangeTable.allGroups
      .map { ISBN.RegistrationGroup(prefix: $0.prefix, name: $0.name) }
      .sorted { $0.prefix < $1.prefix }
  }

  /// All registration groups under the given GS1 prefix ("978" or "979").
  ///
  /// ```swift
  /// let groups979 = ISBN.RegistrationGroup.groups(withGS1Prefix: "979")
  /// // All registration groups allocated under the 979 prefix
  /// ```
  public static func groups(withGS1Prefix gs1Prefix: String) -> [ISBN.RegistrationGroup] {
    allGroups.filter { $0.prefix.hasPrefix(gs1Prefix + "-") }
  }
}

// MARK: PublisherPrefix

extension ISBN {

  /// A publisher allocation prefix: the combination of registration group
  /// and registrant that uniquely identifies a single ISBN allocation.
  ///
  /// Two ISBNs with equal publisher prefixes were issued from the same
  /// registrant allocation. This is *structural* identity — it does not
  /// account for publishers that hold multiple allocations, or for
  /// allocations that have been transferred between legal entities.
  ///
  /// ```swift
  /// let a = ISBN("9780201896831")!  // The Pragmatic Programmer
  /// let b = ISBN("9780201633610")!  // Design Patterns
  ///
  /// a.publisherPrefix == b.publisherPrefix  // true — same registrant
  /// ```
  public struct PublisherPrefix: Hashable, Sendable, CustomStringConvertible {

    // MARK: Public

    /// The registration group containing this allocation.
    public let registrationGroup: RegistrationGroup

    /// The registrant element identifying the publisher within
    /// the registration group (e.g., "201").
    public let registrant: String

    /// The hyphenated prefix form (e.g., "978-0-201").
    public var description: String {
      "\(registrationGroup.prefix)-\(registrant)"
    }
  }

  /// The publisher allocation prefix, or `nil` when the ISBN cannot be
  /// fully decomposed from the embedded range table.
  ///
  /// ```swift
  /// let isbn = ISBN("9780201896831")!
  /// isbn.publisherPrefix  // "978-0-201"
  /// ```
  public var publisherPrefix: PublisherPrefix? {
    guard let components else {
      return nil
    }

    return PublisherPrefix(
      registrationGroup: components.registrationGroup,
      registrant: components.registrant)
  }
}

// MARK: ISBN Structure

extension ISBN {

  /// The registration group, or `nil` when the group is not in the
  /// embedded range table.
  ///
  /// This property can succeed even when ``components`` returns `nil`,
  /// specifically, when the group exists in the range table but the
  /// registrant range is unallocated.
  ///
  /// ```swift
  /// let isbn = ISBN("9780201896831")!
  /// isbn.registrationGroup?.name    // "English language"
  /// isbn.registrationGroup?.prefix  // "978-0"
  /// ```
  public var registrationGroup: RegistrationGroup? {
    guard let result = RangeTable.lookupGroup(digits) else {
      return nil
    }

    return RegistrationGroup(prefix: result.prefix, name: result.name)
  }

  /// The full structural decomposition, or `nil` when the registration
  /// group or registrant range is not in the embedded range table.
  ///
  /// ```swift
  /// let isbn = ISBN("9780201896831")!
  /// let components = isbn.components!
  ///
  /// components.registrationGroup.name   // "English language"
  /// components.registrationGroup.prefix // "978-0"
  /// components.registrant               // "201"
  /// components.publication              // "89683"
  /// ```
  public var components: Components? {
    guard let result = RangeTable.decompose(digits) else {
      return nil
    }

    return Components(
      registrationGroup: RegistrationGroup(prefix: result.prefix, name: result.name),
      registrant: result.registrant,
      publication: result.publication)
  }
}
