//
//  BrightnessToggle.swift
//  Code Stash
//
//  Created by Zsolt Kébel on 18/09/2024.
//

import SwiftUI

struct BrightnessToggle: View {
    @AppStorage("auto_increase_brightness") var auto_increase_brightness: Bool = false
    
    var body: some View {
        Toggle("Automatically Increase Brightness", isOn: $auto_increase_brightness)
    }
}

#Preview {
    List {
        BrightnessToggle()
    }
}

struct AutoIncreaseBrightness: ViewModifier {
    @AppStorage("auto_increase_brightness") var auto_increase_brightness: Bool = false
    
    @State var previousBrightness: CGFloat?
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                if auto_increase_brightness {
                    previousBrightness = UIScreen.main.brightness
                    UIScreen.main.brightness = 1.0
                }
            }
            .onDisappear {
                if let previousBrightness {
                    UIScreen.main.brightness = previousBrightness
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIScreen.brightnessDidChangeNotification)) { _ in
                previousBrightness = UIScreen.main.brightness
            }
    }
}

extension View {
    func autoIncreaseBrightness() -> some View {
        modifier(AutoIncreaseBrightness())
    }
}
