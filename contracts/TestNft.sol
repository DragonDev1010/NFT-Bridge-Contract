// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract TestNft is ERC721, Ownable {
    uint256 public total;
    string public baseURI;
    constructor() ERC721('Test NFT', 'TEST') {}

    function mint() public {
        _mint(msg.sender, total);
        total++;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }
}