//
//  PostsFlowLayout.swift
//  servicely
//
//  Created by Andoni Mendoza on 1/16/18.
//  Copyright © 2018 Andoni Mendoza. All rights reserved.
//

import UIKit

class PostsFlowLayout: UICollectionViewFlowLayout {
    
    let itemHeight: CGFloat = 550
    
    override init() {
        super.init()
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLayout()
    }
    
    
    
    // MARK: - set up layout
    
    /**
     Sets up the layout for the collectionView. 0 distance between each cell, and vertical layout
     */
    func setupLayout() {
        minimumInteritemSpacing = 10
        minimumLineSpacing = 1
        scrollDirection = .vertical
    }
    
    func itemWidth() -> CGFloat {
        //return CGRect.width(collectionView!.frame)
        return collectionView!.frame.width
        
    }
    
    override var itemSize: CGSize {
        set {
            self.itemSize = CGSize.init(width: itemWidth(), height: itemHeight)
        }
        get {
            return CGSize.init(width: itemWidth(), height: itemHeight)
        }
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        return collectionView!.contentOffset
    }
    
    /*
     
     func setupLayout() {
     minimumInteritemSpacing = 1
     minimumLineSpacing = 1
     scrollDirection = .vertical
     }
     
    /// here we define the width of each cell, creating a 2 column layout. In case you would create 3 columns, change the number 2 to 3
    func itemWidth() -> CGFloat {
        return (CGRectGetWidth(collectionView!.frame)/1)-1
    }
    
    override var itemSize: CGSize {
        set {
            self.itemSize = CGSizeMake(itemWidth(), itemHeight)
        }
        get {
            return CGSizeMake(itemWidth(), itemHeight)
        }
    }
    
    override func targetContentOffsetForProposedContentOffset(proposedContentOffset: CGPoint) -> CGPoint {
        return collectionView!.contentOffset
    }
 */
}
