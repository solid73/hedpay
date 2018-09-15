pragma solidity ^0.4.24;

import "./ERC223Receiver.sol";
import "./ERC223BasicHolder.sol";

/**
 * @title Contract that will hold ERC223 tokens
 */
contract ERC223Holder is ERC223BasicHolder, ERC223Receiver {
  event ApprovalReceived(address sender, address owner, uint value);

  /**
   * @dev Function that will handle incoming token approvals
   * @param _owner address the tokens owner
   * @param _value uint the approved tokens amount
   */
  function receiveApproval(address _owner, uint _value) public {
    require(_owner != address(0));
    emit ApprovalReceived(msg.sender, _owner, _value);
  }
}
