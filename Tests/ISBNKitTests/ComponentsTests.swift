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

// MARK: - RegistrationGroupTests

@Suite
struct RegistrationGroupTests {

  @Test
  func englishLanguageGroup() throws {
    let isbn = try #require(ISBN("9780201896831"))
    let group = try #require(isbn.registrationGroup)

    #expect(group.prefix == "978-0")
    #expect(group.name == "English language")
  }

  @Test
  func germanGroup() throws {
    let isbn = try #require(ISBN("9783161484100"))
    let group = try #require(isbn.registrationGroup)

    #expect(group.prefix == "978-3")
    #expect(group.name == "German language")
  }

  @Test
  func japanGroup() throws {
    let isbn = try #require(ISBN("9784101092058"))
    let group = try #require(isbn.registrationGroup)

    #expect(group.prefix == "978-4")
    #expect(group.name == "Japan")
  }

  @Test
  func brazilGroup() throws {
    let isbn = try #require(ISBN("9786555550559"))
    let group = try #require(isbn.registrationGroup)

    #expect(group.prefix == "978-65")
    #expect(group.name == "Brazil")
  }

  @Test
  func us979Group() throws {
    let isbn = try #require(ISBN("9798601570022"))
    let group = try #require(isbn.registrationGroup)

    #expect(group.prefix == "979-8")
    #expect(group.name == "United States")
  }

  @Test
  func groupEquality() throws {
    let isbn1 = try #require(ISBN("9780201896831"))
    let isbn2 = try #require(ISBN("9780060112080"))

    #expect(isbn1.registrationGroup == isbn2.registrationGroup)
  }

  @Test
  func groupInequalityAcrossPrefixes() throws {
    let isbn978 = try #require(ISBN("9780201896831"))
    let isbn979 = try #require(ISBN("9798601570022"))

    #expect(isbn978.registrationGroup != isbn979.registrationGroup)
  }
}

// MARK: - ComponentsTests

@Suite
struct ComponentsTests {

  @Test
  func englishDecomposition() throws {
    let isbn = try #require(ISBN("9780201896831"))
    let c = try #require(isbn.components)

    #expect(c.registrationGroup.prefix == "978-0")
    #expect(c.registrationGroup.name == "English language")
    #expect(c.registrant == "201")
    #expect(c.publication == "89683")
  }

  @Test
  func englishTwoDigitRegistrant() throws {
    let isbn = try #require(ISBN("9780060112080"))
    let c = try #require(isbn.components)

    #expect(c.registrant == "06")
    #expect(c.publication == "011208")
  }

  @Test
  func germanDecomposition() throws {
    let isbn = try #require(ISBN("9783161484100"))
    let c = try #require(isbn.components)

    #expect(c.registrationGroup.prefix == "978-3")
    #expect(c.registrant == "16")
    #expect(c.publication == "148410")
  }

  @Test
  func japanDecomposition() throws {
    let isbn = try #require(ISBN("9784101092058"))
    let c = try #require(isbn.components)

    #expect(c.registrationGroup.prefix == "978-4")
    #expect(c.registrant == "10")
    #expect(c.publication == "109205")
  }

  @Test
  func brazilDecomposition() throws {
    let isbn = try #require(ISBN("9786555550559"))
    let c = try #require(isbn.components)

    #expect(c.registrationGroup.prefix == "978-65")
    #expect(c.registrant == "5555")
    #expect(c.publication == "055")
  }

  @Test
  func us979Decomposition() throws {
    let isbn = try #require(ISBN("9798601570022"))
    let c = try #require(isbn.components)

    #expect(c.registrationGroup.prefix == "979-8")
    #expect(c.registrant == "6015")
    #expect(c.publication == "7002")
  }

  @Test
  func isbn10InputDecomposes() throws {
    let isbn = try #require(ISBN("0201896834"))
    let c = try #require(isbn.components)

    #expect(c.registrationGroup.prefix == "978-0")
    #expect(c.registrant == "201")
    #expect(c.publication == "89683")
  }

  @Test
  func sameRegistrantComparesEqual() throws {
    let isbn1 = try #require(ISBN("9780201896831"))
    let isbn2 = try #require(ISBN("9780201633610"))

    let c1 = try #require(isbn1.components)
    let c2 = try #require(isbn2.components)

    #expect(c1.registrationGroup == c2.registrationGroup)
    #expect(c1.registrant == c2.registrant)
  }

  @Test
  func hyphenatedMatchesComponents() throws {
    let isbn = try #require(ISBN("9780201896831"))
    let c = try #require(isbn.components)

    let expected = [c.registrationGroup.prefix, c.registrant, c.publication, String(String(isbn).suffix(1))]
      .joined(separator: "-")

    #expect(isbn.hyphenated == expected)
  }
}

// MARK: - PublisherPrefixTests

@Suite
struct PublisherPrefixTests {

  @Test
  func publisherPrefixFromISBN() throws {
    let isbn = try #require(ISBN("9780201896831"))
    let prefix = try #require(isbn.publisherPrefix)

    #expect(prefix.registrationGroup.prefix == "978-0")
    #expect(prefix.registrant == "201")
  }

  @Test
  func samePublisherComparesEqual() throws {
    let a = try #require(ISBN("9780201896831"))
    let b = try #require(ISBN("9780201633610"))

    #expect(a.publisherPrefix == b.publisherPrefix)
  }

  @Test
  func differentPublishersCompareUnequal() throws {
    let a = try #require(ISBN("9780201896831"))
    let b = try #require(ISBN("9780060112080"))

    #expect(a.publisherPrefix != b.publisherPrefix)
  }

  @Test
  func differentGroupsCompareUnequal() throws {
    let english = try #require(ISBN("9780201896831"))
    let german = try #require(ISBN("9783161484100"))

    #expect(english.publisherPrefix != german.publisherPrefix)
  }

  @Test
  func descriptionIsHyphenatedPrefix() throws {
    let isbn = try #require(ISBN("9780201896831"))
    let prefix = try #require(isbn.publisherPrefix)

    #expect(String(describing: prefix) == "978-0-201")
  }

  @Test
  func usableAsDictionaryKey() throws {
    let isbn1 = try #require(ISBN("9780201896831"))
    let isbn2 = try #require(ISBN("9780201633610"))
    let isbn3 = try #require(ISBN("9780060112080"))

    let grouped = Dictionary(grouping: [isbn1, isbn2, isbn3]) { $0.publisherPrefix }

    #expect(grouped.count == 2)
  }
}

// MARK: - RegistrationGroupCatalogTests

@Suite
struct RegistrationGroupCatalogTests {

  @Test
  func allGroupsIsNotEmpty() {
    #expect(!ISBN.RegistrationGroup.allGroups.isEmpty)
  }

  @Test
  func allGroupsContainsEnglishLanguage() {
    let english = ISBN.RegistrationGroup.allGroups.first { $0.prefix == "978-0" }

    #expect(english?.name == "English language")
  }

  @Test
  func allGroupsContains979Entries() {
    let has979 = ISBN.RegistrationGroup.allGroups.contains { $0.prefix.hasPrefix("979-") }

    #expect(has979)
  }

  @Test
  func gs1PrefixFilterReturnsOnlyMatchingPrefix() {
    let groups979 = ISBN.RegistrationGroup.groups(withGS1Prefix: "979")

    #expect(!groups979.isEmpty)
    #expect(groups979.allSatisfy { $0.prefix.hasPrefix("979-") })
  }

  @Test
  func gs1PrefixFilterExcludesOtherPrefix() {
    let groups978 = ISBN.RegistrationGroup.groups(withGS1Prefix: "978")

    #expect(groups978.allSatisfy { !$0.prefix.hasPrefix("979-") })
  }

  @Test
  func allGroupsIsSorted() {
    let groups = ISBN.RegistrationGroup.allGroups

    let prefixes = groups.map(\.prefix)
    #expect(prefixes == prefixes.sorted())
  }
}
