// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Ownable, Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";

/**
 *  @title Voting Contract
 *  @notice This contract allows users to vote for candidates.
 *  @notice The contract owner can add candidates, and each address can vote only once.
 *  @notice Anyone can call the getWinner function at any time to see the current leading candidate.
 */
contract Voting is Ownable2Step {
    /*//////////////////////////////////////////////////////////////
                                ERRORS
    //////////////////////////////////////////////////////////////*/

    error Voting__InvalidCandidateName();
    error Voting__AlreadyVoted();
    error Voting__InvalidCandidateIndex();

    /*//////////////////////////////////////////////////////////////
                                EVENTS
    //////////////////////////////////////////////////////////////*/

    event CandidateAdded(string name);
    event VoteCast(address indexed voter, uint256 indexed candidateIndex);

    /*//////////////////////////////////////////////////////////////
                            STORAGE
    //////////////////////////////////////////////////////////////*/

    struct Candidate {
        string name;
        uint256 voteCount;
    }

    Candidate[] public candidates;

    mapping(address voter => bool) public hasVoted;

    /*//////////////////////////////////////////////////////////////
                            CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor() Ownable(msg.sender) {}

    /*//////////////////////////////////////////////////////////////
                            ADMIN FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Adds a new candidate to the voting roll.
     * @notice Can only be called by the contract owner.
     * @param _name The name of the candidate.
     */
    function addCandidate(string memory _name) public onlyOwner {
        if (bytes(_name).length == 0) {
            revert Voting__InvalidCandidateName();
        }
        candidates.push(Candidate({name: _name, voteCount: 0}));

        emit CandidateAdded(_name);
    }

    /*//////////////////////////////////////////////////////////////
                            PUBLIC FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Casts a vote for a candidate.
     * @notice Each address can only vote once.
     * @param _candidateIndex The index of the candidate in the candidates array.
     */
    function vote(uint256 _candidateIndex) public {
        if (hasVoted[msg.sender]) {
            revert Voting__AlreadyVoted();
        }

        if (_candidateIndex >= candidates.length) {
            revert Voting__InvalidCandidateIndex();
        }

        hasVoted[msg.sender] = true;
        candidates[_candidateIndex].voteCount += 1;

        emit VoteCast(msg.sender, _candidateIndex);
    }

    /*//////////////////////////////////////////////////////////////
                             VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Returns the list of candidates.
     * @return An array of Candidate structs.
     */
    function getCandidates() public view returns (Candidate[] memory) {
        return candidates;
    }

    /**
     * @dev Determines the winner of the election.
     * @return winnerName The name of the winning candidate.
     * @return winnerVoteCount The number of votes received by the winning candidate.
     */
    function getWinner() public view returns (string memory winnerName, uint256 winnerVoteCount) {
        uint256 highestVoteCount = 0;
        string memory leadingCandidate = "";

        for (uint256 i = 0; i < candidates.length;) {
            if (candidates[i].voteCount > highestVoteCount) {
                highestVoteCount = candidates[i].voteCount;
                leadingCandidate = candidates[i].name;
            }

            // Safe as list of candidates should never exceed uint256 max size
            unchecked {
                // Gas optimization: incrementing i
                i++;
            }
        }

        return (leadingCandidate, highestVoteCount);
    }
}
