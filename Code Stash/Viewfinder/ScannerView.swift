//
//  ScannerView.swift
//  Code Clone
//
//  Created by Zsolt Kébel on 11/09/2024.
//

import Foundation
import SwiftUI
import VisionKit

struct ScannerView: UIViewControllerRepresentable {
    
    @Binding var recognizedItems: [RecognizedItem]
    let recognizedDataType: DataScannerViewController.RecognizedDataType
    let recognizesMultipleItems: Bool
    let onRecognizedFirstItem: (RecognizedItem) -> Void
    
    func makeUIViewController(context: Context) -> DataScannerViewController {
        let vc = DataScannerViewController(
            recognizedDataTypes: [recognizedDataType],
            qualityLevel: .balanced,
            recognizesMultipleItems: recognizesMultipleItems,
            isGuidanceEnabled: true,
            isHighlightingEnabled: true
        )
        return vc
    }
    
    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
        uiViewController.delegate = context.coordinator
        if ((uiViewController.viewIfLoaded?.window) != nil) {
            try? uiViewController.startScanning()
        } else {
            print("stop called")
            uiViewController.stopScanning()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(recognizedItems: $recognizedItems, onRecognizedFirstItem: onRecognizedFirstItem)
    }
    
    static func dismantleUIViewController(_ uiViewController: DataScannerViewController, coordinator: Coordinator) {
        uiViewController.stopScanning()
    }
    
    
    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        
        @Binding var recognizedItems: [RecognizedItem]
        let onRecognizedFirstItem: ((RecognizedItem) -> Void)?

        init(recognizedItems: Binding<[RecognizedItem]>, onRecognizedFirstItem: ((RecognizedItem) -> Void)? = nil) {
            self._recognizedItems = recognizedItems
            self.onRecognizedFirstItem = onRecognizedFirstItem
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            print("didTapOn \(item)")
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            if recognizedItems.isEmpty,
               let firstItem = recognizedItems.first {
                self.onRecognizedFirstItem?(firstItem)
            }
            recognizedItems.append(contentsOf: addedItems)
            print("didAddItems \(addedItems)")
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didRemove removedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            self.recognizedItems = recognizedItems.filter { item in
                !removedItems.contains(where: {$0.id == item.id })
            }
            print("didRemovedItems \(removedItems)")
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, becameUnavailableWithError error: DataScannerViewController.ScanningUnavailable) {
            print("became unavailable with error \(error.localizedDescription)")
        }
        
    }
    
}


//#Preview {
//    ScannerView(recognizedItems: [], recognizedDataType: <#DataScannerViewController.RecognizedDataType#>, recognizesMultipleItems: <#Bool#>)
//}
