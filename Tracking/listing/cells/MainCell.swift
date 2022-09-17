//
//  MainCell.swift
//  Tracking
//
//  Created by anthonioez on 03/06/2019.
//  Copyright © 2019 anthonioez. All rights reserved.
//

import UIKit

class MainCell: UITableViewCell
{
    public static let cellIdentifier = "MainCell"
    public static let cellHeight = CGFloat(44)
   
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelDesc: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
    }
    
    func setData(_ data: Entry)
    {
        labelTitle.text = String(format: "(%.4f, %.4f), %.2f", data.latitude, data.longitude, data.speed)
        labelDesc.text = AppDelegate.date(data.stamp)
    }
}
