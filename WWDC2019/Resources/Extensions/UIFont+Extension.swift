import UIKit

extension UIFont {
    public static let noteworthy = Noteworthy()
    
    public struct Noteworthy {
        private let fontName = "Noteworthy"
        
        public func light(ofSize size: CGFloat) -> UIFont {
            return UIFont(name: "\(fontName)-Light", size: size)!
        }
        
        public func bold(ofSize size: CGFloat) -> UIFont {
            return UIFont(name: "\(fontName)-Bold", size: size)!
        }
        
        fileprivate init() {}
    }
}
