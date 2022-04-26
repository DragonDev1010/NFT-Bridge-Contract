const SrcBridge = artifacts.require('./SrcBridge.sol')
const DestBridge = artifacts.require('./DestBridge.sol')
const TestNft = artifacts.require('./TestNft.sol')
const Factory = artifacts.require('./wrapNft/NftFactory.sol')

contract('NFT bridge contract testing', async(accounts) => {
    let src, dest, nft, factory, tx
    let locker = accounts[1]

    let signer = accounts[9]
    let signerPrivKey = "0x4d4de74e791ded9d7e0add7a5f50e9097e56102239c5f432e61c325868dd9cb9" // copy paste from ganache-cli
    let nonSignerPrivKey = "0x71234879392cc2923eab957777310515a4fd23db65ce7138ff6952aa806c62d4"

    let srcXId // Lock nft transaction Id
    before(async() => {
        src = await SrcBridge.deployed()
        dest = await DestBridge.deployed()
        nft = await TestNft.deployed()
        factory = await Factory.deployed()
    })
    
    it('mint test nft ', async() => {
        for(let i = 0 ; i < 5 ; i++)
            await nft.mint({from: locker})
    })

    it('set signer', async() => {
        await src.setSigner(signer)
        await dest.setSigner(signer)
    })

    it('lock nft to source bridge', async() => {
        await nft.approve(src.address, 0, {from: locker}) // NFT owner approve bridge contract to transfer token
        tx = await src.lock(nft.address, 0, {from: locker})
        srcXId = tx.logs[0].args.transferId
    })

    it('create wrap nft on destination chain', async() => {
        // set nftFactory contract address
        await dest.setNftFactory(factory.address);

        // create wrap nft
        let wrapName = await nft.name.call()
        let wrapSymbol = await nft.symbol.call()
        let wrapBaseUri = await nft.baseURI.call()
        await dest.createNft(nft.address, wrapName, wrapSymbol, wrapBaseUri)
    })

    it('unlock nft', async() => {
        let wrapNftAddr = await dest.wrapNfts.call(0)
        let receiver = locker
        let tokenId = 0
        
        let msg = web3.eth.abi.encodeParameters(
            [ 'address', 'address', 'uint256', 'uint256' ],
            [ wrapNftAddr, receiver, tokenId, srcXId ]
        )
        
        let signature = web3.eth.accounts.sign(msg, signerPrivKey)
        
        await dest.unlock(msg, signature.messageHash, Number(signature.v), signature.r, signature.s)

        try {
            await dest.unlock(msg, signature.messageHash, Number(signature.v), signature.r, signature.s)
        } catch {
            console.log('Unlock Failed: unlock request has already done ')
        }

        try {
            msg = web3.eth.abi.encodeParameters(
                [ 'address', 'address', 'uint256', 'uint256' ],
                [ wrapNftAddr, receiver, tokenId, srcXId ]
            )
            signature = web3.eth.accounts.sign(msg, nonSignerPrivKey)
            await dest.unlock(msg, signature.messageHash, Number(signature.v), signature.r, signature.s)
        } catch {
            console.log('Unlock Failed: non-signer signed the message')
        }
    })
})