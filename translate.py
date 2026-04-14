import re

keys = [
    "Theme & Colors",
    "Font & Typography",
    "Cursor",
    "Configuration File",
    "Save Configuration",
    "Current Theme",
    "Light Theme",
    "Dark Theme",
    "Default (Built-in)",
    "Theme Mode",
    "Mode",
    "Single",
    "Auto (Light/Dark)",
    "Editing",
    "Light",
    "Dark",
    "Background Effects",
    "Opacity",
    "Enable Background Blur",
    "Effects",
    "Background Blur",
    "Primary Font",
    "Family:",
    "Ghostty Default (JetBrains Mono)",
    "Size:",
    "Typography Features",
    "Coding Ligatures",
    "Combines characters like != or -> into a single symbol.",
    "Slashed Zero",
    "Adds a diagonal slash to the number zero.",
    "Advanced (Raw):",
    "Cell Dimensions",
    "Width Adjust:",
    "Height Adjust:",
    "Live Preview",
    "Cursor Appearance",
    "Shape & Behavior",
    "Style",
    "Block",
    "Bar",
    "Underline",
    "Hollow Block",
    "Blinking Cursor",
    "Language",
    "Auto",
    "English",
    "Chinese (Simplified)",
    "Japanese",
]

with open(
    "/Users/rayhua/Projects/ghostty-configurator/Sources/GhosttyConfigurator/ContentView.swift",
    "r",
) as f:
    content = f.read()

# Add EnvironmentObject
if "@EnvironmentObject var lang: LanguageManager" not in content:
    content = content.replace(
        "@StateObject private var configManager = ConfigManager()",
        "@EnvironmentObject var lang: LanguageManager\n    @StateObject private var configManager = ConfigManager()",
    )
    content = content.replace(
        "struct ThemeSettingsView: View {",
        "struct ThemeSettingsView: View {\n    @EnvironmentObject var lang: LanguageManager",
    )
    content = content.replace(
        "struct FontSettingsView: View {",
        "struct FontSettingsView: View {\n    @EnvironmentObject var lang: LanguageManager",
    )
    content = content.replace(
        "struct CursorSettingsView: View {",
        "struct CursorSettingsView: View {\n    @EnvironmentObject var lang: LanguageManager",
    )

# Tab raw value translation
content = content.replace("Text(tab.rawValue)", "Text(lang.t(tab.rawValue))")

# String wrapper
for key in keys:
    # We want to replace Text("...") with Text(lang.t("..."))
    # Also Picker("...", ...) with Picker(lang.t("..."), ...)
    # Also GroupBox(label: Text("...").font(.headline)) with GroupBox(label: Text(lang.t("...")).font(.headline))

    # Exact match for Text
    content = content.replace(f'Text("{key}")', f'Text(lang.t("{key}"))')
    content = content.replace(f'Picker("{key}"', f'Picker(lang.t("{key}")')

# Bottom language picker
# Add it near "Configuration File"
lang_picker = """
                    HStack(spacing: 8) {
                        Image(systemName: "globe")
                            .foregroundColor(.secondary)
                        Picker("", selection: $lang.language) {
                            Text(lang.t("Auto")).tag("auto")
                            Text(lang.t("English")).tag("en")
                            Text(lang.t("Chinese (Simplified)")).tag("zh")
                            Text(lang.t("Japanese")).tag("ja")
                        }
                        .labelsHidden()
                        .frame(width: 120)
                    }
                    .padding(.leading, 12)
"""

if 'Image(systemName: "globe")' not in content:
    old_code = """                        Text(configManager.configPath)
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(.secondary)
                    }"""
    new_code = old_code + "\n" + lang_picker
    content = content.replace(old_code, new_code)

with open(
    "/Users/rayhua/Projects/ghostty-configurator/Sources/GhosttyConfigurator/ContentView.swift",
    "w",
) as f:
    f.write(content)
