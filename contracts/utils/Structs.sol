// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;


struct TParticipationVariables {
    bool isPaused;
    address distTokenAddress;
}

struct TParticipationPool {
    bool isActive;

    uint256 lastCHCIndex;
    uint256 numberOfParticipants;

    uint256 totalParticipationAmount;

    uint256 minParticipationAmount;

    uint256 rewardPerTime;
    uint256 liquidityAmount;
    uint256 distributedRewards;
    uint256 distributionEndDate;
}

struct TChangeCountIndex{
    bool chcCanWinPrizesToken;

    uint256 chcTotalParticipationScore;
    uint256 chcStartDate;
    uint256 chcEndDate;

    uint256 chcRewardPerTime;
    uint256 chcDistributionEndDate;     
}

struct TUser {
    bool isParticipant;
    
    uint256 userParticipationAmount;
    uint256 userChangeCountIndex;
    uint256 userClaimedAmount;
    uint256 remainingAmount;
    uint256 participationStartDate;
}