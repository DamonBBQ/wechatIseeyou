import Darwin
import XCTest
@testable import WeChatTweak

final class HostPlatformTests: XCTestCase {
    private func platform(
        chip: String?,
        model: String? = "Mac14,12",
        arm64: Bool = true,
        environment: [String: String] = [:]
    ) -> HostPlatform {
        HostPlatform.current(environment: environment) { key in
            switch key {
            case "hw.optional.arm64": return arm64 ? "1" : "0"
            case "machdep.cpu.brand_string": return chip
            case "hw.model": return model
            default: return nil
            }
        }
    }

    func testRecognizesM2Family() {
        for chip in ["Apple M2", "Apple M2 Pro", "Apple M2 Max", "Apple M2 Ultra"] {
            let host = platform(chip: chip)
            XCTAssertEqual(host.architecture, .arm64)
            XCTAssertTrue(host.isAppleSilicon)
            XCTAssertTrue(host.isM2, chip)
        }
    }

    func testDoesNotMisidentifyOtherAppleSilicon() {
        XCTAssertFalse(platform(chip: "Apple M1").isM2)
        XCTAssertFalse(platform(chip: "Apple M3 Pro").isM2)
        XCTAssertFalse(platform(chip: "Apple M4 Max").isM2)
    }

    func testIntelHostUsesX86_64() {
        let host = platform(chip: "Intel Core i7", model: "Mac15,6", arm64: false)
        XCTAssertEqual(host.architecture, .x86_64)
        XCTAssertFalse(host.isAppleSilicon)
        XCTAssertFalse(host.isM2)
    }

    func testRosettaOverrideChangesPatchArchButNotChipIdentity() {
        let host = platform(
            chip: "Apple M2 Pro",
            environment: ["WECHATTWEAK_HOST_ARCH": "x86_64"]
        )
        XCTAssertEqual(host.architecture, .x86_64)
        XCTAssertTrue(host.isAppleSilicon)
        XCTAssertTrue(host.isM2)
        XCTAssertTrue(host.summary.contains("x86_64, Apple Silicon"))
    }

    func testUnknownChipStillUsesHardwareArchitecture() {
        let host = platform(chip: nil, model: nil)
        XCTAssertEqual(host.architecture, .arm64)
        XCTAssertTrue(host.isAppleSilicon)
        XCTAssertFalse(host.isM2)
        XCTAssertEqual(host.summary, "Unknown Mac — arm64, Apple Silicon")
    }

    func testM2SummaryIncludesChipModelAndArchitecture() {
        let host = platform(chip: "Apple M2 Pro")
        XCTAssertEqual(host.summary, "Apple M2 Pro (Mac14,12) — arm64, Apple Silicon")
    }

    func testLiveProbeReadsArm64CapabilityAsInteger() {
        var value: Int32 = 0
        var size = MemoryLayout<Int32>.size
        XCTAssertEqual(sysctlbyname("hw.optional.arm64", &value, &size, nil, 0), 0)
        let expected: Config.Arch = value == 1 ? .arm64 : .x86_64
        XCTAssertEqual(HostPlatform.current(environment: [:]).architecture, expected)
    }
}
