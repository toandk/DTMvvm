//
//  ContactCell.swift
//  DTMvvm_Example
//
//  Created by Dao Duy Duong on 10/5/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import RxCocoa
import DTMvvm

class ContactCell: TableCell<ContactCellViewModel> {

    let avatarIv = UIImageView()
    let nameLbl = UILabel()
    let phoneLbl = UILabel()
    
    override func initialize() {
        avatarIv.image = UIImage(named: "default-contact")
        avatarIv.autoSetDimensions(to: CGSize(width: 64, height: 64))
        
        nameLbl.numberOfLines = 0
        nameLbl.font = Font.system.bold(withSize: 17)
        
        phoneLbl.numberOfLines = 0
        phoneLbl.font = Font.system.normal(withSize: 15)
        
        let infoLayout = StackLayout().direction(.vertical).children([
            nameLbl,
            phoneLbl
        ])
        
        let layout = StackLayout().spacing(8).alignItems(.center).children([
            avatarIv,
            infoLayout
        ])
        contentView.addSubview(layout)
        layout.autoPinEdgesToSuperviewEdges(with: .all(5))
    }
    
    override func bindViewAndViewModel() {
        guard let viewModel = viewModel else { return }
        
        viewModel.rxName ~> nameLbl.rx.text => disposeBag
        viewModel.rxPhone ~> phoneLbl.rx.text => disposeBag
    }
}

class ContactCellViewModel: CellViewModel<ContactModel> {
    
    let rxName = BehaviorRelay<String?>(value: nil)
    let rxPhone = BehaviorRelay<String?>(value: nil)
    
    override func react() {
        modelChanged()
    }
    
    override func modelChanged() {
        rxName.accept(model?.name)
        rxPhone.accept(model?.phone)
    }
}









