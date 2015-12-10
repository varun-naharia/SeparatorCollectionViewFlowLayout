//
//  SeparatorCollectionViewFlowLayout.swift
//  ChicByChoice
//
//  Created by Ivan Bruel on 10/12/15.
//  Copyright © 2015 Chic by Choice. All rights reserved.
//

import Foundation
import UIKit

class SeparatorCollectionViewFlowLayout: UICollectionViewFlowLayout {

  @IBInspectable var separatorWidth: CGFloat = 1 {
    didSet {
      invalidateLayout()
    }
  }

  @IBInspectable var separatorColor: UIColor = UIColor.blackColor() {
    didSet {
      invalidateLayout()
    }
  }

  private static let topSeparatorKind = "SeparatorCollectionViewFlowLayout.Top"
  private static let bottomSeparatorKind = "SeparatorCollectionViewFlowLayout.Bottom"
  private static let leftSeparatorKind = "SeparatorCollectionViewFlowLayout.Left"
  private static let rightSeparatorKind = "SeparatorCollectionViewFlowLayout.Right"

  private static let separatorKinds = [leftSeparatorKind, rightSeparatorKind, topSeparatorKind,
    bottomSeparatorKind]

  init(separatorWidth: CGFloat = 1, separatorColor: UIColor = UIColor.blackColor()) {
    self.separatorWidth = separatorWidth
    self.separatorColor = separatorColor
    super.init()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  override class func layoutAttributesClass() -> AnyClass {
    return ColoredViewLayoutAttributes.self
  }

  override func prepareLayout() {
    super.prepareLayout()

    registerClass(SeparatorView.self,
      forDecorationViewOfKind: SeparatorCollectionViewFlowLayout.topSeparatorKind)
    registerClass(SeparatorView.self,
      forDecorationViewOfKind: SeparatorCollectionViewFlowLayout.bottomSeparatorKind)
    registerClass(SeparatorView.self,
      forDecorationViewOfKind: SeparatorCollectionViewFlowLayout.leftSeparatorKind)
    registerClass(SeparatorView.self,
      forDecorationViewOfKind: SeparatorCollectionViewFlowLayout.rightSeparatorKind)
  }

  override func layoutAttributesForDecorationViewOfKind(elementKind: String,
    atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
      super.layoutAttributesForDecorationViewOfKind(elementKind, atIndexPath: indexPath)

      guard let cellAttributes = layoutAttributesForItemAtIndexPath(indexPath) else {
        return nil
      }

      let layoutAttributes = ColoredViewLayoutAttributes(forDecorationViewOfKind: elementKind,
        withIndexPath: indexPath)

      let baseFrame = cellAttributes.frame

      switch elementKind {
      case SeparatorCollectionViewFlowLayout.rightSeparatorKind:
        layoutAttributes.frame = CGRect(x: baseFrame.maxX - (separatorWidth / 2),
          y: baseFrame.minY, width: separatorWidth, height: baseFrame.height)
      case SeparatorCollectionViewFlowLayout.leftSeparatorKind:
        layoutAttributes.frame = CGRect(x: baseFrame.minX - (separatorWidth / 2),
          y: baseFrame.minY, width: separatorWidth, height: baseFrame.height)
      case SeparatorCollectionViewFlowLayout.topSeparatorKind:
        layoutAttributes.frame = CGRect(x: baseFrame.minX,
          y: baseFrame.minY - (separatorWidth / 2), width: baseFrame.width,
          height: separatorWidth)
      case SeparatorCollectionViewFlowLayout.bottomSeparatorKind:
        layoutAttributes.frame = CGRect(x: baseFrame.minX,
          y: baseFrame.maxY - (separatorWidth / 2), width: baseFrame.width,
          height: separatorWidth)
      default:
        break
      }

      layoutAttributes.color = separatorColor

      return layoutAttributes
  }

  override func layoutAttributesForElementsInRect(rect: CGRect)
    -> [UICollectionViewLayoutAttributes]? {
      guard let baseLayoutAttributes = super.layoutAttributesForElementsInRect(rect) else {
        return nil
      }

      var layoutAttributes = baseLayoutAttributes
      baseLayoutAttributes.filter { $0.representedElementCategory == .Cell }.forEach {
        (layoutAttribute) -> () in

        layoutAttributes += SeparatorCollectionViewFlowLayout.separatorKinds.flatMap {
          (kind) -> UICollectionViewLayoutAttributes? in
            layoutAttributesForDecorationViewOfKind(kind, atIndexPath: layoutAttribute.indexPath)
          }
      }

      return layoutAttributes
  }

  private func indexPathIsLastInSection(indexPath: NSIndexPath) -> Bool {
    guard let collectionView = collectionView, dataSource = collectionView.dataSource else {
      return false
    }
    return indexPath.row == dataSource
      .collectionView(collectionView, numberOfItemsInSection: indexPath.section) - 1
  }

}

private class ColoredViewLayoutAttributes: UICollectionViewLayoutAttributes {

  var color: UIColor = UIColor.blackColor()

}

private class SeparatorView: UICollectionReusableView {

  override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes) {
    super.applyLayoutAttributes(layoutAttributes)

    guard let coloredLayoutAttributes = layoutAttributes as? ColoredViewLayoutAttributes else {
      return
    }
    backgroundColor = coloredLayoutAttributes.color
  }

}