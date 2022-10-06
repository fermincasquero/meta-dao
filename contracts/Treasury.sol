// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./lib/IUniswapV2Pair.sol";
import "./lib/IERC20Decimal.sol";
import "./lib/IBalanceHelper.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "hardhat/console.sol";
import "./NUSDMinter.sol";

interface INSDBMinter {
    function mintFromNMETA(uint nmetaAmount) external;
    function getMarketPrice() external;
}

contract Treasury is Ownable {
    using SafeMath for uint;

    address public immutable NMETA;
    address public immutable NUSD;
    address public balanceHelper;
    address public nusdMinter;

    address[] public reserveTokens;
    mapping(address => bool) public isReserveToken;

    address[] public reserveDepositors;
    mapping(address => bool) public isReserveDepositor;

    address[] public reserveSpenders;
    mapping(address => bool) public isReserveSpender;

    address[] public reserveManagers;
    mapping(address => bool) public isReserveManager;

    uint public totalReserves;

    uint public triggerPercent = 300;

    constructor(address _NMETA, address _NUSD, address _nusdMinter) {
        NMETA = _NMETA;
        NUSD = _NUSD;
        nusdMinter = _nusdMinter;
        reserveManagers.push(msg.sender);
        isReserveManager[msg.sender] = true;
        totalReserves = 0;
    }

    function deposit(uint _amount, address _token)
        external
    {
        require(isReserveToken[_token], "Not accepted");
        IERC20Decimal(_token).transferFrom(msg.sender, address(this), _amount);

        require(isReserveDepositor[msg.sender], "Not approved");
        uint _value = IBalanceHelper(balanceHelper).valueOf(_token, _amount);
        totalReserves = totalReserves + _value;
    }

    function withdraw(uint _amount, address _token) public {
        require(isReserveToken[_token], "Not accepted");
        require(isReserveSpender[msg.sender], "Not approved");

        IERC20Decimal(_token).transfer(msg.sender, _amount);
        uint _value = IBalanceHelper(balanceHelper).valueOf(_token, _amount);
        totalReserves = totalReserves - _value;
    }

    function setBalanceHelper(address _balanceHelper) public onlyOwner {
        balanceHelper = _balanceHelper;
    }

    function rebalance() internal {
        uint _total = 0;
        address[] memory _reserveTokens = reserveTokens;
        for(uint i ; i < _reserveTokens.length; i ++ ) {
            address _token = _reserveTokens[i];
            uint _amount = IERC20Decimal(_token).balanceOf(address(this));
            uint _value = IBalanceHelper(balanceHelper).valueOf(_token, _amount);
            _total = _total + _value;
        }
        uint nusdAmount = IERC20Decimal(NUSD).balanceOf(address(this));
        uint nusdValue = IBalanceHelper(balanceHelper).valueOf(NUSD, nusdAmount);

        uint percent = _total.add(nusdValue).div(_total).mul(1000);

        if(percent > triggerPercent) {
            console.log("Exceed limit");
            
            INSDBMinter(nusdMinter).mintFromNMETA(IERC20Decimal(NMETA).balanceOf(address(this)));
        }
    }

    modifier onlyReserveManager() {
        require(isReserveManager[msg.sender], "Not approved");
        _;
    }
}
