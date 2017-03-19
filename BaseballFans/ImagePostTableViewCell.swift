//
//  ImagePostTableViewCell.swift
//  BaseballFans
//
//  Created by Sun Huanji on 2017/3/19.
//  Copyright © 2017年 Sun Huanji. All rights reserved.
//

import UIKit

class ImagePostTableViewCell: UITableViewCell {
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var account: UILabel!
    @IBOutlet weak var post: UILabel!
    @IBOutlet weak var postImage: UIImageView!

    @IBOutlet weak var userImage: CustomizableImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
