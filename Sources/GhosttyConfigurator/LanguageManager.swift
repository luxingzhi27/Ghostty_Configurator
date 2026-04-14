import Foundation
import SwiftUI

@MainActor
class LanguageManager: ObservableObject {
    static let shared = LanguageManager()
    
    @AppStorage("AppLanguage") var language: String = "auto" {
        didSet {
            self.objectWillChange.send()
        }
    }
    
    var effectiveLanguage: String {
        if language == "auto" {
            let sys = Locale.current.language.languageCode?.identifier ?? "en"
            if sys.hasPrefix("zh") { return "zh" }
            if sys.hasPrefix("ja") { return "ja" }
            return "en"
        }
        return language
    }
    
    func t(_ key: String) -> String {
        return translations[effectiveLanguage]?[key] ?? key
    }
    
    private let translations: [String: [String: String]] = [
        "zh": [
            "Theme & Colors": "主题与颜色",
            "Font & Typography": "字体与排版",
            "Cursor": "光标",
            "Configuration File": "配置文件",
            "Save Configuration": "保存配置",
            "Current Theme": "当前主题",
            "Light Theme": "浅色主题",
            "Dark Theme": "深色主题",
            "Default (Built-in)": "默认 (内置)",
            "Theme Mode": "主题模式",
            "Mode": "模式",
            "Single": "单色",
            "Auto (Light/Dark)": "自动 (随系统)",
            "Editing": "编辑目标",
            "Light": "浅色",
            "Dark": "深色",
            "Background Effects": "背景特效",
            "Opacity": "不透明度",
            "Enable Background Blur": "启用背景模糊",
            "Effects": "特效",
            "Background Blur": "背景模糊",
            
            // Fonts
            "Primary Font": "主字体",
            "Family:": "字体系列：",
            "Ghostty Default (JetBrains Mono)": "Ghostty 默认 (JetBrains Mono)",
            "Size:": "字号：",
            "Typography Features": "排版特性",
            "Coding Ligatures": "代码连字",
            "Combines characters like != or -> into a single symbol.": "将 != 或 -> 等组合成单字符符号。",
            "Slashed Zero": "带斜杠的零",
            "Adds a diagonal slash to the number zero.": "为数字 0 添加对角斜杠。",
            "Advanced (Raw):": "高级指令 (Raw)：",
            "Cell Dimensions": "字符单元格尺寸",
            "Width Adjust:": "宽度调整：",
            "Height Adjust:": "高度调整：",
            "Live Preview": "实时预览",
            
            // Cursor
            "Cursor Appearance": "光标外观",
            "Shape & Behavior": "形状与行为",
            "Style": "样式",
            "Block": "方块",
            "Bar": "竖线",
            "Underline": "下划线",
            "Hollow Block": "空心方块",
            "Blinking Cursor": "光标闪烁",
            
            // Languages
            "Language": "语言",
            "Language / 语言": "Language / 语言",
            "Auto": "自动随系统",
            "English": "English",
            "Chinese (Simplified)": "简体中文",
            "Japanese": "日本語"
        ],
        "ja": [
            "Theme & Colors": "テーマとカラー",
            "Font & Typography": "フォントとタイポグラフィ",
            "Cursor": "カーソル",
            "Configuration File": "設定ファイル",
            "Save Configuration": "設定を保存",
            "Current Theme": "現在のテーマ",
            "Light Theme": "ライトテーマ",
            "Dark Theme": "ダークテーマ",
            "Default (Built-in)": "デフォルト (組み込み)",
            "Theme Mode": "テーマモード",
            "Mode": "モード",
            "Single": "シングル",
            "Auto (Light/Dark)": "自動 (システム)",
            "Editing": "編集中",
            "Light": "ライト",
            "Dark": "ダーク",
            "Background Effects": "背景エフェクト",
            "Opacity": "不透明度",
            "Enable Background Blur": "背景のぼかしを有効にする",
            "Effects": "エフェクト",
            "Background Blur": "背景のぼかし",
            
            // Fonts
            "Primary Font": "メインフォント",
            "Family:": "フォント：",
            "Ghostty Default (JetBrains Mono)": "Ghostty デフォルト (JetBrains Mono)",
            "Size:": "サイズ：",
            "Typography Features": "タイポグラフィ機能",
            "Coding Ligatures": "コードリガチャ",
            "Combines characters like != or -> into a single symbol.": "!= や -> などの文字を1つの記号に結合します。",
            "Slashed Zero": "スラッシュ付きゼロ",
            "Adds a diagonal slash to the number zero.": "数字の0に斜めのスラッシュを追加します。",
            "Advanced (Raw):": "高度な設定 (Raw)：",
            "Cell Dimensions": "セルの寸法",
            "Width Adjust:": "幅の調整：",
            "Height Adjust:": "高さの調整：",
            "Live Preview": "ライブプレビュー",
            
            // Cursor
            "Cursor Appearance": "カーソルの外観",
            "Shape & Behavior": "形状と動作",
            "Style": "スタイル",
            "Block": "ブロック",
            "Bar": "バー",
            "Underline": "アンダーライン",
            "Hollow Block": "ホロウブロック",
            "Blinking Cursor": "カーソルの点滅",
            
            // Languages
            "Language": "言語",
            "Language / 语言": "Language / 言語",
            "Auto": "システム自動",
            "English": "English",
            "Chinese (Simplified)": "简体中文",
            "Japanese": "日本語"
        ]
    ]
}
