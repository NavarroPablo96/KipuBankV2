
// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v5.4.0) (token/ERC20/IERC20.sol)

pragma solidity >=0.4.16;

/**
 * @dev Interface of the ERC-20 standard as defined in the ERC.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.20;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: @openzeppelin/contracts/utils/ReentrancyGuard.sol


// OpenZeppelin Contracts (last updated v5.1.0) (utils/ReentrancyGuard.sol)

pragma solidity ^0.8.20;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If EIP-1153 (transient storage) is available on the chain you're deploying at,
 * consider using {ReentrancyGuardTransient} instead.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    uint256 private _status;

    /**
     * @dev Unauthorized reentrant call.
     */
    error ReentrancyGuardReentrantCall();

    constructor() {
        _status = NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be NOT_ENTERED
        if (_status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }

        // Any calls to nonReentrant after this point will fail
        _status = ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == ENTERED;
    }
}

// File: @openzeppelin/contracts/interfaces/IERC20.sol


// OpenZeppelin Contracts (last updated v5.4.0) (interfaces/IERC20.sol)

pragma solidity >=0.4.16;


// File: @openzeppelin/contracts/utils/introspection/IERC165.sol


// OpenZeppelin Contracts (last updated v5.4.0) (utils/introspection/IERC165.sol)

pragma solidity >=0.4.16;

/**
 * @dev Interface of the ERC-165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[ERC].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[ERC section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File: @openzeppelin/contracts/interfaces/IERC165.sol


// OpenZeppelin Contracts (last updated v5.4.0) (interfaces/IERC165.sol)

pragma solidity >=0.4.16;


// File: @openzeppelin/contracts/interfaces/IERC1363.sol


// OpenZeppelin Contracts (last updated v5.4.0) (interfaces/IERC1363.sol)

pragma solidity >=0.6.2;



/**
 * @title IERC1363
 * @dev Interface of the ERC-1363 standard as defined in the https://eips.ethereum.org/EIPS/eip-1363[ERC-1363].
 *
 * Defines an extension interface for ERC-20 tokens that supports executing code on a recipient contract
 * after `transfer` or `transferFrom`, or code on a spender contract after `approve`, in a single transaction.
 */
interface IERC1363 is IERC20, IERC165 {
    /*
     * Note: the ERC-165 identifier for this interface is 0xb0202a11.
     * 0xb0202a11 ===
     *   bytes4(keccak256('transferAndCall(address,uint256)')) ^
     *   bytes4(keccak256('transferAndCall(address,uint256,bytes)')) ^
     *   bytes4(keccak256('transferFromAndCall(address,address,uint256)')) ^
     *   bytes4(keccak256('transferFromAndCall(address,address,uint256,bytes)')) ^
     *   bytes4(keccak256('approveAndCall(address,uint256)')) ^
     *   bytes4(keccak256('approveAndCall(address,uint256,bytes)'))
     */

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferAndCall(address to, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @param data Additional data with no specified format, sent in call to `to`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferAndCall(address to, uint256 value, bytes calldata data) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the allowance mechanism
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param from The address which you want to send tokens from.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferFromAndCall(address from, address to, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the allowance mechanism
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param from The address which you want to send tokens from.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @param data Additional data with no specified format, sent in call to `to`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferFromAndCall(address from, address to, uint256 value, bytes calldata data) external returns (bool);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens and then calls {IERC1363Spender-onApprovalReceived} on `spender`.
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function approveAndCall(address spender, uint256 value) external returns (bool);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens and then calls {IERC1363Spender-onApprovalReceived} on `spender`.
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     * @param data Additional data with no specified format, sent in call to `spender`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function approveAndCall(address spender, uint256 value, bytes calldata data) external returns (bool);
}

// File: @openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol


// OpenZeppelin Contracts (last updated v5.3.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.20;



/**
 * @title SafeERC20
 * @dev Wrappers around ERC-20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    /**
     * @dev An operation with an ERC-20 token failed.
     */
    error SafeERC20FailedOperation(address token);

    /**
     * @dev Indicates a failed `decreaseAllowance` request.
     */
    error SafeERC20FailedDecreaseAllowance(address spender, uint256 currentAllowance, uint256 requestedDecrease);

    /**
     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transfer, (to, value)));
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transferFrom, (from, to, value)));
    }

    /**
     * @dev Variant of {safeTransfer} that returns a bool instead of reverting if the operation is not successful.
     */
    function trySafeTransfer(IERC20 token, address to, uint256 value) internal returns (bool) {
        return _callOptionalReturnBool(token, abi.encodeCall(token.transfer, (to, value)));
    }

    /**
     * @dev Variant of {safeTransferFrom} that returns a bool instead of reverting if the operation is not successful.
     */
    function trySafeTransferFrom(IERC20 token, address from, address to, uint256 value) internal returns (bool) {
        return _callOptionalReturnBool(token, abi.encodeCall(token.transferFrom, (from, to, value)));
    }

    /**
     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     *
     * IMPORTANT: If the token implements ERC-7674 (ERC-20 with temporary allowance), and if the "client"
     * smart contract uses ERC-7674 to set temporary allowances, then the "client" smart contract should avoid using
     * this function. Performing a {safeIncreaseAllowance} or {safeDecreaseAllowance} operation on a token contract
     * that has a non-zero temporary allowance (for that particular owner-spender) will result in unexpected behavior.
     */
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        forceApprove(token, spender, oldAllowance + value);
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `requestedDecrease`. If `token` returns no
     * value, non-reverting calls are assumed to be successful.
     *
     * IMPORTANT: If the token implements ERC-7674 (ERC-20 with temporary allowance), and if the "client"
     * smart contract uses ERC-7674 to set temporary allowances, then the "client" smart contract should avoid using
     * this function. Performing a {safeIncreaseAllowance} or {safeDecreaseAllowance} operation on a token contract
     * that has a non-zero temporary allowance (for that particular owner-spender) will result in unexpected behavior.
     */
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 requestedDecrease) internal {
        unchecked {
            uint256 currentAllowance = token.allowance(address(this), spender);
            if (currentAllowance < requestedDecrease) {
                revert SafeERC20FailedDecreaseAllowance(spender, currentAllowance, requestedDecrease);
            }
            forceApprove(token, spender, currentAllowance - requestedDecrease);
        }
    }

    /**
     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful. Meant to be used with tokens that require the approval
     * to be set to zero before setting it to a non-zero value, such as USDT.
     *
     * NOTE: If the token implements ERC-7674, this function will not modify any temporary allowance. This function
     * only sets the "standard" allowance. Any temporary allowance will remain active, in addition to the value being
     * set here.
     */
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeCall(token.approve, (spender, value));

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeCall(token.approve, (spender, 0)));
            _callOptionalReturn(token, approvalCall);
        }
    }

    /**
     * @dev Performs an {ERC1363} transferAndCall, with a fallback to the simple {ERC20} transfer if the target has no
     * code. This can be used to implement an {ERC721}-like safe transfer that rely on {ERC1363} checks when
     * targeting contracts.
     *
     * Reverts if the returned value is other than `true`.
     */
    function transferAndCallRelaxed(IERC1363 token, address to, uint256 value, bytes memory data) internal {
        if (to.code.length == 0) {
            safeTransfer(token, to, value);
        } else if (!token.transferAndCall(to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Performs an {ERC1363} transferFromAndCall, with a fallback to the simple {ERC20} transferFrom if the target
     * has no code. This can be used to implement an {ERC721}-like safe transfer that rely on {ERC1363} checks when
     * targeting contracts.
     *
     * Reverts if the returned value is other than `true`.
     */
    function transferFromAndCallRelaxed(
        IERC1363 token,
        address from,
        address to,
        uint256 value,
        bytes memory data
    ) internal {
        if (to.code.length == 0) {
            safeTransferFrom(token, from, to, value);
        } else if (!token.transferFromAndCall(from, to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Performs an {ERC1363} approveAndCall, with a fallback to the simple {ERC20} approve if the target has no
     * code. This can be used to implement an {ERC721}-like safe transfer that rely on {ERC1363} checks when
     * targeting contracts.
     *
     * NOTE: When the recipient address (`to`) has no code (i.e. is an EOA), this function behaves as {forceApprove}.
     * Opposedly, when the recipient address (`to`) has code, this function only attempts to call {ERC1363-approveAndCall}
     * once without retrying, and relies on the returned value to be true.
     *
     * Reverts if the returned value is other than `true`.
     */
    function approveAndCallRelaxed(IERC1363 token, address to, uint256 value, bytes memory data) internal {
        if (to.code.length == 0) {
            forceApprove(token, to, value);
        } else if (!token.approveAndCall(to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturnBool} that reverts if call fails to meet the requirements.
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        uint256 returnSize;
        uint256 returnValue;
        assembly ("memory-safe") {
            let success := call(gas(), token, 0, add(data, 0x20), mload(data), 0, 0x20)
            // bubble errors
            if iszero(success) {
                let ptr := mload(0x40)
                returndatacopy(ptr, 0, returndatasize())
                revert(ptr, returndatasize())
            }
            returnSize := returndatasize()
            returnValue := mload(0)
        }

        if (returnSize == 0 ? address(token).code.length == 0 : returnValue != 1) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturn} that silently catches all reverts and returns a bool instead.
     */
    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {
        bool success;
        uint256 returnSize;
        uint256 returnValue;
        assembly ("memory-safe") {
            success := call(gas(), token, 0, add(data, 0x20), mload(data), 0, 0x20)
            returnSize := returndatasize()
            returnValue := mload(0)
        }
        return success && (returnSize == 0 ? address(token).code.length > 0 : returnValue == 1);
    }
}

// File: @chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol


pragma solidity ^0.8.0;

// solhint-disable-next-line interface-starts-with-i
interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  function getRoundData(
    uint80 _roundId
  ) external view returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);

  function latestRoundData()
    external
    view
    returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
}

// File: kipu-bank/kipubankV2.sol

//SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

//Versión KipubankV2

/*///////////////////////   Imports   ///////////////////////*/




/*///////////////////////  Libraries   ///////////////////////*/


/*///////////////////////  Interfaces  ///////////////////////*/


/*
 @title Contrato KipuBankV2
 @author NavarroPablo96
 @notice Este contrato es una recreación del contrato KipuBank,
 en este contrato los usuarios pueden depositar y retirar fondos de su boveda personal.
 */
contract KipuBank is Ownable, ReentrancyGuard {

/*///////////////////////   DECLARACIÓN DE TIPOS    ///////////////////////*/
    using SafeERC20 for IERC20;


/*///////////////////////////////////     Variables      ///////////////////////////////////*/

    /// @notice Almacena el saldo de cada usuario por tipo de token.
    /// @dev Mapping anidado: dirección del usuario => dirección del token => saldo en Wei/unidades mínimas.
    /// @dev Usa address(0) para representar ETH nativo. Otras direcciones corresponden a tokens ERC20.
    mapping(address usuario => mapping(address token => uint256 saldo)) public s_bovedas;
    
    /// @notice Indica si el contrato está pausado
    /// @dev Cuando es true, se bloquean depósitos y retiros
    bool public s_pausado;

    /// @notice Mapping de tokens ERC20 permitidos
    /// @dev true si el token está en la whitelist, false en caso contrario
    mapping(address token => bool permitido) public s_tokensPermitidos;

    //Actualización de Price Feed
    /// @notice Dirección del Chainlink Price Feed para ETH/USD
    AggregatorV3Interface public s_priceFeed;

    //CONVERSION DE DECIMALES
    ///@notice Variable constante para almacenar el factor de decimales
    ///@dev Se usa para convertir de (ETH 18 decimales * Chainlink 8 decimales) a USDC 6 decimales
    ///@dev Cálculo: 10^(18 + 8 - 6) = 10^20
    uint256 constant DECIMAL_FACTOR = 1 * 10 ** 20;

    ///@notice Constante para almacenar el latido (heartbeat) del Data Feed ETH/USD
    ///@dev Si la última actualización supera este tiempo, el precio se considera obsoleto
    uint16 constant ORACLE_HEARTBEAT = 3600; // 1 hora en segundos

    /// @notice Límite máximo global del banco expresado en USD (6 decimales)
    /// @dev Variable inmutable establecida en el constructor. Representa el cap en términos de USDC.
    uint256 public immutable i_bankCap;
    
    /// @notice Límite máximo de Ether (en Wei) que un usuario puede retirar en una sola transacción.
    /// @dev Variable inmutable establecida en el constructor.
    uint256 public immutable i_umbral;

    /// @notice El número total de depósitos exitosos realizados en el contrato KipuBank.
    /// @dev Variable de estado que se incrementa en cada llamada exitosa a la función deposito().
    uint256 public s_CantDepositos;

    /// @notice El número total de retiros exitosos realizados en el contrato KipuBank.
    /// @dev Variable de estado que se incrementa en cada llamada exitosa a la función retiro().
    uint256 public s_CantRetiros;

/*/////////////////////////////////// Events ///////////////////////////////////*/
    event DepositoExitoso(address indexed usuario, address indexed token, uint256 cantidad);
    event RetiroExitoso(address indexed usuario, address indexed token, uint256 cantidad);
    //Pausado
    event ContratoPausado(address indexed admin);
    event ContratoReanudado(address indexed admin); 
    //WhiteList de Tokens
    event TokenAgregado(address indexed token);
    event TokenRemovido(address indexed token);
    //Actualización de Price Feed
    event PriceFeedActualizado(address indexed nuevoPriceFeed);
/*/////////////////////////////////// Errors ///////////////////////////////////*/
    error BankCapExcedido(uint256 TotalActual, uint256 Limite);
    error UmbralExcedido();
    error SaldoInsuficiente();
    //Pausado
    error ContratoEstaPausado();
    //WhiteList de Tokens
    error TokenNoPermitido(address token);
    //CONVERSION DE DECIMALES
    ///@notice Error emitido cuando el retorno del oráculo es incorrecto
    error KipuBank_OracleCompromised();
    ///@notice Error emitido cuando la última actualización del oráculo supera el heartbeat
    error KipuBank_StalePrice();
/*/////////////////////////////////// Modifiers ///////////////////////////////////*/

    /// @notice Verifica que el depósito propuesto no exceda el límite global de Ether (BANK_CAP) del contrato.
    modifier verificaBankCap() {
        // La verificación utiliza el saldo actual del contrato(balancaActualUSD) MÁS el deposito (depositoUSD)
        // que se intenta enviar.Si la suma supera el límite, se revierte.
        
        // Convertir balance actual de ETH a USD
        uint256 balanceActualUSD = convertirEthEnUSD(address(this).balance);
        // Convertir el depósito entrante a USD
        uint256 depositoUSD = convertirEthEnUSD(msg.value);
        // Verificar límite en USD
        if (balanceActualUSD + depositoUSD > i_bankCap) {
            revert BankCapExcedido(balanceActualUSD + depositoUSD, i_bankCap);
        }
        _;
    }

    /// @notice Verifica que el monto de retiro solicitado no exceda el umbral máximo (UMBRAL) por transacción.
    /// @param _cantidad La cantidad de Ether (en Wei) que el usuario intenta retirar.
    modifier verificaUmbral(uint256 _cantidad) {
        if (_cantidad > i_umbral) {
            revert UmbralExcedido();
        }
        _;
    }

    /// @notice Verifica que el contrato no esté pausado
    modifier cuandoNoPausado() {
        if (s_pausado) {
            revert ContratoEstaPausado();
        }
        _;
    }

/*/////////////////////////////////// Functions ///////////////////////////////////*/

    /**
    * @notice Permite a los usuarios depositar tokens nativos (ETH) en su bóveda personal
    * @dev Verifica el límite global del banco en USD antes de aceptar el depósito
    * @dev Sigue el patrón CEI: actualiza estado antes de emitir eventos
    * @custom:security Protegida contra reentrancy con nonReentrant
    * @custom:security Verifica límite global mediante verificaBankCap que consulta Chainlink
    */
    function depositoETH() external payable verificaBankCap cuandoNoPausado nonReentrant  {
        s_bovedas[msg.sender][address(0)] += msg.value;
        unchecked { s_CantDepositos++; }
        emit DepositoExitoso(msg.sender, address(0), msg.value);
    }

        
    /**
    * @notice Permite a los usuarios depositar tokens ERC20 en su bóveda personal
    * @dev Utiliza SafeERC20 para manejar tokens con comportamientos no estándar
    * @dev Sigue el patrón CEI: checks → interactions → effects
    * @param _token Dirección del contrato del token ERC20 a depositar
    * @param _cantidad Cantidad de tokens a depositar en sus unidades mínimas
    * @custom:security Protegida contra reentrancy con nonReentrant
    * @custom:security Solo acepta tokens en la whitelist (s_tokensPermitidos)
    * @custom:security Usa SafeERC20.safeTransferFrom para proteger contra tokens maliciosos
    */
    function depositoToken(address _token, uint256 _cantidad) external cuandoNoPausado nonReentrant   {

        require(_cantidad > 0, "Cantidad debe ser mayor a 0");
        if (!s_tokensPermitidos[_token]) {
            revert TokenNoPermitido(_token);
        }

        IERC20(_token).safeTransferFrom(msg.sender, address(this), _cantidad);

        s_bovedas[msg.sender][_token] += _cantidad;
        unchecked { s_CantDepositos++; }
        emit DepositoExitoso(msg.sender, _token, _cantidad);
    }


    /**
    * @notice Permite a los usuarios retirar tokens nativos (ETH) de su bóveda personal
    * @dev Sigue el patrón CEI: checks → effects → interactions
    * @param _cantidad La cantidad de ETH (en Wei) que el usuario desea retirar
    * @custom:security Protegida contra reentrancy con nonReentrant
    * @custom:security Actualiza saldo ANTES de transferir ETH (previene reentrancy)
    * @custom:security Usa call{value} en lugar de transfer para mayor compatibilidad
    */
    function retiroETH(uint256 _cantidad) external verificaUmbral(_cantidad) cuandoNoPausado nonReentrant   {
        _verificarSaldo(msg.sender, address(0), _cantidad);
        s_bovedas[msg.sender][address(0)] -= _cantidad;
        unchecked { s_CantRetiros++; }
        emit RetiroExitoso(msg.sender, address(0), _cantidad);
        (bool exito, ) = payable(msg.sender).call{value: _cantidad}("");
        require(exito, "Transferencia ETH fallida");
    }

    /**
    * @notice Permite a los usuarios retirar tokens ERC20 de su bóveda personal
    * @dev Sigue el patrón CEI: checks → effects → interactions
    * @dev Utiliza SafeERC20.safeTransfer para manejar tokens no estándar
    * @param _token Dirección del contrato del token ERC20 a retirar
    * @param _cantidad La cantidad de tokens a retirar en sus unidades mínimas
    * @custom:security Protegida contra reentrancy con nonReentrant
    * @custom:security Actualiza saldo ANTES de transferir tokens (previene reentrancy)
    */
    function retiroToken(address _token, uint256 _cantidad) external verificaUmbral(_cantidad) cuandoNoPausado nonReentrant   {
        _verificarSaldo(msg.sender, _token, _cantidad);
        s_bovedas[msg.sender][_token] -= _cantidad;
        unchecked { s_CantRetiros++; }
        emit RetiroExitoso(msg.sender, _token, _cantidad);
        IERC20(_token).safeTransfer(msg.sender, _cantidad);
    }

    /**
    * @notice Devuelve el límite disponible en USD que aún se puede depositar en el banco
    * @dev Calcula la diferencia entre i_bankCap y el balance actual convertido a USD
    * @dev Utiliza el precio de ETH/USD obtenido del oráculo de Chainlink
    * @return limiteDisponible_ Cantidad en USD (6 decimales, formato USDC) disponible antes de alcanzar el cap
    */
    function obtenerLimiteDisponible() public view returns (uint256 limiteDisponible_) {
        uint256 balanceActualUSD = convertirEthEnUSD(address(this).balance);
        
        if (balanceActualUSD >= i_bankCap) {
            return 0;
        }
        
        limiteDisponible_ = i_bankCap - balanceActualUSD;
    }

//Funciones Administrativas onlyOwner:
    /**
    * @notice Pausa todas las operaciones del contrato en caso de emergencia
    * @dev Solo puede ser llamada por el owner
    * @dev Activa s_pausado que bloquea depósitos y retiros mediante cuandoNoPausado
    * @custom:access Restringida al owner mediante onlyOwner
    * @custom:security Patrón Circuit Breaker para detener operaciones en caso de vulnerabilidad
    */
    function pausar() external onlyOwner {
        s_pausado = true;
        emit ContratoPausado(msg.sender);
    }

    /**
    * @notice Reanuda las operaciones del contrato después de una pausa
    * @dev Solo puede ser llamada por el owner
    * @dev Desactiva s_pausado permitiendo depósitos y retiros nuevamente
    * @custom:access Restringida al owner mediante onlyOwner
    */
    function despausar() external onlyOwner {
        s_pausado = false;
        emit ContratoReanudado(msg.sender);
    }

    /**
    * @notice Permite al owner añadir tokens ERC20 a la whitelist de tokens permitidos
    * @dev Solo puede ser llamada por el owner
    * @param _token Dirección del contrato del token ERC20 a agregar
    * @custom:access Restringida al owner mediante onlyOwner
    * @custom:security Previene address(0) para evitar confusión con ETH
    */
    function agregarTokenPermitido(address _token) external onlyOwner {
        require(_token != address(0), "Token invalido");
        s_tokensPermitidos[_token] = true;
        emit TokenAgregado(_token);
    }

    /**
    * @notice Permite al owner remover tokens ERC20 de la whitelist
    * @dev Solo puede ser llamada por el owner
    * @dev No afecta depósitos ya realizados, solo previene nuevos depósitos
    * @param _token Dirección del contrato del token a remover de la whitelist
    * @custom:access Restringida al owner mediante onlyOwner
    */
    function removerTokenPermitido(address _token) external onlyOwner {
        s_tokensPermitidos[_token] = false;
        emit TokenRemovido(_token);
    }

    /**
    * @notice Permite al owner actualizar la dirección del Chainlink Price Feed
    * @dev Solo puede ser llamada por el owner
    * @dev Útil si el price feed de Chainlink cambia o se depreca
    * @param _nuevoPriceFeed Nueva dirección del contrato AggregatorV3Interface
    * @custom:access Restringida al owner mediante onlyOwner
    * @custom:security Valida que la dirección no sea address(0)
    */
    function actualizarPriceFeed(address _nuevoPriceFeed) external onlyOwner {
        require(_nuevoPriceFeed != address(0), "Direccion invalida");
        s_priceFeed = AggregatorV3Interface(_nuevoPriceFeed);
        emit PriceFeedActualizado(_nuevoPriceFeed);
    }

/*/////////////////////////////////// Receive & Fallback ///////////////////////////////////*/

    /**
    * @notice Permite al contrato recibir ETH directamente sin datos
    * @dev Se ejecuta cuando se envía ETH sin calldata
    */
    receive() external payable {
        // Rechazar depósitos directos
        revert("Usar depositoETH() para depositar");
    }

    /**
    * @notice Maneja llamadas a funciones inexistentes o con calldata
    * @dev Se ejecuta cuando se llama a una función que no existe
    */
    fallback() external payable {
        revert("Funcion no existe");
    }

/*///////////////////////// constructor /////////////////////////*/
    /**
    * @notice Construye e inicializa el contrato KipuBank.
    * @dev Establece de forma permanente el límite global de depósitos en USD y el umbral de retiro.
    * @param _bankCap El límite máximo en USD (6 decimales, formato USDC) que el contrato puede contener.
    * @param _umbral El monto máximo de ETH (en Wei) que un usuario puede retirar en una sola transacción.
    * @param _owner La dirección del propietario del contrato.
    * @param _priceFeed La dirección del Chainlink Price Feed ETH/USD.
    */
    constructor(uint256 _bankCap, uint256 _umbral, address _owner, address _priceFeed) Ownable(_owner) {
        require(_bankCap > 0, "Bank cap debe ser mayor a 0");
        require(_umbral > 0, "Umbral debe ser mayor a 0");
        require(_priceFeed != address(0), "Price feed invalido");

        i_bankCap = _bankCap;
        i_umbral = _umbral;
        s_CantDepositos = 0;
        s_CantRetiros = 0;
        //CONVERSION DE DECIMALES
        s_priceFeed = AggregatorV3Interface(_priceFeed); 
    }

/*///////////////////////// internal /////////////////////////*/

    /**
    * @notice Consulta el precio actual de ETH en USD desde el oráculo de Chainlink
    * @dev Verifica que el precio sea válido (> 0) y no esté obsoleto (< ORACLE_HEARTBEAT)
    * @dev Esta es una implementación simplificada sin manejo de rounds
    * @return ethUSDPrice_ El precio de ETH en USD con 8 decimales
    * @custom:security Revierte si ethUSDPrice <= 0 (KipuBank_OracleCompromised)
    * @custom:security Revierte si updatedAt > ORACLE_HEARTBEAT (KipuBank_StalePrice)
    */
    function chainlinkFeed() internal view returns (uint256 ethUSDPrice_) { //CONVERSION DE DECIMALES
        (, int256 ethUSDPrice,, uint256 updatedAt,) = s_priceFeed.latestRoundData();

        if (ethUSDPrice <= 0) revert KipuBank_OracleCompromised();
        if (block.timestamp - updatedAt > ORACLE_HEARTBEAT) revert KipuBank_StalePrice();

        ethUSDPrice_ = uint256(ethUSDPrice);
    }

    /**
    * @notice Convierte una cantidad de ETH a su equivalente en USD
    * @dev Multiplica ETH (18 decimales) por precio Chainlink (8 decimales) y normaliza a 6 decimales
    * @dev Fórmula: (ethAmount * chainlinkPrice) / DECIMAL_FACTOR donde DECIMAL_FACTOR = 10^20
    * @param _ethAmount La cantidad de ETH a convertir en Wei (18 decimales)
    * @return convertedAmount_ El valor equivalente en USD con 6 decimales (formato USDC)
    */
    function convertirEthEnUSD(uint256 _ethAmount) internal view returns (uint256 convertedAmount_) {
        convertedAmount_ = (_ethAmount * chainlinkFeed()) / DECIMAL_FACTOR;
    }   //CONVERSION DE DECIMALES

    /**
    * @notice Verifica si el usuario tiene saldo suficiente antes de un retiro
    * @dev Función interna usada por retiroETH() y retiroToken()
    * @param _usuario La dirección del usuario a verificar
    * @param _token La dirección del token (address(0) para ETH)
    * @param _cantidad El monto que se desea retirar
    * @custom:security Revierte con SaldoInsuficiente si el saldo es menor a la cantidad
    */
    function _verificarSaldo(address _usuario, address _token, uint256 _cantidad) internal view {
        if (s_bovedas[_usuario][_token] < _cantidad) {
            revert SaldoInsuficiente();
        }
    }

/*///////////////////////// View & Pure /////////////////////////*/
    /**
    * @notice Devuelve el saldo de un token específico en la bóveda de un usuario
    * @dev Consulta el mapping anidado s_bovedas[usuario][token]
    * @param _usuario La dirección del usuario cuyo saldo se desea consultar
    * @param _token La dirección del token (usar address(0) para ETH nativo)
    * @return El saldo del usuario en Wei (para ETH) o unidades mínimas del token (para ERC20)
    */
    function getSaldo(address _usuario, address _token) public view returns (uint256) {
    return s_bovedas[_usuario][_token];
    }
}
