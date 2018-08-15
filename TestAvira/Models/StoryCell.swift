//
//  StoryCell.swift
//  TestAvira
//
//  Created by Adrian Popovici on 15/08/2018.
//  Copyright © 2018 adrian. All rights reserved.
//

import Kingfisher
import UIKit

protocol ReadStatusUpdating: class {
    func didUpdateReadStatus(ofViewModel viewModel: StoryCellViewModel)
}

class StoryCell: UITableViewCell {
    @IBOutlet weak var storyImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var flagButton: UIButton!

    private var viewModel: StoryCellViewModel?
    weak var delegate: ReadStatusUpdating?

    @IBAction func didPressFlagButton(_ sender: UIButton) {
        if viewModel?.status == .read {
            viewModel?.status = .unread
        } else if viewModel?.status == .unread {
            viewModel?.status = .read
        }
        if viewModel != nil {
            delegate?.didUpdateReadStatus(ofViewModel: viewModel!)
        }
    }

    func configure(withViewModel viewModel: StoryCellViewModel,
                   andDelegate delegate: ReadStatusUpdating) {
        self.delegate = delegate
        self.viewModel = viewModel
        titleLabel.text = viewModel.title
        storyImageView.kf.indicatorType = .activity
        storyImageView.kf.setImage(with: URL(string: viewModel.iconUrl))
        switch viewModel.status {
        case .read:
            flagButton.setImage(#imageLiteral(resourceName: "round_flag_black_36pt"), for: .normal)
        case .unread:
            flagButton.setImage(#imageLiteral(resourceName: "outline_outlined_flag_black_36pt"), for: .normal)
        }
    }
}
