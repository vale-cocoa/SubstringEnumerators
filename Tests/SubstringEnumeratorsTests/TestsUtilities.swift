//
//  TestsUtilities.swift
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

let testError = NSError(domain: "com.vdl.substringEnumerators.testError", code: 101, userInfo: nil)

let urlToRandomPage = Bundle.module.url(forResource: "randompage", withExtension: "txt")!

let randomPage = try! String(contentsOf: urlToRandomPage)

// Test environment stuff adopting an html file in TestData: testpage.html
let urlToHtmlPage = Bundle.module.url(forResource: "testpage", withExtension: "html")!

let headHTMLTag = "<head>"

let stringFromTestPageHTMLFile = try! String(contentsOf: urlToHtmlPage, encoding: .utf8)

let streamOfTestPageHTMLFile = InputStream(url: urlToHtmlPage)!

let rangeOfHeadHTMLTagInTestPageHTML: Range<String.Index> = stringFromTestPageHTMLFile.range(of: headHTMLTag)!

let rangeOfHeadHTMLTagInStreamFromTestPageHTML: Range<Int> = {
    let s = stringFromTestPageHTMLFile
    let r = rangeOfHeadHTMLTagInTestPageHTML
    
    return s.distance(from: s.startIndex, to: r.lowerBound)..<s.distance(from: s.startIndex, to: r.upperBound)
}()

// Test environment stuff with example from Algorithms 4th Edition by Robert Sedgewick
let bookExamplePattern = "ABABAC"

let bookExampleText = "AABACAABABACAA"

let rangeOfBookExample = bookExampleText.range(of: bookExamplePattern)!






