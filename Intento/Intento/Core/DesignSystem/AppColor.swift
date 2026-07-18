import SwiftUI

enum AppColor {

    enum Primary {
        nonisolated static let s50 = Color(hex: 0xF8F8F6)
        nonisolated static let s100 = Color(hex: 0xF0EEE7)
        nonisolated static let s200 = Color(hex: 0xEBE5D3)
        nonisolated static let s300 = Color(hex: 0xE9DDB9)
        nonisolated static let s400 = Color(hex: 0xECD694)
        nonisolated static let s500 = Color(hex: 0xF8D25D)
        nonisolated static let s600 = Color(hex: 0xF2BF23)
        nonisolated static let s700 = Color(hex: 0xC3970F)
        nonisolated static let s800 = Color(hex: 0x8E6F0D)
        nonisolated static let s900 = Color(hex: 0x624D0B)
    }

    enum Secondary {
        nonisolated static let s50 = Color(hex: 0xF8F8F7)
        nonisolated static let s100 = Color(hex: 0xF4F4F2)
        nonisolated static let s200 = Color(hex: 0xF0F0ED)
        nonisolated static let s300 = Color(hex: 0xECEBE8)
        nonisolated static let s400 = Color(hex: 0xE7E6E2)
        nonisolated static let s500 = Color(hex: 0xE0DFDA)
        nonisolated static let s600 = Color(hex: 0xB9B6AB)
        nonisolated static let s700 = Color(hex: 0x8F8C7B)
        nonisolated static let s800 = Color(hex: 0x686558)
        nonisolated static let s900 = Color(hex: 0x46443C)
    }

    enum Tertiary {
        nonisolated static let s50 = Color(hex: 0xF8F8F7)
        nonisolated static let s100 = Color(hex: 0xEEEDEC)
        nonisolated static let s200 = Color(hex: 0xE3E2E0)
        nonisolated static let s300 = Color(hex: 0xD7D6D2)
        nonisolated static let s400 = Color(hex: 0xC8C7C2)
        nonisolated static let s500 = Color(hex: 0xB6B4AE)
        nonisolated static let s600 = Color(hex: 0x96938B)
        nonisolated static let s700 = Color(hex: 0x737068)
        nonisolated static let s800 = Color(hex: 0x54524D)
        nonisolated static let s900 = Color(hex: 0x3B3935)
    }

    enum Accent {
        nonisolated static let s50 = Color(hex: 0xF8F7F7)
        nonisolated static let s100 = Color(hex: 0xE8E7E5)
        nonisolated static let s200 = Color(hex: 0xD5D4D1)
        nonisolated static let s300 = Color(hex: 0xC2C0BC)
        nonisolated static let s400 = Color(hex: 0xAAA7A2)
        nonisolated static let s500 = Color(hex: 0x8C8881)
        nonisolated static let s600 = Color(hex: 0x73706A)
        nonisolated static let s700 = Color(hex: 0x595652)
        nonisolated static let s800 = Color(hex: 0x43413E)
        nonisolated static let s900 = Color(hex: 0x31302D)
    }

    enum Gray {
        nonisolated static let s50 = Color(hex: 0xFAFAFA)
        nonisolated static let s100 = Color(hex: 0xF5F5F4)
        nonisolated static let s200 = Color(hex: 0xE9E8E7)
        nonisolated static let s300 = Color(hex: 0xD9D7D4)
        nonisolated static let s400 = Color(hex: 0xBCB8B3)
        nonisolated static let s500 = Color(hex: 0x98928B)
        nonisolated static let s600 = Color(hex: 0x726C65)
        nonisolated static let s700 = Color(hex: 0x54504A)
        nonisolated static let s800 = Color(hex: 0x363430)
        nonisolated static let s900 = Color(hex: 0x1E1C1A)
    }

    enum Success {
        nonisolated static let s50 = Color(hex: 0xF6F8F7)
        nonisolated static let s100 = Color(hex: 0xD9E7DE)
        nonisolated static let s200 = Color(hex: 0xB3D8BF)
        nonisolated static let s300 = Color(hex: 0x84CF9C)
        nonisolated static let s400 = Color(hex: 0x42CD6F)
        nonisolated static let s500 = Color(hex: 0x16A343)
        nonisolated static let s600 = Color(hex: 0x148739)
        nonisolated static let s700 = Color(hex: 0x126B2E)
        nonisolated static let s800 = Color(hex: 0x0F5425)
        nonisolated static let s900 = Color(hex: 0x0D411D)
    }

    enum Error {
        nonisolated static let s50 = Color(hex: 0xF8F7F6)
        nonisolated static let s100 = Color(hex: 0xEBE1E0)
        nonisolated static let s200 = Color(hex: 0xE0C5C3)
        nonisolated static let s300 = Color(hex: 0xD8A3A0)
        nonisolated static let s400 = Color(hex: 0xD6746F)
        nonisolated static let s500 = Color(hex: 0xDC2F26)
        nonisolated static let s600 = Color(hex: 0xB42720)
        nonisolated static let s700 = Color(hex: 0x8A201B)
        nonisolated static let s800 = Color(hex: 0x681A16)
        nonisolated static let s900 = Color(hex: 0x4C1411)
    }

    enum Warning {
        nonisolated static let s50 = Color(hex: 0xF8F7F6)
        nonisolated static let s100 = Color(hex: 0xEAE4DC)
        nonisolated static let s200 = Color(hex: 0xE0CFB8)
        nonisolated static let s300 = Color(hex: 0xDCB98B)
        nonisolated static let s400 = Color(hex: 0xE1A04A)
        nonisolated static let s500 = Color(hex: 0xD97E06)
        nonisolated static let s600 = Color(hex: 0xB16808)
        nonisolated static let s700 = Color(hex: 0x895209)
        nonisolated static let s800 = Color(hex: 0x693F08)
        nonisolated static let s900 = Color(hex: 0x4E3007)
    }

    enum Info {
        nonisolated static let s50 = Color(hex: 0xF6F7F8)
        nonisolated static let s100 = Color(hex: 0xE1E5EC)
        nonisolated static let s200 = Color(hex: 0xC5D0E3)
        nonisolated static let s300 = Color(hex: 0xA2B7DE)
        nonisolated static let s400 = Color(hex: 0x7098DF)
        nonisolated static let s500 = Color(hex: 0x256DEB)
        nonisolated static let s600 = Color(hex: 0x1657CA)
        nonisolated static let s700 = Color(hex: 0x134499)
        nonisolated static let s800 = Color(hex: 0x103472)
        nonisolated static let s900 = Color(hex: 0x0D2652)
    }

    enum Semantic {
        nonisolated static let background = AppColor.Gray.s50
        nonisolated static let surface = Color.white
        nonisolated static let surfaceMuted = AppColor.Secondary.s100
        nonisolated static let border = AppColor.Gray.s200
        nonisolated static let borderStrong = AppColor.Gray.s300

        nonisolated static let brand = AppColor.Primary.s500
        nonisolated static let brandStrong = AppColor.Primary.s600
        nonisolated static let onBrand = AppColor.Gray.s900

        nonisolated static let textPrimary = AppColor.Gray.s900
        nonisolated static let textSecondary = AppColor.Gray.s600
        nonisolated static let textTertiary = AppColor.Gray.s500
        nonisolated static let textOnColor = Color.white

        nonisolated static let success = AppColor.Success.s500
        nonisolated static let warning = AppColor.Warning.s500
        nonisolated static let error = AppColor.Error.s500
        nonisolated static let info = AppColor.Info.s500
    }
}
