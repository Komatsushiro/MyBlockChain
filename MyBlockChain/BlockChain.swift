import Foundation

class BlockChain {

    private var currentTransactions: [Transaction] = []
    var chain: [Block] = []

    init() {
        createBlock(proof: 100, previousHash: "1".data(using: .utf8))
    }

    func createBlock(proof: Int, previousHash: Data? = nil) -> Block {
        let prevHash = previousHash ?? getLastBlock().hash()
        let block = Block(index: chain.count + 1,
                          timestamp: Date().timeIntervalSince1970,
                          transactions: currentTransactions,
                          proof: proof,
                          previousHash: prevHash)
        currentTransactions = []
        chain.append(block)
        return block
    }

    func createTransaction(sender: String, recipient: String, amount: Int) -> Int {
        let transaction = Transaction(sender: sender, recipient: recipient, amount: amount)
        currentTransactions.append(transaction)
        return getLastBlock().index + 1
    }

    func getLastBlock() -> Block {
        guard let lastBlock = chain.last else {
            fatalError("The chain should have at least one block as a genesis.")
        }
        return lastBlock
    }

    class func proofOfWork(lastProof: Int) -> Int {
        var proof = 0
        while !validProof(lastProof: lastProof, proof: proof) {
            proof += 1
        }
        return proof
    }

    class func validProof(lastProof: Int, proof: Int) -> Bool {
        guard let guess = String("\(lastProof)\(proof)").data(using: .utf8) else {
            fatalError()
        }
        let guess_hash = guess.sha256()?.hexDigest()
        return guess_hash?.prefix(4) == "0000"
    }
}
