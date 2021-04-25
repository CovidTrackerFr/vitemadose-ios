//
//  MaintenanceViewController.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 25/04/2021.
//

import UIKit
import WebKit

class MaintenanceViewController: UIViewController {
    let maintenanceUrl: URL?
    lazy var webView: WKWebView = {
        let webView = WKWebView(frame: view.bounds)
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()

    init(urlString: String?) {
        if
            let urlString = urlString,
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
