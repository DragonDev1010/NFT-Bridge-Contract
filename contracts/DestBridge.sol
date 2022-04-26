// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import './interface/INftFactory.sol';
import './interface/IWrapNft.sol';

contract DestBridge is Ownable{
    uint256 private locked;
    uint256 public fee;
    address public signer;
    mapping(bytes32 => bool) private executedXIds;
    address public nftFactory;
    address[] public wrapNfts;
    mapping(address => address) public wrapMatch;
    mapping(bytes => bool) private usedMsg;

    event Locked(bytes32 transferId);

    function lock(address nftAddr, uint256 tokenId) public {
        require(signer != address(0), 'Signer is not yet set.'); // Only if `signer` is set, lock token is allowed
        require(IERC721(nftAddr).getApproved(tokenId) == address(this), 'Owner has to approve token to lock');
        IERC721(nftAddr).transferFrom(msg.sender, address(this), tokenId);

        bytes32 transferId = keccak256(abi.encodePacked(msg.sender, nftAddr, tokenId, (locked*37), block.timestamp));
        locked++;
        emit Locked(transferId);
    }

    function unlock(bytes memory requestMsg, bytes32 msgHash, uint8 v, bytes32 r, bytes32 s) public {
        require(usedMsg[requestMsg] == false, 'Request message is already used.');
        require(_isSigned(msgHash, v, r, s), "failed to verify");
        address wrapNftAddr;
        address receiver;
        uint256 tokenId;
        (wrapNftAddr, receiver, tokenId) = _parse(requestMsg);
        IWrapNft(wrapNftAddr).mint(receiver, tokenId);
        usedMsg[requestMsg] = true;
    }

    function _parse(bytes memory request) private pure returns(address, address, uint256) {
        address wrapNftAddr;
        address receiver;
        uint256 tokenId;

        assembly {
            wrapNftAddr := mload(add(request, 0x20))
            receiver := mload(add(request, 0x40))
            tokenId := mload(add(request, 0x60))
        }

        return (wrapNftAddr, receiver, tokenId);
    }

    function _isSigned( bytes32 msgHash, uint8 v, bytes32 r, bytes32 s) private view returns (bool) {
        return ecrecover(msgHash, v, r, s) == signer;
    }

    function setSigner(address signer_) public onlyOwner {
        signer = signer_;
    }

    function setNftFactory(address factory_) public onlyOwner {
        require(factory_ != address(0), 'Factory contract address can not be zero.');
        nftFactory = factory_;
    }
    
    function createNft(address srcNftAddr, string memory name, string memory symbol, string memory baseUri) public onlyOwner {
        address newWrapNft = INftFactory(nftFactory).createNft(name, symbol, baseUri);
        wrapMatch[srcNftAddr] = newWrapNft;
        wrapNfts.push(newWrapNft);
    }

    function setFee(uint256 fee_) public onlyOwner {
        fee = fee_;
    }
}
