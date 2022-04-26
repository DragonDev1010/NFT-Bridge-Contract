// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

interface INftFactory {
    function createNft (string memory name, string memory symbol, string memory baseUri) external returns(address);
    function setBaseUri(string memory _newBaseURI, uint256 childId) external;
}