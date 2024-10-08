// SPDX-License-Identifier: GPL-3.0
        
pragma solidity >=0.4.22 <0.9.0;

import "remix_tests.sol"; 
import "remix_accounts.sol";
import "../contracts/Fundraising.sol";

contract testSuite {
    Fundraiser fundraiser;

    function beforeEach() public {
        fundraiser = new Fundraiser();
    }

    function testCreateProject() public {
        string memory projectName = "Project A";
        uint256 durationInDays = 1;

        fundraiser.createProject(projectName, durationInDays);

        Fundraiser.Project memory                                  
                                                                    
                                   project = fundraiser.getProjectByName(projectName);
        Assert.equal(project.name, projectName, "Project name should match");
        Assert.equal(project.owner, address(this), "Project owner should be the caller");
        Assert.equal(project.totalContributions, 0, "Total contributions should be zero");
        Assert.equal(project.isActive, true, "Project should be active");
    }

    function testCannotCreateDuplicateProject() public {
        string memory projectName = "Project A";
        uint256 durationInDays = 1;

        fundraiser.createProject(projectName, durationInDays);
        (bool success, ) = address(fundraiser).call(abi.encodeWithSignature("createProject(string,uint256)", projectName, durationInDays));
        Assert.equal(success, false, "Should not allow creating a project with the same name");
    }

    function testGetAllProjects() public {
        string memory projectName1 = "Project A";
        string memory projectName2 = "Project B";
        uint256 durationInDays = 1;

        fundraiser.createProject(projectName1, durationInDays);
        fundraiser.createProject(projectName2, durationInDays);

        Fundraiser.Project[] memory allProjects = fundraiser.getAllProjects();
        Assert.equal(allProjects.length, 2, "Should return two projects");
    }

    function testGetActiveProjects() public {
        string memory projectName1 = "Project A";
        string memory projectName2 = "Project B";
        uint256 durationInDays = 1;

        fundraiser.createProject(projectName1, durationInDays);
        fundraiser.createProject(projectName2, durationInDays);

        Fundraiser.Project[] memory activeProjects = fundraiser.getActiveProjects();
        Assert.equal(activeProjects.length, 2, "Should return two active projects");
    }
}
    