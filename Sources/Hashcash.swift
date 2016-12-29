//
//  Hashcash.swift
//  Hashcash (https://github.com/akramhussein/Hashcash)
//
//  Copyright (c) 2016 Akram Hussein
//

import Foundation
import CommonCrypto

/**
	Generates new hashcash stamp for a given resource and bit length

	- parameter stamp: stamp to check e.g. 1:16:040922:foo::+ArSrtKd:164b3
	- parameter bits: bits of collision (default is 20)
	- parameter ext: additional information to add to the stamp. Specify as 'name1=2,3;name2;name3=var1=2,2,val'
	- parameter stampSeconds: whether or not to include time in datestamp (i.e. yyMMddHHmmss vs yyMMdd)
	- parameter saltCharacters: length of salt to use (defaults is 16)

	- returns: hashcash stamp
 */
public func mint(resource: String,
                 bits: UInt = 20,
                 ext: String = "",
                 saltCharacters: UInt = 16,
                 stampSeconds: Bool = false) -> String? {

    let ver = "1"

    let formatter = DateFormatter()
    formatter.dateFormat = stampSeconds ? "yyMMddHHmmss" : "yyMMdd"

    let ts = formatter.string(from: Date())
    let challenge = "\(ver):\(bits):\(ts):\(resource):\(ext):\(salt(length: saltCharacters))"

    var counter = 0
    let hexDigits = Int(ceil((Double(bits) / 4)))
    let zeros = String(repeating: "0", count: hexDigits)

    while true {
        let hexCounter = String(format:"%2X", counter).trimmingCharacters(in: .whitespaces)
        guard let digest = ("\(challenge):\(hexCounter)").sha256 else {
            print("ERROR: Can't generate SHA256 digest")
            return nil
        }

        let endIndex = digest.index(digest.startIndex, offsetBy: hexDigits)
        if digest.substring(to: endIndex) == zeros {
            let hexCounter = String(format:"%2X", counter).trimmingCharacters(in: .whitespaces)
            return "\(challenge):\(hexCounter)"
        }
        counter += 1
    }
}

/**
	Checks whether a stamp is valid

	- parameter stamp: stamp to check e.g. 1:16:040922:foo::+ArSrtKd:164b3
	- parameter resource: resource to check against
	- parameter bits: minimum bit value to check
	- parameter expiration: number of seconds old the stamp may be

	- returns: true if stamp is valid
 */
public func check(stamp: String,
               resource: String? = nil,
                   bits: UInt,
             expiration: UInt? = nil) -> Bool {

    guard let stamped = Stamp(stamp: stamp) else {
        print("Invalid stamp format")
        return false
    }

    if let res = resource, res != stamped.resource {
        print("Resources do not match")
        return false
    }

    var count = bits
    if let claim = stamped.claim {
        if bits > claim {
            return false
        } else {
            count = claim
        }
    }

    if let expiration = expiration {
        let goodUntilDate = Date(timeIntervalSinceNow: TimeInterval(expiration))
        if (stamped.date < goodUntilDate) {
            return false
        }
    }

    guard let digest = stamp.sha256 else {
        return false
    }

    let hexDigits = Int(ceil((Double(count) / 4)))
    return digest.hasPrefix(String(repeating: "0", count: hexDigits))
}

/**
	Generates random string of chosen length

	- parameter length:	length of random string

	- returns: random string
 */
internal func salt(length: UInt) -> String {
    let allowedCharacters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ+/="
    var result = ""

    for _ in 0..<length {
        let randomValue = arc4random_uniform(UInt32(allowedCharacters.characters.count))
        result += "\(allowedCharacters[allowedCharacters.index(allowedCharacters.startIndex, offsetBy: Int(randomValue))])"
    }
    return result
}
