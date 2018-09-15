pragma solidity ^0.4.11;

import "./ERC223BasicReceiver.sol";


contract ERC223Receiver is ERC223BasicReceiver {
  function receiveApproval(address _owner, uint _value) public;
}