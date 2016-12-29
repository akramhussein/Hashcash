import PackageDescription

let package = Package(
    name: "Hashcash",
    targets: [],
    dependencies: [
        .Package(url: "https://github.com/akramhussein/CommonCrypto.git", versions: Version(0,2,1) ..< Version(1,0,0))
    ]
)
