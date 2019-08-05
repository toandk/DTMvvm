//
//  CollectionPage.swift
//  DDMvvm
//
//  Created by Dao Duy Duong on 9/26/18.
//

import UIKit
import RxSwift
import RxCocoa

open class CollectionPage<VM: IListViewModel>: Page<VM>, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    public typealias CVM = VM.CellViewModelElement

    public lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout())
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        
        return collectionView
    }()
    
    private var counter = [Int: Int]()
    
    public override init(viewModel: VM? = nil) {
        super.init(viewModel: viewModel)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override open func viewDidLoad() {
        view.addSubview(collectionView)
        super.viewDidLoad()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.backgroundView = nil
    }

    override open func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { _ in
            self.collectionView.collectionViewLayout.invalidateLayout()
        }, completion: nil)
    }
    
    /**
     Subclasses override this method to create its own collection view layout.
     
     By default, flow layout will be used.
     */
    open func collectionViewLayout() -> UICollectionViewLayout {
        return UICollectionViewFlowLayout()
    }

    open override func initialize() {
        collectionView.autoPinEdgesToSuperviewEdges()
    }
    
    open override func destroy() {
        super.destroy()
        collectionView.removeFromSuperview()
    }

    open override func localHudToggled(_ value: Bool) {
        collectionView.isHidden = value
    }

    open override func bindViewAndViewModel() {
        updateCounter()
        collectionView.reloadData()
        
        collectionView.rx.itemSelected.asObservable().subscribe(onNext: onItemSelected) => disposeBag
        viewModel?.itemsSource.collectionChanged
            .observeOn(Scheduler.shared.mainScheduler)
            .subscribe(onNext: onDataSourceChanged) => disposeBag
    }

    private func onItemSelected(_ indexPath: IndexPath) {
        guard let viewModel = viewModel else { return }
        let cellViewModel = viewModel.itemsSource[indexPath.row, indexPath.section]
        
        viewModel.rxSelectedItem.accept(cellViewModel)
        viewModel.rxSelectedIndex.accept(indexPath)
        
        viewModel.selectedItemDidChange(cellViewModel)
        selectedItemDidChange(cellViewModel)
    }
    
    private func onDataSourceChanged(_ changeSet: ChangeSet) {
        if changeSet.animated {
            collectionView.performBatchUpdates({
                switch changeSet {
                case .insertSection(let section, _):
                    collectionView.insertSections(IndexSet([section]))
                    
                case .deleteSection(let section, _):
                    if section < 0 {
                        if collectionView.numberOfSections > 0 {
                            let sections = Array(0...collectionView.numberOfSections - 1)
                            collectionView.deleteSections(IndexSet(sections))
                        }
                    } else {
                        collectionView.deleteSections(IndexSet([section]))
                    }
                    
                case .insertElements(let indexPaths, _):
                    collectionView.insertItems(at: indexPaths)
                    
                case .deleteElements(let indexPaths, _):
                    collectionView.deleteItems(at: indexPaths)
                    
                case .moveElements(let fromIndexPaths, let toIndexPaths, _):
                    for (i, fromIndexPath) in fromIndexPaths.enumerated() {
                        let toIndexPath = toIndexPaths[i]
                        collectionView.moveItem(at: fromIndexPath, to: toIndexPath)
                    }
                }
                
                // update counter
                updateCounter()
            }, completion: nil)
        } else {
            updateCounter()
            collectionView.reloadData()
        }
    }
    
    private func updateCounter() {
        counter.removeAll()
        viewModel?.itemsSource.forEach { counter[$0] = $1.count }
    }
    
    // MARK: - Abstract for subclasses
    
    /**
     Subclasses have to override this method to return correct cell identifier based `CVM` type.
     */
    open func cellIdentifier(_ cellViewModel: CVM) -> String {
        fatalError("Subclasses have to implemented this method.")
    }
    
    /**
     Subclasses override this method to handle cell pressed action.
     */
    open func selectedItemDidChange(_ cellViewModel: CVM) { }
    
    // MARK: - Collection view datasources
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return counter.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return counter[section] ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let viewModel = viewModel else {
            return UICollectionViewCell(frame: .zero)
        }
        
        let cellViewModel = viewModel.itemsSource[indexPath.row, indexPath.section]
        
        // set index for each cell
        (cellViewModel as? IndexableCellViewModel)?.setIndexPath(indexPath)
        
        let identifier = cellIdentifier(cellViewModel)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        if let cell = cell as? IAnyView {
            cell.anyViewModel = cellViewModel
        }
        return cell
    }
    
    open func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return (nil as UICollectionReusableView?)!
    }
    
    // MARK: - Collection view delegates
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) { }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .zero
    }

    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .zero
    }

    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }

    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}













