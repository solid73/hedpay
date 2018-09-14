pragma solidity ^0.4.11;

import "./ERC223BasicReceiver.sol";


/**
* @title Contract that will work with ERC223 tokens.
*/
contract ERC223Receiver is ERC223ReceivingContract { 
  function receiveApproval(address _owner, uint _value) public;
}