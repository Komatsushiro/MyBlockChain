import UIKit

class ViewController: UIViewController {

    private let myId = "me"
    private let recipientId = "someone"
    private let server = BlockChainServer()

    @IBOutlet weak var logView: UITextView!
    @IBOutlet weak var chainView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        logView.text = ""

        updateChain()
    }

    private func updateChain() {
        let chain = server.chain()
        var text = "chain:\n"
        for block in chain {
            text.append(block.description() + "\n")
        }
        chainView.text = text
    }

    @IBAction func sendBtnTapped(_ sender: UIButton) {
        let index = server.send(sender: myId, recipient: recipientId, amount: 5)
        let text = "Transaction will be added to Block \(index)"
        logView.text = text + "\n" + logView.text
        updateChain()
    }

    @IBAction func mineBtnTapped(_ sender: UIButton) {
        let startTime = CACurrentMediaTime()
        let text = "Mining..."
        self.logView.text = text + "\n" + self.logView.text

        server.mine(recipient: myId, completion: { (block) in
            let text = String(format: "New Block Forged (%.1f s)", CACurrentMediaTime() - startTime)
            self.logView.text = text + "\n" + self.logView.text
            print(text+block.description())
            self.updateChain()
        })
    }

}

