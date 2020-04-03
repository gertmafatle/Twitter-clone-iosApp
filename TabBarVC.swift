
import UIKit

class TabBarVC: UITabBarController {
    
    
    // first load func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // color of item in tabbar controller
        self.tabBar.tintColor = .whiteColor()

        // color of background of tabbar controller
        self.tabBar.barTintColor = colorBrandBlue
        
        // disable translucent
        self.tabBar.translucent = false
        
        
        // color of text under icon in tabbar controller
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName : colorSmoothGray], forState: .Normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName : UIColor.whiteColor()], forState: .Selected)
        
        // new color for all icons of tabbar controller
        for item in self.tabBar.items! as [UITabBarItem] {
            if let image = item.image {
                item.image = image.imageColor(colorSmoothGray).imageWithRenderingMode(.AlwaysOriginal)
            }
        }
        
        
        // call animation of twitter
        twitterAnimation()
        
    }
    
    
    // Twitter Brand Animation
    func twitterAnimation() {
        
        // Blue layer
        let layer = UIView() // declare var of type UIView
        layer.frame = self.view.frame // declare size = same as screen's
        layer.backgroundColor = colorBrandBlue // color of view
        self.view.addSubview(layer) // add view to vc
        
        // Twitter icon
        let icon = UIImageView() // declare var of type uiimageView. Because it can store an image
        icon.image = UIImage(named: "twitter.png") // we refer to our image to be stored
        icon.frame.size.width = 100 // width of imageview
        icon.frame.size.height = 100 // height of imageview
        icon.center = view.center // center imageview as per screen size
        self.view.addSubview(icon) // imageview to vc
        
        // starting animation - zoom out bird
        UIView.animateWithDuration(0.5, delay: 1, options: .CurveLinear, animations: { 
            
            // make small twitter
            icon.transform = CGAffineTransformMakeScale(0.9, 0.9)
            
        }) { (finished:Bool) in
            
            // first func is finished
            if finished {
                
                // second animation - zoom in bird
                UIView.animateWithDuration(0.5, animations: { 
                    
                    // make big twitter
                    icon.transform = CGAffineTransformMakeScale(20, 20)
                    
                    // third animation - disapear bird
                    UIView.animateWithDuration(0.1, delay: 0.3, options: .CurveLinear, animations: { 
                        
                        // hide bird & layer
                        icon.alpha = 0
                        layer.alpha = 0
                        
                    }, completion: nil)
                    
                    
                })
                
            }
            
        }
        
        
        
    }
    
    
    
}


// new class we created to refer to our icon in tabbar controller.
extension UIImage {
    
    // in this func we customize our UIImage - our icon
    func imageColor(color : UIColor) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        
        let context = UIGraphicsGetCurrentContext()! as CGContextRef
        CGContextTranslateCTM(context, 0, self.size.height)
        CGContextScaleCTM(context, 1.0, -1.0)
        
        let rect = CGRectMake(0, 0, self.size.width, self.size.height) as CGRect
        CGContextClipToMask(context, rect, self.CGImage)
        
        color.setFill()
        CGContextFillRect(context, rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext() as UIImage
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
}
