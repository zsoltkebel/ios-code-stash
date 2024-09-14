//
//  EditBarcodeView.swift
//  Code Clone
//
//  Created by Zsolt Kébel on 11/09/2024.
//

import SwiftUI
import Vision

struct EditBarcodeView: View {
    @Bindable var item: Item
    
    @State var sectionExpanded: Bool = false
    @State private var previousBrightness: Double?
    @State private var showingDeleteConfirmAlert = false
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    @AppStorage("auto_increase_brightness") var auto_increase_brigthness = false
    @AppStorage("default_symbology") var default_symbology: String = "VNBarcodeSymbologyQR"
    
    var body: some View {
        let screen = UIScreen.main
        List {
            BarcodeImage(item: item)
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.white)
            
            CodeTypeAndContentInputSection(item: item)
        }
        .listStyle(.sidebar)
        .navigationTitle($item.name)
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: auto_increase_brigthness, { oldValue, newValue in
            if newValue {
                previousBrightness = screen.brightness
                screen.brightness = 1.0
            } else {
                if let brightness = previousBrightness {
                    screen.brightness = brightness
                }
            }
        })
        .onAppear(perform: {
            if auto_increase_brigthness {
                previousBrightness = screen.brightness
                screen.brightness = 1.0
            }
        })
        .onDisappear(perform: {
            if auto_increase_brigthness,
               let brightness = previousBrightness {
                screen.brightness = brightness
            }
        })
        .toolbar {
            //            UserDefaultSettings()
            ToolbarItem {
                Button(action: { item.favorite.toggle() },
                       label: {
                    Image(systemName: item.favorite ? "star.fill" : "star")
                })
            }
            
            ToolbarItem {
                Menu("More", systemImage: "ellipsis.circle") {
                    Toggle("Auto Increase Brightness", systemImage: auto_increase_brigthness ? "sun.max.fill" : "sun.min", isOn: $auto_increase_brigthness)
                    
                    Button("Reload Image", systemImage: "icloud.and.arrow.down") {
                        item.barcodeImageData = nil
                    }
                    .disabled(item.barcodeImageData == nil)
                    
                    Section {
                        Button("Delete", systemImage: "trash", role: .destructive) {
                            showingDeleteConfirmAlert = true
                        }
                    }
                }
            }
        }
        // Delete confirmation alert
        .alert("Delete \"\(item.name)\"?", isPresented: $showingDeleteConfirmAlert) {
            Button("No", role: .cancel) {}
            Button("Yes", action: deleteBarcode)
        }
    }
    
    private func clearImageData() {
        print("Clear image data")
        item.barcodeImageData = nil
    }
    
    private func deleteBarcode() {
        modelContext.delete(item)
        dismiss()
    }
}

#Preview {
    NavigationStack {
        EditBarcodeView(item: .QR())
            .modelContainer(for: Item.self, inMemory: true)
    }
}

extension VNBarcodeSymbology {
    static let allCases: [VNBarcodeSymbology] = [
        .aztec,
        .codabar,
        .code128,
        .code39,
        .code39Checksum,
        .code39FullASCII,
        .code39FullASCIIChecksum,
        .code93,
        .code93i,
        .dataMatrix,
        .ean13,
        .ean8,
        .gs1DataBar,
        .gs1DataBarExpanded,
        .gs1DataBarLimited,
        .i2of5,
        .i2of5Checksum,
        .itf14,
        .microPDF417,
        .microQR,
        .msiPlessey,
        .pdf417,
        .qr,
        .upce
    ]
}

extension String {
    
    // turn a pascal case string into a sentence
    func toSentence() -> String {
        var sentence = ""
        for c in self {
            if let prev = sentence.last {
                if prev.isLetter && prev.isLowercase && c.isUppercase {
                    sentence += " \(c)"
                } else if prev.isNumber && c.isLetter {
                    sentence += " \(c)"
                } else if prev.isLetter && c.isNumber {
                    sentence += " \(c)"
                } else {
                    sentence += "\(c)"
                }
            } else {
                sentence += "\(c)"
            }
        }
        return sentence
    }
}

struct UserDefaultSettings: View {
    
    @AppStorage("auto_increase_brightness") var auto_increase_brigthness = false
    @AppStorage("default_symbology") var default_symbology: String = "VNBarcodeSymbologyQR"
    
    var body: some View {
        Menu("More", systemImage: "ellipsis.circle") {
            Picker(selection: $default_symbology) {
                ForEach(VNBarcodeSymbology.allCases, id: \.self) { symbology in
                    Text(symbology.rawValue.replacing("VNBarcodeSymbology", with: "").toSentence()).tag(symbology.rawValue)
                }
            } label: {
                Button(action: {}, label: {
                    Text("Default Code Type")
                    Text(default_symbology.replacing("VNBarcodeSymbology", with: "").toSentence())
                    Image(systemName: "chevron.up.chevron.down")
                })
            }
            .pickerStyle(.menu)
            
            Toggle("Auto Increase Brightness", systemImage: auto_increase_brigthness ? "sun.max.fill" : "sun.min", isOn: $auto_increase_brigthness)
        }
    }
}

struct CodeTypeAndContentInputSection: View {
    @Bindable var item: Item
    
    @State var sectionExpanded = false
    
    var body: some View {
        Section("Code Type & Content", isExpanded: $sectionExpanded) {
            Picker("Type", selection: $item.symbologyRawValue) {
                ForEach(VNBarcodeSymbology.allCases, id: \.self) { symbology in
                    Text(symbology.rawValue.replacing("VNBarcodeSymbology", with: "").toSentence()).tag(symbology.rawValue)
                }
            }
            .onChange(of: item.symbologyRawValue) { oldValue, newValue in
                clearImageData()
            }
            
            TextField("Content", text: $item.payloadStringValue)
                .onSubmit(clearImageData)
        }
    }
    
    private func clearImageData() {
        print("Clear image data")
        item.barcodeImageData = nil
    }
}
