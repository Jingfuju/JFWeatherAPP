//
//  EmptyStateView.swift
//  JFWeatherApp
//
//  Created by Jingfu Ju on 2/22/23.
//

import Foundation
import UIKit

class EmptyStateView: UIView {
    
    // MARK: - IBOutlet

    @IBOutlet private var contentView: UIView!
    @IBOutlet private var noDataLabel: UILabel!

    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Methods
    
    func setupEmptyStateView() {
        contentView.removeFromSuperview()
        addSubview(contentView)
        noDataLabel.text = AppMessages.noLocationFound
    }

    func setupSelectLocatin() {
        contentView.removeFromSuperview()
        addSubview(contentView)
        noDataLabel.text = AppMessages.selectLocation
    }
    
    // MARK: - Privates

    private func commonInit() {
        UIView.fromNib()
        noDataLabel.text = AppMessages.noLocationFound
        addSubview(contentView)
    }
}

