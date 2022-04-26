// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import '@openzeppelin/contracts/access/Ownable.sol';
import './WrapNft.sol';

contract NftFactory is Ownable{
    WrapNft[] public childList;
    
    function createNft (string memory name, string memory symbol, string memory _baseURI) public returns (address){
        WrapNft wrapNft = new WrapNft(name, symbol);
        wrapNft.setBaseURI(_baseURI);
        childList.push(wrapNft);
        return address(wrapNft);
    }

    function updateBaseUri(string memory _newBaseURI, uint256 childId) public onlyOwner {
        childList[childId].setBaseURI(_newBaseURI);
    }
}