import CoreText
import UIKit

/// 번들에 포함된 Gothic A1 폰트를 Info.plist 등록 없이 런타임에 등록한다.
/// 폰트 파일이 없으면 시스템 폰트로 대체되므로 빌드는 깨지지 않는다.
enum FontRegistrar {
    // 최초 접근 시 한 번만 등록 (Preview에서도 동작하도록 lazy 처리)
    private static let availableWeights: Set<MoSSFontWeight> = {
        let urls = (Bundle.main.urls(forResourcesWithExtension: "ttf", subdirectory: nil) ?? [])
            + (Bundle.main.urls(forResourcesWithExtension: "otf", subdirectory: nil) ?? [])

        for url in urls {
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }

        let available = Set(MoSSFontWeight.allCases.filter { UIFont(name: $0.fontName, size: 12) != nil })

        #if DEBUG
        let missing = MoSSFontWeight.allCases.filter { !available.contains($0) }.map(\.fontName)
        if !missing.isEmpty {
            print("[FontRegistrar] 시스템 폰트로 대체됨: \(missing.joined(separator: ", "))")
        }
        #endif

        return available
    }()

    static func registerFonts() {
        _ = availableWeights
    }

    static func isAvailable(_ weight: MoSSFontWeight) -> Bool {
        availableWeights.contains(weight)
    }
}
