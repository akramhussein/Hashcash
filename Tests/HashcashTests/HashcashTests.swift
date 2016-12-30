//
//  HashcashTests.swift
//  Hashcash ( https://github.com/akramhussein/Hashcash )
//
//  Copyright (c) 2017 Akram Hussein
//

import XCTest
@testable import Hashcash

class HashcashTests: XCTestCase {
    func testSaltLength() {
        XCTAssertEqual(salt(length: 0).characters.count, 0)
        XCTAssertEqual(salt(length: 1).characters.count, 1)
        XCTAssertEqual(salt(length: 20).characters.count, 20)
    }

    func testCreateValidStampVersion0() {
        let stamp = "0:040922:foo:1=12,2=4"
        let s = Stamp(stamp: stamp)

        let df = DateFormatter()
        df.dateFormat = "yyMMdd"
        let d = df.date(from: "040922")

        XCTAssertEqual(s?.version, 0)
        XCTAssertEqual(s?.date, d)
        XCTAssertEqual(s?.resource, "foo")
        XCTAssertEqual(s?.suffix, "1=12,2=4")
    }

    func testCreateInvalidStampVersion0() {
        let stamp = "0:040922"
        let s = Stamp(stamp: stamp)

        XCTAssertNil(s)
    }

    func testCreateValidStampVersion1() {
        let stamp = "1:16:040922:foo:1=12,2=4:+ArSrtKd:164b3"
        let s = Stamp(stamp: stamp)

        let df = DateFormatter()
        df.dateFormat = "yyMMdd"
        let d = df.date(from: "040922")

        XCTAssertEqual(s?.version, 1)
        XCTAssertEqual(s?.claim, 16)
        XCTAssertEqual(s?.date, d)
        XCTAssertEqual(s?.resource, "foo")
        XCTAssertEqual(s?.ext, "1=12,2=4")
        XCTAssertEqual(s?.random, "+ArSrtKd")
        XCTAssertEqual(s?.counter, "164b3")
    }

    func testCreateInvalidStampVersion1() {
        let stamp = "foo:1=12,2=4:+ArSrtKd:164b3"
        let s = Stamp(stamp: stamp)

        XCTAssertNil(s)
    }

    func testCreateInvalidStampWrongVersion() {
        let stamp = "2:16:040922:foo:1=12,2=4:+ArSrtKd:164b3"
        let s = Stamp(stamp: stamp)

        XCTAssertNil(s)
    }

    func testMintValid() {
        let stamp = mint(resource: "foo", bits: 8)
        XCTAssertNotNil(stamp)

        let stampCheck = check(stamp: stamp!, resource: "foo", bits: 8)
        XCTAssertTrue(stampCheck)
    }

    func testMintDifferentResource() {
        let stamp = mint(resource: "foo", bits: 8)
        XCTAssertNotNil(stamp)

        let stampCheck = check(stamp: stamp!, resource: "bar", bits: 8)
        XCTAssertFalse(stampCheck)
    }

    func testMintDifferentBits() {
        let stamp = mint(resource: "foo", bits: 8)
        XCTAssertNotNil(stamp)

        let stampCheck = check(stamp: stamp!, resource: "foo", bits: 12)
        XCTAssertFalse(stampCheck)
    }

    func testCheckNotExpired() {
        let stamp = mint(resource: "foo", bits: 8)
        XCTAssertNotNil(stamp)

        let stampCheck = check(stamp: stamp!, resource: "foo", bits: 8, expiration: 3600)
        XCTAssertTrue(stampCheck)
    }

    static var allTests : [(String, (HashcashTests) -> () throws -> Void)] {
        return [
            ("testSaltLength", testSaltLength),
            ("testCreateValidStampVersion0", testCreateValidStampVersion0),
            ("testCreateInvalidStampVersion0", testCreateInvalidStampVersion0),
            ("testCreateValidStampVersion1", testCreateValidStampVersion1),
            ("testCreateInvalidStampVersion1", testCreateInvalidStampVersion1),
            ("testCreateInvalidStampWrongVersion", testCreateInvalidStampWrongVersion),
            ("testMintValid", testMintValid),
            ("testMintDifferentResource", testMintDifferentResource),
            ("testMintDifferentBits", testMintDifferentBits),
            ("testCheckNotExpired", testCheckNotExpired),
        ]
    }
}
