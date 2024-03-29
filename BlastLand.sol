// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC424.sol";
import "./ERC424Mirror.sol";
import "./Base64.sol";

import {Ownable} from "./Ownable.sol";
import {LibString} from "./LibString.sol";
import {SafeTransferLib} from "./SafeTransferLib.sol";

contract BlastLand is DN404, Ownable {
    using LibString for uint256;
    string private _name = "BlastLand";
    string private _symbol = "BlastLand";
    uint256 public constant LandMaxSupply = 576 * 576 ; 
    uint256 public constant TokenMaxSupply = 576 * 576 * 10 ** 18; 

    address public allowedBlastLandDistributor = 0x43f602eA11EfCa691F165e2B41B9D9771207A292;

    
    constructor() {
        _initializeOwner(msg.sender);
        address mirror = address(new DN404Mirror(msg.sender));
        _initializeDN404(576 * 576 * 10 ** 18, msg.sender, mirror);
        
    }

    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() public view override returns (string memory) {
        return _symbol;
    }

   
    function withdraw() public onlyOwner {
        SafeTransferLib.safeTransferAllETH(msg.sender);
    }

    function setSkipBlastLandDistributor(address BlastLandDistributor, bool skip) public {
        require(msg.sender == allowedBlastLandDistributor, "Caller is not the allowed BlastLandDistributor");
        _setSkipNFT(BlastLandDistributor, skip);
    }

    function setAllowedBlastLandDistributor(address _newDistributor) public onlyOwner {
        require(_newDistributor != address(0), "Invalid address");
        allowedBlastLandDistributor = _newDistributor;
    }


    function LandIDformXY(uint256 tokenId) public pure returns (uint256 x, uint256 y) {
        require(tokenId >= 1 && tokenId <= LandMaxSupply, "Land ID goes beyond borders");

        tokenId--;
        x = (tokenId % 576) + 1;
        y = (tokenId / 576) + 1;
    }

    function XYformLandID(uint256 x, uint256 y) public pure returns (uint256 tokenId) {
        require(x >= 1 && x <= 576, "X coordinate is out of bounds");
        require(y >= 1 && y <= 576, "Y coordinate is out of bounds");

        tokenId = ((y - 1) * 576 + (x - 1)) + 1;
    }

    function generateSVGImage(uint256 x, uint256 y) internal pure returns (string memory) {
        string memory jsonContent = string(abi.encodePacked(
            '{"p":"erc-424","tick":"land","x":"', x.toString(), '","y":"', y.toString(), '"}'
        ));

        return string(abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMidYMid meet" viewBox="0 0 400 400">',
            '<style>.base { fill: white; font-family: Sans-serif; font-size: 14px; text-anchor: middle; }</style>',
            '<rect width="100%" height="100%" fill="#FA951C" />',
            '<text x="200" y="200" class="base">', jsonContent, '</text></svg>'
        ));
    }

     function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(tokenId >= 1 && tokenId <= LandMaxSupply, "Land ID goes beyond borders");

        (uint256 x, uint256 y) = LandIDformXY(tokenId);
        string memory svgImage = generateSVGImage(x, y);
        string memory base64EncodedImage = Base64.encode(bytes(svgImage));

        string memory json = string(abi.encodePacked(
            '{"name": "Blast Land #',
            tokenId.toString(),
            '", "description": "The unique magical land in Blast Land, built on the ERC-424 protocol.", "image": "data:image/svg+xml;base64,',
            base64EncodedImage,
            '", "attributes":[{"trait_type":"X","value":"',
            x.toString(),
            '"}, {"trait_type":"Y","value":"',
            y.toString(),
            '"}, {"trait_type":"tick","value":"land"}], "external_url": "https://blastLand.pro"}'
        ));

        return string(abi.encodePacked("data:application/json;utf8,", json));
    }


}
