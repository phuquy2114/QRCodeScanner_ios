//
//  FavoriteViewController.swift
//  QRCodeScanner
//
//  Created by Ngo Nghia on 20/3/26.
//

import UIKit

class FavoriteViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func setupUI() {
        view.backgroundColor = .black
        
        emptyUI()

    }
    
    private func emptyUI() {
        view.subviews.forEach { sub in
            sub.removeFromSuperview()
        }
        
        let label = UILabel()
        label.text = "No favorites"
        label.font = .systemFont(ofSize: 25)
        label.textColor = .white
        
        view.addSubview(label)
        
        label.changeConstraints()
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
    }

}
