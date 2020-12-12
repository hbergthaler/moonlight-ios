//  Created by Hannes Bergthaler on 12.12.20.

import UIKit

final class TestViewController: UIViewController {
    
    private lazy var discoveryManager = DiscoveryManager(hosts: [], andCallback: self)!
    
    private var hosts: [TemporaryHost] = []
    
    // MARK: -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupForegroundRefresh()
    }
    
}

// MARK: - Setup

extension TestViewController {

    private func setupView() {
        view.backgroundColor = .white
    }

    private func setupForegroundRefresh() {
        // Reset state first so we can rediscover hosts that were deleted before
        discoveryManager.resetDiscoveryState()
        discoveryManager.startDiscovery()
    }

}

// MARK: - Discovery callback

extension TestViewController: DiscoveryCallback {
    
    func updateAllHosts(_ hosts: [Any]!) {
        guard let hosts = hosts as? [TemporaryHost] else { return }
        self.hosts = hosts
    }

}

// MARK: - Private

extension TestViewController {

}
