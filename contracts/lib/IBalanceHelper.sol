// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface IBalanceHelper {
    function valueOf(address _token, uint _amount)
        external
        view
        returns (uint amount_);
}
