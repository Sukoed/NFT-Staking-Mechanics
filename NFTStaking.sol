// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract NFTStaking {
    mapping(uint256 => address) public tokenOwners;
    function stake(uint256 tokenId) external {
        tokenOwners[tokenId] = msg.sender;
        // Transfer logic here
    }
}
