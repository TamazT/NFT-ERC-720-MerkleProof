//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.7;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract Artwork is ERC721 {
    using Strings for uint256;

    uint256 public tokenCounter = 1;
    uint256 totalsupply = 3333;
    uint256 maxPerWlAddress;
    uint256 AllowlistPrice = 9 wei;
    uint256 PublicPrice = 15 wei;

    bool mintWlOpen = false;
    bool mintAllowlistOpen = false;
    bool mintPublicOpen = false;

    address owner;
    string baseURI;

    //all mappings
    mapping(uint256 => string) private _tokenURIs;
    mapping(address => bool) inWlAddresses;
    mapping(address => bool) inAllowlistAddresses;
    mapping(address => uint256) AddressesMinted;
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this fucntion");
        _;
    }

    constructor(string memory name, string memory symbol) ERC721(name, symbol) {
        tokenCounter = 1;
        owner = msg.sender;
    }

    function look() public view returns (uint256) {
        return AddressesMinted[msg.sender];
    }

    //Fucntion to add wll adresses who alligbl to mint Fre
    function addWlAdresses(address[] memory _wl) public onlyOwner {
        address a;
        for (uint256 i; i < _wl.length; i++) {
            a = _wl[i];
            inWlAddresses[a] = true;
        }
    }

    function addAllowlistAdresses(address[] memory _wl) public onlyOwner {
        address a;
        for (uint256 i; i < _wl.length; i++) {
            a = _wl[i];
            inAllowlistAddresses[a] = true;
        }
    }

    function setMaxPerWLAddress(uint256 _c) public onlyOwner {
        maxPerWlAddress = _c;
    }

    //chech and open phases of mint
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

    //Minting fucntion for different phases
    function mintWl(uint256 _amount) public {
        require(mintWlOpen == true, "Wl mint didnot open");
        require(inWlAddresses[msg.sender] == true, "You are not in wl list");
        require(
            tokenCounter + _amount < totalsupply,
            "You reached maxtotal supply"
        );
        require(
            AddressesMinted[msg.sender] + _amount <= maxPerWlAddress,
            "You have minted max per you address"
        );

        for (uint256 i; i < _amount; i++) {
            _safeMint(msg.sender, tokenCounter);
            tokenCounter++;
            AddressesMinted[msg.sender] += 1;
        }
    }

    function mintAllowlist(uint256 _amount) public payable {
        require(msg.value >= AllowlistPrice * _amount, "Not enough ETH");
        require(mintAllowlistOpen == true, "Allowlist mint did not open");
        require(
            AddressesMinted[msg.sender] + _amount <= maxPerWlAddress,
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
        require(mintPublicOpen == true, "Public mint did not open");
        require(
            AddressesMinted[msg.sender] + _amount <= maxPerWlAddress,
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

    function TresuareMint(uint256 _amount) public onlyOwner {
        for (uint256 i; i < _amount; i++) {
            _safeMint(owner, tokenCounter);
            tokenCounter++;
        }
    }
}



