// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "../lib/IERC20Decimal.sol";
import "../lib/IUniswapV2Factory.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../lib/UniswapV2Library.sol";

contract BalanceHelper is Ownable {
    using UniswapV2Library for *;

    address public NUSD;
    address public NMETA;
    address public factory;

    constructor(address _NUSD, address _NMETA) {
        NUSD = _NUSD;
        NMETA = _NMETA;
    }

    // Set uniswap factory
    function setFactory(address _factory) public onlyOwner {
        factory = _factory;
    }

    // Token value evaluation in NMETA
    function valueOf(address _token, uint _amount)
        public view
        returns (uint amount_)
    {
        (uint reserve0, uint reserve1) = factory.getReserves(_token, NMETA);
        amount_ = _amount.getAmountOut(reserve0, reserve1);
    }


}
