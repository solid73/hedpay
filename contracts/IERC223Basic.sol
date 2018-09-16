pragma solidity ^0.4.11;


contract IERC223Basic {
  function balanceOf(address _owner) public constant returns (uint);
  function transfer(address _to, uint _value) public;
  function transfer(address _to, uint _value, bytes _data) public;
  event Transfer(
    address indexed from, 
    address indexed to, 
    uint value, 
    bytes data
  );
}
