import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    private let server = BlockChainServer()

    private let logView: UITextView! = {
        let logView = UITextView()
        logView.backgroundColor = .white
        logView.isEditable = false
        return logView
    }()
    private let chainView: UITextView! = {
        let chainView = UITextView()
        chainView.backgroundColor = .white
        return chainView
    }()

    private lazy var tableView: UITableView! = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorInset = .zero
        tableView.showsVerticalScrollIndicator = false
        tableView.estimatedRowHeight = 5
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(ChainTableViewCell.self, forCellReuseIdentifier: "ChainTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
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
            let text = "この取引はBlock \(index)に追加されます。"
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
                let text = String(format: "新しいBlockをマイニングしました (%.1f s)", CACurrentMediaTime() - startTime)
                self.logView.text = text + "\n" + self.logView.text
                print(text+block.description())
                self.updateChain()
                self.tableView.reloadData()
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

        tableView.rx.itemSelected.subscribe(onNext: { [unowned self] indexPath in
            print((self.tableView.cellForRow(at: indexPath) as! ChainTableViewCell).senderLabel.text)
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
        view.addSubview(tableView)
    }

    private func addConstraints(){
        logView.anchor()
            .topToSuperview()
            .leftToSuperview()
            .rightToSuperview()
            .height(to: self.view.heightAnchor, multiplier: 1/3).activate()
        tableView.anchor()
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

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section != 0 ? self.server.blockChain.chain[section].transactions.count : 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChainTableViewCell", for: indexPath) as! ChainTableViewCell
        if indexPath.section == 0 {
            return cell
        }
        let item = self.server.blockChain.chain[indexPath.section].transactions[indexPath.row]
        cell.senderLabel.text = self.server.blockChain.chain[indexPath.section].transactions[indexPath.row].sender
        cell.recipientLabel.text = self.server.blockChain.chain[indexPath.section].transactions[indexPath.row].recipient
        cell.amountLabel.text = String(self.server.blockChain.chain[indexPath.section].transactions[indexPath.row].amount) + "coin"
        cell.viewData = ChainTableViewCell.ViewData(item: item)
        return cell
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return server.blockChain.chain.count
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section != 0 ? "Block" + String(server.blockChain.chain[section].index) : "InitialBlock"
    }
}
