// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract WrapNft is ERC721, Ownable {
    string public baseURI;

    constructor(string memory name, string memory symbol) ERC721(name, symbol) {}

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function mint(address receiver, uint tokenId) public {
        _mint(receiver, tokenId);
    }
}