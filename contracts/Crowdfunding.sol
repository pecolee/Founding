// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract CrowdFunding {
    address public immutable beneficiary;
    uint256 public immutable fundingGoal;
    uint256 public fundingAmount;
    mapping (address=>uint256) public funders;
    mapping(address=>bool) private  fundersInsert;
    address[] public fundersKey;
    bool public Available=true;

    uint256 public countdownEnd;
    bool public isCountdownActive;
    // beneficiary+target
    constructor(address beneficiary_, uint256 goal){
        beneficiary = beneficiary_;
        fundingGoal = goal;
    }
    // Countdown
    function Start(uint256 duration)external returns (string memory){
        if(msg.sender == beneficiary){
        require(!isCountdownActive, "Countdown already active");
        countdownEnd = block.timestamp + duration;
        isCountdownActive = true;
        return "Start";
        }
        return "permission denied";
    }
    // CheckConutDown
      function CheckCountdown() external view returns (bool) {
        if (block.timestamp >= countdownEnd) {
            return true; // 倒计时已结束
        } else {
            return false; // 倒计时仍在进行
        }
    }
    // StopCountdown
      function StopCountdown() external {
        if (msg.sender == beneficiary){
        require(isCountdownActive, "No active countdown to stop");
        isCountdownActive = false;
        }
    }

    // funding
    function Donate() external payable {
        require(Available,"this contract was closed");
         require(isCountdownActive,"didt open or times up");
        funders[msg.sender] += msg.value;
        fundingAmount += msg.value;
        if(!fundersInsert[msg.sender]){
            fundersInsert[msg.sender] = true;
            fundersKey.push(msg.sender);
        }
    }
    // closeContract
    function Close()external returns (bool res){
      if(fundingGoal>fundingAmount){
        return false;
      }
      uint256 amount= fundingAmount;
      fundingAmount =0;
      Available=false;
      // transfer
      payable (beneficiary).transfer(amount);
      return true;
    }
    // getParticipants
    function GetParticipants() public view  returns (uint256) {
        return fundersKey.length;
    }
}