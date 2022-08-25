pragma solidity 0.8.15;

import "./interfaces/IStats.sol";

contract TestGAME {

    IStats private stats;

    constructor(address _stats){
        stats = IStats(_stats);
    }

    function testInstantiateStats(uint16 tokenID, address minter) external {
        require(stats.instantiateStats(minter, tokenID),"ERR:IS");//IS => Instantiating Stats
    }

    function testInstantiateStats(uint16[] memory tokenIDs, address[] memory minters) external {
        require(stats.batchInstantiateStats(minters,tokenIDs),"ERR:IS");//IS => Instantiating Stats
    }

    function testSetActiveTime(address minter, uint16 tokenID, uint8 option ) external {
        require(stats.setActiveTime(minter,tokenID,option),"ERR:SA");//SA => Setting Active
    }

    function testIncreaseCharisma(address minter, uint16 tokenId, uint8 amount) external {
        require(stats.increaseCharisma(minter, tokenId, amount),"ERR:IC");//IC => Increasing Charisma
    }

    function testIncreaseWisdom(address minter, uint16 tokenID, uint8 amount) external {
        require(stats.increaseWisdom(minter,tokenID, amount),"ERR:IW");//IW => Increasing Wisdom
    }

    function testIncreaseIntelligence(address minter, uint16 tokenID, uint8 amount) external {
        require(stats.increaseIntelligence(minter,tokenID,amount),"ERR:II");//II => Increasing Intelligence
    }

    function testIncreaseConstitution(address minter, uint16 tokenID, uint8 amount) external {
        require(stats.increaseConstitution(minter, tokenID, amount),"ERR:IC");//IC => Increasing Constitution
    }   

    function testIncreaseDexterity(address minter, uint16 tokenID, uint8 amount) external {
        require(stats.increaseDexterity(minter, tokenID, amount),"ERR:ID");//ID => Increasing Dexterity
    }

    function testIncreaseStrength(address minter, uint16 tokenID, uint8 amount) external {
        require(stats.increaseStrength(minter, tokenID, amount),"ERR:IS");//IS => Increasing Strength
    }

}