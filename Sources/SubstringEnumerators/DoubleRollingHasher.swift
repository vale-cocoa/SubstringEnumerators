//
//  DoubleRollingHasher.swift
//  SubstringEnumerators
//
//  Created by Valeriano Della Longa on 2021/11/02.
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
import RabinKarpHasher

// We use a double Rabin-Karp hasher with different
// modulo values of 10⁹ magnitude: this effectively lowers the
// possibility of hash collisions to a 10⁻⁶ chance, hence making
// reliable the Montecarlo implementation (just comparing the rolling hashes
// without having to also check for equality the found substring
// against the pattern).
// Moreover this helper also just checks the rolling hash values, since
// it is used privately with two pre-defined modulo values randomly generated
// and valid for the whole running time of the application, working on
// the same length of bytes (therefore reminder values are also guaranteed to be the
// same when comparing).
struct DoubleRollingHasher<S: StringProtocol> {
    fileprivate var _h1: RabinKarpHasher<S.UTF8View>
    
    fileprivate var _h2: RabinKarpHasher<S.UTF8View>
    
    var actualRange: Range<String.Index> { _h1.range }
    
    init<R: RangeExpression>(_ string: S, range: R) where R.Bound == String.Index {
        self._h1 = RabinKarpHasher(string.utf8, range: range, q: _q1)
        self._h2 = RabinKarpHasher(string.utf8, range: range, q: _q2)
    }
    
    @discardableResult
    @inline(__always)
    mutating func rollHashValue() -> Bool {
        defer { _h2.rollHashValue() }
        
        return _h1.rollHashValue()
    }
    
    func hasSameHash<T>(of other: DoubleRollingHasher<T>) -> Bool {
        other._h1.rollingHashValue == _h1.rollingHashValue && other._h2.rollingHashValue == _h2.rollingHashValue
    }
    
}

// These two different modulo values are randomly generated once at runtime
// and are kept the same during the runtime of the application.
fileprivate let (_q1, _q2): (Int, Int) = {
    let q1 = LargePrimes.randomLargePrime()
    var q2 = LargePrimes.randomLargePrime()
    while q1 == q2 {
        q2 = LargePrimes.randomLargePrime()
    }
    
    return (q1, q2)
}()
