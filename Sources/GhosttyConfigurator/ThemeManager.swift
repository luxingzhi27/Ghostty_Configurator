import Foundation
import SwiftUI

struct GhosttyTheme: Identifiable, Hashable {
    let id: String
    let name: String
    let background: Color?
    let foreground: Color?
    let palette: [Int: Color]
}

@MainActor
class ThemeManager: ObservableObject {
    @Published var availableThemes: [GhosttyTheme] = []
    
    init() {
        loadThemes()
    }
    
    func loadThemes() {
        var themes: [GhosttyTheme] = []
        
        let locations = [
            "/Applications/Ghostty.app/Contents/Resources/ghostty/themes",
            FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library/Application Support/com.mitchellh.ghostty/themes").path
        ]
        
        for location in locations {
            guard let files = try? FileManager.default.contentsOfDirectory(atPath: location) else { continue }
            
            for file in files {
                if file.hasPrefix(".") { continue }
                
                let filePath = (location as NSString).appendingPathComponent(file)
                guard let content = try? String(contentsOfFile: filePath, encoding: .utf8) else { continue }
                
                var bg: Color? = nil
                var fg: Color? = nil
                var palette: [Int: Color] = [:]
                
                let lines = content.components(separatedBy: .newlines)
                for line in lines {
                    let trimmed = line.trimmingCharacters(in: .whitespaces)
                    if trimmed.hasPrefix("background") {
                        let parts = trimmed.split(separator: "=", maxSplits: 1).map { String($0).trimmingCharacters(in: .whitespaces) }
                        if parts.count == 2 {
                            bg = Color(hex: parts[1])
                        }
                    } else if trimmed.hasPrefix("foreground") {
                        let parts = trimmed.split(separator: "=", maxSplits: 1).map { String($0).trimmingCharacters(in: .whitespaces) }
                        if parts.count == 2 {
                            fg = Color(hex: parts[1])
                        }
                    } else if trimmed.hasPrefix("palette") {
                        let parts = trimmed.split(separator: "=").map { String($0).trimmingCharacters(in: .whitespaces) }
                        if parts.count >= 3, let index = Int(parts[1]) {
                            palette[index] = Color(hex: parts[2])
                        }
                    }
                }
                
                themes.append(GhosttyTheme(id: file, name: file, background: bg, foreground: fg, palette: palette))
            }
        }
        
        let sortedThemes = themes.sorted(by: { $0.name.lowercased() < $1.name.lowercased() })
        
        let defaultTheme = GhosttyTheme(
            id: "",
            name: "Default (Built-in)",
            background: Color(red: 0.15, green: 0.15, blue: 0.15),
            foreground: Color(red: 0.9, green: 0.9, blue: 0.9),
            palette: [
                1: Color(hex: "#ff5555"), // Red
                2: Color(hex: "#50fa7b"), // Green
                3: Color(hex: "#f1fa8c"), // Yellow
                4: Color(hex: "#bd93f9"), // Blue
                5: Color(hex: "#ff79c6"), // Magenta
                6: Color(hex: "#8be9fd")  // Cyan
            ]
        )
        
        self.availableThemes = [defaultTheme] + sortedThemes
    }
}
