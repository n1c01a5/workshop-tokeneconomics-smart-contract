/* SPDX-License-Identifier: UNLICENSED */
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MetaCoin is ERC20 {
    constructor() ERC20("MetaCoin", "MTC") {
        _mint(msg.sender, 1000000000000000000000000);
    }
}

contract META_ICO {
    ERC20 token;
    
    address owner;
    
    mapping(address => uint) public contributorsToTokenAmount;
    
    uint public RATE_ETH = 1000; // price ICO : 1 ether for 1000 MTC tokens
    uint public RATE_DISCOUNT = 50;
    uint public ethRaised; // in wei
    uint public timeout;
    uint public MIN_CAP = 1000000000000000000;  // in wei (1 ether)

    struct PeriodWithDiscount {
        uint period;
        uint rate_discount;
    }

    PeriodWithDiscount[2] public periodWithDiscounts;
    
    bool public isFinalized;
    bool public isSuccessful;
    
    event boughtTokens(address contributor, uint amount);
    event withdrawTokens(address contributor, uint amount);
    
    modifier whenSaleIsActive() {
        require(block.timestamp <= timeout, "ICO is not active.");
        _;
    }
    
    modifier whenSaleIsFinalized() {
        require(isFinalized);
        _;
    }
    
    constructor(ERC20 _token, uint _delay) {
        owner = msg.sender;
        token = _token;
        periodWithDiscounts[0] = PeriodWithDiscount(
            block.timestamp + 2628000, // +30j 
            50
        );
        periodWithDiscounts[1] = PeriodWithDiscount(
            block.timestamp + 5256000, // +60j
            25
        );
        timeout = block.timestamp + _delay;
    }
    
    function buyTokens() public payable whenSaleIsActive {
        uint tokensAmount = msg.value * RATE_ETH;
        ethRaised += msg.value;

        if (block.timestamp <= periodWithDiscounts[0].period) {
            contributorsToTokenAmount[msg.sender] += tokensAmount * (100 + periodWithDiscounts[0].rate_discount) / 100;
        } else if (block.timestamp <= periodWithDiscounts[1].period) {
            contributorsToTokenAmount[msg.sender] += tokensAmount * (100 + periodWithDiscounts[1].rate_discount) / 100;
        } else {
            contributorsToTokenAmount[msg.sender] += tokensAmount;
        }
        
        emit boughtTokens(msg.sender, tokensAmount);
    }
    
    function finalize() external {
        require(block.timestamp > timeout, "ICO is not finished.");
        isFinalized = true;

        if (ethRaised >= MIN_CAP) {
            isSuccessful = true;
        }
    }
    
    function withdraw() external whenSaleIsFinalized {
        require(contributorsToTokenAmount[msg.sender] > 0, "Should have some tokens.");
        
        uint tokensAmount = contributorsToTokenAmount[msg.sender];
        contributorsToTokenAmount[msg.sender] = 0;
        
        if (isSuccessful) {
            token.transfer(msg.sender, tokensAmount); // withdraw tokens 
            emit withdrawTokens(msg.sender, tokensAmount);
        } else {
            payable(msg.sender).transfer(tokensAmount / RATE_ETH);  // withdraw eth 
        }
    }
    
    function withdrawEthers() external whenSaleIsFinalized {
        payable(owner).transfer(address(this).balance);  // transfer ethers
    }
    
    function timeleft() external view returns (uint) {
        if (block.timestamp > timeout) {
            return 0;
        }
        
        return timeout - block.timestamp;
    }
    
    function addTimeleft(uint _addTime) external {
        require(owner == msg.sender);
        timeout += _addTime;
    }
    
    receive() external payable {
        buyTokens();
    }
}