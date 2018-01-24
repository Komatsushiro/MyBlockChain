import Foundation

class BlockChainServer {

    let blockChain = BlockChain()

    func send(sender: String, recipient: String, amount: Int) -> Int {
        return blockChain.createTransaction(sender: sender, recipient: recipient, amount: amount)
    }

    func mine(recipient: String, completion: ((Block) -> Void)?) {
        DispatchQueue.global(qos: .default).async {
            let lastblock = self.blockChain.getLastBlock()
            let lastProof = lastblock.proof
            let proof = BlockChain.proofOfWork(lastProof: lastProof)

            self.blockChain.createTransaction(sender: "0", recipient: recipient, amount: 1)

            let block = self.blockChain.createBlock(proof: proof)

            DispatchQueue.main.async(execute: {
                completion?(block)
            })
        }
    }

    func chain() -> [Block] {
        return blockChain.chain
    }
}
