// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

interface IWrapNft {
    function mint(address receiver, uint tokenId) external;
    function setBaseURI(string memory _newBaseURI) external;
}