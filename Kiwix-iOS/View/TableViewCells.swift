//
//  BookCell.swift
//  Kiwix
//
//  Created by Chris on 12/13/15.
//  Copyright © 2015 Chris. All rights reserved.
//

import UIKit

// MARK: - Book Cells (new)

/* Book Cell With picture indicator */
class BasicBookCell: UITableViewCell {
    
    @IBOutlet weak var favIcon: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var hasPicIndicator: UIView!
    
    // MARK: Override
    
    override func awakeFromNib() {
        hasPicIndicator.layer.cornerRadius = 1.0
        hasPicIndicator.layer.masksToBounds = true
        hasPicIndicator.backgroundColor = UIColor.clearColor()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        selected = false
        highlighted = false
    }
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        setIndicatorColor()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        setIndicatorColor()
    }
    
    // MARK: Shorthand properties
    
    var hasPic: Bool = false {
        didSet {
            setIndicatorColor()
        }
    }
    
    private func setIndicatorColor() {
        hasPicIndicator.backgroundColor = hasPic ? AppColors.hasPicTintColor : UIColor.lightGrayColor()
    }
}

/* Book Cell With P & I indicator, a check mark on the right */
class CheckMarkBookCell: BasicBookCell {
    @IBOutlet weak var accessoryImageView: LargeHitZoneImageView!
    weak var delegate: TableCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CheckMarkBookCell.handleTap))
        accessoryImageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    var isChecked: Bool = false {
        didSet {
            accessoryImageView.highlighted = isChecked
        }
    }
    
    func handleTap() {
        self.delegate?.didTapOnAccessoryViewForCell(self)
    }
}

/* Book Cell With progress bar and 2 line detail label */
class DownloadBookCell: UITableViewCell {
    @IBOutlet weak var favIcon: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
}

// MARK: - Article Cell

class ArticleCell: UITableViewCell {
    @IBOutlet weak var favIcon: UIImageView!
    @IBOutlet weak var hasPicIndicator: UIView!
    @IBOutlet weak var titleLabel: UILabel!
}

class ArticleSnippetCell: ArticleCell {
    @IBOutlet weak var snippetLabel: UILabel!
}

// MARK: - Bookmark Cell

class BookmarkCell: UITableViewCell {
    override func awakeFromNib() {
        thumbImageView.layer.cornerRadius = 4.0
        thumbImageView.clipsToBounds = true
    }
    
    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
}

class BookmarkSnippetCell: BookmarkCell {
    @IBOutlet weak var snippetLabel: UILabel!
}

// MARK: - Protocol

protocol TableCellDelegate: class {
    func didTapOnAccessoryViewForCell(cell: UITableViewCell)
}

// MARK: - General

class TextSwitchCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var switchControl: UISwitch!
}
