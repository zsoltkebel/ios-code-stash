//
//  EditBarcodeView.swift
//  Code Clone
//
//  Created by Zsolt Kébel on 11/09/2024.
//

import SwiftUI
import Vision

enum BarcodeField {
    case name, symbology, payload
}

struct EditBarcodeView: View {
    @Bindable var item: Item
    
    @State var sectionExpanded: Bool = true
    @State private var previousBrightness: Double?
    @State private var showingDeleteConfirmAlert = false
    @State private var imageNeedsReloading = false
    
    let namespace: Namespace.ID
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    @AppStorage("auto_increase_brightness") var auto_increase_brigthness = false
    @AppStorage("default_symbology") var default_symbology: String = "VNBarcodeSymbologyQR"
    
    @Namespace var pageAnimation
    @Namespace var codeView
    
    var body: some View {
        let screen = UIScreen.main
        
        Form {
            Section {
                HStack {
                    Spacer()
                    BarcodeImage(item: item)
                        .matchedGeometryEffect(id: "codeView", in: namespace)
                    //                    .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 120)
                    Spacer()
                }
                .listRowInsets(.init())
                .listRowBackground(Color.clear)
            }
            
//            Section {
                BarcodeNameTypeContentInput(item: item)
//                    .onChange(of: item.payloadStringValue) { _, _ in
////                        imageNeedsReloading = true
//                        item.barcodeImageData = nil
//                    }
//            }
            
            Section {
                Button(role: .destructive, action: {
                    showingDeleteConfirmAlert = true
                }, label: {
                    Text("Delete")
                })
                .frame(maxWidth: .infinity)
            }
        }
//        .navigationTitle(item.name)
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
            
//            if imageNeedsReloading {
//                clearImageData()
//            }
        })
        //        .toolbar {
        //
        //            ToolbarItem {
        //                Menu("More", systemImage: "ellipsis.circle") {
        //                    Section {
        //                        if let imageData = item.barcodeImageData,
        //                           let uiImage = UIImage(data: imageData) {
        //                            let image = Image(uiImage: uiImage)
        //                            ShareLink(item: image, preview: SharePreview(item.name, image: image))
        //                        }
        //
        //                        Button("Reload Image", systemImage: "icloud.and.arrow.down") {
        //                            item.barcodeImageData = nil
        //                        }
        //                        .disabled(item.barcodeImageData == nil)
        //                    }
        //
        //                    Toggle("Auto Increase Brightness", systemImage: auto_increase_brigthness ? "sun.max.fill" : "sun.min", isOn: $auto_increase_brigthness)
        //
        //                    Section {
        //                        Button("Delete", systemImage: "trash", role: .destructive) {
        //                            showingDeleteConfirmAlert = true
        //                        }
        //                    }
        //                }
        //            }
        //        }
        
        // Delete confirmation alert
        .alert("Delete \"\(item.name)\"?", isPresented: $showingDeleteConfirmAlert) {
            Button("No", role: .cancel) {}
            Button("Yes", role: .destructive, action: deleteBarcode)
        }
    }
    
    private func clearImageData() {
        print("Clear image data")
        item.barcodeImageData = nil
        imageNeedsReloading = false
    }
    
    private func deleteBarcode() {
        withAnimation {
            modelContext.delete(item)
            dismiss()
        }
    }
}

#Preview {
    @Namespace var smtg
    return NavigationStack {
        EditBarcodeView(item: .StudentID(), namespace: smtg)
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

struct BarcodeNameTypeContentInput: View {
    @Bindable var item: Item
    @FocusState var focusedField: BarcodeField?
    
    var body: some View {
        TextField("Name", text: $item.name)
            .focused($focusedField, equals: .name)
        
        Picker("Type", selection: $item.symbologyRawValue) {
            ForEach(VNBarcodeSymbology.allCases, id: \.self) { symbology in
                Text(symbology.rawValue.replacing("VNBarcodeSymbology", with: "").toSentence()).tag(symbology.rawValue)
            }
        }
        .focused($focusedField, equals: .symbology)
        
        TextField("Content", text: $item.payloadStringValue, axis: .vertical)
            .focused($focusedField, equals: .payload)
            .lineLimit(.max)
    }
}
