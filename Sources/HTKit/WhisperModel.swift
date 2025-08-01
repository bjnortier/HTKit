//
//  WhisperModel.swift
//  HTKit
//
//  Created by Ben Nortier on 2025/02/28.
//

public enum WhisperModel: String, Hashable, CaseIterable {
    case tiny
    case tinyEN
    case base
    case baseEN
    case small
    case smallEN
    case medium
    case mediumEN
    case largeV1
    case largeV2
    case largeV3
    case largeV3Turbo

    public var filename: String {
        switch self {
        case .tiny: return "ggml-tiny.bin"
        case .tinyEN: return "ggml-tiny.en.bin"
        case .base: return "ggml-base.bin"
        case .baseEN: return "ggml-base.en.bin"
        case .small: return "ggml-small.bin"
        case .smallEN: return "ggml-small.en.bin"
        case .medium: return "ggml-medium.bin"
        case .mediumEN: return "ggml-medium.en.bin"
        case .largeV1: return "ggml-large-v1.bin"
        case .largeV2: return "ggml-large-v2.bin"
        case .largeV3: return "ggml-large-v3.bin"
        case .largeV3Turbo: return "ggml-large-v3-turbo.bin"
        }
    }

    public var sha1: String {
        switch self {
        case .tiny: return "bd577a113a864445d4c299885e0cb97d4ba92b5f"
        case .tinyEN: return "c78c86eb1a8faa21b369bcd33207cc90d64ae9df"
        case .base: return "465707469ff3a37a2b9b8d8f89f2f99de7299dac"
        case .baseEN: return "137c40403d78fd54d454da0f9bd998f78703390c"
        case .small: return "55356645c2b361a969dfd0ef2c5a50d530afd8d5"
        case .smallEN: return "db8a495a91d927739e50b3fc1cc4c6b8f6c2d022"
        case .medium: return "fd9727b6e1217c2f614f9b698455c4ffd82463b4"
        case .mediumEN: return "8c30f0e44ce9560643ebd10bbe50cd20eafd3723"
        case .largeV1: return "b1caaf735c4cc1429223d5a74f0f4d0b9b59a299"
        case .largeV2: return "0f4c8e34f21cf1a914c59d8b3ce882345ad349d6"
        case .largeV3: return "ad82bf6a9043ceed055076d0fd39f5f186ff8062"
        case .largeV3Turbo: return "4af2b29d7ec73d781377bfd1758ca957a807e941"
        }
    }

    public var sizeMB: Int {
        switch self {
        case .tiny, .tinyEN: return 74
        case .base, .baseEN: return 141
        case .small, .smallEN: return 465
        case .medium, .mediumEN: return 1477
        case .largeV1, .largeV2, .largeV3: return 2980
        case .largeV3Turbo: return 1564
        }
    }

    public var multilingual: Bool {
        switch self {
        case .tinyEN, .baseEN, .smallEN, .mediumEN: return false
        case .tiny, .base, .small, .medium, .largeV1, .largeV2, .largeV3, .largeV3Turbo:
            return true
        }
    }

}
