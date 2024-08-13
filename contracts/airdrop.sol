// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Airdrop {
    IERC20 public token;
    mapping(address => bool) public hasClaimed;

    // 代币合约地址作为参数
    constructor(IERC20 _token) {
        token = _token;
    }

    // 空投领取函数
    function claimAirdrop(uint256 amount) external {
        require(!hasClaimed[msg.sender], "Airdrop already claimed");
        require(token.balanceOf(address(this)) >= amount, "Not enough tokens in contract");

        hasClaimed[msg.sender] = true;
        token.transfer(msg.sender, amount);
    }

    // 合约部署者可以将代币转入空投合约
    function depositTokens(uint256 amount) external {
        require(token.transferFrom(msg.sender, address(this), amount), "Token transfer failed");
    }
}
