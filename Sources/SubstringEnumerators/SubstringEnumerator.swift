//
//  SubstringEnumerator.swift
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

/// An algorithm for substrings enumeration.
public enum SubstringEnumerator: CaseIterable {
    /// Knutt-Morris-Pratt algorithm.
    ///
    /// - Complexity:   O(2*n* + *m* ) for its worst case  scenario,
    ///                 where *n* is the length of the string where a substring is searched,
    ///                 and *m* is the length of the substring to search.
    ///                 Tipically O(1.1*n*).
    case KMP
    
    /// Boyer-Moore algorithm.
    ///
    /// - Complexity:   O(*n* \* *m*) for its worst case scenario,
    ///                 where *n* is the length of the string where a substring is searched,
    ///                 and *m* is the length of the substring to search.
    ///                 Tipically O(*n* / *m*).
    case BM
    
    /// Rabin-Karp fingerprint algorithm.
    ///
    /// - Complexity:   This algorithm has O(7*n* + 2*m*) complexity,
    ///                 where *n* is the length of the string where a substring is searched,
    ///                 and *m* is the length of the substring to search.
    /// - Warning:  This algorithm has a 10⁻⁶ mismatch probability since it relies
    ///             only on hash values comparisons as per its *Montecarlo* implementation.
    case RK
    
    /// Rabin-Karp fingerprint algorithm, *Las Vegas* version
    ///
    /// - Complexity:   This algorithm has O(7*n* + 2*m*) complexity,
    ///                 where *n* is the length of the string where a substring is searched,
    ///                 and *m* is the length of the substring to search.
    case RKLasVegas
    
}
