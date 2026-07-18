import Foundation

struct DotEnvEnvironment: EnvironmentConfigProviding {
    private let values: [String: String]

    init(values: [String: String]) {
        self.values = values
    }

    init(contents: String) {
        self.values = Self.parse(contents)
    }

    init?(bundle: Bundle = .main) {
        let candidates: [(name: String, ext: String?)] = [
            (".env", nil),
            ("env", nil),
            ("env", "env"),
            ("Environment", "env")
        ]

        for candidate in candidates {
            if let url = bundle.url(forResource: candidate.name, withExtension: candidate.ext),
               let contents = try? String(contentsOf: url, encoding: .utf8) {
                self.values = Self.parse(contents)
                return
            }
        }
        return nil
    }

    func value(forKey key: String) -> String? {
        guard let value = values[key], !value.isEmpty else { return nil }
        return value
    }

    nonisolated static func parse(_ contents: String) -> [String: String] {
        var result: [String: String] = [:]

        for rawLine in contents.split(whereSeparator: \.isNewline) {
            let line = rawLine.trimmingCharacters(in: .whitespaces)
            guard !line.isEmpty, !line.hasPrefix("#") else { continue }
            guard let separator = line.firstIndex(of: "=") else { continue }

            let key = line[..<separator].trimmingCharacters(in: .whitespaces)
            guard !key.isEmpty else { continue }

            var value = line[line.index(after: separator)...].trimmingCharacters(in: .whitespaces)

            if !(value.hasPrefix("\"") || value.hasPrefix("'")),
               let hashIndex = value.firstIndex(of: "#") {
                value = String(value[..<hashIndex]).trimmingCharacters(in: .whitespaces)
            }

            if value.count >= 2 {
                let first = value.first!
                let last = value.last!
                if (first == "\"" && last == "\"") || (first == "'" && last == "'") {
                    value = String(value.dropFirst().dropLast())
                }
            }

            result[key] = value
        }

        return result
    }
}
