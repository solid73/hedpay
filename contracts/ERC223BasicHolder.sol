pragma solidity ^0.4.24;

import "./ERC223BasicReceiver.sol";


/**
 * @title Basic contract that will hold ERC223 tokens
 */
contract ERC223BasicHolder is ERC223BasicReceiver {
  event TokensReceived(address sender, address origin, uint value, bytes data);
  
  /**
   * @dev Standard ERC223 function that will handle incoming token transfers
   * @param _from address the tokens owner
   * @param _value uint the sent tokens amount
   * @param _data bytes metadata
   */
  function tokenFallback(address _from, uint _value, bytes _data) public {
    require(_from != address(0));
    emit TokensReceived(msg.sender, _from, _value, _data);
  }
}
