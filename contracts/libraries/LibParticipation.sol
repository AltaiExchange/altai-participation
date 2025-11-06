// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import { TParticipationPool, TChangeCountIndex, TUser, TParticipationVariables } from "../utils/Structs.sol";
import { IERC20 } from "../interfaces/IERC20.sol";

library LibParticipation {
    bytes32 internal constant STORAGE_SLOT = keccak256('storage.altai.exchange.participation');

       function updateChc(
        address _tokenIn,
        address _user
    ) 
        internal 
    {
        uint256 blockTime = block.timestamp;
        uint256 currentCHCIndex = layout().participationPool[_tokenIn].lastCHCIndex;
        uint256 nextCHCIndex = currentCHCIndex + 1;
        TParticipationPool storage participationPool = layout().participationPool[_tokenIn];

        layout().chc[_tokenIn][currentCHCIndex].chcEndDate = blockTime;
        participationPool.lastCHCIndex = nextCHCIndex;
        layout().user[_tokenIn][_user].userChangeCountIndex = nextCHCIndex;

        TChangeCountIndex storage nextChc = layout().chc[_tokenIn][nextCHCIndex];

        nextChc.chcStartDate = blockTime;
        nextChc.chcTotalParticipationScore = participationPool.totalParticipationAmount;
        nextChc.chcRewardPerTime = participationPool.rewardPerTime;
        nextChc.chcDistributionEndDate = participationPool.distributionEndDate;
        nextChc.chcCanWinPrizesToken = blockTime < nextChc.chcDistributionEndDate;
    }

  function safeClaim(
        address _tokenIn,
        address _user
    ) 
        internal 
        returns(
            bool success_
        )
    {
        uint256 remainingAmount = calculateRewards(_tokenIn,_user);
        if(remainingAmount > 0){
            Layout storage ss = layout();
            ss.user[_tokenIn][_user].userClaimedAmount += remainingAmount;
            ss.user[_tokenIn][_user].remainingAmount = 0;
            ss.participationPool[_tokenIn].distributedRewards += remainingAmount;
            ss.participationPool[_tokenIn].liquidityAmount -= remainingAmount;

            require(IERC20(ss.participationVariables.distTokenAddress).transfer(_user, remainingAmount),"Transfer failed");
            success_ = true;
        }
    }

    function safeTransferFrom(
        uint256 _amount,
        address _from,
        address _to,
        address _tokenAddress
    ) 
        internal 
    {
        IERC20 token = IERC20(_tokenAddress);
        require(token.balanceOf(_from) >= _amount, "Insufficient Balance");
        require(token.allowance(_from, _to) >= _amount, "Insufficient Allowance");
        require(token.transferFrom(_from, _to, _amount),"Transfer failed");
    }


    function calculateRewards(
        address _tokenIn,
        address _user
    ) 
        internal 
        view 
        returns (
            uint256
        ) 
    {
        Layout storage ss = layout();
        address tokenIn = _tokenIn;
        if(!ss.user[tokenIn][_user].isParticipant) return 0;

        uint256 blockTime = block.timestamp;
        uint256 differenceAmount = 1 ether;

        uint256 userCCIndex = ss.user[tokenIn][_user].userChangeCountIndex;
        uint256 poolCCIndex = ss.participationPool[tokenIn].lastCHCIndex;
        uint256 userParticipationAmount = ss.user[tokenIn][_user].userParticipationAmount;

        uint256 tokenRewards = 0;
        for(
            uint256 i = userCCIndex; 
            i <= poolCCIndex;
        ){
            if(ss.chc[tokenIn][i].chcCanWinPrizesToken) {
                uint256 userWeight = (userParticipationAmount * differenceAmount) / ss.chc[tokenIn][i].chcTotalParticipationScore;
                uint256 reward = (ss.chc[tokenIn][i].chcRewardPerTime * userWeight) / differenceAmount;
                uint256 userActiveTime = 0;

                if(i == poolCCIndex && blockTime > ss.chc[tokenIn][i].chcDistributionEndDate) {
                    unchecked {
                        userActiveTime = ss.chc[tokenIn][i].chcDistributionEndDate - ss.chc[tokenIn][i].chcStartDate;
                    }
                } else {
                    if(i == poolCCIndex) {
                        unchecked {
                            userActiveTime = blockTime - ss.chc[tokenIn][i].chcStartDate;
                        }
                    } else {
                        unchecked {
                            userActiveTime = ss.chc[tokenIn][i].chcEndDate - ss.chc[tokenIn][i].chcStartDate;
                        }
                    }
                }
                unchecked {
                    tokenRewards = tokenRewards + (reward * userActiveTime);
                }
            }
            unchecked {
                i++;
            }
        }
        return tokenRewards + ss.user[tokenIn][_user].remainingAmount;
    }

   struct Layout {
        TParticipationVariables participationVariables;
        // token address => data
        mapping(address => TParticipationPool) participationPool;

        // token address => chc index => data
        mapping(address => mapping(uint256 => TChangeCountIndex)) chc;

        // token address => user address => data
        mapping(address => mapping(address => TUser)) user;
    }

    function layout(
    ) 
        internal 
        pure 
        returns (
            Layout storage l
        ) 
    {
        bytes32 slot = STORAGE_SLOT;
        assembly {
            l.slot := slot
        }
    }
}