// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PixellationsDev is ERC721, Ownable {
    uint256 public constant _PRICE = 20000000000000000; // 0.02 ETH
    uint256 public _TOTALSUPPLY = 1024;

    uint256 private tokenCount;
    string[] private opacity = [
        "0.2",
        "0.2",
        "0.2",
        "0.2",
        "0.4",
        "0.4",
        "0.4",
        "0.8",
        "0.8",
        "1"
    ];
    uint256[] private smallStarOptions = [32, 40, 48, 56, 64];
    uint256 private redChance = 9995;
    uint256 private purpleChance = 9980;
    uint256 private blueChance = 9950;
    uint256 private yellowChance = 9900;

    struct Metadata {
        uint256 redStars;
        uint256 purpleStars;
        uint256 blueStars;
        uint256 yellowStars;
        uint256 bigStars;
        uint256 smallStars;
    }

    constructor() ERC721("PixellationsBeta", "PXL") {
        tokenCount = 1;
    }

    function safeMint(address to) public onlyOwner {
        _safeMint(to, tokenCount);
        string memory formattedTokenURI = formatTokenURI();
        _setTokenURI(tokenCount, formattedTokenURI);
        tokenCount++;
    }

    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId) internal override(ERC721) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function random(
        uint256 input,
        uint256 min,
        uint256 max
    ) public view returns (uint256) {
        uint256 range = max - min;
        return
            max -
            (uint256(
                keccak256(
                    abi.encodePacked(
                        input,
                        msg.sender,
                        tokenCount,
                        block.timestamp
                    )
                )
            ) % range) -
            1;
    }

    function getColor(uint256 starNumber)
        internal
        view
        returns (string memory)
    {
        uint256 roll = random(starNumber, 0, 10001);

        if (roll > redChance) {
            return "#FF8D8D";
        } else if (roll > purpleChance) {
            return "#D7A4FF";
        } else if (roll > blueChance) {
            return "#7DD0FF";
        } else if (roll > yellowChance) {
            return "#FFE790";
        } else {
            return "#FFF";
        }
    }

    function mint(uint256 quantity) public payable {
        require(quantity <= 3, "Mint 3 or less NFTs at a time");
        //require(msg.value >= quantity * 20000000000000000, "Not enough ETH sent");
        for (uint256 i = 0; i < quantity; i++) {
            safeMint(msg.sender);
        }
    }

    // function makeSmallStar() internal view returns ()

    function formatTokenURI() public view returns (string memory) {
        string
            memory svg = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMidYMid meet" viewBox="0 0 64 64" fill="#000"><rect x="0" y="0" width="64" height="64" fill="#000"></rect>';

        //uint256 smallStarCount = smallStarOptions[random(tokenCount, 0, 4)];
        //uint256 bigStarCount = random(tokenCount, 2, 7);

        Metadata memory metadata = Metadata(
            0,
            0,
            0,
            0,
            random(tokenCount, 2, 7),
            smallStarOptions[random(tokenCount, 0, 4)]
        );

        uint256 bigStarRefX = random(tokenCount * metadata.bigStars, 0, 17) * 2;
        uint256 bigStarRefY = random(tokenCount * metadata.smallStars, 0, 17) *
            2;
        uint256 bigStarMaxX = bigStarRefX + 31;
        uint256 bigStarMaxY = bigStarRefY + 31;

        //uint256[6] memory starCounts = [
        //    0, 0, 0, 0, bigStarCount, smallStarCount
        //];

        // array values: 0 = red, 1 = purple, 2 = blue, 3 = yellow, 4 = bigStars, 5 = smallStars

        for (uint256 i = 0; i < metadata.bigStars; i++) {
            svg = string(
                abi.encodePacked(
                    svg,
                    '<rect x="',
                    uint2str(
                        random((tokenCount + i), bigStarRefX, bigStarMaxX)
                    ),
                    '" y="',
                    uint2str(
                        random((tokenCount + i * 2), bigStarRefY, bigStarMaxY)
                    ),
                    '" width="2" height="2" fill="#FFF"></rect>'
                )
            );
        }

        for (uint256 i = 0; i < metadata.smallStars; i++) {
            uint256 colorComparison = random(i, 0, 10001);
            string memory currentOpacity;

            if (colorComparison > redChance) {
                metadata.redStars = metadata.redStars + 1;
                currentOpacity = "1";
            } else if (colorComparison > purpleChance) {
                metadata.purpleStars = metadata.purpleStars + 1;
                currentOpacity = "1";
            } else if (colorComparison > blueChance) {
                metadata.blueStars = metadata.blueStars + 1;
                currentOpacity = "1";
            } else if (colorComparison > yellowChance) {
                metadata.yellowStars = metadata.yellowStars + 1;
                currentOpacity = "1";
            } else {
                currentOpacity = opacity[random(i, 0, 10)];
            }

            svg = string(
                abi.encodePacked(
                    svg,
                    '<rect x="',
                    uint2str(random((i), 0, 64)),
                    '" y="',
                    uint2str(random((tokenCount + i), 0, 64)),
                    '" width="1" height="1" fill="',
                    getColor(i),
                    '" opacity="',
                    currentOpacity,
                    '"></rect>'
                )
            );
        }

        svg = string(abi.encodePacked(svg, "</svg>"));

        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    encode(
                        bytes(
                            abi.encodePacked(
                                '{"name": "Pixellation #',
                                uint2str(tokenCount),
                                '",',
                                '"description": "The first Pixellations contract",',
                                '"attributes": [',
                                "{",
                                '"trait_type": "Big Stars",',
                                '"value": "',
                                uint2str(metadata.bigStars),
                                '"'
                                "},",
                                "{",
                                '"trait_type": "Small Stars",',
                                '"value": "',
                                uint2str(metadata.smallStars),
                                '"'
                                "},",
                                "{",
                                '"trait_type": "Red Stars",',
                                '"value": "',
                                uint2str(metadata.redStars),
                                '"'
                                "},",
                                "{",
                                '"trait_type": "Purple Stars",',
                                '"value": "',
                                uint2str(metadata.purpleStars),
                                '"'
                                "},",
                                "{",
                                '"trait_type": "Blue Stars",',
                                '"value": "',
                                uint2str(metadata.blueStars),
                                '"'
                                "},",
                                "{",
                                '"trait_type": "Yellow Stars",',
                                '"value": "',
                                uint2str(metadata.yellowStars),
                                '"'
                                "}",
                                "],",
                                '"image": "data:image/svg+xml;base64,',
                                encode(bytes(string(abi.encodePacked(svg)))),
                                '"}'
                            )
                        )
                    )
                )
            );
    }

    // From https://stackoverflow.com/questions/47129173/how-to-convert-uint-to-string-in-solidity
    function uint2str(uint256 _i)
        internal
        pure
        returns (string memory _uintAsString)
    {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(_i - (_i / 10) * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }

    // by Brecht Devos- provides a function for encoding some bytes in base64
    string internal constant TABLE =
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    function encode(bytes memory data) internal pure returns (string memory) {
        if (data.length == 0) return "";

        // load the table into memory
        string memory table = TABLE;

        // multiply by 4/3 rounded up
        uint256 encodedLen = 4 * ((data.length + 2) / 3);

        // add some extra buffer at the end required for the writing
        string memory result = new string(encodedLen + 32);

        assembly {
            // set the actual output length
            mstore(result, encodedLen)

            // prepare the lookup table
            let tablePtr := add(table, 1)

            // input ptr
            let dataPtr := data
            let endPtr := add(dataPtr, mload(data))

            // result ptr, jump over length
            let resultPtr := add(result, 32)

            // run over the input, 3 bytes at a time
            for {

            } lt(dataPtr, endPtr) {

            } {
                dataPtr := add(dataPtr, 3)

                // read 3 bytes
                let input := mload(dataPtr)

                // write 4 characters
                mstore(
                    resultPtr,
                    shl(248, mload(add(tablePtr, and(shr(18, input), 0x3F))))
                )
                resultPtr := add(resultPtr, 1)
                mstore(
                    resultPtr,
                    shl(248, mload(add(tablePtr, and(shr(12, input), 0x3F))))
                )
                resultPtr := add(resultPtr, 1)
                mstore(
                    resultPtr,
                    shl(248, mload(add(tablePtr, and(shr(6, input), 0x3F))))
                )
                resultPtr := add(resultPtr, 1)
                mstore(
                    resultPtr,
                    shl(248, mload(add(tablePtr, and(input, 0x3F))))
                )
                resultPtr := add(resultPtr, 1)
            }

            // padding with '='
            switch mod(mload(data), 3)
            case 1 {
                mstore(sub(resultPtr, 2), shl(240, 0x3d3d))
            }
            case 2 {
                mstore(sub(resultPtr, 1), shl(248, 0x3d))
            }
        }

        return result;
    }
}
