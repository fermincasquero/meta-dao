// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./lib/IUniswapV2Pair.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

interface IMintable {
    function mint(address to, uint256 amount) external;
}

interface IBurnable {
    function burnFrom(address account_, uint256 amount_) external;
}

contract NUSDMinter is Ownable, AccessControl {
    using SafeMath for uint;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    address public NMETA;
    address public NUSD;
    address public NMETAPair;

    uint256 public decimals;

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _msgSender());
    }

    function getMarketPrice() public view returns (uint256) {
        (uint256 reserve0, uint256 reserve1, ) = IUniswapV2Pair(NMETAPair)
            .getReserves();
        if (IUniswapV2Pair(NMETAPair).token0() == NMETA) {
            return reserve1.mul(10**decimals).div(reserve0);
        } else {
            return reserve0.mul(10**decimals).div(reserve1);
        }
    }

    function mintFromNMETA(uint nmetaAmount) external {
        require(hasRole(MINTER_ROLE, _msgSender()), "MINTER_ROLE_MISSING");

        uint nusdAmount = getMarketPrice().mul(nmetaAmount);

        IMintable(NUSD).mint(msg.sender, nusdAmount);
        IBurnable(NMETA).burnFrom(msg.sender, nmetaAmount);
    }
}
