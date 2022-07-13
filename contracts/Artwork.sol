//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract Artwork is ERC721 {
    using Strings for uint256;
    uint256 public tokenCounter = 1;
    bool mintWlOpen = false;
    bool mintPublicOpen = false;
    address owner;
    string baseURI;
    uint256 maxPerWlAddress;
    mapping(uint256 => string) private _tokenURIs;
    mapping(address => bool) inWlAddresses;
    mapping(address => uint256) inWlAddressesMinted;
    mapping(address => uint256) AddressesMinted;
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    constructor(string memory name, string memory symbol) ERC721(name, symbol) {
        tokenCounter = 1;
        owner = msg.sender;
    }

    function addWlAdresses(address[] memory _wl) public onlyOwner {
        address a;
        for (uint256 i; i < _wl.length; i++) {
            a = _wl[i];
            inWlAddresses[a] = true;
        }
    }

    function setMaxPerWLAddress(uint256 _c) public onlyOwner {
        maxPerWlAddress = _c;
    }

    function checkWlMint() public view returns (bool) {
        return mintWlOpen;
    }

    function checkPublicMint() public view returns (bool) {
        return mintPublicOpen;
    }

    function openWLMint() public onlyOwner {
        mintWlOpen = true;
    }

    function openPublicMint() public onlyOwner {
        mintPublicOpen = true;
    }

    function mintPublic(uint256 _amount) public {
        require(mintPublicOpen == true, "Public mint did not open");
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

    function mintWl(uint256 _amount) public {
        require(mintWlOpen == true, "didnot open");
        require(inWlAddresses[msg.sender] == true, "You are not in wl list");
        require(
            inWlAddressesMinted[msg.sender] + _amount <= maxPerWlAddress,
            "You have minted max per you address"
        );

        for (uint256 i; i < _amount; i++) {
            _safeMint(msg.sender, tokenCounter);
            tokenCounter++;
            inWlAddressesMinted[msg.sender] += 1;
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
}
