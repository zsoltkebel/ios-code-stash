//
//  SwiftUIView.swift
//  Code Clone
//
//  Created by Zsolt Kébel on 11/09/2024.
//

import SwiftUI
import VisionKit

struct BarcodeViewfinderView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject var vm: AppViewModel
    
    @State var recognizedItems: [RecognizedItem] = []
    @State var showSheet = false
    @State var isFirstItem = true
    
    private let textContentTypes: [(title: String, textContentType: DataScannerViewController.TextContentType?)] = [
        ("All", .none),
        ("URL", .URL),
        ("Phone", .telephoneNumber),
        ("Email", .emailAddress),
        ("Address", .fullStreetAddress)
    ]
    
    var body: some View {
        NavigationStack {
            HStack {
                switch vm.dataScannerAccessStatus {
                case .scannerAvailable:
                    mainView
                case .cameraNotAvailable:
                    Text("Your device doesn't have a camera")
                case .scannerNotAvailable:
                    Text("Your device doesn't have support for scanning barcode with this app")
                case .cameraAccessNotGranted:
                    Text("Please provide access to the camera in settings")
                case .notDetermined:
                    //            mainView
                    Text("Requesting camera access")
                }
            }
            .safeAreaPadding()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel, action: {
                        dismiss()
                    }, label: {
                        Text("Cancel")
                            .frame(maxWidth: .infinity)
                    })
                    .tint(Color(UIColor.secondarySystemBackground))
                    .foregroundStyle(Color.accentColor)
                    .buttonStyle(BorderedProminentButtonStyle())
                }
            }
            .task {
                await vm.requestDataScannerAccessStatus()
            }
        }
    }
    
    private var mainView: some View {
        ScannerView(
            recognizedItems: $vm.recognizedItems,
            recognizedDataType: vm.recognizedDataType,
            recognizesMultipleItems: vm.recognizesMultipleItems,
            onRecognizedItems: onRecognizedItems
        )
        .background { Color.gray.opacity(0.3) }
        .ignoresSafeArea()
        .id(vm.dataScannerViewId)
//                .sheet(isPresented: .constant(true)) {
//                    bottomContainerView
//                        .background(.ultraThinMaterial)
//                        .presentationDetents([.medium, .fraction(0.25)])
//                        .presentationDragIndicator(.visible)
//                        .interactiveDismissDisabled()
//                        .onAppear {
//                            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//                                  let controller = windowScene.windows.first?.rootViewController?.presentedViewController else {
//                                return
//                            }
//                            controller.view.backgroundColor = .clear
//                        }
//                }
        .onChange(of: vm.scanType) { _ in vm.recognizedItems = [] }
        .onChange(of: vm.textContentType) { _ in vm.recognizedItems = [] }
        .onChange(of: vm.recognizesMultipleItems) { _ in vm.recognizedItems = []}
//        .sheet(isPresented: $showSheet) {
//            EditBarcodeView(item: .Barcode(), namespace: <#Namespace.ID#>)
//        }
        .onAppear(perform: {
            // reset recognized items
//            vm.recognizedItems = []
            isFirstItem = true
        })
    }
    
    private func onRecognizedItems(recognizedItems: [RecognizedItem]) {
        guard isFirstItem,
              let firstRecognizedItem = recognizedItems.first else {
            return
        }
        
        isFirstItem = false
        
        switch firstRecognizedItem {
        case .text(_):
            fatalError("This should not be recognised")
        case .barcode(let barcode):
            withAnimation {
                let newItem = Item(payloadStringValue: barcode.payloadStringValue ?? "", symbologyRawValue: barcode.observation.symbology.rawValue)
                modelContext.insert(newItem)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    dismiss()
                }
            }
        @unknown default:
            fatalError()
        }
                
        
    }
    
    private var headerView: some View {
        VStack {
            HStack {
                Picker("Scan Type", selection: $vm.scanType) {
                    Text("Barcode").tag(ScanType.barcode)
                    Text("Text").tag(ScanType.text)
                }.pickerStyle(.segmented)
                
                Toggle("Scan multiple", isOn: $vm.recognizesMultipleItems)
            }.padding(.top)
            
            if vm.scanType == .text {
                Picker("Text content type", selection: $vm.textContentType) {
                    ForEach(textContentTypes, id: \.self.textContentType) { option in
                        Text(option.title).tag(option.textContentType)
                    }
                }.pickerStyle(.segmented)
            }
            
            Text(vm.headerText).padding(.top)
        }.padding(.horizontal)
    }
    
    private var bottomContainerView: some View {
        VStack {
            headerView
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    ForEach(vm.recognizedItems) { item in
                        switch item {
                        case .barcode(let barcode):
                            HStack {
                                Text(barcode.payloadStringValue ?? "Unknown barcode")
                                Text(barcode.observation.symbology.rawValue)
                            }
                        case .text(let text):
                            Text(text.transcript)
                            
                        @unknown default:
                            Text("Unknown")
                        }
                    }
                }
                .padding()
            }
        }
    }
}


#Preview {
    BarcodeViewfinderView()
        .environmentObject(AppViewModel())
}
