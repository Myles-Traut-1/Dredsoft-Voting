## Voting Contract

### Overview

The `Voting` contract is a smart contract that facilitates a voting system where users can vote for candidates. The contract owner has administrative privileges to manage candidates, and the voting process ensures fairness by allowing each address to vote only once.

### Features

- **Add Candidates**: The contract owner can add candidates to the voting roll.
- **Vote**: Users can cast their vote for a candidate. Each address can vote only once.
- **View Candidates**: Anyone can retrieve the list of candidates.
- **Determine Winner**: The current leading candidate can be queried at any time.

### Contract Details

#### Errors
- `Voting__InvalidCandidateName`: Thrown when attempting to add a candidate with an empty name.
- `Voting__AlreadyVoted`: Thrown when an address tries to vote more than once.
- `Voting__InvalidCandidateIndex`: Thrown when a vote is cast for a non-existent candidate.

#### Events
- `CandidateAdded(string name)`: Emitted when a new candidate is added.
- `VoteCast(address indexed voter, uint256 indexed candidateIndex)`: Emitted when a vote is cast.

#### Functions

1. **addCandidate(string memory _name)**
   - Adds a new candidate to the voting roll.
   - Can only be called by the contract owner.

2. **vote(uint256 _candidateIndex)**
   - Casts a vote for a candidate by their index.
   - Ensures that the voter has not already voted and the candidate index is valid.

3. **getCandidates() public view returns (Candidate[] memory)**
   - Returns the list of all candidates.

4. **getWinner() public view returns (string memory winnerName, uint256 winnerVoteCount)**
   - Determines the current leading candidate and their vote count.

### Deployment

To deploy the `Voting` contract, use the following command:

```shell
$ forge script script/DeployVoting.s.sol:DeployVoting --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Example Usage

1. **Add Candidates**:
   ```solidity
   voting.addCandidate("Alice");
   voting.addCandidate("Bob");
   ```

2. **Vote**:
   ```solidity
   voting.vote(0); // Vote for Alice
   ```

3. **Get Candidates**:
   ```solidity
   Candidate[] memory candidates = voting.getCandidates();
   ```

4. **Get Winner**:
   ```solidity
   (string memory winnerName, uint256 winnerVoteCount) = voting.getWinner();
   ```
