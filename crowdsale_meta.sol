/* SPDX-License-Identifier: UNLICENSED */
pragma solidity ^0.5.0;


import "@openzeppelin/contracts@2.5.0/token/ERC20/ERC20Detailed.sol";
import "@openzeppelin/contracts@2.5.0/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts@2.5.0/crowdsale/Crowdsale.sol";
import "@openzeppelin/contracts@2.5.0/crowdsale/emission/AllowanceCrowdsale.sol";

contract MetaCoin is ERC20, ERC20Detailed {
    constructor(uint256 initialSupply) ERC20Detailed("Meta", "MTC", 18) public {
        _mint(msg.sender, initialSupply);
    }
}

contract MyCrowdsale is Crowdsale, AllowanceCrowdsale {
    constructor(
        uint256 rate,
        address payable wallet,
        IERC20 token,
        address tokenWallet
    )
        AllowanceCrowdsale(tokenWallet)
        Crowdsale(rate, wallet, token)
        public
    {}
}
