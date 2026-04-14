import SwiftUI

struct InlineColorPicker: View {
    let title: String
    @Binding var selectedColor: Color

    let presetColors: [Color] = [
        .red, .orange, .yellow, .green, .cyan, .blue, .purple, .pink,
        Color(hex: "#1e1e2e"), Color(hex: "#cdd6f4"), .white, .gray, .black
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if !title.isEmpty {
                Text(title).font(.subheadline).foregroundColor(.secondary)
            }
            
            HStack(spacing: 12) {
                // Custom Color Swatch bypassing macOS buggy ColorPicker
                Circle()
                    .fill(selectedColor)
                    .frame(width: 28, height: 28)
                    .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                    .shadow(color: Color.black.opacity(0.1), radius: 2, y: 1)
                
                // Hex Input
                HStack(spacing: 4) {
                    Text("#").foregroundColor(.secondary).font(.system(.body, design: .monospaced))
                    TextField("Hex", text: Binding(
                        get: { String(selectedColor.toHex().dropFirst()) },
                        set: { selectedColor = Color(hex: $0) }
                    ))
                    .textFieldStyle(.plain)
                    .font(.system(.body, design: .monospaced))
                    .frame(width: 65)
                }
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(Color(NSColor.textBackgroundColor))
                .cornerRadius(6)
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.gray.opacity(0.2), lineWidth: 1))
            }
            
            // Presets
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(presetColors, id: \.self) { color in
                        Circle()
                            .fill(color)
                            .frame(width: 20, height: 20)
                            .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.1)) {
                                    selectedColor = color
                                }
                            }
                    }
                }
                .padding(.vertical, 2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
