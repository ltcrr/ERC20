// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract token is ERC20, ERC20Capped, Ownable, Pausable {

    mapping (address => bool) private hasClaimed;
    uint public taxRate = 400;
    address public taxRecipient = owner();

    
    mapping(address => uint256) public stakingBalance;
    mapping(address => uint256) public stakeStart;
    uint256 public rewardRate = 1e16; 

    

    constructor(uint256 initialSupply)
        ERC20("SwearU", "SWU")
        Ownable(msg.sender)
        ERC20Capped(1_000_000 * 10 ** 18)
    {
        _mint(msg.sender, initialSupply * 10 ** 18);
    }

    function _update(address from, address to, uint256 amount)
        internal
        override(ERC20, ERC20Capped)
    {
        if (from != address(0) && to != address(0) && taxRate > 0) {
            uint256 fee = (amount * taxRate) / 10_000;
            uint256 netAmount = amount - fee;

            if (fee > 0) super._update(from, taxRecipient, fee);
            if (netAmount > 0) super._update(from, to, netAmount);
        } else {
            super._update(from, to, amount);
        }
    }

    function claimToken() external {
        require(!hasClaimed[msg.sender], "Already claimed");
        hasClaimed[msg.sender] = true;
        _mint(msg.sender, 100 * 10 ** 18);
    }

    function devMint(uint256 amount) external onlyOwner {
        _mint(msg.sender, amount * 10 ** 18);
    }

    function burnTokens(uint256 _amount) external {
        _burn(msg.sender, _amount);
    }

    function stake(uint256 amount) external {
        require(amount > 0, "Amount = 0");
        require(balanceOf(msg.sender) >= amount, "Not enough tokens");

        _claim(msg.sender);

        _transfer(msg.sender, address(this), amount);
        stakingBalance[msg.sender] += amount;
        stakeStart[msg.sender] = block.timestamp;
    }

    function unstake(uint256 amount) external {
        require(stakingBalance[msg.sender] >= amount, "Not staked enough");

        _claim(msg.sender);

        stakingBalance[msg.sender] -= amount;
        _transfer(address(this), msg.sender, amount);

        if (stakingBalance[msg.sender] == 0) {
            stakeStart[msg.sender] = 0;
        } else {
            stakeStart[msg.sender] = block.timestamp;
        }
    }

    function claimRewards() external {
        _claim(msg.sender);
    }

    function _claim(address user) internal {
        uint256 staked = stakingBalance[user];
        if (staked == 0) return;

        uint256 duration = block.timestamp - stakeStart[user];
        uint256 reward = (staked * rewardRate * duration) / 1e18;

        if (reward > 0) {
            _mint(user, reward);
        }
        stakeStart[user] = block.timestamp;
    }
}
