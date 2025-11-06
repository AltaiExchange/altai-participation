// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

/**
 * بِسْــــمِ اللّٰهِ الرَّحْمَـنِ الرَّحِيـمِ
 *
 * @title ALTAI Participation Contract
 * @author altai.exchange
 * @notice 
 * This contract allows users to participate in multiple token pools,
 * earn rewards over time, claim accumulated rewards, and redeem
 * their deposited tokens when desired.
 *
 * @dev 
 * - Supports multiple participation pools, each with its own parameters.
 * - Includes reward calculation and distribution per user per pool.
 * - Only Externally Owned Accounts (EOAs) can interact with participation functions.
 * - Uses ReentrancyGuard to prevent reentrancy attacks.
 * - Contract owner can manage pools, update parameters, and add liquidity.
 * - Users’ participation and rewards are tracked via TUser and pool structures.
 *
 * Contract Purpose:
 * This contract is designed as a core mechanism within ALTAI’s ecosystem 
 * to enable users to engage with various token pools, participate in
 * reward-earning opportunities, and manage their deposits safely.
 */

import { TParticipationPool, TChangeCountIndex, TUser, TParticipationVariables } from "./utils/Structs.sol";
import { LibParticipation } from "./libraries/LibParticipation.sol";
import { IERC20 } from "./interfaces/IERC20.sol";
import "./utils/ReentrancyGuard.sol";
import "./utils/Modifiers.sol";
import "./utils/Ownable.sol";

contract Participation is Modifiers, ReentrancyGuard, Ownable {

    constructor(address _initialOwner) Ownable(_initialOwner) {}

    function participation(
        uint256 _amountIn,
        address _tokenIn
    ) 
        external 
        nonReentrant 
        onlyEOA(msg.sender) 
    {
        LibParticipation.Layout storage ss = LibParticipation.layout();

        if(ss.participationVariables.isPaused) revert Paused();
        if(!ss.participationPool[_tokenIn].isActive) revert Paused();
        if(_amountIn < ss.participationPool[_tokenIn].minParticipationAmount) revert InvalidInput();
        
        ss.participationPool[_tokenIn].totalParticipationAmount += _amountIn;
        ss.participationPool[_tokenIn].numberOfParticipants += 1;

        uint256 remainingAmount = LibParticipation.calculateRewards(_tokenIn,msg.sender);
        uint256 userParticipationAmount = _amountIn + ss.user[_tokenIn][msg.sender].userParticipationAmount;
        uint256 participationStartDate = !ss.user[_tokenIn][msg.sender].isParticipant ? block.timestamp : ss.user[_tokenIn][msg.sender].participationStartDate;

        ss.user[_tokenIn][msg.sender] = TUser({
            isParticipant : true,
            userParticipationAmount : userParticipationAmount,
            userChangeCountIndex : 0,
            userClaimedAmount : ss.user[_tokenIn][msg.sender].userClaimedAmount,
            remainingAmount : remainingAmount,
            participationStartDate: participationStartDate
        });

        LibParticipation.updateChc(_tokenIn, msg.sender);

        LibParticipation.safeTransferFrom(_amountIn, msg.sender, address(this), _tokenIn);
    }

    function claim(
        address _tokenIn
    ) 
        external 
        nonReentrant 
        onlyEOA(msg.sender) 
    {
        LibParticipation.Layout storage ss = LibParticipation.layout();

        if(ss.participationVariables.isPaused) revert Paused();
        if(!ss.participationPool[_tokenIn].isActive) revert Paused();
        if(!ss.user[_tokenIn][msg.sender].isParticipant) revert InvalidInput();

        bool success = LibParticipation.safeClaim(_tokenIn, msg.sender);
        if(!success) revert InvalidInput();

        LibParticipation.updateChc(_tokenIn,msg.sender);
    }

    function redeem(
        address _tokenIn
    ) 
        external 
        nonReentrant 
        onlyEOA(msg.sender) 
    {
        LibParticipation.Layout storage ss = LibParticipation.layout();

        if(ss.participationVariables.isPaused) revert Paused();
        if(!ss.participationPool[_tokenIn].isActive) revert Paused();
        if(!ss.user[_tokenIn][msg.sender].isParticipant) revert InvalidInput();

        LibParticipation.safeClaim(_tokenIn, msg.sender);

        uint256 userParticipationAmountBefore = ss.user[_tokenIn][msg.sender].userParticipationAmount;

        ss.participationPool[_tokenIn].totalParticipationAmount -= userParticipationAmountBefore;
        ss.participationPool[_tokenIn].numberOfParticipants -= 1;

        ss.user[_tokenIn][msg.sender] = TUser({
            isParticipant : false,
            userParticipationAmount : 0,
            userChangeCountIndex : 0,
            userClaimedAmount : ss.user[_tokenIn][msg.sender].userClaimedAmount,
            remainingAmount : 0,
            participationStartDate : 0
        });

        LibParticipation.updateChc(_tokenIn, address(0));

        require(IERC20(_tokenIn).transfer(msg.sender, userParticipationAmountBefore),"Transfer failed.");
    }

    function addLiquidity(
        uint256 _amountIn,
        address _tokenIn
    ) 
        external 
        onlyOwner 
    {
        LibParticipation.Layout storage ss = LibParticipation.layout();

        ss.participationPool[_tokenIn].liquidityAmount += _amountIn;
        ss.participationPool[_tokenIn].rewardPerTime = _amountIn / 365 days;
        ss.participationPool[_tokenIn].distributionEndDate = block.timestamp + 365 days;

        LibParticipation.safeTransferFrom(_amountIn, msg.sender, address(this), ss.participationVariables.distTokenAddress);

        LibParticipation.updateChc(_tokenIn, address(0));
    }

    function setParticipationPool(
        address _tokenIn,
        TParticipationPool calldata _params
    ) 
        external 
        onlyOwner 
    {
        LibParticipation.layout().participationPool[_tokenIn] = _params;
    }

    function setParticipationVariables(
        TParticipationVariables calldata _params
    ) 
        external 
        onlyOwner 
    {
        LibParticipation.layout().participationVariables = _params;
    }

    function rescueNative(
        address _to
    ) 
        external 
        onlyOwner 
    {
        (bool ok, ) = payable(_to).call{value: address(this).balance}("");
        if (!ok) revert TransferFailed();
    }

    function rescueERC20(
        address _tokenAddr, 
        address _to, 
        uint256 _amount
    ) 
        external 
        onlyOwner 
    {
        IERC20(_tokenAddr).transfer(_to, _amount);
    }

    function getRewards(
        address _tokenIn,
        address _user
    ) 
        public 
        view 
        returns (
            uint256 rewards_
        ) 
    {
        rewards_ = LibParticipation.calculateRewards(_tokenIn, _user);
    }

    function getUser(
        address _tokenIn,
        address _user
    ) 
        external 
        view 
        returns (
            TUser memory user_
        ) 
    {
        user_ = LibParticipation.layout().user[_tokenIn][_user];
    }

    function getParticipationPool(
        address _tokenIn
    ) 
        external 
        view 
        returns (
            TParticipationPool memory participationPool_
        ) 
    {
        participationPool_ = LibParticipation.layout().participationPool[_tokenIn];
    }

    function getChc(
        uint256 _index,
        address _tokenIn
    ) 
        external 
        view 
        returns (
            TChangeCountIndex memory chc_
        ) 
    {
        chc_ = LibParticipation.layout().chc[_tokenIn][_index];
    }
    
}