/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit
import Preferences
import Combine

class TabBarCell: UICollectionViewCell {

  lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    return label
  }()

  private lazy var closeButton: UIButton = {
    let button = UIButton()
    button.addTarget(self, action: #selector(closeTab), for: .touchUpInside)
    button.setImage(UIImage(named: "close_tab_bar", in: .module, compatibleWith: nil)!.template, for: .normal)
    button.tintColor = .braveLabel
    // Close button is a bit wider to increase tap area, this aligns the 'X' image closer to the right.
    button.imageEdgeInsets.left = 6
    return button
  }()

  private let separatorLine = UIView()

  let separatorLineRight = UIView().then {
    $0.isHidden = true
  }

  var currentIndex: Int = -1 {
    didSet {
      isSelected = currentIndex == tabManager?.currentDisplayedIndex
      separatorLine.isHidden = currentIndex == 0
    }
  }
  weak var tab: Tab?
  weak var tabManager: TabManager? {
    didSet {
      updateColors()
      privateModeCancellable = tabManager?.privateBrowsingManager
        .$isPrivateBrowsing
        .removeDuplicates()
        .receive(on: RunLoop.main)
        .sink(receiveValue: { [weak self] _ in
          self?.updateColors()
        })
    }
  }

  var closeTabCallback: ((Tab) -> Void)?
  private var cancellables: Set<AnyCancellable> = []

  override init(frame: CGRect) {
    super.init(frame: frame)
    
    [closeButton, titleLabel, separatorLine, separatorLineRight].forEach { contentView.addSubview($0) }
    initConstraints()
    updateFont()
    
    isSelected = false
  }

  private var privateModeCancellable: AnyCancellable?
  private func updateColors() {
    let browserColors: any BrowserColors = tabManager?.privateBrowsingManager.browserColors ?? .standard
    separatorLine.backgroundColor = browserColors.dividerSubtle
    separatorLineRight.backgroundColor = browserColors.dividerSubtle
    backgroundColor = isSelected ? browserColors.tabBarTabActiveBackground : browserColors.tabBarTabBackground
    closeButton.tintColor = browserColors.iconDefault
    titleLabel.textColor = isSelected ? browserColors.textPrimary : browserColors.textSecondary
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func initConstraints() {
    titleLabel.snp.makeConstraints { make in
      make.top.bottom.equalTo(self)
      make.left.equalTo(self).inset(16)
      make.right.equalTo(closeButton.snp.left)
    }

    closeButton.snp.makeConstraints { make in
      make.top.bottom.equalTo(self)
      make.right.equalTo(self).inset(2)
      make.width.equalTo(30)
    }

    separatorLine.snp.makeConstraints { make in
      make.left.equalTo(self)
      make.width.equalTo(0.5)
      make.height.equalTo(self)
      make.centerY.equalTo(self.snp.centerY)
    }

    separatorLineRight.snp.makeConstraints { make in
      make.right.equalTo(self)
      make.width.equalTo(0.5)
      make.height.equalTo(self)
      make.centerY.equalTo(self.snp.centerY)
    }
  }

  override var isSelected: Bool {
    didSet {
      configure()
    }
  }

  func configure() {
    if isSelected {
      titleLabel.alpha = 1.0
      closeButton.isHidden = false
    }
    // Prevent swipe and release outside- deselects cell.
    else if currentIndex != tabManager?.currentDisplayedIndex {
      titleLabel.alpha = 0.8
      closeButton.isHidden = true
    }
    updateFont()
    updateColors()
  }
  
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    updateFont()
  }
  
  private func updateFont() {
    let clampedTraitCollection = self.traitCollection.clampingSizeCategory(maximum: .extraExtraLarge)
    let font = UIFont.preferredFont(forTextStyle: .caption1, compatibleWith: clampedTraitCollection)
    titleLabel.font = .systemFont(ofSize: font.pointSize, weight: isSelected ? .semibold : .regular)
  }

  @objc func closeTab() {
    guard let tab = tab else { return }
    closeTabCallback?(tab)
  }

  fileprivate var titleUpdateScheduled = false
  func updateTitleThrottled(for tab: Tab) {
    if titleUpdateScheduled {
      return
    }
    titleUpdateScheduled = true
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
      guard let strongSelf = self else { return }
      strongSelf.titleUpdateScheduled = false
      strongSelf.titleLabel.text = tab.displayTitle
    }
  }
}
