// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title NFTStakingEngine
 * @dev High-performance staking system for ERC-721 tokens with ERC-20 rewards.
 */
contract NFTStakingEngine is Ownable {
    IERC721 public nftCollection;
    IERC20 public rewardToken;

    uint256 public rewardRatePerHour = 10 * 10**18; // 10 tokens per hour
    
    struct Stake {
        uint240 timestamp;
        address owner;
    }

    mapping(uint256 => Stake) public vault;
    mapping(address => uint256) public totalStaked;

    event Staked(address indexed user, uint256 tokenId, uint256 timestamp);
    event Unstaked(address indexed user, uint256 tokenId, uint256 timestamp);
    event RewardClaimed(address indexed user, uint256 reward);

    constructor(address _nft, address _reward) Ownable(msg.sender) {
        nftCollection = IERC721(_nft);
        rewardToken = IERC20(_reward);
    }

    function stake(uint256[] calldata tokenIds) external {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            require(nftCollection.ownerOf(tokenId) == msg.sender, "Not the owner");
            
            nftCollection.transferFrom(msg.sender, address(this), tokenId);
            vault[tokenId] = Stake(uint240(block.timestamp), msg.sender);
            totalStaked[msg.sender]++;
            
            emit Staked(msg.sender, tokenId, block.timestamp);
        }
    }

    function calculateReward(address user, uint256 tokenId) public view returns (uint256) {
        Stake memory stakedItem = vault[tokenId];
        if (stakedItem.owner != user) return 0;
        
        uint256 stakingDuration = block.timestamp - uint256(stakedItem.timestamp);
        return (stakingDuration * rewardRatePerHour) / 3600;
    }

    function unstake(uint256[] calldata tokenIds) external {
        uint256 totalReward = 0;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            require(vault[tokenId].owner == msg.sender, "Not the owner");
            
            totalReward += calculateReward(msg.sender, tokenId);
            delete vault[tokenId];
            totalStaked[msg.sender]--;
            
            nftCollection.transferFrom(address(this), msg.sender, tokenId);
            emit Unstaked(msg.sender, tokenId, block.timestamp);
        }
        if (totalReward > 0) {
            rewardToken.transfer(msg.sender, totalReward);
        }
    }
}
