//
//  StringProtocol+SubstringEnumerator.swift
//  SubstringEnumerators
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

import Foundation
import DFA
import RabinKarpHasher

extension StringProtocol {
    /// Executes the given body closure every time an occurence of the string specified as `pattern`
    /// parameter is encountered in this string, adopting the algorithm specified as `enumerator`
    /// parameter for the lookup.
    ///
    /// - Parameter pattern: Another string to find in this string.
    /// - Parameter enumerator: A `SubstringEnumerator` value, that is the
    ///                         the algorithm that will be used for the lookup.
    /// - Parameter body:   A closure to execute every time the specified `pattern` string is found
    ///                     in this string's range.
    ///                     This closure gets two arguments: a `Range<Index>` value
    ///                     and an `inout Bool` value.
    /// - Parameter rangeOfSubstring:   A `Range<Index>` value valid for this string,
    ///                                 representing the position where
    ///                                 the specified `pattern` has been found.
    /// - Parameter stop: An `inout Bool` value, set it to `true` to stop the enumeration.
    /// - Complexity:   Depending on the enumerator in use, the worst case scenario
    ///                 varies between O(*n* + *m*) and O(*n* \* *m*), where *n* is the length of
    ///                 this string, and *m* is the length of the specified `pattern` string.
    public func enumerateRanges<S: StringProtocol>(of pattern: S, adopting enumerator: SubstringEnumerator, _ body: (_ rangeOfSubstring: Range<Index>, _ stop: inout Bool) throws -> Void) rethrows {
        try enumerateRanges(of: pattern, in: startIndex..., adopting: enumerator, body)
    }
    
    /// Executes the given body closure every time an occurence of the string specified as `pattern`
    /// parameter is encountered in this string's specified range, adopting the algorithm specified as `enumerator`
    /// parameter for the lookup.
    ///
    /// - Parameter pattern: Another string to find in this string.
    /// - Parameter range: A range expression specifying the range of this string for the pattern lookup.
    /// - Parameter enumerator: A `SubstringEnumerator` value, that is the
    ///                         the algorithm that will be used for the lookup.
    /// - Parameter body:   A closure to execute every time the specified `pattern` string is found
    ///                     in this string's range.
    ///                     This closure gets two arguments: a `Range<Index>` value
    ///                     and an `inout Bool` value.
    /// - Parameter rangeOfSubstring:   A `Range<Index>` value valid for this string,
    ///                                 representing the position where
    ///                                 the specified `pattern` has been found.
    /// - Parameter stop: An `inout Bool` value, set it to `true` to stop the enumeration.
    /// - Complexity:   Depending on the enumerator in use, the worst case scenario
    ///                 varies between O(*n* + *m*) and O(*n* \* *m*), where *n* is
    ///                 the length of the spcified `range` of this string,
    ///                 and *m* is the length of the specified `pattern` string.
    @inline(__always)
    public func enumerateRanges<S: StringProtocol, R: RangeExpression>(of pattern: S, in range: R, adopting enumerator: SubstringEnumerator, _ body: (_ rangeOfSubstring: Range<Index>, _ stop: inout Bool) throws -> Void) rethrows where R.Bound == Index {
        let r = range.relative(to: self)
        guard
            distance(from: r.lowerBound, to: r.upperBound) >= pattern.count
        else { return }
        
        switch enumerator {
        case .KMP: try _knuttMorrisPratt(of: pattern, range: r, body)
        case .BM: try _boyerMoore(of: pattern, range: r, body)
        case .RK: try _rabinKarp(of: pattern, range: r, body)
        }
    }
    
}

// Private helpers
extension StringProtocol {
    @inline(__always)
    fileprivate func _knuttMorrisPratt<S: StringProtocol>(of pattern: S, range: Range<Index>, _ body: (Range<Index>, inout Bool) throws -> Void) rethrows {
        var dfa = DFA(pattern)
        var stop = false
        var idx = range.lowerBound
        while
            !stop,
            idx < range.upperBound
        {
            dfa.updateState(for: self[idx])
            formIndex(after: &idx)
            if dfa.isAtFinalState {
                let lowerBound = index(idx, offsetBy: -pattern.count)
                try body(lowerBound..<idx, &stop)
            }
        }
    }
    
    @inline(__always)
    fileprivate func _boyerMoore<S: StringProtocol>(of pattern: S, range: Range<Index>, _ body: (Range<Index>, inout Bool) throws -> Void) rethrows {
        let right = Dictionary(pattern.enumerated().map({ ($0.element, $0.offset) }), uniquingKeysWith: { $1 })
        let limit = index(range.upperBound, offsetBy: -pattern.count)
        var i = range.lowerBound
        var skip = 0
        var stop = false
        repeat {
            skip = 0
            var j = pattern.endIndex
            while pattern.formIndex(&j, offsetBy: -1, limitedBy: pattern.startIndex) {
                let jOffset = pattern.distance(from: pattern.startIndex, to: j)
                let idx = index(i, offsetBy: jOffset)
                let c = self[idx]
                if pattern[j] != c {
                    skip = Swift.max(1, jOffset - right[c, default: -1])
                    
                    break
                }
            }
            if skip == 0 {
                let upper = index(i, offsetBy: pattern.count)
                try body(i..<upper, &stop)
                guard !stop else { return }
                
                skip = 1
            }
        } while formIndex(&i, offsetBy: skip, limitedBy: limit)
    }
    
    @inline(__always)
    fileprivate func _rabinKarp<S: StringProtocol>(of pattern: S, range: Range<Index>, _ body: (Range<Index>, inout Bool) throws -> Void) rethrows {
        let patternRK = DoubleRollingHasher(pattern, range: pattern.startIndex...)
        let hi = utf8.index(range.lowerBound, offsetBy: pattern.utf8.count)
        var rk = DoubleRollingHasher(self, range: range.lowerBound..<hi)
        var stop = false
        repeat {
            let r = rk.actualRange
            if patternRK.hasSameHash(of: rk) {
                try body(r, &stop)
            }
        } while !stop && rk.actualRange.upperBound < range.upperBound && rk.rollHashValue()
    }
    
}

