//
//  TodoDetailsViewController.swift
//  Todoey
//
//  Created by Julie Alexan on 4/26/24.
//  Copyright © 2024 App Brewery. All rights reserved.
//

import Foundation
import UIKit

class TodoDetailsViewController: UIViewController {
    let stackView = UIStackView()
    var subtitleLabel = UILabel()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        stackView.frame = CGRect(x: 0, y: self.navigationItem.titleView?.layer.frame.size.height ?? 0 + (self.navigationItem.titleView?.layer.frame.origin.y ?? 0), width: self.view.frame.width, height: self.view.frame.height + 900.0)
        subtitleLabel.frame = CGRect(x: stackView.frame.origin.x, y: stackView.frame.origin.y, width: self.view.frame.width, height: 300)

        subtitleLabel.backgroundColor = .orange
        subtitleLabel.textColor = .white
        subtitleLabel.layer.opacity = 0.5
        stackView.addSubview(subtitleLabel)
        
        self.view.addSubview(stackView)
    }
    
}
