//
//  AssetPackDownloadManager.swift
//  applebgassets
//

import BackgroundAssets
import SwiftUI
import Combine
import System

@MainActor
class AssetPackDownloadManager: ObservableObject {
    @Published var essentialStatus: String = "Not loaded"
    @Published var prefetchStatus: String = "Not loaded"
    @Published var onDemandStatus: String = "Not loaded"

    @Published var essentialImage: UIImage?
    @Published var prefetchImage: UIImage?
    @Published var onDemandImage: UIImage?

    @Published var essentialProgress: Double = 0.0
    @Published var prefetchProgress: Double = 0.0
    @Published var onDemandProgress: Double = 0.0

    func checkEssentialAsset() async {
        do {
            print("🟢 [Essential] Starting check...")
            essentialStatus = "Checking..."

            print("🟢 [Essential] Fetching asset pack...")
            let assetPack = try await AssetPackManager.shared.assetPack(withID: "Essential")
            print("🟢 [Essential] Asset pack found: \(assetPack)")

            essentialStatus = "Ensuring availability..."
            print("🟢 [Essential] Ensuring local availability...")
            try await AssetPackManager.shared.ensureLocalAvailability(of: assetPack)
            print("🟢 [Essential] Asset pack is available locally")

            // Load the image
            print("🟢 [Essential] Loading image data...")
            let imageData = try AssetPackManager.shared.contents(at: "AssetPacks/Essential/image1.jpg")
            print("🟢 [Essential] Image data loaded: \(imageData.count) bytes")

            if let image = UIImage(data: imageData) {
                essentialImage = image
                essentialStatus = "✓ Downloaded and loaded"
                print("🟢 [Essential] ✅ Success! Image displayed")
            } else {
                essentialStatus = "✗ Failed to load image"
                print("🟢 [Essential] ❌ Failed to create UIImage from data")
            }
        } catch {
            essentialStatus = "✗ Error: \(error.localizedDescription)"
            print("🟢 [Essential] ❌ Error: \(error)")
        }
    }

    func checkPrefetchAsset() async {
        do {
            print("🟠 [Prefetch] Starting check...")
            prefetchStatus = "Checking..."

            print("🟠 [Prefetch] Fetching asset pack...")
            let assetPack = try await AssetPackManager.shared.assetPack(withID: "Prefetch")
            print("🟠 [Prefetch] Asset pack found: \(assetPack)")

            prefetchStatus = "Ensuring availability..."
            print("🟠 [Prefetch] Ensuring local availability...")
            try await AssetPackManager.shared.ensureLocalAvailability(of: assetPack)
            print("🟠 [Prefetch] Asset pack is available locally")

            // Load the image
            print("🟠 [Prefetch] Loading image data...")
            let imageData = try AssetPackManager.shared.contents(at: "AssetPacks/Prefetch/image2.jpg")
            print("🟠 [Prefetch] Image data loaded: \(imageData.count) bytes")

            if let image = UIImage(data: imageData) {
                prefetchImage = image
                prefetchStatus = "✓ Downloaded and loaded"
                print("🟠 [Prefetch] ✅ Success! Image displayed")
            } else {
                prefetchStatus = "✗ Failed to load image"
                print("🟠 [Prefetch] ❌ Failed to create UIImage from data")
            }
        } catch {
            prefetchStatus = "✗ Error: \(error.localizedDescription)"
            print("🟠 [Prefetch] ❌ Error: \(error)")
        }
    }

    func downloadOnDemandAsset() async {
        do {
            print("🟣 [OnDemand] Starting download...")
            onDemandStatus = "Starting download..."

            print("🟣 [OnDemand] Fetching asset pack...")
            let assetPack = try await AssetPackManager.shared.assetPack(withID: "OnDemand")
            print("🟣 [OnDemand] Asset pack found: \(assetPack)")

            // Start monitoring progress
            Task {
                let statusUpdates = AssetPackManager.shared.statusUpdates(forAssetPackWithID: "OnDemand")
                for await statusUpdate in statusUpdates {
                    print("🟣 [OnDemand] Status update: \(statusUpdate)")
                    switch statusUpdate {
                    case .began:
                        onDemandStatus = "Download began..."
                    case .paused:
                        onDemandStatus = "Download paused"
                    case .downloading(_, let progress):
                        onDemandProgress = progress.fractionCompleted
                        onDemandStatus = "Downloading: \(Int(progress.fractionCompleted * 100))%"
                        print("🟣 [OnDemand] Progress: \(Int(progress.fractionCompleted * 100))%")
                    case .finished:
                        onDemandStatus = "Download finished"
                    case .failed(_, let error):
                        onDemandStatus = "✗ Failed: \(error.localizedDescription)"
                        print("🟣 [OnDemand] ❌ Download failed: \(error)")
                    }
                }
            }

            onDemandStatus = "Downloading..."
            print("🟣 [OnDemand] Ensuring local availability...")
            try await AssetPackManager.shared.ensureLocalAvailability(of: assetPack)
            print("🟣 [OnDemand] Asset pack is available locally")

            // Load the image
            print("🟣 [OnDemand] Loading image data...")
            let imageData = try AssetPackManager.shared.contents(at: "AssetPacks/OnDemand/image3.jpg")
            print("🟣 [OnDemand] Image data loaded: \(imageData.count) bytes")

            if let image = UIImage(data: imageData) {
                onDemandImage = image
                onDemandStatus = "✓ Downloaded and loaded"
                print("🟣 [OnDemand] ✅ Success! Image displayed")
            } else {
                onDemandStatus = "✗ Failed to load image"
                print("🟣 [OnDemand] ❌ Failed to create UIImage from data")
            }
        } catch {
            onDemandStatus = "✗ Error: \(error.localizedDescription)"
            print("🟣 [OnDemand] ❌ Error: \(error)")
        }
    }

    func removeOnDemandAsset() async {
        do {
            try await AssetPackManager.shared.remove(assetPackWithID: "OnDemand")
            onDemandImage = nil
            onDemandStatus = "Asset removed"
            onDemandProgress = 0.0
        } catch {
            onDemandStatus = "✗ Error removing: \(error.localizedDescription)"
        }
    }
}
