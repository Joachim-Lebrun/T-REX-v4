// SPDX-License-Identifier: GPL-3.0
//
//                                             :+#####%%%%%%%%%%%%%%+
//                                         .-*@@@%+.:+%@@@@@%%#***%@@%=
//                                     :=*%@@@#=.      :#@@%       *@@@%=
//                       .-+*%@%*-.:+%@@@@@@+.     -*+:  .=#.       :%@@@%-
//                   :=*@@@@%%@@@@@@@@@%@@@-   .=#@@@%@%=             =@@@@#.
//             -=+#%@@%#*=:.  :%@@@@%.   -*@@#*@@@@@@@#=:-              *@@@@+
//            =@@%=:.     :=:   *@@@@@%#-   =%*%@@@@#+-.        =+       :%@@@%-
//           -@@%.     .+@@@     =+=-.         @@#-           +@@@%-       =@@@@%:
//          :@@@.    .+@@#%:                   :    .=*=-::.-%@@@+*@@=       +@@@@#.
//          %@@:    +@%%*                         =%@@@@@@@@@@@#.  .*@%-       +@@@@*.
//         #@@=                                .+@@@@%:=*@@@@@-      :%@%:      .*@@@@+
//        *@@*                                +@@@#-@@%-:%@@*          +@@#.      :%@@@@-
//       -@@%           .:-=++*##%%%@@@@@@@@@@@@*. :@+.@@@%:            .#@@+       =@@@@#:
//      .@@@*-+*#%%%@@@@@@@@@@@@@@@@%%#**@@%@@@.   *@=*@@#                :#@%=      .#@@@@#-
//      -%@@@@@@@@@@@@@@@*+==-:-@@@=    *@# .#@*-=*@@@@%=                 -%@@@*       =@@@@@%-
//         -+%@@@#.   %@%%=   -@@:+@: -@@*    *@@*-::                   -%@@%=.         .*@@@@@#
//            *@@@*  +@* *@@##@@-  #@*@@+    -@@=          .         :+@@@#:           .-+@@@%+-
//             +@@@%*@@:..=@@@@*   .@@@*   .#@#.       .=+-       .=%@@@*.         :+#@@@@*=:
//              =@@@@%@@@@@@@@@@@@@@@@@@@@@@%-      :+#*.       :*@@@%=.       .=#@@@@%+:
//               .%@@=                 .....    .=#@@+.       .#@@@*:       -*%@@@@%+.
//                 +@@#+===---:::...         .=%@@*-         +@@@+.      -*@@@@@%+.
//                  -@@@@@@@@@@@@@@@@@@@@@@%@@@@=          -@@@+      -#@@@@@#=.
//                    ..:::---===+++***###%%%@@@#-       .#@@+     -*@@@@@#=.
//                                           @@@@@@+.   +@@*.   .+@@@@@%=.
//                                          -@@@@@=   =@@%:   -#@@@@%+.
//                                          +@@@@@. =@@@=  .+@@@@@*:
//                                          #@@@@#:%@@#. :*@@@@#-
//                                          @@@@@%@@@= :#@@@@+.
//                                         :@@@@@@@#.:#@@@%-
//                                         +@@@@@@-.*@@@*:
//                                         #@@@@#.=@@@+.
//                                         @@@@+-%@%=
//                                        :@@@#%@%=
//                                        +@@@@%-
//                                        :#%%=
//
/**
 *     NOTICE
 *
 *     The T-REX software is licensed under a proprietary license or the GPL v.3.
 *     If you choose to receive it under the GPL v.3 license, the following applies:
 *     T-REX is a suite of smart contracts developed by Tokeny to manage and transfer financial assets on the ethereum blockchain
 *
 *     Copyright (C) 2021, Tokeny sàrl.
 *
 *     This program is free software: you can redistribute it and/or modify
 *     it under the terms of the GNU General Public License as published by
 *     the Free Software Foundation, either version 3 of the License, or
 *     (at your option) any later version.
 *
 *     This program is distributed in the hope that it will be useful,
 *     but WITHOUT ANY WARRANTY; without even the implied warranty of
 *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *     GNU General Public License for more details.
 *
 *     You should have received a copy of the GNU General Public License
 *     along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

pragma solidity ^0.8.0;

import '../IModularCompliance.sol';
import '../../../token/IToken.sol';
import './AbstractModule.sol';

contract CountryAllowModule is AbstractModule {
    /**
     *  this event is emitted whenever a Country has been allowed.
     *  the event is emitted by 'addAllowedCountry' and 'batchAllowCountries' functions.
     *  `_country` is the numeric ISO 3166-1 of the restricted country.
     */
    event AddedAllowedCountry(address _compliance, uint16 _country);
    /**
     *  this event is emitted whenever a Country has been disallowed.
     *  the event is emitted by 'removeAllowedCountry' and 'batchDisallowCountries' functions.
     *  `_country` is the numeric ISO 3166-1 of the disallowed country.
     */
    event RemoveAllowedCountry(address _compliance, uint16 _country);

    /// Mapping between country and their allowance status per compliance contract
    mapping(address => mapping(uint16 => bool)) private _allowedCountries;

    /// Custom Errors
    error CountryAlreadyAllowed(address _compliance, uint16 _country);
    error CountryNotAllowed(address _compliance, uint16 _country);

    /**
     *  @dev Returns true if country is Allowed
     *  @param _country, numeric ISO 3166-1 standard of the country to be checked
     */
    function isCountryAllowed(address _compliance, uint16 _country) public view onlyBoundCompliance(_compliance) returns (bool) {
        return _allowedCountries[_compliance][_country];
    }

    /**
     *  @dev Adds country allowance.
     *  Identities from this country will be able to manipulate Tokens linked to this Compliance.
     *  @param _country Country to be allowed, should be expressed by following numeric ISO 3166-1 standard
     *  Only the owner of the Compliance smart contract can call this function
     *  emits an `AddedAllowedCountry` event
     */
    function addAllowedCountry(uint16 _country) external onlyComplianceCall {
        if ((_allowedCountries[msg.sender])[_country] == true) revert CountryAlreadyAllowed(msg.sender, _country);
        (_allowedCountries[msg.sender])[_country] = true;
        emit AddedAllowedCountry(msg.sender, _country);
    }

    /**
     *  @dev Removes country allowance.
     *  Identities from those countries will lose the authorization to manipulate Tokens linked to this Compliance.
     *  @param _country Country to be unrestricted, should be expressed by following numeric ISO 3166-1 standard
     *  Can be called only for a compliance contract that is bound to the CountryAllowModule
     *  Only the owner of the Compliance smart contract can call this function
     *  emits an `RemoveAllowedCountry` event
     */
    function removeAllowedCountry(uint16 _country) external onlyComplianceCall {
        if ((_allowedCountries[msg.sender])[_country] == false) revert CountryNotAllowed(msg.sender, _country);
        (_allowedCountries[msg.sender])[_country] = false;
        emit RemoveAllowedCountry(msg.sender, _country);
    }

    /**
     *  @dev Adds country allowance in batch.
     *  Identities from those countries will be allowed to manipulate Tokens linked to this Compliance.
     *  @param _countries Countries to be restricted, should be expressed by following numeric ISO 3166-1 standard
     *  Can be called only for a compliance contract that is bound to the CountryAllowModule
     *  Only the owner of the Compliance smart contract can call this function
     *  emits an `AddedAllowedCountry` event
     */
    function batchAllowCountries(uint16[] calldata _countries) external onlyComplianceCall {
        for (uint256 i = 0; i < _countries.length; i++) {
            (_allowedCountries[msg.sender])[_countries[i]] = true;
            emit AddedAllowedCountry(msg.sender, _countries[i]);
        }
    }

    /**
     *  @dev Removes country allowance in batch.
     *  Identities from those countries will lose the authorization to manipulate Tokens linked to this Compliance.
     *  @param _countries Countries to be disallowed, should be expressed by following numeric ISO 3166-1 standard
     *  Can be called only for a compliance contract that is bound to the CountryAllowModule
     *  Only the owner of the Compliance smart contract can call this function
     *  emits an `RemoveAllowedCountry` event
     */
    function batchDisallowCountries(uint16[] calldata _countries) external onlyComplianceCall {
        for (uint256 i = 0; i < _countries.length; i++) {
            (_allowedCountries[msg.sender])[_countries[i]] = false;
            emit RemoveAllowedCountry(msg.sender, _countries[i]);
        }
    }

    /**
     *  @dev function used to get the country of a wallet address.
     *  @param _compliance the compliance contract address for which the country verification is required
     *  @param _userAddress the address of the wallet to be checked
     *  Returns the ISO 3166-1 standard country code of the wallet owner
     *  internal function, used only by the contract itself to process checks on investor countries
     */
    function _getCountry(address _compliance, address _userAddress) internal view returns (uint16) {
        return IToken(IModularCompliance(_compliance).getTokenBound()).identityRegistry().investorCountry(_userAddress);
    }

    /**
     *  @dev See {IModule-moduleTransferAction}.
     *  no transfer action required in this module
     */
    function moduleTransferAction(
        address _from,
        address _to,
        uint256 _value,
        address _compliance
    ) external override onComplianceAction(_compliance) {}

    /**
     *  @dev See {IModule-moduleMintAction}.
     *  no mint action required in this module
     */
    function moduleMintAction(
        address _to,
        uint256 _value,
        address _compliance
    ) external override onComplianceAction(_compliance) {}

    /**
     *  @dev See {IModule-moduleBurnAction}.
     *  no burn action required in this module
     */
    function moduleBurnAction(
        address _from,
        uint256 _value,
        address _compliance
    ) external override onComplianceAction(_compliance) {}

    /**
     *  @dev See {IModule-moduleCheck}.
     *  checks if the country of address _to is allowed for this _compliance
     *  returns TRUE if the country of _to is allowed for this _compliance
     *  returns FALSE if the country of _to is not allowed for this _compliance
     */
    function moduleCheck(
        address _from,
        address _to,
        uint256 _value,
        address _compliance
    ) external view override onlyBoundCompliance(_compliance) returns (bool) {
        uint16 receiverCountry = _getCountry(_compliance, _to);
        return isCountryAllowed(_compliance, receiverCountry);
    }
}
