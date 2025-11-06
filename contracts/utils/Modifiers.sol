// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import  "./Errors.sol";

abstract contract  Modifiers{

    // EOA = Externally Owned Account
    modifier onlyEOA(
        address _address
    ) {
        if (
            msg.sender != tx.origin
        ) revert AddressIsAContract(
            _address
        );
        if (
            _address != tx.origin
        ) revert AddressIsNotSender(
            _address
        );
        if (
            _address == address(this)
        ) revert AddressIsAContract(
            _address
        );
        if (
            _address == address(0)
        ) revert AddressCannotBeZero(
            _address
        );
        if (
            isAddressContract(
                _address
            )
        ) revert AddressIsAContract(
            _address
        );
        if (
            isAddressContract(
                msg.sender
            )
        ) revert AddressIsAContract(
            msg.sender
        );

        uint256 size;
        assembly {
            size := extcodesize(
                _address
            )
        }
        if (
            size > 0
        ) revert AddressIsAContract(
            _address
        );
        _;
    }

    function isAddressContract(
        address _address
    ) 
        internal 
        view 
        returns (
            bool
        ) 
    {
        if(
            _address == address(0)
        ) revert AddressCannotBeZero(
            _address
        );
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { 
            codehash := extcodehash(
                _address
            ) 
        }
        return (
            codehash != accountHash && codehash != 0x0
        );
    }

    modifier onlySmartContract(
        address _address
    ) {
        if(
            _address == address(0)
        ) revert AddressCannotBeZero(
            _address
        );
        uint256 size;
        assembly {
            size := extcodesize(
                _address
            )
        }
        bool isContract = size > 0;
        if(
            !isContract
        ) revert AddressIsNotAContract(
            _address
        );
        _;
    }

}