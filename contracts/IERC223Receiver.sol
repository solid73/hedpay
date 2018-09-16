pragma solidity ^0.4.11;

import "./IERC223BasicReceiver.sol";


contract IERC223Receiver is IERC223BasicReceiver {
  function receiveApproval(address _owner, uint _value) public;
}