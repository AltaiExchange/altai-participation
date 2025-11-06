// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

/**
 * @dev Revert with an error when an account is expected to be a contract
 *      but does not have any associated bytecode, indicating it is not a contract.
 * @param addr The address that is expected to contain code.
 */
error AddressIsAContract(address addr);

/**
 * @dev Revert with an error when an account is called as an assumed
 *      contract but does not contain any bytecode, indicating that
 *      it is not a contract address.
 * @param addr The address that is being checked for contract code.
 */
error AddressIsNotAContract(address addr);

/**
 * @dev Revert with an error when an account is specified as zero address,
 *      which is not a valid address in the context of contract operations.
 * @param addr The zero address being checked.
 */
error AddressCannotBeZero(address addr);

/**
 * @dev Revert with an error when the provided address does not match
 *      the original transaction sender (`tx.origin`). This ensures that
 *      only the externally owned account (EOA) initiating the transaction
 *      can be used as the valid address.
 * @param addr The address that does not match the transaction origin.
 */
error AddressIsNotSender(address addr);

/**
 * @dev Revert with an error when an operation is attempted while the contract
 *      is paused. This error indicates that the contract is temporarily
 *      inactive and does not allow any state changes or sensitive operations.
 */
error Paused();

error TransferFailed();

/**
 * @dev Revert with an error when an invalid input is provided for a function or operation.
 *      This error indicates that one or more of the inputs do not meet the required criteria, 
 *      such as being out of range, not matching expected formats, or violating specific constraints 
 *      defined by the contract. It prevents the execution of the operation with an unacceptable input.
 */
error InvalidInput();