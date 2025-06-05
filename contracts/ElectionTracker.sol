// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title ElectionTracker
 * @dev Main contract for tracking election data on blockchain
 * @notice This contract stores booth-level election data immutably
 */
contract ElectionTracker {
    
    // Struct to store booth data
    struct BoothData {
        string boothId;
        uint256 turnoutPercent;
        string resultHash;
        uint256 timestamp;
        address uploadedBy;
        bool isValid;
    }
    
    // State variables
    address public owner;
    mapping(string => BoothData) public booths;
    mapping(address => bool) public authorizedAdmins;
    string[] public allBoothIds;
    
    // Events
    event BoothDataUploaded(
        string indexed boothId, 
        uint256 turnoutPercent, 
        string resultHash, 
        address uploadedBy,
        uint256 timestamp
    );
    
    event AdminAdded(address indexed admin);
    event AdminRemoved(address indexed admin);
    
    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    
    modifier onlyAuthorized() {
        require(authorizedAdmins[msg.sender] || msg.sender == owner, "Unauthorized access");
        _;
    }
    
    modifier validBoothId(string memory boothId) {
        require(bytes(boothId).length > 0, "Booth ID cannot be empty");
        _;
    }
    
    modifier validTurnout(uint256 turnout) {
        require(turnout <= 100, "Turnout cannot exceed 100%");
        _;
    }
    
    // Constructor
    constructor() {
        owner = msg.sender;
        authorizedAdmins[msg.sender] = true;
    }
    
    /**
     * @dev Upload booth data to blockchain
     * @param boothId Unique identifier for the booth
     * @param turnoutPercent Voter turnout percentage (0-100)
     * @param resultHash IPFS hash of detailed results
     */
    function uploadBoothData(
        string memory boothId,
        uint256 turnoutPercent,
        string memory resultHash
    ) 
        public 
        onlyAuthorized 
        validBoothId(boothId) 
        validTurnout(turnoutPercent) 
    {
        // Check if booth data already exists
        if (!booths[boothId].isValid) {
            allBoothIds.push(boothId);
        }
        
        // Store booth data
        booths[boothId] = BoothData({
            boothId: boothId,
            turnoutPercent: turnoutPercent,
            resultHash: resultHash,
            timestamp: block.timestamp,
            uploadedBy: msg.sender,
            isValid: true
        });
        
        // Emit event
        emit BoothDataUploaded(
            boothId, 
            turnoutPercent, 
            resultHash, 
            msg.sender, 
            block.timestamp
        );
    }
    
    /**
     * @dev Get booth data from blockchain
     * @param boothId Unique identifier for the booth
     * @return BoothData struct containing all booth information
     */
    function getBoothData(string memory boothId) 
        public 
        view 
        validBoothId(boothId) 
        returns (BoothData memory) 
    {
        require(booths[boothId].isValid, "Booth data does not exist");
        return booths[boothId];
    }
    
    /**
     * @dev Get all booth IDs
     * @return Array of all booth IDs
     */
    function getAllBoothIds() public view returns (string[] memory) {
        return allBoothIds;
    }
    
    /**
     * @dev Add new admin
     * @param admin Address to be granted admin privileges
     */
    function addAdmin(address admin) public onlyOwner {
        require(admin != address(0), "Invalid admin address");
        authorizedAdmins[admin] = true;
        emit AdminAdded(admin);
    }
    
    /**
     * @dev Remove admin
     * @param admin Address to remove admin privileges
     */
    function removeAdmin(address admin) public onlyOwner {
        require(admin != owner, "Cannot remove owner");
        authorizedAdmins[admin] = false;
        emit AdminRemoved(admin);
    }
    
    /**
     * @dev Check if address is authorized admin
     * @param admin Address to check
     * @return Boolean indicating admin status
     */
    function isAdmin(address admin) public view returns (bool) {
        return authorizedAdmins[admin];
    }
    
    /**
     * @dev Get total number of booths
     * @return Total count of booths
     */
    function getTotalBooths() public view returns (uint256) {
        return allBoothIds.length;
    }
}