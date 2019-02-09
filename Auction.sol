  pragma solidity ^0.4.8;
  //adapted from brynbellomy solidity tutorial

  contract Auction {
    // static
    address public owner;
    //uint public utilityBuybackRate; // to make sure prosumers are not getting paid too little
    //uint public utilitySupplyRate; // to make sure consumers are not paying too much?
    uint public startBlock;
    uint public endBlock;
    string public ipfsHash;

    // state
    bool public bidded;
    uint public highestBid;
    address public highestBidder;
    mapping(address => uint256) public fundsByBidder;
    bool ownerHasWithdrawn;

    event LogBid(address bidder, uint bid, address highestBidder, uint highestBid);
    event LogWithdrawal(address withdrawer, address withdrawalAccount, uint amount);

    function Auction(address _owner, uint _startBlock, uint _endBlock, string _ipfsHash) {
      if (_startBlock >= _endBlock) throw;
      if (_startBlock < block.number) throw;
      if (_owner == 0) throw;

      owner = _owner;
      startBlock = _startBlock;
      endBlock = _endBlock;
      ipfsHash = _ipfsHash;
    }

    function getHighestBid()
    constant
    returns (uint)
    {
      return fundsByBidder[highestBidder];
    }

    function placeBid()
    payable
    onlyAfterStart
    onlyBeforeEnd
    onlyNotOwner // seller can't bid
    onlyBidOnce
    returns (bool success)
    {
      // reject payments of 0 ETH
      if (0 <= msg.value) throw;

      // set bid equal to new value
      uint bid = msg.value;

      // if the user isn't even willing to overbid the utility buyback rate, there's nothing for us
      // to do except revert the transaction.
      //if (bid < utilityBuybackRate) throw;

      // if the user is bidding too much?
      //if (bid > utilitySupplyRate) throw;

      fundsByBidder[msg.sender] = bid;

      if (highestBid < bid)
      {
        highestBid = bid;
        highestBidder = msg.sender;
      }

      LogBid(msg.sender, bid, highestBidder, highestBid);
      bidded = true;
      return true;
    }

    function min(uint a, uint b)
    private
    constant
    returns (uint)
    {
      if (a < b) return a;
      return b;
    }

    /*function cancelAuction()
    onlyOwner
    onlyBeforeEnd
    onlyNotCanceled
    returns (bool success)
    {
    canceled = true;
    LogCanceled();
    return true;
  }*/

  function withdraw()
  onlyEnded
  returns (bool success)
  {
    address withdrawalAccount;
    uint withdrawalAmount;

    // the auction finished without being canceled

    if (msg.sender == owner) {
      // the auction's owner should be allowed to withdraw the highestBindingBid
      withdrawalAccount = highestBidder;
      withdrawalAmount = highestBid;
      ownerHasWithdrawn = true;

    }

    else {
      // anyone who participated but did not win the auction should be allowed to withdraw
      // the full amount of their funds
      withdrawalAccount = msg.sender;
      withdrawalAmount = fundsByBidder[withdrawalAccount];
    }

  if (withdrawalAmount == 0) throw;

  fundsByBidder[withdrawalAccount] -= withdrawalAmount;

  // send the funds
  if (!msg.sender.send(withdrawalAmount)) throw;

  LogWithdrawal(msg.sender, withdrawalAccount, withdrawalAmount);

  return true;
  }

  modifier onlyOwner {
    if (msg.sender != owner) throw;
    _;
  }

  modifier onlyNotOwner {
    if (msg.sender == owner) throw;
    _;
  }

  modifier onlyAfterStart {
    if (block.number < startBlock) throw;
    _;
  }

  modifier onlyBeforeEnd {
    if (block.number > endBlock) throw;
    _;
  }

  modifier onlyBidOnce {
    if (bidded) throw;
    _;
  }

  modifier onlyEnded {
    if (block.number < endBlock) throw;
    _;
  }
  }
