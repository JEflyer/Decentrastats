// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

interface IStats{
    struct LIMITS {
        uint8 strengthIncrease;
        uint8 dexterityIncrease;
        uint8 constitutionIncrease;
        uint8 intelligenceIncrease;
        uint8 wisdomIncrease;
        uint8 charismaIncrease; 
    }

     struct STATS {
        uint64 strength;
        uint64 dexterity;
        uint64 constitution;
        uint64 intelligence;
        uint64 wisdom;
        uint64 charisma; 
        uint64 activeTime;
        bool active;
    }

    function setLimits(LIMITS memory _limits) external   returns(bool);

    function addGame(address _game) external   returns(bool);

    function addMinter(address _minter) external   returns(bool);

    function checkMinter(address _minter) external view returns(bool);

    //This function can be called by any one and they can only vpte once per game for a very small fee
    function voteToRemoveGame(address _game) external returns(bool);

    function instantiateStats(address minter, uint16 tokenID) external payable   returns(bool);
    function batchInstantiateStats(address[] memory minters, uint16[] memory tokenID) external   returns(bool);

    function setActiveTime(address minter, uint16 tokenId, uint8 option) external   returns(bool);

    function increaseCharisma(address minter, uint16 tokenId, uint8 amount) external   returns(bool);

    function increaseWisdom(address minter, uint16 tokenId, uint8 amount) external   returns(bool);

    function increaseIntelligence(address minter, uint16 tokenId, uint8 amount) external   returns(bool);

    function increaseConstitution(address minter, uint16 tokenId, uint8 amount) external   returns(bool);
    function increaseDexterity(address minter, uint16 tokenId, uint8 amount) external   returns(bool);

    function increaseStrength(address minter, uint16 tokenId, uint8 amount) external   returns(bool);
    function getStats(address minter, uint16 tokenID) external view returns(STATS memory);

    function getBatchStats(address[] memory minters, uint16[] memory tokenIDs ) external view returns(STATS[] memory);

    function getStrength(address minter, uint16 tokenID) external view returns(uint64);

    function getBatchStrength(address[] memory minters, uint16[] memory tokenIDs) external view returns(uint64[] memory);

    function getDexterity(address minter, uint16 tokenID) external view returns(uint64);


    function getBatchDexterity(address[] memory minters, uint16[] memory tokenIDs) external view returns(uint64[] memory);

    function getConstitution(address minter, uint16 tokenID) external view returns(uint64);


    function getBatchConstitution(address[] memory minters, uint16[] memory tokenIDs) external view returns(uint64[] memory);

    function getIntelligience(address minter, uint16 tokenID) external view returns(uint64);
    


    function getBatchIntelligence(address[] memory minters, uint16[] memory tokenIDs) external view returns(uint64[] memory);

    function getWisdom(address minter, uint16 tokenID) external view returns(uint64);


    function getBatchWisdom(address[] memory minters, uint16[] memory tokenIDs) external view returns(uint64[] memory);

    function getCharisma(address minter, uint16 tokenID) external view returns(uint64);


    function getBatchCharisma(address[] memory minters, uint16[] memory tokenIDs) external view returns(uint64[] memory);

    function getActiveTime(address minter, uint16 tokenID) external view returns(uint64);

    function getBatchActiveTime(address[] memory minters, uint16[] memory tokenIDs) external view returns(uint64[] memory);


    function isActive(address minter, uint16 tokenID) external view returns(bool);

    function batchIsActive(address[] memory minters, uint16[] memory tokenIDs) external view returns(bool[] memory);
}