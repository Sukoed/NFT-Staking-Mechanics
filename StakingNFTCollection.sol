// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract StakingNFTCollection is ERC721, Ownable {
    uint256 public constant MAX_SUPPLY = 10000;
    uint256 private _nextTokenId;

    constructor() ERC721("Staking Test Collection", "STK") Ownable(msg.sender) {}

    function mint(address to) external onlyOwner {
        require(_nextTokenId < MAX_SUPPLY, "Sold out");
        _safeMint(to, _nextTokenId);
        _nextTokenId++;
    }

    function burn(uint256 tokenId) external {
        require(ownerOf(tokenId) == msg.sender, "Not owner");
        _burn(tokenId);
    }
}
