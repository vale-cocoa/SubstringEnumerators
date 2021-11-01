//
//  SubstringEnumeratorsTests.swift
//  SubstringEnumeratorsTests
//
//  Created by Valeriano Della Longa on 2021/10/28.
//  Copyright © 2021 Valeriano Della Longa. All rights reserved.
//
//  Permission to use, copy, modify, and/or distribute this software for any
//  purpose with or without fee is hereby granted, provided that the above
//  copyright notice and this permission notice appear in all copies.
//
//  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
//  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
//  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
//  SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
//  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
//  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR
//  IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
//

import XCTest
@testable import SubstringEnumerators

final class SubstringEnumeratorsTests: XCTestCase {
    var text: String!
    
    var pattern: String!
    
    var rangeOfPatternInText: Range<String.Index>?
    
    var rangesOfPatternInText: [Range<String.Index>] {
        var expectedResult: [Range<String.Index>] = []
        var lo = text.startIndex
        repeat {
            if let r = text[lo...].range(of: pattern) {
                expectedResult.append(r)
                lo = r.upperBound
            } else {
                lo = text.endIndex
            }
        } while lo < text.endIndex
        
        return expectedResult
    }
    
    // MARK: - given
    func givenRandomPatternFromRandomPage() -> String {
        let length = Int.random(in: 1..<11)
        let loOffset = Int.random(in: 0..<(randomPage.count - length))
        let lo = randomPage.index(randomPage.startIndex, offsetBy: loOffset)
        let hi = randomPage.index(lo, offsetBy: length)
        
        return String(randomPage[lo..<hi])
    }
    
    // MARK: - When
    func whenBookExample() {
        // setup test environment with example from Algorithms 4th Edition by Robert Sedgewick
        pattern = bookExamplePattern
        text = bookExampleText
        rangeOfPatternInText = rangeOfBookExample
    }
    
    func whenPatternIsInText() {
        pattern = headHTMLTag
        text = stringFromTestPageHTMLFile
        rangeOfPatternInText = rangeOfHeadHTMLTagInTestPageHTML
    }
    
    func whenPatternIsEmptyAndTextIsNotEmpty() {
        pattern = ""
        text = bookExampleText
        rangeOfPatternInText = nil
    }
    
    func whenPatternIsNotInText() {
        pattern = "<h4 id"
        text = stringFromTestPageHTMLFile
        rangeOfPatternInText = nil
    }
    
    func whenPatternAppearsInTextMultipleTimes() {
        pattern = "<li class=\"\">"
        text = stringFromTestPageHTMLFile
        rangeOfPatternInText = stringFromTestPageHTMLFile.range(of: pattern)!
    }
    
    // MARK: - Tests
    // MARK: - enumerateRanges(of:adopting:_:) tests
    func testEnumerateRangesOfAdopting_whenPatternIsNotInText_thenBodyNeverExecutes() {
        whenPatternIsNotInText()
        for enumerator in SubstringEnumerator.allCases {
            var hasExecuted = false
            text.enumerateRanges(of: pattern, adopting: enumerator, { _, _ in
                hasExecuted = true
            })
            XCTAssertFalse(hasExecuted, "Body has executed adopting: \(enumerator)")
        }
    }
    func testEnumerateOccurenciesIn_whenPatternAppearsInTextMultipleTimesAndStopIsNotSetToTrueInBody_thenBodyExecutesWithAllRangesOfTextContainingPattern() {
        whenPatternAppearsInTextMultipleTimes()
        let expectedResult = rangesOfPatternInText
        for enumerator in SubstringEnumerator.allCases {
            var result: [Range<String.Index>] = []
            text.enumerateRanges(of: pattern, adopting: enumerator, { r, _ in
                result.append(r)
            })
            XCTAssertEqual(result, expectedResult, "Didn't get expected ranges adopting: \(enumerator)")
        }
        
    }
    
    func testEnumerateOccurenciesIn_whenStopIsSetToTrueInBody_thenStopsEnumeration() {
        whenPatternAppearsInTextMultipleTimes()
        var expectedResult = rangesOfPatternInText
        expectedResult.removeLast()
        for enumerator in SubstringEnumerator.allCases {
            var result = [Range<String.Index>]()
            var countOfExecutions = 0
            text.enumerateRanges(of: pattern, adopting: enumerator, { r, stop in
                countOfExecutions += 1
                result.append(r)
                stop = countOfExecutions >= expectedResult.count
            })
            XCTAssertEqual(result, expectedResult)
        }
    }
    
    func testEnumerateOccurenciesIn_whenBodyThrows_thenRethrows() {
        whenPatternAppearsInTextMultipleTimes()
        let throwNow = rangesOfPatternInText.count - 1
        for enumerator in SubstringEnumerator.allCases {
            var countOfExecutions = 0
            do {
                try text.enumerateRanges(of: pattern, adopting: enumerator, { _, _ in
                    countOfExecutions += 1
                    guard countOfExecutions < throwNow else { throw testError }
                })
                XCTFail("Didn't rethrow adopting: \(enumerator)")
            } catch {
                XCTAssertEqual(error as NSError, testError, "Did't rethrow same error thrown by body adopting: \(enumerator)")
            }
        }
    }
    
    // MARK: - enumerateRanges(of:in:adopting:_:) tests
    // since this method is invoked by enumerateRanges(of:adopting:_:)
    // some of its functionalities are already tested by tests done earlier
    // for enumerateRanges(of:adopting:_:) method.
    func testEnumerateRangesOfInAdopting_whenRangeIsEmpty_thenBodyNeverExecutes() {
        whenPatternAppearsInTextMultipleTimes()
        let limit = rangeOfPatternInText!.upperBound
        for enumerator in SubstringEnumerator.allCases {
            var lo = rangeOfPatternInText!.lowerBound
            var hasExecuted = false
            repeat {
                text.enumerateRanges(of: pattern, in: lo..<lo, adopting: enumerator, { _, stop in
                    hasExecuted = true
                    stop = true
                })
            } while text.formIndex(&lo, offsetBy: 1, limitedBy: limit)
            XCTAssertFalse(hasExecuted, "Body executed adopting: \(enumerator)")
        }
    }
    
    func testEnumerateRangesOfInAdopting_whenRangeCountIsSmallerThanPatternCount_thenBodyNEverExecutes() throws {
        whenPatternAppearsInTextMultipleTimes()
        let lo = rangeOfPatternInText!.lowerBound
        let limit = text.index(before: rangeOfPatternInText!.upperBound)
        for enumerator in SubstringEnumerator.allCases {
            var hi = lo
            var hasExecuted = false
            while text.formIndex(&hi, offsetBy: 1, limitedBy: limit) {
                try XCTSkipIf(text.distance(from: lo, to: hi) >= pattern.count, "something went wrong with creating a range of text with a count less than pattern.count")
                text.enumerateRanges(of: pattern, in: lo..<hi, adopting: enumerator, { _, stop in
                    hasExecuted = true
                    stop = true
                })
            }
            XCTAssertFalse(hasExecuted, "Body executed adopting: \(enumerator)")
        }
    }
    
    func testEnumerateRangesOfInAdopting_whenRangeCountIsEqualToPatternCountAndItDoesntContainPattern_thenBodyDoesntExecute() {
        whenPatternAppearsInTextMultipleTimes()
        let lo = rangesOfPatternInText.last!.upperBound
        let hi = text.index(lo, offsetBy: pattern.count)
        for enumerator in SubstringEnumerator.allCases {
            var hasExecuted = false
            text.enumerateRanges(of: pattern, in: lo..<hi, adopting: enumerator, { _, stop in
                hasExecuted = true
                stop = true
            })
            XCTAssertFalse(hasExecuted, "Body executed adopting: \(enumerator)")
        }
    }
    
    func testEnumerateRangesOfInAdopting_whenRangeCountIsLargerThanPatternCountAndDoesntContainAnyOccurrenceOfPattern_thenBodyNeverExecutes() {
        whenPatternAppearsInTextMultipleTimes()
        let lo = text.range(of: "</nav>")!.upperBound
        for enumerator in SubstringEnumerator.allCases {
            var hasExecuted = false
            text.enumerateRanges(of: pattern, in: lo..., adopting: enumerator, { _, stop in
                hasExecuted = true
                stop = true
            })
            XCTAssertFalse(hasExecuted, "Body executed adopting: \(enumerator)")
        }
    }
    
    func testEnumerateRangesOfInAdopting_whenRangeCountIsEqualToPatternCountAndContainsPattern_thenBodyExecutesOnceAndPassesSuchRangeToBody() {
        whenPatternAppearsInTextMultipleTimes()
        for enumerator in SubstringEnumerator.allCases {
            var countOfExecutions = 0
            text.enumerateRanges(of: pattern, in: rangeOfPatternInText!, adopting: enumerator, { r, _ in
                countOfExecutions += 1
                XCTAssertEqual(r, rangeOfPatternInText, "Range different adopting: \(enumerator)")
            })
            XCTAssertEqual(countOfExecutions, 1, "Adopting: \(enumerator)")
        }
    }
    
    func testEnumerateRangesOfInAdopting_whenRangeContainsMultipleOccurenciesOfPattern_thenBodyExecutesWithEveryRangeOfPatternFound() {
        whenPatternAppearsInTextMultipleTimes()
        let lo = text.range(of: "<nav>")!.lowerBound
        let hi = text.range(of: "</nav>")!.upperBound
        let expectedResult = rangesOfPatternInText
        for enumerator in SubstringEnumerator.allCases {
            var result = [Range<String.Index>]()
            text.enumerateRanges(of: pattern, in: lo..<hi, adopting: enumerator, { r, _ in
                result.append(r)
            })
            XCTAssertEqual(result, expectedResult, "Adopting: \(enumerator)")
        }
    }
    
}
