//
//  SimpleListPage.swift
//  DTMvvm_Example
//
//  Created by Dao Duy Duong on 10/4/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import Action
import DTMvvm

class SimpleListPage: ListPage<SimpleListPageViewModel> {
    
    let addBtn = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)

    override func initialize() {
        // By default, tableView will pin to 4 edges of superview
        // If you want to layout tableView differently, then remove this line
        super.initialize()
        
        enableBackButton = true
        
        navigationItem.rightBarButtonItem = addBtn
        
        tableView.estimatedRowHeight = 100
        tableView.register(SimpleListPageCell.self, forCellReuseIdentifier: SimpleListPageCell.identifier)
    }
    
    override func bindViewAndViewModel() {
        super.bindViewAndViewModel()
        
        guard let viewModel = viewModel else { return }
        
        addBtn.rx.bind(to: viewModel.addAction, input: ())
    }
    
    override func cellIdentifier(_ cellViewModel: SimpleListPageCellViewModel) -> String {
        return SimpleListPageCell.identifier
    }
}

class SimpleListPageViewModel: ListViewModel<Model, SimpleListPageCellViewModel> {
    
    lazy var addAction: Action<Void, Void> = {
        return Action() { .just(self.add()) }
    }()
    
    private func add() {
        let number = Int.random(in: 1000...10000)
        let title = "This is your random number: \(number)"
        let cvm = SimpleListPageCellViewModel(model: SimpleModel(withTitle: title))
        itemsSource.append(cvm)
    }
}










