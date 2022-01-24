// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TaxOracle is Ownable {
    using SafeMath for uint256;

    IERC20 public cream;
    IERC20 public mim;
    address public pair;

    constructor(
        address _cream,
        address _mim,
        address _pair
    ) public {
        require(_cream != address(0), "cream address cannot be 0");
        require(_mim != address(0), "mim address cannot be 0");
        require(_pair != address(0), "pair address cannot be 0");
        cream = IERC20(_cream);
        mim = IERC20(_mim);
        pair = _pair;
    }

    function consult(address _token, uint256 _amountIn)
        external
        view
        returns (uint144 amountOut)
    {
        require(_token == address(cream), "token needs to be cream");
        uint256 creamBalance = cream.balanceOf(pair);
        uint256 mimBalance = mim.balanceOf(pair);
        return uint144(creamBalance.mul(_amountIn).div(mimBalance));
    }

    function getCreamBalance() external view returns (uint256) {
        return cream.balanceOf(pair);
    }

    function getMimBalance() external view returns (uint256) {
        return mim.balanceOf(pair);
    }

    function getPrice() external view returns (uint256) {
        uint256 creamBalance = cream.balanceOf(pair);
        uint256 mimBalance = mim.balanceOf(pair);
        return creamBalance.mul(1e18).div(mimBalance);
    }

    function setCream(address _cream) external onlyOwner {
        require(_cream != address(0), "cream address cannot be 0");
        cream = IERC20(_cream);
    }

    function setMim(address _mim) external onlyOwner {
        require(_mim != address(0), "mim address cannot be 0");
        mim = IERC20(_mim);
    }

    function setPair(address _pair) external onlyOwner {
        require(_pair != address(0), "pair address cannot be 0");
        pair = _pair;
    }
}
