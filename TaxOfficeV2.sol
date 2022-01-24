// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "./owner/Operator.sol";
import "./interfaces/ITaxable.sol";
import "./interfaces/IUniswapV2Router.sol";
import "./interfaces/IERC20.sol";

contract TaxOfficeV2 is Operator {
    using SafeMath for uint256;

    address public cream = address();
    address public weth = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    address public uniRouter =
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    mapping(address => bool) public taxExclusionEnabled;

    function setTaxTiersTwap(uint8 _index, uint256 _value)
        public
        onlyOperator
        returns (bool)
    {
        return ITaxable(cream).setTaxTiersTwap(_index, _value);
    }

    function setTaxTiersRate(uint8 _index, uint256 _value)
        public
        onlyOperator
        returns (bool)
    {
        return ITaxable(cream).setTaxTiersRate(_index, _value);
    }

    function enableAutoCalculateTax() public onlyOperator {
        ITaxable(cream).enableAutoCalculateTax();
    }

    function disableAutoCalculateTax() public onlyOperator {
        ITaxable(cream).disableAutoCalculateTax();
    }

    function setTaxRate(uint256 _taxRate) public onlyOperator {
        ITaxable(cream).setTaxRate(_taxRate);
    }

    function setBurnThreshold(uint256 _burnThreshold) public onlyOperator {
        ITaxable(cream).setBurnThreshold(_burnThreshold);
    }

    function setTaxCollectorAddress(address _taxCollectorAddress)
        public
        onlyOperator
    {
        ITaxable(cream).setTaxCollectorAddress(_taxCollectorAddress);
    }

    function excludeAddressFromTax(address _address)
        external
        onlyOperator
        returns (bool)
    {
        return _excludeAddressFromTax(_address);
    }

    function _excludeAddressFromTax(address _address) private returns (bool) {
        if (!ITaxable(cream).isAddressExcluded(_address)) {
            return ITaxable(cream).excludeAddress(_address);
        }
    }

    function includeAddressInTax(address _address)
        external
        onlyOperator
        returns (bool)
    {
        return _includeAddressInTax(_address);
    }

    function _includeAddressInTax(address _address) private returns (bool) {
        if (ITaxable(cream).isAddressExcluded(_address)) {
            return ITaxable(cream).includeAddress(_address);
        }
    }

    function taxRate() external returns (uint256) {
        return ITaxable(cream).taxRate();
    }

    function addLiquidityTaxFree(
        address token,
        uint256 amtCream,
        uint256 amtToken,
        uint256 amtCreamMin,
        uint256 amtTokenMin
    )
        external
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        require(amtCream != 0 && amtToken != 0, "amounts can't be 0");
        _excludeAddressFromTax(msg.sender);

        IERC20(cream).transferFrom(msg.sender, address(this), amtCream);
        IERC20(token).transferFrom(msg.sender, address(this), amtToken);
        _approveTokenIfNeeded(cream, uniRouter);
        _approveTokenIfNeeded(token, uniRouter);

        _includeAddressInTax(msg.sender);

        uint256 resultAmtCream;
        uint256 resultAmtToken;
        uint256 liquidity;
        (resultAmtCream, resultAmtToken, liquidity) = IUniswapV2Router(
            uniRouter
        ).addLiquidity(
                cream,
                token,
                amtCream,
                amtToken,
                amtCreamMin,
                amtTokenMin,
                msg.sender,
                block.timestamp
            );

        if (amtCream.sub(resultAmtCream) > 0) {
            IERC20(cream).transfer(msg.sender, amtCream.sub(resultAmtCream));
        }
        if (amtToken.sub(resultAmtToken) > 0) {
            IERC20(token).transfer(msg.sender, amtToken.sub(resultAmtToken));
        }
        return (resultAmtCream, resultAmtToken, liquidity);
    }

    function addLiquidityETHTaxFree(
        uint256 amtCream,
        uint256 amtCreamMin,
        uint256 amtEthMin
    )
        external
        payable
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        require(amtCream != 0 && msg.value != 0, "amounts can't be 0");
        _excludeAddressFromTax(msg.sender);

        IERC20(cream).transferFrom(msg.sender, address(this), amtCream);
        _approveTokenIfNeeded(cream, uniRouter);

        _includeAddressInTax(msg.sender);

        uint256 resultAmtCream;
        uint256 resultAmtEth;
        uint256 liquidity;
        (resultAmtCream, resultAmtEth, liquidity) = IUniswapV2Router(uniRouter)
            .addLiquidityETH{value: msg.value}(
            cream,
            amtCream,
            amtCreamMin,
            amtEthMin,
            msg.sender,
            block.timestamp
        );

        if (amtCream.sub(resultAmtCream) > 0) {
            IERC20(cream).transfer(msg.sender, amtCream.sub(resultAmtCream));
        }
        return (resultAmtCream, resultAmtEth, liquidity);
    }

    function setTaxableCreamOracle(address _creamOracle) external onlyOperator {
        ITaxable(cream).setCreamOracle(_creamOracle);
    }

    function transferTaxOffice(address _newTaxOffice) external onlyOperator {
        ITaxable(cream).setTaxOffice(_newTaxOffice);
    }

    function taxFreeTransferFrom(
        address _sender,
        address _recipient,
        uint256 _amt
    ) external {
        require(
            taxExclusionEnabled[msg.sender],
            "Address not approved for tax free transfers"
        );
        _excludeAddressFromTax(_sender);
        IERC20(cream).transferFrom(_sender, _recipient, _amt);
        _includeAddressInTax(_sender);
    }

    function setTaxExclusionForAddress(address _address, bool _excluded)
        external
        onlyOperator
    {
        taxExclusionEnabled[_address] = _excluded;
    }

    function _approveTokenIfNeeded(address _token, address _router) private {
        if (IERC20(_token).allowance(address(this), _router) == 0) {
            IERC20(_token).approve(_router, type(uint256).max);
        }
    }
}
