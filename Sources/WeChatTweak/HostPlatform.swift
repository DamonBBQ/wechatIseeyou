import Darwin
import Foundation

struct HostPlatform {
    let architecture: Config.Arch
    let chip: String?
    let model: String?

    var isAppleSilicon: Bool {
        chip?.lowercased().hasPrefix("apple m") == true || (chip == nil && architecture == .arm64)
    }

    var isM2: Bool {
        chip?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased().hasPrefix("apple m2") == true
    }

    var summary: String {
        var parts: [String] = []
        if let chip, !chip.isEmpty { parts.append(chip) }
        if let model, !model.isEmpty { parts.append("(\(model))") }
        let name = parts.isEmpty ? "Unknown Mac" : parts.joined(separator: " ")
        let platform = isAppleSilicon ? "Apple Silicon" : "Intel"
        return "\(name) — \(architecture.rawValue), \(platform)"
    }

    static func current(
        environment: [String: String] = ProcessInfo.processInfo.environment,
        sysctl: (String) -> String? = HostPlatform.sysctlString
    ) -> HostPlatform {
        let chip = sysctl("machdep.cpu.brand_string")
        let model = sysctl("hw.model")
        if let forced = environment["WECHATTWEAK_HOST_ARCH"],
           let architecture = Config.Arch(rawValue: forced) {
            return HostPlatform(architecture: architecture, chip: chip, model: model)
        }
        let architecture: Config.Arch = sysctl("hw.optional.arm64") == "1" ? .arm64 : .x86_64
        return HostPlatform(architecture: architecture, chip: chip, model: model)
    }

    private static func sysctlString(_ name: String) -> String? {
        if name == "hw.optional.arm64" {
            var value: Int32 = 0
            var size = MemoryLayout<Int32>.size
            guard sysctlbyname(name, &value, &size, nil, 0) == 0 else { return nil }
            return value == 1 ? "1" : "0"
        }
        var size = 0
        guard sysctlbyname(name, nil, &size, nil, 0) == 0, size > 1 else { return nil }
        var buffer = [CChar](repeating: 0, count: size)
        guard sysctlbyname(name, &buffer, &size, nil, 0) == 0 else { return nil }
        let bytes = buffer.prefix { $0 != 0 }.map { UInt8(bitPattern: $0) }
        let value = String(decoding: bytes, as: UTF8.self).trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty ? nil : value
    }
}
