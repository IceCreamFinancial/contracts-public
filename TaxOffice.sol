// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

import "./owner/Operator.sol";
import "./interfaces/ITaxable.sol";

contract TaxOffice is Operator {
    address public cream;

    constructor(address _cream) public {
        require(_cream != address(0), "cream address cannot be 0");
        cream = _cream;
    }

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
        return ITaxable(cream).excludeAddress(_address);
    }

    function includeAddressInTax(address _address)
        external
        onlyOperator
        returns (bool)
    {
        return ITaxable(cream).includeAddress(_address);
    }

    function setTaxableCreamOracle(address _creamOracle) external onlyOperator {
        ITaxable(cream).setCreamOracle(_creamOracle);
    }

    function transferTaxOffice(address _newTaxOffice) external onlyOperator {
        ITaxable(cream).setTaxOffice(_newTaxOffice);
    }
}
