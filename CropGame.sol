pragma solidity ^0.5.0;
import "./Market.sol";
import "./SafeMath.sol";

contract CropGame{
  // META
  address owner;
  Market market;

  //structs
  // TODO: add rarity systems for different types of land
  //enum PlotType {Midwest, Asian, African} //different types of seed require different types of land

  /**
    @param _type determines what kinds of seeds can grow on this land
      1:Midwest, 2:Asian, 3:African
    @param _fertility determines the bonus to harvest amount 
  */
  struct PlotToken {
    uint256 _type;
    uint256 _fertility; 
  }
  // tokenIds to Plot Token types. Non sequential as tokenIds are UUIDs shared amonst ALL tokens (used for Market.sol)
  mapping(uint256 => PlotToken) plotTokenIds;

  /**
    @dev Planted Plot consumes a Plot Token and a Seed Token. Can be harvested after the given time has passed. After harvesting, returns Plot Token and whatever Seed's harvest stuff is
    @param plotTokenId is the TokenId for what type of plot this is
    @param seedTokenId is the TokenId for what type of seed this is
   */

  struct PlantedPlot {
    uint256 plotTokenId;
    uint256 seedTokenId;
    uint256 harvestBlock;
  }
  //Maps User to the list of current planted plots they own
  mapping(address => PlantedPlot[]) plantedPlots; 

  struct Seed {
      string name;
      uint256 seedTokenId;
      uint256 readyTime; 
      uint cooldownTime; //cooldownTime for seedTokenId
  }
  
  struct Crop {
      string name;
      uint256 cropTokenId;
      uint256 seedTokenId;
      uint256 readyTime;
      uint cooldownTime; //cooldownTime for cropTokenId
  }
  struct Food {
      string name;
      uint256 foodTokenId;
      uint256 cropTokenId;
      
  }

  modifier onlyOwner() {
    require(msg.sender == owner, "Only the owner may call this function");
    _;
  }   

  // Takes in the current 
  constructor(Market _marketContract) public{
    owner = msg.sender;
    market = _marketContract;
    // Make sure to update the operator for the data contract to this contract. 
  }

  // Allow Owner of this contract to create new types of cards DOES NOT PRINT ANY COPIES OF THE CARD
  function newPlotToken(uint256 _plotType, uint256 _plotFertility) public onlyOwner() {
    PlotToken memory plot = PlotToken({
      _type : _plotType,
      _fertility : _plotFertility
    });

    uint256 newId = market.getNewTokenId();
    plotTokenIds[newId] = plot;
  }

  function mint(address to, uint256 tokenId) public onlyMinter returns (bool) {
        _mint(to, tokenId);
        return true;
  }
  /**
  @dev Anyone can plant a seed on a plot. This will check to make sure they have a plot and seed of the given type available and consume them
  @param plotId
  @param seedId 
  */
  function plantSeed(uint256 _plotId, uint256 _seedId) public {
    market.consumeToken(msg.sender, _plotId, 1); //will autocheck that the user has 
    market.consumeToken(msg.sender, _seedId, 1); 
  }
    
    //TODO: Create new PlotedLand object with harvest time based on Seed
    function createPlotedLand(uint256 _plotId) public {
        harvestTime=45 minutes;
    }
  

  //TODO: Function HARVEST 
  function harvest(uint256 _cropTokenId, uint256 _plotTokenId) public {
      market.consumeToken(msg.sender, _cropTokenId, 1);
  }
}
