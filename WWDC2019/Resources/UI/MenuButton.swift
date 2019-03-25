import UIKit

public final class MenuButton: UIButton {
    
    public override var isHighlighted: Bool {
        get {
            return super.isHighlighted
        } set {
            if newValue != super.isHighlighted {
                shouldHighlight(newValue)
                super.isHighlighted = newValue
            }
        }
    }
    
    private func shouldHighlight(_ condition: Bool) {
        if condition {
            alpha = 0.5
        } else {
            
            UIView.animate(withDuration: 0.25,
                           delay: 0,
                           options: [
                            .beginFromCurrentState,
                            .allowUserInteraction
                ],
                           animations: {
                            self.alpha = 1.0
            })
        }
    }
    
    private func setup() {
        titleLabel?.font = UIFont.noteworthy.light(ofSize: 18)
        setTitleColor(.black, for: .normal)
        backgroundColor = .orange
        layer.cornerRadius = 18.0
    }
    
    public init(withTitle title: String, target: Any?, action: Selector) {
        super.init(frame: .zero)
        
        setTitle(title, for: .normal)
        addTarget(target, action: action, for: .touchUpInside)
        setup()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
}
