//SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;



import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BabySwaggos is ERC721Enumerable, Ownable {
  using Strings for uint256;

  string baseURI;
  string public baseExtension = ".json";
  uint256 public cost = 0;
  uint256 public maxSupply = 500;
  uint256 public maxMintAmount = 1;
  bool public paused = false;
  bool public revealed = true;
  string public notRevealedUri;
  uint256[] public rand;
  address public ClassicSwaggosContract;


  mapping(uint256 => bool) IDstatus;
  


  constructor(
    string memory _name,
    string memory _symbol,
    string memory _initBaseURI,
    address _contract
  ) ERC721(_name, _symbol) {
    ClassicSwaggosContract = _contract;
    setBaseURI(_initBaseURI);
    
  }

  // internal
  function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
  }

  // public
  function mint(uint256 _mintQuantity, uint ID1, uint ID2, uint ID3, uint ID4, uint ID5) public payable {
    uint256 supply = totalSupply();
    require(!paused);
    require(_mintQuantity > 0);
    require(_mintQuantity <= maxMintAmount);
    require(supply + _mintQuantity <= maxSupply);

    //BabySwaggos Minting Protocol Implementation Start

    require(IERC721(ClassicSwaggosContract).ownerOf(ID1) == msg.sender);
    require(IERC721(ClassicSwaggosContract).ownerOf(ID2) == msg.sender);
    require(IERC721(ClassicSwaggosContract).ownerOf(ID3) == msg.sender);
    require(IERC721(ClassicSwaggosContract).ownerOf(ID4) == msg.sender);
    require(IERC721(ClassicSwaggosContract).ownerOf(ID5) == msg.sender);

    require(IDstatus[ID1] == false);
    require(IDstatus[ID2] == false);
    require(IDstatus[ID3] == false);
    require(IDstatus[ID4] == false);
    require(IDstatus[ID5] == false);

    IDstatus[ID1] = true;
    IDstatus[ID2] = true;
    IDstatus[ID3] = true;
    IDstatus[ID4] = true;
    IDstatus[ID5] = true;

    //BabySwaggos Minting Protocol Implementation End


    if (msg.sender != owner()) {
      require(msg.value >= cost * _mintQuantity);
    }

    for (uint256 i = 1; i <= _mintQuantity; i++) {
      uint256 randomNumber  = _generateRandom(supply + i);
      rand.push(randomNumber);
      _safeMint(msg.sender, randomNumber);
    }
  }

  function walletOfOwner(address _owner)
    public
    view
    returns (uint256[] memory)
  {
    uint256 ownerTokenCount = balanceOf(_owner);
    uint256[] memory tokenIds = new uint256[](ownerTokenCount);
    for (uint256 i; i < ownerTokenCount; i++) {
      tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
    }
    return tokenIds;
  }

  function tokenURI(uint256 tokenId)
    public
    view
    virtual
    override
    returns (string memory)
  {
    require(
      _exists(tokenId),
      "ERC721Metadata: URI query for nonexistent token"
    );
    
    if(revealed == false) {
        return notRevealedUri;
    }

    string memory currentBaseURI = _baseURI();
    return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension))
        : "";
  }

  //only owner
  function reveal() public onlyOwner() {
      revealed = true;
  }
  
  function setCost(uint256 _newCost) public onlyOwner() {
    cost = _newCost;
  }

  function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner() {
    maxMintAmount = _newmaxMintAmount;
  }
  
  function setNotRevealedURI(string memory _notRevealedURI) public onlyOwner {
    notRevealedUri = _notRevealedURI;
  }

  function setBaseURI(string memory _newBaseURI) public onlyOwner {
    baseURI = _newBaseURI;
  }

  function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
    baseExtension = _newBaseExtension;
  }

  function pause(bool _state) public onlyOwner {
    paused = _state;
  }
 
  function withdraw() public payable onlyOwner {
    (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
    require(success);
  }


  function transferContract(address newOwner) public onlyOwner{
    transferOwnership(newOwner);
  }

  function _generateRandom(uint256 id) private view returns (uint256)
  {
       uint256 random;
        
      random = uint256(keccak256
        (abi.encodePacked(id, block.timestamp, msg.sender))) 
        % maxSupply;

        return random;

  }
  
}

