// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title ElectionMetadata
 * @dev Contract for storing election configuration and metadata
 */
contract ElectionMetadata {
    
    struct Election {
        string name;
        string description;
        uint256 startTime;
        uint256 endTime;
        bool isActive;
        string[] participatingBooths;
    }
    
    struct Candidate {
        string name;
        string party;
        string symbol;
        string manifesto;
        bool isActive;
    }
    
    address public owner;
    Election public currentElection;
    mapping(string => Candidate) public candidates;
    string[] public candidateIds;
    
    event ElectionCreated(string name, uint256 startTime, uint256 endTime);
    event CandidateAdded(string candidateId, string name, string party);
    event ElectionStatusUpdated(bool isActive);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner allowed");
        _;
    }
    
    constructor() {
        owner = msg.sender;
    }
    
    function createElection(
        string memory name,
        string memory description,
        uint256 startTime,
        uint256 endTime,
        string[] memory participatingBooths
    ) public onlyOwner {
        require(startTime < endTime, "Invalid time range");
        require(startTime > block.timestamp, "Start time must be in future");
        
        currentElection = Election({
            name: name,
            description: description,
            startTime: startTime,
            endTime: endTime,
            isActive: true,
            participatingBooths: participatingBooths
        });
        
        emit ElectionCreated(name, startTime, endTime);
    }
    
    function addCandidate(
        string memory candidateId,
        string memory name,
        string memory party,
        string memory symbol,
        string memory manifesto
    ) public onlyOwner {
        require(bytes(candidateId).length > 0, "Candidate ID required");
        require(!candidates[candidateId].isActive, "Candidate already exists");
        
        candidates[candidateId] = Candidate({
            name: name,
            party: party,
            symbol: symbol,
            manifesto: manifesto,
            isActive: true
        });
        
        candidateIds.push(candidateId);
        emit CandidateAdded(candidateId, name, party);
    }
    
    function updateElectionStatus(bool isActive) public onlyOwner {
        currentElection.isActive = isActive;
        emit ElectionStatusUpdated(isActive);
    }
    
    function getCurrentElection() public view returns (Election memory) {
        return currentElection;
    }
    
    function getAllCandidates() public view returns (string[] memory) {
        return candidateIds;
    }
    
    function getCandidate(string memory candidateId) 
        public 
        view 
        returns (Candidate memory) 
    {
        require(candidates[candidateId].isActive, "Candidate not found");
        return candidates[candidateId];
    }
    
    function isElectionActive() public view returns (bool) {
        return currentElection.isActive && 
               block.timestamp >= currentElection.startTime && 
               block.timestamp <= currentElection.endTime;
    }
}