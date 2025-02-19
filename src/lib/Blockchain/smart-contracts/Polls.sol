// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import './RightToVote.sol';
import './Delegations.sol';

contract Polls is RightToVote, Delegations {
    struct Poll {
        string title;
        string tag;
        uint group;
        uint pollStartDate;
        uint proposalEndDate;
        uint votingStartDate;
        uint delegateEndDate;
        uint endDate;
        uint pollId;
        uint proposalCount;
    }

    struct Proposal {
        string description;
        uint voteCount;
        uint proposalId;
        uint predictionCount;
    }

    mapping(uint => Poll) public polls;
    uint public pollCount;

    //Ties proposals to polls by pollId
    mapping(uint => Proposal[]) public proposals;

    event PollCreated(uint pollId, string title);

    function createPoll(
        string memory _title,
        string memory _tag,
        uint _group,
        uint _pollStartDate,
        uint _proposalEndDate,
        uint _votingStartDate, 
        uint _delegateEndDate,
        uint _endDate
        ) public {
            pollCount++;

            Poll memory newPoll = Poll({
                title: _title,
                tag: _tag,
                group: _group,
                pollStartDate: _pollStartDate,
                proposalEndDate: _proposalEndDate,
                votingStartDate: _votingStartDate,
                delegateEndDate: _delegateEndDate,
                endDate: _endDate,
                pollId: pollCount, 
                proposalCount: 0
            });

            polls[pollCount] = newPoll;

            emit PollCreated(pollCount, _title);
        }

    function requirePollToExist(uint _pollId) internal view {
        require(_pollId > 0 && _pollId <= pollCount, "Poll ID does not exist");
    }

    event ProposalAdded(uint pollId, uint proposalId, string description, uint proposalCount);

    function addProposal(uint _pollId, string memory _description) public {
        requirePollToExist(_pollId);
        polls[_pollId].proposalCount++;
        uint _proposalId = polls[_pollId].proposalCount;

        proposals[_pollId].push(Proposal({
            description: _description,
            voteCount: 0,
            proposalId: _proposalId,
            predictionCount: 0
        }));

        emit ProposalAdded(_pollId, _proposalId, _description, _proposalId);
    }

    function getProposals(uint _pollId) external view returns(Proposal[] memory) {
        requirePollToExist(_pollId);
        return proposals[_pollId];
    }

    function userHasDelegatedInGroup(uint _pollGroup) private view returns(bool) {
        uint[] memory delegatedGroups = groupDelegationsByUser[msg.sender];

        for (uint i; i < delegatedGroups.length;) {
            if (delegatedGroups[i] == _pollGroup) {
                return true;
            }
            unchecked {
                ++i;
            }
        }
        return false;
    }

    function userIsMemberOfPollGroup(uint _pollId) internal view returns(bool isInGroup) {
        uint[] memory userGroups = voters[msg.sender].groups;

        for (uint i; i < userGroups.length;) {
            if (userGroups[i] == polls[_pollId].group) {
                return true;
            }
            unchecked {
                ++i;
            }
        }
        return false;
    }

    event VoteSubmitted(uint indexed pollId, address indexed voter, bytes32 hashedVote, uint votesForProposal);

    function vote(uint _pollId, uint _proposalId, bytes32 _hashedVote) public {
        uint _pollGroup = polls[_pollId].group;
        uint delegatedVotingPower;

        requirePollToExist(_pollId);

        require(userIsMemberOfPollGroup(_pollId), "The user is not a member of poll group");

        // require(block.timestamp <= polls[_pollId].endDate, "Voting is not allowed at this time");
        
        require(!hasVoted(_pollId), "Vote has already been cast");

        require(_proposalId > 0 && _proposalId <= polls[_pollId].proposalCount, "Proposal does not exist");

        require(!userHasDelegatedInGroup(_pollGroup), "You have delegated your vote in the polls group.");

        Proposal[] storage pollProposals = proposals[_pollId];

        for (uint i; i < groupDelegates[_pollGroup].length;) {
            if (groupDelegates[_pollGroup][i].delegate == msg.sender) {
                delegatedVotingPower = groupDelegates[_pollGroup][i].delegatedVotes;
            }
            unchecked {
                ++i;
            }
        } 

        uint proposalsLength = pollProposals.length;

        uint _votesForProposal;

        for (uint i; i < proposalsLength;) {
            if (pollProposals[i].proposalId == _proposalId) {
                pollProposals[i].voteCount += delegatedVotingPower + 1;
                _votesForProposal = pollProposals[i].voteCount;
                votersForPoll[_pollId].push(msg.sender);
                emit VoteSubmitted(_pollId, msg.sender, _hashedVote, _votesForProposal);
                return;
            }
            unchecked {
                ++i;
            }
        }
        revert("There is no such proposal for the specified pollId");
    }

    mapping(uint => address[]) internal votersForPoll;

    function hasVoted(uint _pollId) internal view returns(bool voted) {
        address[] memory addresses = votersForPoll[_pollId];

        for (uint i; i < addresses.length;) {
            if (addresses[i] == msg.sender) {
                return true;
            }
            unchecked {
                ++i;
            }
        }
        return false;
    }
    
}
