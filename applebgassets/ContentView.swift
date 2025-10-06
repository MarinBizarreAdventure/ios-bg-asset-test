//
//  ContentView.swift
//  applebgassets
//
//  Created by Marin on 06.10.2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var downloadManager = AssetPackDownloadManager()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // Header
                    VStack(spacing: 10) {
                        Image(systemName: "arrow.down.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        Text("Background Assets Test")
                            .font(.title)
                            .bold()
                        Text("Testing three download policies")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top)

                    Divider()

                    // Essential Asset Pack
                    AssetPackCard(
                        title: "Essential",
                        subtitle: "Downloads before first launch",
                        status: downloadManager.essentialStatus,
                        image: downloadManager.essentialImage,
                        progress: downloadManager.essentialProgress,
                        color: .green
                    ) {
                        Task {
                            await downloadManager.checkEssentialAsset()
                        }
                    }

                    // Prefetch Asset Pack
                    AssetPackCard(
                        title: "Prefetch",
                        subtitle: "Downloads in background after install",
                        status: downloadManager.prefetchStatus,
                        image: downloadManager.prefetchImage,
                        progress: downloadManager.prefetchProgress,
                        color: .orange
                    ) {
                        Task {
                            await downloadManager.checkPrefetchAsset()
                        }
                    }

                    // On-Demand Asset Pack
                    VStack(spacing: 15) {
                        AssetPackCard(
                            title: "On-Demand",
                            subtitle: "Downloads only when requested",
                            status: downloadManager.onDemandStatus,
                            image: downloadManager.onDemandImage,
                            progress: downloadManager.onDemandProgress,
                            color: .purple,
                            buttonTitle: "Download Asset"
                        ) {
                            Task {
                                await downloadManager.downloadOnDemandAsset()
                            }
                        }

                        if downloadManager.onDemandImage != nil {
                            Button(role: .destructive) {
                                Task {
                                    await downloadManager.removeOnDemandAsset()
                                }
                            } label: {
                                Label("Remove Asset", systemImage: "trash")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                            .padding(.horizontal)
                        }
                    }

                    Spacer()
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct AssetPackCard: View {
    let title: String
    let subtitle: String
    let status: String
    let image: UIImage?
    let progress: Double
    let color: Color
    var buttonTitle: String = "Check Asset"
    let action: () -> Void

    var body: some View {
        VStack(spacing: 15) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Circle()
                        .fill(color)
                        .frame(width: 12, height: 12)
                    Text(title)
                        .font(.headline)
                }

                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(status)
                    .font(.subheadline)
                    .foregroundColor(status.hasPrefix("✓") ? .green : status.hasPrefix("✗") ? .red : .blue)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)

                if progress > 0 && progress < 1 {
                    ProgressView(value: progress)
                        .progressViewStyle(.linear)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .frame(height: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            Button(action: action) {
                Text(buttonTitle)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(color)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .padding(.horizontal)
    }
}

#Preview {
    ContentView()
}
