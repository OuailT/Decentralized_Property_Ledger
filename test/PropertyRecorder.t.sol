// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "../src/PropertyRecorder.sol";

contract ContractTest is Test {

    // Constants
    address constant public ADMIN = address(0x1);
    address constant public ALICE = address(0x2);
    address constant public BOB = address(0x3);
    address constant public MAX = address(0x4);

    PropertyRecorder propertyRecorder;
    
    /// @dev Sets up the test environment by initializing contract instances and labeling addresses.
    function setUp() public {
        vm.startPrank(ADMIN);
            propertyRecorder = new PropertyRecorder();
            propertyRecorder.addManager(address(ADMIN));

            vm.label(address(ADMIN), "Admin");
            vm.label(address(ALICE), "Alice");
            vm.label(address(BOB), "Bob");
            vm.label(address(MAX), "Max");
        vm.stopPrank();
    }


    /// @dev Tests the creation of property tokens and asserts the validity of properties.
    function test_Create_Property() public returns(uint256 tokenId) {
        string memory tokenURI1 = "ipfs://token1.com";
        uint256 InstrumentNum1 = 1992;
        string memory tokenURI2 = "ipfs://token2.com";
        uint256 InstrumentNum2 = 1995;

        vm.startPrank(ALICE);
            // Property #1
            tokenId = propertyRecorder.createProperty(tokenURI1, InstrumentNum1);
            (,
            address recorder,
            address database,
            uint256 instrumentNum,string memory status,) = propertyRecorder.idToProperty(tokenId);
            console2.log("The token Id for token1 is", tokenId);
            console2.log("Struct info for token 1...", instrumentNum);
            assertEq(tokenId, 1);
            assertEq(recorder, address(ALICE));
        vm.stopPrank();

        vm.startPrank(BOB); 
            // Property #2
            tokenId = propertyRecorder.createProperty(tokenURI2, InstrumentNum2);
            (,
            recorder,
            database,
            instrumentNum,,) = propertyRecorder.idToProperty(tokenId);
            console2.log("Struct info for token 2...", instrumentNum);
            assertEq(recorder, address(BOB));
            assertEq(tokenId, 2);
        vm.stopPrank();
    }

    /// @dev Tests setting a new token URI and asserts whether it has been successfully changed.
    function test_setTokenURI() public {
        test_Create_Property();
        vm.startPrank(ALICE);
        string memory newTokenURI1 = "ipfs://token123.com";
            propertyRecorder.setTokenURI(1, newTokenURI1);
            string memory newTokenURI2 = propertyRecorder.tokenURI(1);
            console.log(newTokenURI2, newTokenURI1);
        vm.stopPrank();

        vm.startPrank(ADMIN);
        string memory newTokenURI3 = "ipfs://token456.com";
            propertyRecorder.setTokenURI(1, newTokenURI3);
            string memory newTokenURI4 = propertyRecorder.tokenURI(1);
            console.log(newTokenURI3, newTokenURI4);
        vm.stopPrank();
    }

    /// @dev Tests unauthorized attempts to set a new token URI and expects reverts.
    function test_revert_setTokenURI() public {
        test_Create_Property();
        vm.startPrank(BOB);
        string memory newTokenURI1 = "ipfs://token123.com";
            propertyRecorder.setTokenURI(1, newTokenURI1);
            vm.expectRevert("UnautorizedCaller(Unautorized Caller)");
        vm.stopPrank();

        vm.startPrank(MAX);
        string memory newTokenURI3 = "ipfs://token456.com";
            propertyRecorder.setTokenURI(1, newTokenURI3);
            vm.expectRevert("UnautorizedCaller(Unautorized Caller)");
        vm.stopPrank();
    }

    /// @dev Tests fetching all the properties and asserts the count.
    function test_fetchAllProperties() public {
        test_Create_Property();
        PropertyRecorder.PropertyData[] memory items = propertyRecorder.fetchAllProperties();

        for(uint256 i = 0; i < items.length; i++) {
            console2.log("Items", i);
            console2.log("Tokens ID", items[i].tokenId);
            console2.log("Recorder:", items[i].recorder);
            console2.log("Database:", items[i].database);
            console2.log("Instrument Number:", items[i].instrumentNumber);
            console2.log("Recorded:", items[i].recorded);
        }

        console2.log("Arrya lengh", items.length);
        assertEq(items.length, 2);
    }


    /// @dev Tests fetching properties by their instrument number and asserts the count.
    function test_fetchPropertiesByNum() public {
        test_Create_Property();

        uint256 InstrumentNum1 = 1995;
        PropertyRecorder.PropertyData[] memory items1 =  propertyRecorder.fetchPropertiesByNum(InstrumentNum1);
        console.log("Items1", items1[0].instrumentNumber);
        assertEq(items1.length, 1);
    }
    

    /// @dev Tests fetching user properties and asserts the recorder and count.
    function test_fetchUserProperty() public {
        test_Create_Property();
        vm.startPrank(ALICE);
        PropertyRecorder.PropertyData[] memory items = propertyRecorder.fetchUserProperty();

            for(uint256 i = 0; i < items.length; i++) {
                console2.log("Items", i);
                console2.log("Tokens ID", items[i].tokenId);
                console2.log("Recorder:", items[i].recorder);
                console2.log("Database:", items[i].database);
                console2.log("Instrument Number:", items[i].instrumentNumber);
                console2.log("Recorded:", items[i].recorded);

            assertEq(items[i].recorder, address(ALICE));

            }
            assertEq(items.length, 1);
        vm.stopPrank();
        
    }

    
    /// @dev This test checks if a new manager can be successfully added to the list of managers.
    function test_addManager() public {
        vm.startPrank(ADMIN);
        
            propertyRecorder.addManager(BOB);
            bool ManagerExist = propertyRecorder.isManager(BOB);
            assertTrue(ManagerExist);
        vm.stopPrank();
    }


    /// @dev Tests if property status can be approved by the admin.
    function test_approvedPropertyStatus() public {
        test_Create_Property();
        vm.startPrank(ADMIN);
        (, , , , string memory status,) = propertyRecorder.idToProperty(1);
        console2.log("status property before ", status);
        propertyRecorder.approvedPropertyStatus(1);
        (, , , , status,) = propertyRecorder.idToProperty(1);
        console2.log("status property after ", status);
        assertEq(status, "approved");
        vm.stopPrank();
    }

    
}