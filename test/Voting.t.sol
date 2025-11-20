// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Test} from "forge-std/Test.sol";
import {Voting} from "../src/Voting.sol";
import {Ownable, Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";

import {DeployVoting} from "../script/DeployVoting.s.sol";

contract VotingTest is Test {
    address owner = makeAddr("owner");
    address voter1 = makeAddr("voter1");
    address voter2 = makeAddr("voter2");
    address voter3 = makeAddr("voter3");

    DeployVoting public deployVoting;
    Voting public voting;

    function setUp() public {
        // Integrate Deploy Script into tests.
        deployVoting = new DeployVoting();
        voting = deployVoting.run(owner);
    }

    /*//////////////////////////////////////////////////////////////
                                  INIT
    //////////////////////////////////////////////////////////////*/

    function test_initialization() public {
        assertEq(voting.owner(), owner);

        Voting.Candidate[] memory candidates = voting.getCandidates();
        assertEq(candidates.length, 0);
    }

    /*//////////////////////////////////////////////////////////////
                             ADD CANDIDATE
    //////////////////////////////////////////////////////////////*/

    function test_addCandidate() public {
        vm.prank(owner);
        voting.addCandidate("Alice");

        Voting.Candidate[] memory candidates = voting.getCandidates();
        assertEq(candidates.length, 1);
        assertEq(candidates[0].name, "Alice");
        assertEq(candidates[0].voteCount, 0);

        vm.prank(owner);
        vm.expectEmit(false, false, false, false);
        emit Voting.CandidateAdded("Bob");
        voting.addCandidate("Bob");

        candidates = voting.getCandidates();
        assertEq(candidates.length, 2);
        assertEq(candidates[1].name, "Bob");
        assertEq(candidates[1].voteCount, 0);
    }

    function test_revert_addCandidate_emptyName() public {
        vm.prank(owner);
        vm.expectRevert(Voting.Voting__InvalidCandidateName.selector);
        voting.addCandidate("");
    }

    function test_revert_addCandiaite_notOwner() public {
        vm.prank(voter1);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, voter1));
        voting.addCandidate("Charlie");
    }

    /*//////////////////////////////////////////////////////////////
                                VOTE
    //////////////////////////////////////////////////////////////*/

    function test_vote() public {
        _addCandidates();

        vm.prank(voter1);
        vm.expectEmit(false, false, false, false);
        emit Voting.VoteCast(voter1, 0);
        voting.vote(0);

        Voting.Candidate[] memory candidates = voting.getCandidates();
        assertEq(candidates[0].voteCount, 1);
        assertEq(candidates[1].voteCount, 0);

        vm.prank(voter2);
        voting.vote(1);

        candidates = voting.getCandidates();
        assertEq(candidates[0].voteCount, 1);
        assertEq(candidates[1].voteCount, 1);
    }

    function test_revert_hasVoted() public {
        _addCandidates();

        vm.prank(voter1);
        voting.vote(0);

        vm.prank(voter1);
        vm.expectRevert(Voting.Voting__AlreadyVoted.selector);
        voting.vote(0);
    }

    function test_revert_InvalidCandidateIndex() public {
        _addCandidates();

        vm.prank(voter1);
        vm.expectRevert(Voting.Voting__InvalidCandidateIndex.selector);
        voting.vote(3);
    }

    /*//////////////////////////////////////////////////////////////
                             GET CANDIDATES
    //////////////////////////////////////////////////////////////*/

    function test_getCandidates() public {
        Voting.Candidate[] memory candidates = voting.getCandidates();

        assertEq(candidates.length, 0);

        _addCandidates();

        candidates = voting.getCandidates();

        assertEq(candidates.length, 3);
        assertEq(candidates[0].name, "Alice");
        assertEq(candidates[1].name, "Bob");
        assertEq(candidates[2].name, "Charlie");
        assertEq(candidates[0].voteCount, 0);
        assertEq(candidates[1].voteCount, 0);
        assertEq(candidates[2].voteCount, 0);

        vm.prank(voter1);
        voting.vote(1);
        candidates = voting.getCandidates();
        assertEq(candidates[0].voteCount, 0);
        assertEq(candidates[1].voteCount, 1);
        assertEq(candidates[2].voteCount, 0);
    }

    /*//////////////////////////////////////////////////////////////
                               GET WINNER
    //////////////////////////////////////////////////////////////*/

    function test_getWinner() public {
        _addCandidates();

        vm.prank(voter1);
        voting.vote(0);

        vm.prank(voter2);
        voting.vote(1);

        vm.prank(voter3);
        voting.vote(1);

        (string memory winnerName, uint256 winnerVoteCount) = voting.getWinner();

        assertEq(winnerName, "Bob");
        assertEq(winnerVoteCount, 2);
    }

    /*//////////////////////////////////////////////////////////////
                           OWNERSHIP TRANSFER
    //////////////////////////////////////////////////////////////*/

    function test_ownershipTransfer() public {
        address newOwner = makeAddr("newOwner");

        assertEq(voting.pendingOwner(), address(0));
        assertEq(voting.owner(), owner);

        vm.prank(owner);
        voting.transferOwnership(newOwner);

        assertEq(voting.pendingOwner(), newOwner);

        vm.prank(newOwner);
        voting.acceptOwnership();

        assertEq(voting.owner(), newOwner);
        assertEq(voting.pendingOwner(), address(0));
    }

    function test_transferOwnership_reverts_notOwner() public {
        address newOwner = makeAddr("newOwner");

        vm.prank(voter1);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, voter1));
        voting.transferOwnership(newOwner);
    }

    /*//////////////////////////////////////////////////////////////
                                HELPERS
    //////////////////////////////////////////////////////////////*/

    function _addCandidates() internal {
        string[] memory names = new string[](3);
        names[0] = "Alice";
        names[1] = "Bob";
        names[2] = "Charlie";
        vm.startPrank(owner);
        for (uint256 i = 0; i < names.length; i++) {
            voting.addCandidate(names[i]);
        }
        vm.stopPrank();
    }
}
