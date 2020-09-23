pragma solidity ^0.4.24;

import "../Crowdsale.sol";
import "../WhitelistedRole.sol";

contract WhitelistCrowdsale is WhitelistedRole, Crowdsale {

    function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal view {
        
        require(isWhitelisted(_beneficiary));
        super._preValidatePurchase(_beneficiary, _weiAmount);
        
    }
    
}