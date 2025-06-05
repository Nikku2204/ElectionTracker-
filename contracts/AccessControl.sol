// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title AccessControl
 * @dev Enhanced access control for election officials
 */
contract AccessControl {
    
    enum Role { NONE, ADMIN, SUPER_ADMIN, AUDITOR }
    
    struct User {
        Role role;
        string name;
        string designation;
        bool isActive;
        uint256 registeredAt;
    }
    
    address public superAdmin;
    mapping(address => User) public users;
    mapping(Role => uint256) public roleCount;
    
    event UserRegistered(address indexed user, Role role, string name);
    event RoleUpdated(address indexed user, Role oldRole, Role newRole);
    event UserDeactivated(address indexed user);
    
    modifier onlySuperAdmin() {
        require(msg.sender == superAdmin, "Only super admin allowed");
        _;
    }
    
    modifier onlyAdmin() {
        require(
            users[msg.sender].role == Role.ADMIN || 
            users[msg.sender].role == Role.SUPER_ADMIN,
            "Admin access required"
        );
        _;
    }
    
    modifier onlyActive() {
        require(users[msg.sender].isActive, "User account is deactivated");
        _;
    }
    
    constructor() {
        superAdmin = msg.sender;
        users[msg.sender] = User({
            role: Role.SUPER_ADMIN,
            name: "System Administrator",
            designation: "Super Admin",
            isActive: true,
            registeredAt: block.timestamp
        });
        roleCount[Role.SUPER_ADMIN] = 1;
    }
    
    function registerUser(
        address userAddress,
        Role role,
        string memory name,
        string memory designation
    ) public onlySuperAdmin {
        require(userAddress != address(0), "Invalid address");
        require(role != Role.SUPER_ADMIN, "Cannot assign super admin role");
        require(bytes(name).length > 0, "Name cannot be empty");
        
        users[userAddress] = User({
            role: role,
            name: name,
            designation: designation,
            isActive: true,
            registeredAt: block.timestamp
        });
        
        roleCount[role]++;
        emit UserRegistered(userAddress, role, name);
    }
    
    function updateRole(address userAddress, Role newRole) public onlySuperAdmin {
        require(users[userAddress].isActive, "User does not exist");
        require(newRole != Role.SUPER_ADMIN, "Cannot assign super admin role");
        
        Role oldRole = users[userAddress].role;
        users[userAddress].role = newRole;
        
        roleCount[oldRole]--;
        roleCount[newRole]++;
        
        emit RoleUpdated(userAddress, oldRole, newRole);
    }
    
    function deactivateUser(address userAddress) public onlySuperAdmin {
        require(userAddress != superAdmin, "Cannot deactivate super admin");
        require(users[userAddress].isActive, "User already deactivated");
        
        users[userAddress].isActive = false;
        roleCount[users[userAddress].role]--;
        
        emit UserDeactivated(userAddress);
    }
    
    function hasRole(address userAddress, Role role) public view returns (bool) {
        return users[userAddress].role == role && users[userAddress].isActive;
    }
    
    function getUserInfo(address userAddress) public view returns (User memory) {
        return users[userAddress];
    }
}