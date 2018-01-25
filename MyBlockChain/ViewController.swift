import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

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

    private lazy var sendingDialog: UIAlertController = {
        let sendingDialog = UIAlertController(title:"coinを送信する",
                                           message: "項目を入力してください",
                                           preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "送信", style: .default) {
            action -> Void in
            let textFields = sendingDialog.textFields as Array<UITextField>?
            guard let values = textFields else {
                return
            }
            for textField in values {
                if (textField.text ?? "").isEmpty {
                    self.present(self.alertDialog, animated: true, completion: nil)
                    return
                }
            }
            let index = self.server.send(sender: values[0].text!,
                                         recipient: values[1].text!,
                                         amount: Int(values[2].text!)!)
            let text = "Transaction will be added to Block \(index)"
            self.logView.text = text + "\n" + self.logView.text
            self.updateChain()
        }
        sendingDialog.addAction(cancelAction)
        sendingDialog.addAction(okAction)
        sendingDialog.addTextField { textField -> Void in
            textField.placeholder = "送信者"
            var label = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 30))
            label.text = "From"
            textField.leftView = label
            textField.leftViewMode = .always
        }
        sendingDialog.addTextField { textField -> Void in
            textField.placeholder = "送信先"
            var label = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 30))
            label.text = "To"
            textField.leftView = label
            textField.leftViewMode = .always
        }
        sendingDialog.addTextField { textField -> Void in
            textField.placeholder = "金額"
            textField.keyboardType = .decimalPad
            var label = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 30))
            label.text = "$"
            textField.leftView = label
            textField.leftViewMode = .always
        }

        return sendingDialog
    }()

    private lazy var miningDialog: UIAlertController = {
        let miningDialog = UIAlertController(title: "マイニングする",
                                             message: "あなたのIDを入力してください",
                                             preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "採掘", style: .default) {
            action -> Void in
            let textFields = miningDialog.textFields as Array<UITextField>?
            guard let values = textFields else {
                return
            }
            for textField in values {
                if (textField.text ?? "").isEmpty {
                    self.present(self.alertDialog, animated: true, completion: nil)
                    return
                }
            }
            let startTime = CACurrentMediaTime()
            let text = "Mining..."
            self.logView.text = text + "\n" + self.logView.text

            self.server.mine(recipient: values[0].text!, completion: { (block) in
                let text = String(format: "New Block Forged (%.1f s)", CACurrentMediaTime() - startTime)
                self.logView.text = text + "\n" + self.logView.text
                print(text+block.description())
                self.updateChain()
            })
        }
        miningDialog.addAction(cancelAction)
        miningDialog.addAction(okAction)
        miningDialog.addTextField { textField -> Void in
            textField.placeholder = "ID"
            var label = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 30))
            label.text = "ID"
            textField.leftView = label
            textField.leftViewMode = .always
        }
        return miningDialog
    }()

    private lazy var alertDialog: UIAlertController = {
        let alertDialog = UIAlertController(title:"エラー",
                                           message: "全ての項目を入力してください",
                                           preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { action -> Void in
        }
        alertDialog.addAction(okAction)
        return alertDialog
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
            self.present(self.sendingDialog, animated: true, completion: nil)
        }).disposed(by: disposeBag)

        mineButton.rx.tap.subscribe(onNext: { [unowned self] _ in
            self.present(self.miningDialog, animated: true, completion: nil)
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
