// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title DataVerifier
 * @dev Contract for verifying election data integrity
 */
contract DataVerifier {
    
    struct VerificationRecord {
        string dataHash;
        address verifier;
        uint256 timestamp;
        bool isVerified;
        string comments;
    }
    
    mapping(string => VerificationRecord[]) public verificationHistory;
    mapping(address => bool) public authorizedVerifiers;
    address public owner;
    
    event DataVerified(
        string indexed boothId,
        string dataHash,
        address verifier,
        bool isVerified,
        uint256 timestamp
    );
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner allowed");
        _;
    }
    
    modifier onlyVerifier() {
        require(authorizedVerifiers[msg.sender], "Only authorized verifiers");
        _;
    }
    
    constructor() {
        owner = msg.sender;
        authorizedVerifiers[msg.sender] = true;
    }
    
    function addVerifier(address verifier) public onlyOwner {
        authorizedVerifiers[verifier] = true;
    }
    
    function removeVerifier(address verifier) public onlyOwner {
        authorizedVerifiers[verifier] = false;
    }
    
    function verifyData(
        string memory boothId,
        string memory dataHash,
        bool isVerified,
        string memory comments
    ) public onlyVerifier {
        
        VerificationRecord memory record = VerificationRecord({
            dataHash: dataHash,
            verifier: msg.sender,
            timestamp: block.timestamp,
            isVerified: isVerified,
            comments: comments
        });
        
        verificationHistory[boothId].push(record);
        
        emit DataVerified(boothId, dataHash, msg.sender, isVerified, block.timestamp);
    }
    
    function getVerificationHistory(string memory boothId) 
        public 
        view 
        returns (VerificationRecord[] memory) 
    {
        return verificationHistory[boothId];
    }
    
    function getLatestVerification(string memory boothId) 
        public 
        view 
        returns (VerificationRecord memory) 
    {
        require(verificationHistory[boothId].length > 0, "No verification records");
        return verificationHistory[boothId][verificationHistory[boothId].length - 1];
    }
}