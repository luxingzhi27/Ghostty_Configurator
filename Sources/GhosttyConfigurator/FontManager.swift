import Foundation
import AppKit

@MainActor
class FontManager: ObservableObject {
    @Published var availableFonts: [String] = []
    
    init() {
        loadFonts()
    }
    
    func loadFonts() {
        self.availableFonts = NSFontManager.shared.availableFontFamilies
    }
}
