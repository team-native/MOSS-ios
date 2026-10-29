import Foundation

/// 1초마다 남은 시간을 알려주는 카운트다운 (인증번호 유효시간 등)
@MainActor
final class CountdownTimer {
    private var task: Task<Void, Never>?

    /// - Parameters:
    ///   - seconds: 시작 시간(초)
    ///   - onTick: 남은 시간이 바뀔 때마다 호출 (시작 시 seconds, 마지막 0)
    func start(seconds: Int, onTick: @escaping (Int) -> Void) {
        stop()
        onTick(seconds)

        task = Task {
            var remaining = seconds
            while remaining > 0 {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                guard !Task.isCancelled else { return }
                remaining -= 1
                onTick(remaining)
            }
        }
    }

    func stop() {
        task?.cancel()
        task = nil
    }

    deinit {
        task?.cancel()
    }
}
