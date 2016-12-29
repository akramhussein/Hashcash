//
//  String+Crypto.swift
//  Hashcash (https://github.com/akramhussein/Hashcash)
//
//  Copyright (c) 2016 Akram Hussein
//

import Foundation
import CommonCrypto

extension String {
    public var sha256 : String? {
        guard let stringData = self.data(using: String.Encoding.utf8) else {
            return nil
        }
        return hexStringFromData(input: digest(input: stringData))
    }

    private func digest(input: Data) -> Data {
        var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
        input.withUnsafeBytes { _ = CC_SHA256($0, CC_LONG(input.count), &hash) }
        return Data(bytes: hash)
    }

    private func hexStringFromData(input: Data) -> String {
        var string = ""
        input.enumerateBytes { pointer, count, _ in
            for i in 0..<count {
                string += String(format: "%02x", pointer[i])
            }
        }
        return string
    }
}
