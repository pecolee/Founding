// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract MultiWallet {
    address[] public owners;
    mapping(address=>bool) public isOwner;
    uint256 public required;

    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        bool exected;
    }
    Transaction[] public transactions;
    mapping (uint256=>mapping (address=>bool)) public approved;

    event Deposit(address indexed sender,uint256 amount);
    event Submit(uint256 indexed txId);
    event Approve(address indexed owner,uint256 indexed txId);
    event Revoke(address indexed owner,uint256 txId);
    event Execute(uint256 indexed txId);

    constructor(address[] memory _owners, uint256 _required) {
        require(_owners.length>0,"not enough address");
        require(_required <=_owners.length && _required>0,"wrong required number");
        // checkAddress
        for (uint256 i;i<_owners.length;i++){
            address owner = _owners[i];
            require(owner != address(0),"wrong address");
            require(!isOwner[owner],"owner is not unique");
        }
        required=_required;
    }

    receive() external payable {
        emit Deposit(msg.sender,msg.value);
    } 
}

