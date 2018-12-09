pragma solidity ^0.5.0;
import "./SafeMath.sol";

contract Market{
  using SafeMath for uint256;

  //storage
  address owner;
  address operator;
  uint256[] internal allTokens; //maintain _tokenIds of all tokens
  mapping(uint256 => uint256) tokensSupply; //maintains total supply of each token tokenId=>supply
  mapping(address => mapping(uint256 => uint256)) packedTokenBalances; // userAddr => tokens:balance
      

  
  constructor() public{
    owner = msg.sender;
    operator = msg.sender; //only operator will be able to add new tokens to the mix
  }
  
  modifier onlyOwnerOperator() {
    require(msg.sender == operator || msg.sender == owner, "Only the Owner or Operator can call this function");
    _;
  }

  function updateOperator(address _newOperator) public onlyOwnerOperator() {
    operator = _newOperator;
  }

  // ------ TOKEN MANAGEMENT ----- \\

  function totalSupply() public view returns (uint256) {
    return allTokens.length;
  } //Returns the amount of types of tokens, not the amount of those tokens that exist
  function tokenSupply(uint256 tokenId) public view returns (uint256) { 
    return tokensSupply[tokenId];
  } // Returns the amount of a given token in circulation

  /**
    *  @dev Gets the number of tokens owned by the address we are checking
    *  @param _owner The adddress we are checking
    *  @return balance The unique amount of tokens owned
    */
  function balanceOf(address _owner) public view returns (uint256 balance) {
    (,uint256[] memory tokens) = tokensOwned(_owner);
    return tokens.length;
  }
  
  function balanceOf(address owner, uint256 tokenId) public view returns (uint256){
    return(packedTokenBalances[owner][tokenId]);
  }

  function tokensOwned(address owner) public view returns (uint256[] memory indexes, uint256[] memory balances){
    uint256 numTokens = totalSupply();
    uint256[] memory tokenIndexes = new uint256[](numTokens);
    uint256[] memory tempTokens = new uint256[](numTokens);
  
    // Gets a list of all token balances, 0 values for tokens that user doesn't own
    uint256 count = 0;
    for (uint256 i = 0; i < numTokens; i++) {
      uint256 tokenId = allTokens[i];
      if (balanceOf(owner, tokenId) > 0) {
        tempTokens[count] = balanceOf(owner, tokenId);
        tokenIndexes[count] = tokenId;
        count++;
      }
    }

    // copy over the data to a correct size array by removing tokens with 0 values
    uint256[] memory _ownedTokens = new uint256[](count);
    uint256[] memory _ownedTokensIndexes = new uint256[](count);

    for (uint i = 0; i < count; i++) {
      _ownedTokens[i] = tempTokens[i];
      _ownedTokensIndexes[i] = tokenIndexes[i];
    }

    return (_ownedTokensIndexes, _ownedTokens);        
  }

  function transfer(address to, uint256 tokenId, uint256 quantity) public{
    transferFrom(msg.sender,to,tokenId,quantity);
  }
  function transferFrom(address from, address to, uint256 tokenId, uint256 quantity) public{
    require(to != address(0), "Invalid to address");
    require(balanceOf(from, tokenId) >= quantity, "Insufficent Quantity of Tokens to Transfer");

    //Reduce balance of sender
    packedTokenBalances[from][tokenId] = packedTokenBalances[from][tokenId].sub(quantity); //Use safemath SUB function
    packedTokenBalances[to][tokenId] = packedTokenBalances[to][tokenId].add(quantity);   //Use safemath ADD function

    emit Transfer(from, to, tokenId, quantity); //emits a Transfer Event      
  }

  //used to register a new TokenId fwithout printing any copies of it
  function getNewTokenId() public onlyOwnerOperator() returns(uint256){
    uint256 newID = allTokens.length;
    allTokens.push(newID);
    return newID;
  }

  function mintToken(address _reciever, uint256 _tokenId, uint256 _quantity) public onlyOwnerOperator() {
    //TokensSupply (tokenId => globalSupplyToken)
    tokensSupply[_tokenId] = tokensSupply[_tokenId].add(_quantity);
    //PackedTokenBalances  (user => (tokenId=>balance))
    packedTokenBalances[_reciever][_tokenId] = packedTokenBalances[_reciever][_tokenId].add(_quantity);

    emit TokensMinted(_reciever, _tokenId, _quantity);
  }

  function consumeToken(address _user, uint256 _tokenId, uint256 _quantity) public onlyOwnerOperator() {
    //TokensSupply (tokenId => globalSupplyToken)
    tokensSupply[_tokenId] = tokensSupply[_tokenId].sub(_quantity);
    //PackedTokenBalances  (user => (tokenId=>balance))
    packedTokenBalances[_user][_tokenId] = packedTokenBalances[_user][_tokenId].sub(_quantity);
    emit TokensConsumed(_user, _tokenId, _quantity);
  }

  // Required Events
  event TokensMinted(address indexed _reciever, uint256 indexed _tokenId, uint256 _quantity);
  event TokensConsumed(address indexed _user, uint256 indexed _tokenId, uint256 _quantity);
  event Transfer(address indexed from, address indexed to, uint256 indexed tokenId, uint256 quantity);
}
