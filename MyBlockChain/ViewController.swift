import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    private let myId = "me"
    private let recipientId = "someone"
    private let server = BlockChainServer()

    private let logView: UITextView! = {
        let logView = UITextView()
        logView.backgroundColor = .white
        return logView
    }()
    private let chainView: UITextView! = {
        let chainView = UITextView()
        chainView.backgroundColor = .white
        return chainView
    }()
    private let sendButton: UIButton! = {
        let sendButton = UIButton()
        sendButton.setTitle("Send", for: .normal)
        sendButton.setTitleColor(.blue, for: .normal)
        return sendButton
    }()
    private let mineButton: UIButton! = {
        let mineButton = UIButton()
        mineButton.setTitle("Mine", for: .normal)
        mineButton.setTitleColor(.blue, for: .normal)
        return mineButton
    }()

    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        logView.text = ""
        addSubviews()
        addConstraints()
        updateChain()

        sendButton.rx.tap.subscribe(onNext: { [unowned self] _ in
            let index = self.server.send(sender: self.myId, recipient: self.recipientId, amount: 5)
            let text = "Transaction will be added to Block \(index)"
            self.logView.text = text + "\n" + self.logView.text
            self.updateChain()
        }).disposed(by: disposeBag)

        mineButton.rx.tap.subscribe(onNext: { [unowned self] _ in
            let startTime = CACurrentMediaTime()
            let text = "Mining..."
            self.logView.text = text + "\n" + self.logView.text

            self.server.mine(recipient: self.myId, completion: { (block) in
                let text = String(format: "New Block Forged (%.1f s)", CACurrentMediaTime() - startTime)
                self.logView.text = text + "\n" + self.logView.text
                print(text+block.description())
                self.updateChain()
            })
        }).disposed(by: disposeBag)
    }

    private func updateChain() {
        let chain = server.chain()
        var text = "chain:\n"
        for block in chain {
            text.append(block.description() + "\n")
        }
        chainView.text = text
    }

    private func addSubviews() {
        view.addSubview(logView)
        view.addSubview(chainView)
        view.addSubview(sendButton)
        view.addSubview(mineButton)
    }

    private func addConstraints(){
        logView.anchor()
            .topToSuperview()
            .leftToSuperview()
            .rightToSuperview()
            .height(to: chainView.heightAnchor).activate()
        chainView.anchor()
            .top(to: logView.bottomAnchor)
            .bottom(to: sendButton.topAnchor)
            .leftToSuperview()
            .rightToSuperview().activate()
        sendButton.anchor()
            .bottomToSuperview()
            .leftToSuperview()
            .height(constant: 30).activate()
        mineButton.anchor()
            .top(to: chainView.bottomAnchor)
            .left(to: sendButton.rightAnchor)
            .rightToSuperview()
            .bottom(to: view.safeAreaLayoutGuide.bottomAnchor)
            .width(to: sendButton.widthAnchor)
            .height(to: sendButton.heightAnchor).activate()
    }

}

