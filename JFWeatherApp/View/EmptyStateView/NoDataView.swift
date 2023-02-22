//
//  NoDataView.swift
//  AUWeatherApp
//
//  Created by Anand Upadhyay on 09/02/23.
//

import Foundation
import UIKit

class NoDataView: UIView {
    
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
    
    func setupNoDataView() {
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
