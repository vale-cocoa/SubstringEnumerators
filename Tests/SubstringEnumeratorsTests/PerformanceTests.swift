//
//  PerformanceTests.swift
//  SubstringEnumeratorsTests
//
//  Created by Valeriano Della Longa on 2021/11/04.
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

import Foundation

final class PerformanceTests: XCTestCase {
    let text = stringFromTestPageHTMLFile
    
    let pattern = "</span>"
    
    let expectedCount = 343
    
    var result: Array<Substring>!
    
    override func setUp() {
        super.setUp()
        
        result = []
        result.reserveCapacity(expectedCount)
    }
    
    override func tearDown() {
        result = nil
        
        super.tearDown()
    }
    
    // The native version is now outperforming other algorithms,
    // I don't know why.
    // This is happening after I've update to macOS Monterey.
    // Thus none of these algorithms makes sense to be used at this point. 
    func testPerformanceSwiftNative() {
        measure {
            result.removeAll(keepingCapacity: true)
            var lo = text.startIndex
            while lo < text.endIndex {
                guard
                    let range = text[lo..<text.endIndex].range(of: pattern)
                else { break }
                
                result.append(text[range])
                lo = range.upperBound
            }
            XCTAssertEqual(result.count, expectedCount)
        }
    }
    
    func testPerformanceOfKMP() {
        measure {
            result.removeAll(keepingCapacity: true)
            text.enumerateRanges(of: pattern, adopting: .KMP, { r, _ in
                result.append(text[r])
            })
            XCTAssertEqual(result.count, expectedCount)
        }
    }
    
    func testPerformanceOfBM() {
        measure {
            result.removeAll(keepingCapacity: true)
            text.enumerateRanges(of: pattern, adopting: .BM, { r, _ in
                result.append(text[r])
            })
            XCTAssertEqual(result.count, expectedCount)
        }
    }
    
    // There is a perfomance problem with Rabin-Karp algorithms,
    // I have to yet understand what is causing it.
    func testPerformanceOfRK() {
        measure {
            result.removeAll(keepingCapacity: true)
            text.enumerateRanges(of: pattern, adopting: .RK, { r, _ in
                result.append(text[r])
            })
            XCTAssertEqual(result.count, expectedCount)
        }
    }
    
    func testPerformanceOfRKLasVegas() {
        measure {
            result.removeAll(keepingCapacity: true)
            text.enumerateRanges(of: pattern, adopting: .RKLasVegas, { r, _ in
                result.append(text[r])
            })
            XCTAssertEqual(result.count, expectedCount)
        }
    }
    
}
