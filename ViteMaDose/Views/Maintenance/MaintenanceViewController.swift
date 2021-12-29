// Software Name: vitemadose-ios
// SPDX-FileCopyrightText: Copyright (c) 2021 CovidTracker
// SPDX-License-Identifier: GNU General Public License v3.0 or later
//
// This software is distributed under the GPL-3.0-or-later license.
//

import UIKit
import WebKit

final class MaintenanceViewController: UIViewController {
    let maintenanceUrl: URL?
    lazy var webView: WKWebView = {
        let webView = WKWebView(frame: view.bounds)
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()

    /// Custom init with `urlString`
    /// If the URL is invalid, it will show a default local maintenance page
    /// Please see `Resources/maintenance.html`
    /// - Parameter urlString: maintenance page URL
    init(urlString: String) {
        if
            let url = URL(string: urlString),
            url.isValid
        {
            self.maintenanceUrl = url
        } else {
            self.maintenanceUrl = nil
        }
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        self.maintenanceUrl = nil
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        isModalInPresentation = true
        configureWebView()

        guard let url = maintenanceUrl else {
            // Fallback
            loadLocalMaintenanceHTML()
            return
        }
        load(url: url)
    }

    private func configureWebView() {
        view.addSubview(webView)
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ])
    }

    private func load(url: URL) {
        let request = URLRequest(url: url)
        webView.load(request)
    }

    private func loadLocalMaintenanceHTML() {
        let localUrl = Bundle.main.url(
            forResource: "maintenance",
            withExtension: "html"
        )

        guard let url = localUrl else {
            assertionFailure("Local maintenance html file not found")
            return
        }

        webView.loadFileURL(url, allowingReadAccessTo: url)
    }
}
