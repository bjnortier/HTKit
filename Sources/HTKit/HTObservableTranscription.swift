//
//  ObservableTranscription.swift
//  HTKit
//
//  Created by Ben Nortier on 2025/08/09.
//

import Combine
import Foundation

// ObservableTranscription is a wrapper around HTTranscription that allows for
// observing changes in the transcription segments and text.
@Observable public class HTObservableTranscription {
    public var segments: [HTTranscriptionSegment] = []
    public var text: String = ""

    private var cancellables = Set<AnyCancellable>()

    public init(transcription: HTTranscription) {
        Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                if transcription.segments != self.segments {
                    self.segments = transcription.segments
                    self.text = transcription.getText()
                }
            }
            .store(in: &cancellables)
    }

    deinit {
        cancellables.removeAll()
    }

}
