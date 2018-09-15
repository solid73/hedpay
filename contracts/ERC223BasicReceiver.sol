pragma solidity ^0.4.11;


contract ERC223BasicReceiver {
  function tokenFallback(address _from, uint _value, bytes _data) public;
}