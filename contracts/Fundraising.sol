// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Fundraiser {
    struct Project {
        string name;
        address owner;
        uint256 totalContributions;
        uint256 deadline;
        bool isActive;
    }

    mapping(string => Project) private projects;
    string[] private projectNames;

    event ProjectCreated(string name, address owner, uint256 deadline);
    event ContributionReceived(string projectName, address contributor, uint256 amount);
    event FundsWithdrawn(string projectName, address owner, uint256 amount);

    modifier onlyOwner(string memory projectName) {
        require(
            msg.sender == projects[projectName].owner,
            "Not the project owner"
        );
        _;
    }
                                  

    function createProject(string memory name, uint256 durationInSeconds)
        external
    {
        require(
            bytes(projects[name].name).length == 0,
            "Project already exists"
        );

        uint256 deadline = block.timestamp + (durationInSeconds);
        projects[name] = Project({
            name: name,
            owner: msg.sender,
            totalContributions: 0,
            deadline: deadline,
            isActive: true
        });

        projectNames.push(name);
        emit ProjectCreated(name, msg.sender, deadline);
    }

    function contribute(string memory projectName) external payable {
        require(projects[projectName].isActive, "Project is not active");
        require(
            block.timestamp < projects[projectName].deadline,
            "Project has ended"
        );
        require(msg.value > 0, "Contribution must be greater than zero");

        projects[projectName].totalContributions += msg.value;
        emit ContributionReceived(projectName, msg.sender, msg.value);
    }

    function withdrawFunds(string memory projectName)
        external
        onlyOwner(projectName)
    {
        require(projects[projectName].isActive, "Project is not active");
        require(
            block.timestamp >= projects[projectName].deadline,
            "Project has not ended"
        );

        uint256 amount = projects[projectName].totalContributions;
        require(amount > 0, "No funds available for withdrawal");

        projects[projectName].isActive = false;
        payable(msg.sender).transfer(amount);
        emit FundsWithdrawn(projectName, msg.sender, amount);
    }

    function getProjectNames() external view returns (string[] memory) {
        return projectNames;
    }

    function getProjectByName(string memory projectName)
        external
        view
        returns (Project memory)
    {
        Project memory project = projects[projectName];
        return project;
    }

    function getAllProjects() external view returns (Project[] memory) {
        Project[] memory allProjects = new Project[](projectNames.length);

        for (uint256 i = 0; i < projectNames.length; i++) {
            allProjects[i] = projects[projectNames[i]];
        }

        return allProjects;
    }

    function getActiveProjects() external view returns (Project[] memory) {
        uint256 activeCount = 0;
        for (uint256 i = 0; i < projectNames.length; i++) {
            if (projects[projectNames[i]].isActive) {
                activeCount++;
            }
        }

        Project[] memory activeProjects = new Project[](activeCount);
        for (uint256 i = 0; i < projectNames.length; i++) {
            if (projects[projectNames[i]].isActive) {
                activeProjects[i] = projects[projectNames[i]];
            }
        }

        return activeProjects;
    }
}
