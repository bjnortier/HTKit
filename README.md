# HTKit

## Introduction

HTKit is an open-source Swift/SwiftUI library for transcribing audio on iOS and macOS using [whisper.cpp](https://github.com/ggml-org/whisper.cpp).

HTKit is the transcription engine I wrote for the next version of my app Hello Transcribe, which is available [on the App Store](TODO). HTKit adds some functionality on top of whisper.cpp's Swift library:

1. Swift 6 strict concurrency conformance.
1. Thread-safe access to the transcription to render results as they are produced.
1. Live transcription from the microphone from SwiftUI (including handling frame buffers and audio conversion to the required format).

## Requirements

HTKit requires iOS 17.0+, iPadOS 17.0+, or macOS 14.0+.

## Whisper.cpp models

HTKit is compatible with all Whisper models supported by whisper.cpp. You can download these models from the [whisper.cpp releases page](https://huggingface.co/ggerganov/whisper.cpp/tree/main).

## Demo App

There is a demo app, [HTKitDemo](https://github.com/bjnortier/HTKitDemo), which you can run from XCode to see how HTKit works in practice. The demo app includes file and microphone transcription.

## How to use HTKit in your app

To use HTKit in your project, add it as a Package dependency in your XCode project:

```
https://github.com/bjnortier/HTKit
```

The high-level classes applicable to clients are:
1. `HTTranscription`: Instances of this class will contain the transcription results. The results are a sequence of `HTTranscriptionSegment` objects, which contain the text and timestamps (in milliseconds) for each segment.
1. `HTObservableTranscription`: An `@Observable` version of `HTTranscription` that provides a live transcription result, updated every 100ms. This is useful for SwiftUI views to observe the transcription results as they are produced (since HTTranscription isn't Observable).
1. `HTFileJob`: An object that managers the transcription of a file (as the samples from the audio file). **NB** The audio files samples must be in 16-bit, 44kHz PCM format for Whisper.
1. `HTStreamingJob`: An object that manages the transcription of a live audio stream (e.g. from the microphone). It handles the audio conversion and buffering for you. The `HTMicrophoneStreamingEngine` class manages streaming audio samples from the microphone.

The file job and streaming job acan be instantiated as follows:

``` swift
let fileJob = HTFileJob(samples: samples)
let streamingJob = HTStreamingJob(streamingEngine: HTMicrophoneStreamingEngine())
``` 

Both job types have similar semantic to start, stop and cancel transcriptions:

``` swift
// Start the transcription. This will create a Swift Task to run the transcription in the background.
let task = job.start(modelPath: String, options: HTTranscriber.Options)
// Wait for a file job to finish. 
try await task.value
// Stop the transcription. This will stop whisper.cpp 
try await job.stop()
// Restart the transcription. The transcription can be restarted with new options (e.g. using a different language)
// or a different model. This will cancel the existing task, wait for it to finish, then create a new transcription task.
let task2 = job.restart(modelPath: String, options: HTTranscriber.Options) 
```

A streaming transcription can also be cleared. This will clear the transcription buffer and clear the current transcription:

``` swift
try await job.clear()
```

During the job execution the transcription can be 


## Testing 

You can build & test HTKit in XCode or by using the Swift command line tools. To run the tests you will need the `ggml-tiny.bin` Whisper model, as well as the test audio files. You need to download them into the `Tests/HTKitTests/Resources` directory:

```
cd Tests/HTKitTests/Resources
wget https://files.bjnortier.com/HTKit/jfk.wav
wget https://files.bjnortier.com/HTKit/aragorn.wav
wget https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-tiny.bin
cd -
```

``` bash
$ swift test
...
􁁛  Test testAbort() passed after 0.138 seconds.
􁁛  Suite HTTranscriberTests passed after 2.718 seconds.
􁁛  Test run with 11 tests passed after 2.718 seconds.
```

The tests also show how to use HTKit in practice. The tests include file transcription and real-time transcription useing a simulated audio stream.

## License

HTKit is licensed under the [MIT License](LICENSE). You can use it in your projects, commercial or otherwise, as long as you include the license file in your distribution.


