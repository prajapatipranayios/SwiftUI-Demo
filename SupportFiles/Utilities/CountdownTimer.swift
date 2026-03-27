//
//  CountdownTimer.swift
//  Tussly
//
//  Created by Auxano on 27/03/26.
//


import Foundation

final class CountdownTimer {

    // MARK: - Format
    enum Format {
        case seconds
        case mmSS
        case custom((Int) -> String)
    }

    // MARK: - Properties
    private var timer: Timer?
    private var totalSeconds: Int
    private var remainingSeconds: Int
    private var format: Format = .seconds

    private var onUpdate: ((String, Int) -> Void)?
    private var onCompletion: (() -> Void)?

    // MARK: - Init
    init(totalSeconds: Int) {
        self.totalSeconds = totalSeconds
        self.remainingSeconds = totalSeconds
    }

    // MARK: - Start Timer
    func start(format: Format = .seconds,
               onUpdate: @escaping (String, Int) -> Void,
               onCompletion: (() -> Void)? = nil) {

        stop() // stop previous if running

        self.format = format
        self.onUpdate = onUpdate
        self.onCompletion = onCompletion
        self.remainingSeconds = totalSeconds

        // Initial value (example: 90)
        onUpdate(formatTime(remainingSeconds), remainingSeconds)

        timer = Timer.scheduledTimer(timeInterval: 1.0,
                                     target: self,
                                     selector: #selector(tick),
                                     userInfo: nil,
                                     repeats: true)
    }

    // MARK: - Tick
    @objc private func tick() {

        guard remainingSeconds > 0 else {
            stop()
            onCompletion?()
            return
        }

        remainingSeconds -= 1
        onUpdate?(formatTime(remainingSeconds), remainingSeconds)
    }

    // MARK: - Stop Timer
    func stop() {
        timer?.invalidate()
        timer = nil
    }

    // MARK: - Reset Timer
    func reset() {
        stop()
        remainingSeconds = totalSeconds
    }

    // MARK: - Time Format
    private func formatTime(_ seconds: Int) -> String {

        let minutes = seconds / 60
        let secs = seconds % 60

        switch format {

        case .seconds:
            return "\(seconds)"

        case .mmSS:
            return String(format: "%02d:%02d", minutes, secs)

        case .custom(let formatter):
            return formatter(seconds)
        }
    }
}


// MARK: Usage Examples
//let timer = CountdownTimer(totalSeconds: 90)

// MARK: 1️⃣ Seconds Format (90 → 89 → 88)
//timer.start(format: .seconds) { formatted, raw in
//    print(formatted)
//}

// MARK: 2️⃣ MM:SS Format (01:29 → 01:28)
//timer.start(format: .mmSS) { formatted, _ in
//    print(formatted)
//}

// MARK: 3️⃣ Custom Format: 01 Min 28 Second
//timer.start(format: .custom({ seconds in
//    let m = seconds / 60
//    let s = seconds % 60
//    return String(format: "%02d Min %02d Second", m, s)
//})) { formatted, _ in
//    print(formatted)
//}

// MARK: 4️⃣ Custom Format: 1 min 28 sec
//timer.start(format: .custom({ seconds in
//    let m = seconds / 60
//    let s = seconds % 60
//    return "\(m) min \(s) sec"
//})) { formatted, _ in
//    print(formatted)
//}

// MARK: 5️⃣ Completion Handler
//timer.start(format: .mmSS, onUpdate: { formatted, _ in
//    print(formatted)
//}) {
//    print("⏱ Timer Completed")
//}
