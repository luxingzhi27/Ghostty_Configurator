import Foundation
import SwiftUI

@MainActor
class ConfigManager: ObservableObject {
    // MARK: - Font Settings
    @Published var fontFamily: String = ""
    @Published var fontSize: String = ""
    @Published var fontFeature: String = ""
    @Published var adjustCellWidth: String = ""
    @Published var adjustCellHeight: String = ""

    // MARK: - Theme & Colors
    @Published var theme: String = ""
    @Published var autoTheme: Bool = false
    @Published var lightTheme: String = ""
    @Published var darkTheme: String = ""
    @Published var backgroundOpacity: Double = 1.0
    @Published var backgroundBlur: String = "false"
    
    // MARK: - Cursor
    @Published var cursorStyle: String = "block"
    @Published var cursorStyleBlink: Bool = true

    @Published var configPath: String = ""

    private let configURL: URL
    private var rawLines: [String] = []

    init() {
        let homeDir = FileManager.default.homeDirectoryForCurrentUser
        self.configURL = homeDir.appendingPathComponent("Library/Application Support/com.mitchellh.ghostty/config")
        self.configPath = self.configURL.path
    }

    func loadConfig() {
        guard FileManager.default.fileExists(atPath: configURL.path) else {
            print("Config file not found at \(configURL.path), using defaults.")
            return
        }

        do {
            let configString = try String(contentsOf: configURL, encoding: .utf8)
            self.rawLines = configString.components(separatedBy: .newlines)
            parseConfig(lines: self.rawLines)
        } catch {
            print("Failed to read config file: \(error)")
        }
    }

    private func parseConfig(lines: [String]) {
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty || trimmed.hasPrefix("#") { continue }

            let parts = trimmed.split(separator: "=", maxSplits: 1).map { String($0).trimmingCharacters(in: .whitespaces) }
            if parts.count == 2 {
                let key = parts[0]
                let value = parts[1].trimmingCharacters(in: CharacterSet(charactersIn: "\""))
                
                switch key {
                case "font-family": self.fontFamily = value
                case "font-size": self.fontSize = value
                case "font-feature": self.fontFeature = value
                case "adjust-cell-width": self.adjustCellWidth = value
                case "adjust-cell-height": self.adjustCellHeight = value
                    
                case "theme":
                    if value.contains("light:") || value.contains("dark:") {
                        self.autoTheme = true
                        let parts = value.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                        for part in parts {
                            if part.hasPrefix("light:") {
                                self.lightTheme = String(part.dropFirst(6)).trimmingCharacters(in: .whitespaces)
                            } else if part.hasPrefix("dark:") {
                                self.darkTheme = String(part.dropFirst(5)).trimmingCharacters(in: .whitespaces)
                            }
                        }
                    } else {
                        self.autoTheme = false
                        self.theme = value
                    }
                case "background-opacity":
                    self.backgroundOpacity = Double(value) ?? 1.0
                case "background-blur": self.backgroundBlur = value
                    
                case "cursor-style": self.cursorStyle = value
                case "cursor-style-blink": self.cursorStyleBlink = (value == "true")
                    
                default: break
                }
            }
        }
    }

    func saveConfig() -> Bool {
        var newLines = [String]()
        var updatedKeys = Set<String>()

        func processKey(_ key: String, newValue: String?) -> String? {
            updatedKeys.insert(key)
            guard let val = newValue, !val.isEmpty else { return nil }
            return "\(key) = \(val)"
        }

        for line in rawLines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty || trimmed.hasPrefix("#") {
                newLines.append(line)
                continue
            }

            let parts = trimmed.split(separator: "=", maxSplits: 1).map { String($0).trimmingCharacters(in: .whitespaces) }
            if parts.count == 2 {
                let key = parts[0]
                var processedLine: String?
                
                switch key {
                case "font-family": processedLine = processKey(key, newValue: fontFamily.isEmpty ? nil : "\"\(fontFamily)\"")
                case "font-size": processedLine = processKey(key, newValue: fontSize)
                case "font-feature": processedLine = processKey(key, newValue: fontFeature)
                case "adjust-cell-width": processedLine = processKey(key, newValue: adjustCellWidth)
                case "adjust-cell-height": processedLine = processKey(key, newValue: adjustCellHeight)
                    
                case "theme": 
                    let themeValue = autoTheme ? "light:\(lightTheme.isEmpty ? "default" : lightTheme),dark:\(darkTheme.isEmpty ? "default" : darkTheme)" : theme
                    processedLine = processKey(key, newValue: themeValue)
                case "background-opacity": processedLine = processKey(key, newValue: String(format: "%.2f", backgroundOpacity))
                case "background-blur": processedLine = processKey(key, newValue: backgroundBlur)
                    
                case "cursor-style": processedLine = processKey(key, newValue: cursorStyle)
                case "cursor-style-blink": processedLine = processKey(key, newValue: cursorStyleBlink ? "true" : "false")
                    
                default: processedLine = line // Keep unrecognized lines
                }
                
                if let validLine = processedLine {
                    newLines.append(validLine)
                }
            } else {
                newLines.append(line)
            }
        }

        // Add new keys if not empty
        let additions: [(String, String)] = [
            ("font-family", fontFamily.isEmpty ? "" : "\"\(fontFamily)\""),
            ("font-size", fontSize),
            ("font-feature", fontFeature),
            ("adjust-cell-width", adjustCellWidth),
            ("adjust-cell-height", adjustCellHeight),
            ("theme", autoTheme ? "light:\(lightTheme.isEmpty ? "default" : lightTheme),dark:\(darkTheme.isEmpty ? "default" : darkTheme)" : theme),
            ("background-opacity", backgroundOpacity < 1.0 ? String(format: "%.2f", backgroundOpacity) : ""),
            ("background-blur", backgroundBlur != "false" ? backgroundBlur : ""),
            ("cursor-style", cursorStyle),
            ("cursor-style-blink", cursorStyleBlink ? "true" : "false")
        ]
        
        for (key, value) in additions {
            if !updatedKeys.contains(key) && !value.isEmpty {
                newLines.append("\(key) = \(value)")
            }
        }

        // Write backup
        do {
            if FileManager.default.fileExists(atPath: configURL.path) {
                let backupURL = configURL.appendingPathExtension("bak")
                try? FileManager.default.removeItem(at: backupURL)
                try FileManager.default.copyItem(at: configURL, to: backupURL)
            }

            let configDirectory = configURL.deletingLastPathComponent()
            if !FileManager.default.fileExists(atPath: configDirectory.path) {
                try FileManager.default.createDirectory(at: configDirectory, withIntermediateDirectories: true, attributes: nil)
            }
            
            let outputString = newLines.joined(separator: "\n") + "\n"
            try outputString.write(to: configURL, atomically: true, encoding: .utf8)
            print("Successfully saved config to \(configURL.path)")
            
            self.rawLines = newLines
            return true
        } catch {
            print("Failed to save config: \(error)")
            return false
        }
    }
}
