//
//  HTStreamingJobTests.swift
//  HTKit
//
//  Created by Ben Nortier on 2025/05/26.
//

import Foundation
import Testing

@testable import HTKit

actor ChunkStreamer {
    private let chunks: [[Float]]
    private var chunkIndex: Int
    private var task: Task<Void, Error>?
    private var paused: Bool = false

    init(samples: [Float]) {
        self.chunks = toChunks(samples: samples, chunkSize: WhisperConstants.samplingFrequency * 1)
        self.chunkIndex = 0
    }

    func getNextChunk() -> [Float]? {
        guard chunkIndex < chunks.count else { return nil }
        let chunk = chunks[chunkIndex]
        chunkIndex += 1
        return chunk
    }

    func hasMoreChunks() -> Bool {
        return chunkIndex < chunks.count
    }

    func startStreaming(buffer: HTStreamingAudioBuffer) {
        task = Task {
            var nextChunk = getNextChunk()
            while nextChunk != nil {
                if paused {
                    try await Task.sleep(for: .milliseconds(100))
                    await Task.yield()
                } else {
                    if !Task.isCancelled {
                        await buffer.append(nextChunk!)
                        nextChunk = getNextChunk()
                        try await Task.sleep(for: .milliseconds(200))
                        await Task.yield()
                    }
                }
            }
        }
    }

    func pause() {
        self.paused = true
    }

    func unpause() {
        self.paused = false
    }

    func stop() {
        task?.cancel()
    }
}

private final class ChunkedStreamingEngine: HTStreamingEngine {
    //    var task: Task<Void, Error>?
    //    var paused: Bool = false
    var chunkActor: ChunkStreamer
    //    var samples: [Float]

    init(samples: [Float]) {
        self.chunkActor = ChunkStreamer(samples: samples)
    }

    func startStreaming(buffer: HTStreamingAudioBuffer) {
        let localA = chunkActor
        Task {
            await localA.startStreaming(buffer: buffer)
        }
    }

    func pauseStreaming() {
        let localA = chunkActor
        Task {
            await localA.pause()
        }
    }

    func unpauseStreaming() {
        let localA = chunkActor
        Task {
            await localA.unpause()
        }
    }

    func stopStreaming() {
        let localA = chunkActor
        Task {
            await localA.stop()
        }
    }
}

struct HTStreamingJobTests {

    let aragornSamples: [Float]!
    let modelPath: String

    init() async throws {
        aragornSamples = try readWAV(
            Bundle.module.url(forResource: "aragorn", withExtension: "wav")!
        ).toFloatArray()
        modelPath = Bundle.module.path(forResource: "ggml-tiny", ofType: "bin")!
    }

    @MainActor
    @Test func testStreamingAragorn() async throws {
        let job = HTStreamingJob(
            streamingEngine: ChunkedStreamingEngine(samples: aragornSamples))

        let task = job.start(modelPath: modelPath)

        try await Task.sleep(for: .seconds(2))
        try await job.stop()
        try await task.value

        #expect(job.state == .done)
        #expect(
            job.transcription.getText().similarityPercentage(
                to:
                    " I see in your eyes, the same fear that would take the half of me. The day may come, and the courage of men pray, and we will sink our friends and pray all [MUSIC] But it is not this game, and I will hold and shut the seal for me to get up to class and now, but it is not this bad. This day we fight, by all they can hold here. This could have, I've been in start, and I'm lost."
            ) > 0.8)

    }

    @MainActor
    @Test func testRestart() async throws {
        let job = HTStreamingJob(
            streamingEngine: ChunkedStreamingEngine(samples: aragornSamples))

        let _ = job.start(modelPath: modelPath)

        try await Task.sleep(for: .seconds(1))
        let _ = try await job.restart(modelPath: modelPath)

        try await Task.sleep(for: .seconds(1))
        try await job.stop()

        #expect(job.state == .done)
        #expect(
            job.transcription.getText().similarityPercentage(
                to:
                    " I see in your eyes, the same fear that would take the half of me. The day may come, and the courage of men pray, and we will sink our friends and pray all [MUSIC] But it is not this game, and I will hold and shut the seal for me to get up to class and now, but it is not this bad. This day we fight, by all they can hold here. This could have, I've been in start, and I'm lost."
            ) > 0.8)

    }

}
