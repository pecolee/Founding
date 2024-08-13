// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

// testAddress["0x5B38Da6a701c568545dCfcB03FcB875f56beddC4","0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2","0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db"]
// 多签钱包，多个owner，权限控制；
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

    modifier onlyOwner(){
        require(isOwner[msg.sender],"not owner");
        _;
    }

    modifier txExists(uint256 txId){
        require(txId<transactions.length,"tx does not exit");
        _;
    }

    modifier notApproved(uint256 txId){
        require(!approved[txId][msg.sender],"tx already approved");
        _;
    }

    modifier notExcuted(uint256 txId){
        require(!transactions[txId].exected,"tx is exected");
        _;
    }

    constructor(address[] memory _owners, uint256 _required) {
        require(_owners.length>0,"not enough address");
        require(_required <=_owners.length && _required>0,"wrong required number");
        // checkAddress
        for (uint256 i;i<_owners.length;i++){
            address owner = _owners[i];
            require(owner != address(0),"wrong address");
            require(!isOwner[owner],"owner is not unique");
            isOwner[owner] = true;
            owners.push(owner);
        }
        required=_required;
    }

    receive() external payable {
        emit Deposit(msg.sender,msg.value);
    } 

    function getBalance() external view returns (uint256){
        return address(this).balance;
    } 

    function submit(address _to,uint256 _value,bytes calldata _data) external onlyOwner returns (uint256 id_){
        transactions.push(
            Transaction({to:_to,value:_value,data:_data,exected:false})
        );
        emit Submit(transactions.length-1);
        return transactions.length-1;
    }

    function approve(uint256 _txId)external onlyOwner txExists(_txId) notApproved(_txId) notExcuted(_txId){
        approved[_txId][msg.sender] = true;
        emit Approve(msg.sender, _txId);
    }

    function revoke(uint256 _txId)external onlyOwner txExists(_txId) notExcuted(_txId){
        require(approved[_txId][msg.sender],"tx not approved");
        approved[_txId][msg.sender] = false;
        emit Revoke(msg.sender, _txId);
    }
    
    function getSigCount(uint256 _txId) public view returns (uint256 count){
        for (uint256 i = 0;i<owners.length;i++){
            if (approved[_txId][owners[i]]){
                count += 1;
            }
        }
    }

    function excute(uint256 _txId)external onlyOwner txExists(_txId) notExcuted(_txId){
        require(getSigCount(_txId)>=required,"approve<required");
        Transaction storage transaction = transactions[_txId];
        transaction.exected = true;
        (bool sucess, ) = transaction.to.call{value: transaction.value}(transaction.data);
        require(sucess,"tx falied");
        emit Execute(_txId);
    }
}

