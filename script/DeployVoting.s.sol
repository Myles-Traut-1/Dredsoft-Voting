// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Script} from "forge-std/Script.sol";
import {Voting} from "../src/Voting.sol";

// Deployed Sepolia Address:  0x0e4897aB9EEf760CF0a8e8bcD31936E35a25cc53

contract DeployVoting is Script {
    function run(address _owner) external returns (Voting) {
        vm.startBroadcast(_owner);

        Voting voting = new Voting();

        vm.stopBroadcast();

        return voting;
    }
}
