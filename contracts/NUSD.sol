// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";

contract NUSD is ERC20PresetMinterPauser, Ownable {
    constructor() ERC20PresetMinterPauser("NowUSD", "NUSD") {}

    function recoverTokens(address token) external virtual onlyOwner {
        IERC20(token).transfer(owner(), IERC20(token).balanceOf(address(this)));
    }

    function grantRoleMinter(address _account) external {
        grantRole(MINTER_ROLE, _account);
    }

    function revokeRoleMinter(address _account) external {
        revokeRole(MINTER_ROLE, _account);
    }
}
