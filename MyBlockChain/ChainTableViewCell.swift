import Foundation
import UIKit

class ChainTableViewCell: UITableViewCell {

    private let senderTitleLabel: UILabel! = {
        let senderTitleLabel = UILabel()
        senderTitleLabel.text = "送信者："
        senderTitleLabel.textColor = .black
        return senderTitleLabel
    }()
    let senderLabel: UILabel! = {
        let senderLabel = UILabel()
        senderLabel.textColor = .black
        return senderLabel
    }()
    private let recipientTitleLabel: UILabel! = {
        let recipientTitleLabel = UILabel()
        recipientTitleLabel.text = "受信者："
        recipientTitleLabel.textColor = .black
        return recipientTitleLabel
    }()
    let recipientLabel: UILabel! = {
        let recipientLabel = UILabel()
        recipientLabel.textColor = .black
        return recipientLabel
    }()
    private let amountTitleLabel: UILabel! = {
        let amountTitleLabel = UILabel()
        amountTitleLabel.text = "金額："
        amountTitleLabel.textColor = .black
        return amountTitleLabel
    }()
    let amountLabel: UILabel! = {
        let amountLabel = UILabel()
        amountLabel.textColor = .black
        return amountLabel
    }()

    struct ViewData {
        let sender: String
        let recipient: String
        let amount: Int
    }

    var viewData: ViewData? {
        didSet {
            senderLabel.text = viewData?.sender
            recipientLabel.text = viewData?.recipient
            amountLabel.text = (viewData?.amount.description)! + "coin"
        }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(senderTitleLabel)
        addSubview(senderLabel)
        addSubview(recipientTitleLabel)
        addSubview(recipientLabel)
        addSubview(amountTitleLabel)
        addSubview(amountLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateConstraints() {
        super.updateConstraints()
        senderTitleLabel.anchor().topToSuperview().leftToSuperview().activate()
        senderLabel.anchor().centerY(to: senderTitleLabel.centerYAnchor).left(to: senderTitleLabel.rightAnchor).activate()
        recipientTitleLabel.anchor().top(to: senderLabel.bottomAnchor).left(to: senderTitleLabel.leftAnchor).activate()
        recipientLabel.anchor().centerY(to: recipientTitleLabel.centerYAnchor).left(to: recipientTitleLabel.rightAnchor).activate()
        amountTitleLabel.anchor().top(to: recipientTitleLabel.bottomAnchor).bottomToSuperview().left(to: senderTitleLabel.leftAnchor).activate()
        amountLabel.anchor().centerY(to: amountTitleLabel.centerYAnchor).left(to: amountTitleLabel.rightAnchor).activate()
    }

}

extension ChainTableViewCell.ViewData {
    init(item: Transaction) {
        sender = item.sender
        recipient = item.recipient
        amount = item.amount
    }
}
