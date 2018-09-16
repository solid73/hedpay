pragma solidity ^0.4.24;

import "./ERC223Receiver.sol";
import "./IERC223.sol";
import "openzeppelin-solidity/contracts/ownership/Contactable.sol";


/**
 * @title Contract that can hold and transfer ERC-223 tokens
 */
contract Fund is ERC223Receiver, Contactable {
  IERC223 public token;
  string public fundName;

  /**
   * @dev Constructor that sets the initial contract parameters
   * @param _token ERC223 address of the ERC-223 token
   * @param _fundName string the fund name
   */
  constructor(IERC223 _token, string _fundName) public {
    require(address(_token) != address(0));
    token = _token;
    fundName = _fundName;
  }

  /**
   * @dev ERC-20 compatible function to transfer tokens
   * @param _to address the tokens recepient
   * @param _value uint amount of the tokens to be transferred
   */
  function transfer(address _to, uint _value) public onlyOwner {
    token.transfer(_to, _value);
  }

  /**
   * @dev Function to transfer tokens
   * @param _to address the tokens recepient
   * @param _value uint amount of the tokens to be transferred
   * @param _data bytes metadata
   */
  function transfer(address _to, uint _value, bytes _data) public onlyOwner {
    token.transfer(_to, _value, _data);
  }

  /**
   * @dev Function to transfer tokens from the approved `msg.sender` account
   * @param _from address the tokens owner
   * @param _to address the tokens recepient
   * @param _value uint amount of the tokens to be transferred
   * @param _data bytes metadata
   */
  function transferFrom(
    address _from, 
    address _to, 
    uint _value, 
    bytes _data
  ) 
    public
    onlyOwner
  {
    token.transferFrom(_from, _to, _value, _data);
  }

  /**
   * @dev Function to approve account to spend owned tokens
   * @param _spender address the tokens spender
   * @param _value uint amount of the tokens to be approved
   */
  function approve(address _spender, uint _value) public onlyOwner {
    token.approve(_spender, _value);
  }
}
