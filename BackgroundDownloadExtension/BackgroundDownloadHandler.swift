//
//  BackgroundDownloadHandler.swift
//  BackgroundDownloadExtension
//
//  Created by Marin on 06.10.2025.
//

import BackgroundAssets
import ExtensionFoundation

@main
struct BackgroundDownloadHandler: ManagedDownloaderExtension {
    func shouldDownload(_ assetPack: AssetPack) async -> Bool {
        // Download all asset packs by default
        // You can add custom filtering logic here if needed
        return true
    }
}
