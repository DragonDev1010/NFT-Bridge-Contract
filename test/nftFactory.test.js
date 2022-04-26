const NftFactory = artifacts.require('./wrapNft/NftFactory.sol')
const WrapNft = artifacts.require('./wrapNft/WrapNft.sol')

contract('NFT Factory Contract', async(accounts) => {
    let wrapNft, factory, tx
    before(async() => {
        wrapNft = await WrapNft.deployed()
        factory = await NftFactory.deployed()
    })

    it('create wrapNft contract', async() => {
        tx = await factory.createNft('Wrap Nft', 'WRAPNFT', '')

        let nfts = await factory.childList.call(0)
        console.log(nfts)
        const nft_1 = await WrapNft.at(nfts)

        // set base uri
        await factory.updateBaseUri('ipfs/gateway/cloud/', 0)

        // mint
        await nft_1.mint(accounts[0], 5)

        // check token uri of #5 wrapNft
        let tokenURI = await nft_1.tokenURI(5)
        console.log(tokenURI.toString())
    })
})