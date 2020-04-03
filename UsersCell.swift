
import UIKit

class UsersCell: UITableViewCell {

    // UI obj
    @IBOutlet var avaImg: UIImageView!
    @IBOutlet var usernameLbl: UILabel!
    @IBOutlet var fullnameLbl: UILabel!
    
    
    // first load func
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // round corners
        avaImg.layer.cornerRadius = avaImg.bounds.width / 2
        avaImg.clipsToBounds = true
        
        // color
        usernameLbl.textColor = colorBrandBlue
        
    }
    
    
}
