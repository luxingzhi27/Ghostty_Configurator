import SwiftUI
import AppKit

enum AppTab: String, CaseIterable {
    case theme = "Theme & Colors"
    case font = "Font & Typography"
    case cursor = "Cursor"
}

enum SaveStatus {
    case none
    case success
    case error
}

struct ContentView: View {
    @EnvironmentObject var lang: LanguageManager
    @StateObject private var configManager = ConfigManager()
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var fontManager = FontManager()

    @State private var selectedTab: AppTab = .theme
    @State private var saveStatus: SaveStatus = .none

    var body: some View {
        ZStack {
            // Ambient Background for enhanced Glass Effect
            VisualEffectView(material: .underWindowBackground, blendingMode: .behindWindow, state: .active)
                .ignoresSafeArea()
            
            GeometryReader { proxy in
                Circle()
                    .fill(Color.accentColor.opacity(0.15))
                    .frame(width: proxy.size.width * 0.8)
                    .blur(radius: 120)
                    .offset(x: -proxy.size.width * 0.2, y: -proxy.size.height * 0.2)
                
                Circle()
                    .fill(Color.purple.opacity(0.1))
                    .frame(width: proxy.size.width * 0.7)
                    .blur(radius: 120)
                    .offset(x: proxy.size.width * 0.4, y: proxy.size.height * 0.3)
            }
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Floating Ultra-Glass Tab Bar
                HStack(spacing: 8) {
                    ForEach(AppTab.allCases, id: \.self) { tab in
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedTab = tab
                            }
                        }) {
                            Text(lang.t(tab.rawValue))
                                .font(.system(size: 14, weight: selectedTab == tab ? .semibold : .medium))
                                .padding(.vertical, 10)
                                .padding(.horizontal, 20)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(selectedTab == tab ? Color.accentColor.opacity(0.2) : Color.clear)
                                )
                                .foregroundColor(selectedTab == tab ? .accentColor : .primary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(10)
                .background(
                    VisualEffectView(material: .popover, blendingMode: .withinWindow, state: .active)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        .blendMode(.overlay)
                )
                .padding(.top, 28)
                .padding(.bottom, 16)
                .zIndex(2)

                // Content Area
                ZStack {
                    switch selectedTab {
                    case .theme:
                        ThemeSettingsView(configManager: configManager, themeManager: themeManager)
                            .transition(.asymmetric(insertion: .opacity.combined(with: .scale(scale: 0.98)), removal: .opacity))
                    case .font:
                        FontSettingsView(configManager: configManager, fontManager: fontManager)
                            .transition(.asymmetric(insertion: .opacity.combined(with: .scale(scale: 0.98)), removal: .opacity))
                    case .cursor:
                        CursorSettingsView(configManager: configManager)
                            .transition(.asymmetric(insertion: .opacity.combined(with: .scale(scale: 0.98)), removal: .opacity))
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .zIndex(1)
                
                // Bottom Action Bar
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(lang.t("Configuration File"))
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.secondary)
                        Text(configManager.configPath)
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(.secondary)
                    }

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

                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        if saveStatus == .success {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.system(size: 22))
                                .transition(.scale.combined(with: .opacity))
                        } else if saveStatus == .error {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                                .font(.system(size: 22))
                                .transition(.scale.combined(with: .opacity))
                        }
                        
                        Button(action: {
                            let success = configManager.saveConfig()
                            withAnimation(.spring()) {
                                saveStatus = success ? .success : .error
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                                withAnimation {
                                    saveStatus = .none
                                }
                            }
                        }) {
                            Text(lang.t("Save Configuration"))
                                .font(.system(size: 14, weight: .bold))
                                .padding(.vertical, 10)
                                .padding(.horizontal, 24)
                                .background(Color.accentColor)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .shadow(color: Color.accentColor.opacity(0.3), radius: 5, y: 2)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .background(VisualEffectView(material: .popover, blendingMode: .withinWindow, state: .active))
                .overlay(Rectangle().frame(height: 1).foregroundColor(Color.gray.opacity(0.1)), alignment: .top)
                .zIndex(2)
            }
        }
        .frame(minWidth: 900, minHeight: 750)
        .background(VisualEffectView(material: .underWindowBackground, blendingMode: .behindWindow, state: .active))
        .onAppear {
            configManager.loadConfig()
            themeManager.loadThemes()
        }
    }
}

// MARK: - Theme Card Component
struct ThemeCard: View {
    let theme: GhosttyTheme
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Circle().fill(Color(red: 1.0, green: 0.36, blue: 0.33)).frame(width: 10, height: 10)
                    Circle().fill(Color(red: 1.0, green: 0.76, blue: 0.03)).frame(width: 10, height: 10)
                    Circle().fill(Color(red: 0.15, green: 0.79, blue: 0.25)).frame(width: 10, height: 10)
                    Spacer()
                }
                .padding(.bottom, 2)

                HStack(spacing: 4) {
                    Text("user").foregroundColor(theme.palette[2] ?? Color.green)
                    Text("~").foregroundColor(theme.palette[4] ?? Color.blue)
                    Text("$").foregroundColor(theme.foreground ?? Color.white)
                    Text("ghostty").foregroundColor(theme.palette[3] ?? Color.yellow)
                }
                HStack(spacing: 4) {
                    Text("fast").foregroundColor(theme.palette[5] ?? Color.purple)
                    Text("native").foregroundColor(theme.palette[6] ?? Color.cyan)
                    Text("term").foregroundColor(theme.palette[1] ?? Color.red)
                }

                Spacer(minLength: 0)

                HStack(spacing: 0) {
                    ForEach(1..<7) { i in
                        Rectangle()
                            .fill(theme.palette[i] ?? Color.gray.opacity(0.3))
                            .frame(height: 8)
                    }
                }
                .cornerRadius(4)
            }
            .font(.system(size: 11, weight: .bold, design: .monospaced))
            .padding(10)
            .frame(height: 100)
            .background(theme.background ?? Color(white: 0.1))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.accentColor : Color.gray.opacity(0.2), lineWidth: isSelected ? 3 : 1)
            )
            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)

            Text(theme.name)
                .font(.system(size: 12, weight: isSelected ? .bold : .regular))
                .foregroundColor(isSelected ? Color.accentColor : .primary)
                .lineLimit(1)
                .truncationMode(.tail)
                .padding(.horizontal, 2)
        }
        .padding(6)
        .background(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
        .cornerRadius(10)
        .contentShape(Rectangle())
    }
}

// MARK: - Theme View
struct ThemeSettingsView: View {
    @EnvironmentObject var lang: LanguageManager
    @ObservedObject var configManager: ConfigManager
    @ObservedObject var themeManager: ThemeManager

    let columns = [GridItem(.adaptive(minimum: 150, maximum: 180), spacing: 16)]
    @State private var editingMode: String = "single" // "single", "light", "dark"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Header Area seamlessly integrated
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(editingMode == "single" ? "Current Theme" : (editingMode == "light" ? "Light Theme" : "Dark Theme"))
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.primary)
                        
                        let activeThemeId = editingMode == "single" ? configManager.theme : (editingMode == "light" ? configManager.lightTheme : configManager.darkTheme)
                        let activeThemeName = activeThemeId.isEmpty ? "Default (Built-in)" : themeManager.availableThemes.first(where: { $0.id == activeThemeId })?.name ?? activeThemeId
                        
                        Text(activeThemeName)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.accentColor)
                    }
                    
                    Spacer()
                    
                    // Theme Mode Selector
                    VStack(alignment: .trailing, spacing: 8) {
                        Picker(lang.t("Mode"), selection: $configManager.autoTheme) {
                            Text(lang.t("Single")).tag(false)
                            Text(lang.t("Auto (Light/Dark)")).tag(true)
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 180)
                        .onChange(of: configManager.autoTheme) { oldValue, newValue in
                            if newValue && editingMode == "single" {
                                editingMode = "light"
                            } else if !newValue {
                                editingMode = "single"
                            }
                        }
                        
                        if configManager.autoTheme {
                            Picker(lang.t("Editing"), selection: $editingMode) {
                                Text(lang.t("Light")).tag("light")
                                Text(lang.t("Dark")).tag("dark")
                            }
                            .pickerStyle(.segmented)
                            .frame(width: 180)
                        }
                    }
                }
                .padding(.horizontal, 32)
                .padding(.top, 32)
                .padding(.bottom, 24)
                
                // Effects Inline Bar
                HStack(spacing: 24) {
                    HStack(spacing: 12) {
                        Image(systemName: "circle.lefthalf.filled")
                            .foregroundColor(.secondary)
                        Text(lang.t("Opacity")).foregroundColor(.secondary).font(.system(size: 14))
                        Slider(value: $configManager.backgroundOpacity, in: 0.0...1.0, step: 0.05)
                            .frame(width: 100)
                        Text(String(format: "%.0f%%", configManager.backgroundOpacity * 100))
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundColor(.primary)
                            .frame(width: 40, alignment: .trailing)
                    }
                    
                    Divider().frame(height: 16)
                    
                    Toggle(isOn: Binding(
                        get: { configManager.backgroundBlur == "true" || Int(configManager.backgroundBlur) ?? 0 > 0 },
                        set: { configManager.backgroundBlur = $0 ? "true" : "false" }
                    )) {
                        HStack(spacing: 6) {
                            Image(systemName: "drop")
                                .foregroundColor(.secondary)
                            Text(lang.t("Background Blur")).foregroundColor(.secondary).font(.system(size: 14))
                        }
                    }
                    .toggleStyle(.checkbox)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 24)
                
                Divider()
                    .padding(.horizontal, 32)
                
                // Grid Area
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(themeManager.availableThemes) { theme in
                        let isSelected = (editingMode == "single" && configManager.theme == theme.id) ||
                                         (editingMode == "light" && configManager.lightTheme == theme.id) ||
                                         (editingMode == "dark" && configManager.darkTheme == theme.id)

                        ThemeCard(theme: theme, isSelected: isSelected)
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    if editingMode == "single" {
                                        configManager.theme = theme.id
                                    } else if editingMode == "light" {
                                        configManager.lightTheme = theme.id
                                    } else if editingMode == "dark" {
                                        configManager.darkTheme = theme.id
                                    }
                                }
                            }
                    }
                }
                .padding(32)
            }
        }
        .onAppear {
            if configManager.autoTheme {
                editingMode = "light"
            }
        }
    }
}

// MARK: - Font View
struct FontSettingsView: View {
    @EnvironmentObject var lang: LanguageManager
    @ObservedObject var configManager: ConfigManager
    @ObservedObject var fontManager: FontManager

    var body: some View {
        
        let ligaturesBinding = Binding<Bool>(
            get: { !configManager.fontFeature.contains("-calt") && !configManager.fontFeature.contains("-liga") },
            set: { enable in
                var features = configManager.fontFeature.components(separatedBy: ",").map{$0.trimmingCharacters(in: .whitespaces)}.filter{ !$0.isEmpty }
                features.removeAll { $0.contains("calt") || $0.contains("liga") || $0.contains("dlig") }
                if !enable {
                    features.append("-calt")
                    features.append("-liga")
                    features.append("-dlig")
                }
                configManager.fontFeature = features.joined(separator: ", ")
            }
        )

        let zeroBinding = Binding<Bool>(
            get: { configManager.fontFeature.contains("+zero") || configManager.fontFeature.contains("zero") && !configManager.fontFeature.contains("-zero") },
            set: { enable in
                var features = configManager.fontFeature.components(separatedBy: ",").map{$0.trimmingCharacters(in: .whitespaces)}.filter{ !$0.isEmpty }
                features.removeAll { $0.contains("zero") }
                if enable {
                    features.append("+zero")
                }
                configManager.fontFeature = features.joined(separator: ", ")
            }
        )

        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text(lang.t("Font & Typography"))
                    .font(.title2)
                    .fontWeight(.semibold)
                
                GroupBox(label: Text(lang.t("Live Preview")).font(.headline)) {
                    let fontSize = CGFloat(Double(configManager.fontSize) ?? 14.0)
                    let fontName = configManager.fontFamily.isEmpty ? "JetBrains Mono" : configManager.fontFamily
                    
                    let customFont = NSFont(name: fontName, size: fontSize) ?? NSFont.userFixedPitchFont(ofSize: fontSize) ?? NSFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("func helloGhostty() {")
                        Text("    print(\"Welcome to Ghostty Configurator!\")")
                        Text("    let symbols = \"!= === -> =>\"")
                        Text("}")
                    }
                    .font(Font(customFont))
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(NSColor.textBackgroundColor))
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2), lineWidth: 1))
                }

                GroupBox(label: Text(lang.t("Primary Font")).font(.headline)) {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text(lang.t("Family:"))
                                .frame(width: 80, alignment: .leading)
                            Picker("", selection: $configManager.fontFamily) {
                                Text(lang.t("Ghostty Default (JetBrains Mono)")).tag("")
                                ForEach(fontManager.availableFonts, id: \.self) { font in
                                    Text(font).tag(font)
                                        .font(.custom(font, size: 14))
                                }
                            }
                            .labelsHidden()
                        }
                        
                        HStack(spacing: 32) {
                            HStack {
                                let sizeBinding = Binding<Double>(
                                    get: { Double(configManager.fontSize) ?? 14.0 },
                                    set: { configManager.fontSize = String(format: "%.1f", $0) }
                                )
                                Text(lang.t("Size:"))
                                    .frame(width: 80, alignment: .leading)
                                Stepper("\(String(format: "%.1f", sizeBinding.wrappedValue)) pt", value: sizeBinding, in: 8...72, step: 0.5)
                                    .frame(width: 140)
                            }
                        }
                    }
                    .padding(12)
                }
                
                GroupBox(label: Text(lang.t("Typography Features")).font(.headline)) {
                    VStack(spacing: 16) {
                        HStack(alignment: .center) {
                            VStack(alignment: .leading, spacing: 4) {
                                Toggle(lang.t("Coding Ligatures"), isOn: ligaturesBinding)
                                Text(lang.t("Combines characters like != or -> into a single symbol.")).font(.caption).foregroundColor(.secondary)
                            }
                            Spacer()
                            VStack {
                                Text("!=  =>  ≠  ⇒")
                                    .font(.system(size: 13, design: .monospaced))
                                    .foregroundColor(.accentColor)
                            }
                            .padding(8)
                            .background(Color.accentColor.opacity(0.1))
                            .cornerRadius(6)
                        }
                        
                        Divider()
                        
                        HStack(alignment: .center) {
                            VStack(alignment: .leading, spacing: 4) {
                                Toggle(lang.t("Slashed Zero"), isOn: zeroBinding)
                                Text(lang.t("Adds a diagonal slash to the number zero.")).font(.caption).foregroundColor(.secondary)
                            }
                            Spacer()
                            VStack {
                                Text("0  O  ∅")
                                    .font(.system(size: 13, design: .monospaced))
                                    .foregroundColor(.accentColor)
                            }
                            .padding(8)
                            .background(Color.accentColor.opacity(0.1))
                            .cornerRadius(6)
                        }
                        
                        Divider()
                        
                        HStack {
                            Text(lang.t("Advanced (Raw):"))
                                .foregroundColor(.secondary)
                            TextField("e.g. +cv01, -calt", text: $configManager.fontFeature)
                        }
                    }
                    .padding(12)
                }
                
                GroupBox(label: Text(lang.t("Cell Dimensions")).font(.headline)) {
                    HStack(spacing: 40) {
                        VStack(alignment: .leading) {
                            Text(lang.t("Width Adjust:"))
                            HStack {
                                let widthBinding = Binding<Double>(
                                    get: { Double(configManager.adjustCellWidth) ?? 0.0 },
                                    set: { configManager.adjustCellWidth = String(format: "%.0f", $0) }
                                )
                                Slider(value: widthBinding, in: -20...20, step: 1)
                                Text("\(String(format: "%.0f", widthBinding.wrappedValue)) px")
                                    .frame(width: 40, alignment: .trailing)
                            }
                        }
                        
                        VStack(alignment: .leading) {
                            Text(lang.t("Height Adjust:"))
                            HStack {
                                let heightBinding = Binding<Double>(
                                    get: { Double(configManager.adjustCellHeight) ?? 0.0 },
                                    set: { configManager.adjustCellHeight = String(format: "%.0f", $0) }
                                )
                                Slider(value: heightBinding, in: -20...20, step: 1)
                                Text("\(String(format: "%.0f", heightBinding.wrappedValue)) px")
                                    .frame(width: 40, alignment: .trailing)
                            }
                        }
                    }
                    .padding(12)
                }
                
                Spacer()
            }
            .padding(24)
        }
    }
}

// MARK: - Cursor Preview
struct CursorPreview: View {
    @ObservedObject var configManager: ConfigManager
    @State private var isBlinking = false
    let timer = Timer.publish(every: 0.6, on: .main, in: .common).autoconnect()

    var body: some View {
        let cursorColor = Color.gray
        let cursorText = Color.white

        HStack(spacing: 0) {
            Text("user@mac ~ $ ")
                .foregroundColor(.green)
                .font(.system(size: 14, design: .monospaced))
            
            ZStack(alignment: .leading) {
                Group {
                    switch configManager.cursorStyle {
                    case "block":
                        Rectangle()
                            .fill(cursorColor)
                            .frame(width: 9, height: 16)
                            .overlay(Text("g").foregroundColor(cursorText).font(.system(size: 14, design: .monospaced)).offset(y: -1))
                    case "bar":
                        Rectangle()
                            .fill(cursorColor)
                            .frame(width: 2, height: 16)
                    case "underline":
                        VStack {
                            Spacer()
                            Rectangle()
                                .fill(cursorColor)
                                .frame(width: 9, height: 2)
                        }
                        .frame(height: 16)
                    case "block_hollow":
                        Rectangle()
                            .stroke(cursorColor, lineWidth: 1.5)
                            .frame(width: 9, height: 16)
                    default:
                        Rectangle()
                            .fill(cursorColor)
                            .frame(width: 9, height: 16)
                    }
                }
                .opacity((configManager.cursorStyleBlink && isBlinking) ? 0 : 1)
                .animation(.easeInOut(duration: 0.1), value: isBlinking)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(NSColor.textBackgroundColor))
        .cornerRadius(8)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2), lineWidth: 1))
        .onReceive(timer) { _ in
            if configManager.cursorStyleBlink {
                isBlinking.toggle()
            } else {
                isBlinking = false
            }
        }
    }
}

// MARK: - Cursor View
struct CursorSettingsView: View {
    @EnvironmentObject var lang: LanguageManager
    @ObservedObject var configManager: ConfigManager

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text(lang.t("Cursor Appearance"))
                    .font(.title2)
                    .fontWeight(.semibold)

                GroupBox(label: Text(lang.t("Live Preview")).font(.headline)) {
                    CursorPreview(configManager: configManager)
                }
                
                HStack(alignment: .top, spacing: 24) {
                    GroupBox(label: Text(lang.t("Shape & Behavior")).font(.headline)) {
                        VStack(alignment: .leading, spacing: 16) {
                            Picker(lang.t("Style"), selection: $configManager.cursorStyle) {
                                Text(lang.t("Block")).tag("block")
                                Text(lang.t("Bar")).tag("bar")
                                Text(lang.t("Underline")).tag("underline")
                                Text(lang.t("Hollow Block")).tag("block_hollow")
                            }
                            .pickerStyle(.segmented) // Horizontal segmented control!
                            .padding(.vertical, 4)
                            
                            Divider()
                            
                            Toggle(lang.t("Blinking Cursor"), isOn: $configManager.cursorStyleBlink)
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                
                Spacer()
            }
            .padding(24)
        }
    }
}


