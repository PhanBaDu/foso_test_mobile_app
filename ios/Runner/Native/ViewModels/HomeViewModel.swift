import Combine
import Foundation

final class HomeViewModel: ObservableObject {
    let catalog: CatalogData
    @Published private(set) var remainingSeconds: Int
    @Published var banner = 1
    private let now: () -> Date
    private let deadline: Date
    private var timer: Timer?
    init(catalog: CatalogData, now: @escaping () -> Date = Date.init, startTimer: Bool = true) {
        self.catalog = catalog
        self.now = now
        deadline = now().addingTimeInterval(TimeInterval(catalog.flashSaleDurationSeconds))
        remainingSeconds = catalog.flashSaleDurationSeconds
        if startTimer {
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in self?.refreshCountdown() }
            if let timer = timer { RunLoop.main.add(timer, forMode: .common) }
        }
    }
    var clock: [String] {
        [remainingSeconds / 3600, (remainingSeconds % 3600) / 60, remainingSeconds % 60].map { String(format: "%02d", $0) }
    }
    // Absolute time accounts for suspended/background execution; no tick-count drift.
    func refreshCountdown() {
        remainingSeconds = max(0, min(catalog.flashSaleDurationSeconds, Int(ceil(deadline.timeIntervalSince(now())))))
        if remainingSeconds == 0 { timer?.invalidate() }
    }
    deinit { timer?.invalidate() }
}
