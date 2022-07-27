//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract Artwork is ERC721 {
    using Strings for uint256;

    uint256 public tokenCounter;
    uint256 constant totalsupply = 3333;
    uint256 maxPerAddress; 
    uint256 private AllowlistPrice = 9 wei;
    uint256 private PublicPrice = 15 wei;

    bytes32 private MerkleRootWL; 
    bytes32 private MerkleRootAllowlist;

    bool private mintWlOpen = false; 
    bool private mintAllowlistOpen = false; 
    bool private mintPublicOpen = false; 

    address public owner;
    string baseURI;

    
    mapping(uint256 => string) private _tokenURIs;
    mapping(address => uint256) AddressesMinted;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this fucntion");
        _;
    }

    constructor(string memory name, string memory symbol) ERC721(name, symbol) {
        tokenCounter = 1;
        owner = msg.sender;
    }

    function changeAllPrice(uint256 _price) public onlyOwner {
        AllowlistPrice = _price;
    }

    function changePublicPrice(uint256 _price) public onlyOwner {
        PublicPrice = _price;
    }

    function addMerkleRootWL(bytes32 _MerkleRoot) public onlyOwner {
        MerkleRootWL = _MerkleRoot;
    }

    function addMerkleRootAllowlist(bytes32 _MerkleRoot) public onlyOwner {
        MerkleRootAllowlist = _MerkleRoot;
    }

    function setmaxPerAddress(uint256 _maxPerAddress) public onlyOwner {
        maxPerAddress = _maxPerAddress;
    }

    function checkWlMint() public view returns (bool) {
        return mintWlOpen;
    }

    function checkPublicMint() public view returns (bool) {
        return mintPublicOpen;
    }

    function checkAllowlistMint() public view returns (bool) {
        return mintAllowlistOpen;
    }

    function turnWLMint() public onlyOwner {
        if (mintWlOpen == false) {
            mintWlOpen = true;
        } else {
            mintWlOpen = false;
        }
    }

    function turnAllowlistMint() public onlyOwner {
        if (mintAllowlistOpen == false) {
            mintAllowlistOpen = true;
        } else {
            mintAllowlistOpen = false;
        }
    }

    function turnPublicMint() public onlyOwner {
        if (mintPublicOpen == false) {
            mintPublicOpen = true;
        } else {
            mintPublicOpen = false;
        }
    }

   
    function mintWl(bytes32[] calldata _merkleProof, uint256 _amount) public {
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        require(
            MerkleProof.verify(_merkleProof, MerkleRootWL, leaf),
            "You are not in whitelist"
        );

        require(mintWlOpen == true, "Wl mint didn't open");
        require(
            tokenCounter + _amount <= totalsupply,
            "You reached maxtotal supply"
        );
        require(
            AddressesMinted[msg.sender] + _amount <= maxPerAddress,
            "You have minted max per your address"
        );

        for (uint256 i; i < _amount; i++) {
            _safeMint(msg.sender, tokenCounter);
            tokenCounter++;
            AddressesMinted[msg.sender] += 1;
        }
    }

   
    function mintAllowlist(bytes32[] calldata _merkleProof, uint256 _amount)
        public
        payable
    {
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        require(
            MerkleProof.verify(_merkleProof, MerkleRootAllowlist, leaf),
            "You are not in Allowlist"
        );
        require(msg.value >= AllowlistPrice * _amount, "Not enough ETH");
        require(mintAllowlistOpen == true, "Allowlist mint did not open");
        require(
            AddressesMinted[msg.sender] + _amount <= maxPerAddress,
            "You have minted max per you address"
        );
        require(
            tokenCounter + _amount <= totalsupply,
            "You reached maxtotal supply"
        );
        for (uint256 i; i < _amount; i++) {
            _safeMint(msg.sender, tokenCounter);
            tokenCounter++;
            AddressesMinted[msg.sender] += 1;
        }
    }

    function mintPublic(uint256 _amount) public payable {
        require(msg.value >= PublicPrice * _amount, "Not enough ETH");
        require(mintPublicOpen == true, "Public mint didn't open");
        require(
            AddressesMinted[msg.sender] + _amount <= maxPerAddress,
            "You have minted max per you address"
        );
        require(
            tokenCounter + _amount <= totalsupply,
            "You reached maxtotal supply"
        );
        for (uint256 i; i < _amount; i++) {
            _safeMint(msg.sender, tokenCounter);
            tokenCounter++;
            AddressesMinted[msg.sender] += 1;
        }
    }

    function setBaseURI(string memory _set) public onlyOwner {
        baseURI = _set;
    }

    function baseurl() internal view virtual returns (string memory) {
        return baseURI;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        _requireMinted(tokenId);
        string memory url = baseurl();
        string memory f = ".json";
        return
            bytes(url).length > 0
                ? string(abi.encodePacked(url, tokenId.toString(), f))
                : "";
    }

    function withdraw() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function changeOwner(address _owner) public onlyOwner {
        owner = _owner;
    }

    function checkOwner() public view returns (address) {
        return owner;
    }

    function burn(uint256 _tokenid) public onlyOwner {
        _burn(_tokenid);
    }

    
    fallback() external payable {}

    receive() external payable {}

    function TresuareMint(uint256 _amount) public onlyOwner {
        for (uint256 i; i < _amount; i++) {
            _safeMint(owner, tokenCounter);
            tokenCounter++;
        }
    }
}
