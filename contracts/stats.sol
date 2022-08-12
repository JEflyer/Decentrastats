// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

// Import this file to use console.log
import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "@openzeppelin/contracts/utils/Context.sol";

import "./interfaces/IGame.sol";

contract Stats is Context{

    address private DAO;

    address private deployer;

    mapping(address => bool) private isAllowedGame;
    mapping(address => bool) private isMinter;

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

    //minter => tokenID => stats
    mapping(address => mapping(uint16 => STATS)) private stats;

    struct LIMITS {
        uint8 strengthIncrease;
        uint8 dexterityIncrease;
        uint8 constitutionIncrease;
        uint8 intelligenceIncrease;
        uint8 wisdomIncrease;
        uint8 charismaIncrease; 
    }

    LIMITS private limits;

    IERC20 private token;

    uint256 private priceToInstantiate;
    uint256 private priceToUpgrade;

    enum Time {
        oneHour,
        twoHours,
        fiveHours,
        twelveHours,
        oneDay
    }

    constructor(
        address _token,
        address _dao,
        LIMITS memory _limits
    ){
        limits = _limits;
        deployer = _msgSender();
        DAO = _dao;
        token = IERC20(_token);

        priceToInstantiate = 1 * 10 ** 17;
        priceToUpgrade = 1 * 10 ** 17;
    }

    modifier onlyDAO{
        require(_msgSender() == DAO,"ERR:ND");//ND => Not DAO
        _;
    }

    modifier onlyGame{
        require(isAllowedGame[_msgSender()],"ERR:NG");//NG => Not Game
        _;
    }

    function setLimits(LIMITS memory _limits) external onlyDAO returns(bool){
        limits = _limits;

        return true;
    }

    function addGame(address _game) external onlyDAO returns(bool){
        require(_game != address(0), "ERRZA");//Za => Zero Address

        require(!isAllowedGame[_game], "ERR:AA" );//AA => Already Approved

        isAllowedGame[_game] = true;
    
        return true;
    }

    function addMinter(address _minter) external onlyGame returns(bool){
        require(!isMinter[_minter],"ERR:AM");//AM => Already Minter

        require(_minter != address(0), "ERR:NA");//NA => Null Address

        isMinter[_minter] = true;

        return true;
    }

    function checkMinter(address _minter) external view returns(bool){
        return isMinter[_minter];
    }

    
    // enum Time {
    //     oneHour,
    //     twoHours,
    //     fiveHours,
    //     twelveHours,
    //     oneDay
    // }

    function getSeconds(uint8 option) internal pure returns(uint64){
        if(option == 0){
            return 60 * 60;
        }else if(option == 1){
            return 2 * 60 * 60;
        }else if(option == 2){
            return 5 * 60 * 60;
        }else if(option == 3){
            return 12 * 60 * 60;
        }else if(option == 4){
            return 24 * 60 * 60;
        }else{
            return 0;
        }
    }

    //This function can be called by any one and they can only vpte once per game for a very small fee
    function voteToRemoveGame(address _game) external returns(bool){

        //Get the caller address
        address caller = _msgSender();

        //Check that the game is a valid game
        require(isAllowedGame[_game], "ERR:NG");//NG => Not Game

        //Check that the caller has played this game
        require(IGame(_game).checkIfPlayer(caller), "ERR:NP");//NP => Not Player

        //Check that the caller has not already voted to remove game

        //Vote

        //If total players who have played game < 10% of all players then vote count must be > 5% of all players

        //Else vote count > 40% of total players who have played game 

    }

    function instantiateStats(address minter, uint16 tokenID) external payable onlyGame returns(bool){

        //Check tokenID != 0
        require(tokenID != 0, "ERR:ZT");//ZT => Zero Token
        
        //Check that the minter is an allowed minter
        require(isMinter[minter],"ERR:NM");//NM => Not Minter

        //Get the caller of the function
        address caller = _msgSender();

        //Get the value that the game contract has approved this contract to spend
        uint256 value = token.allowance(caller,address(this));

        //Check that msg.value is equal to stats instantiating cost
        require(value >= priceToInstantiate, "ERR:WV");// WV => Wrong Value

        //Check that stats has not already been instantiated for this minter & token
        require(!stats[minter][tokenID].active,"ERR:AA");//AA => Already Active

        //Transfer the tokens here
        token.transferFrom(caller,address(this),priceToInstantiate);

        //Calc dev fee 
        uint256 fee = priceToInstantiate / 50;

        //Pay the devs
        token.transfer(deployer, fee);

        //Send funds to DAO
        token.transfer(address(DAO),priceToInstantiate - fee);        

        //Set standard stats for this minter & token ID
        stats[minter][tokenID] = STATS({
            strength:10,
            dexterity:10,
            constitution:10,
            intelligence:10,
            wisdom:10,
            charisma:10, 
            activeTime:uint64(block.timestamp),
            active:true
        });

        //Emit Event

        //Return true    
        return true;
    }

    function batchInstantiateStats(address[] memory minters, uint16[] memory tokenID) external onlyGame returns(bool){

        //Instantiate counter to be used across all for loops
        uint8 i = 0;
        uint256 length = tokenID.length;

        for(; i < length;){

            //Check that all tokenIDs != 0
            require(tokenID[i] != 0, "ERR:NI");//NI => Null ID        

            //Check that the minters are allowed minters
            require(isMinter[minters[i]], "ERR:NM");//NM => Not Minter

            //Remove safemath check
            unchecked{
                i++;
            }
        }
        
        //Reset counter
        i = 0;

        //Calculate the amount due
        uint256 amount = priceToInstantiate * length;

        //Get the address of the caller
        address caller = _msgSender();

        //Get the amount that the caller has approved for this contract to spend
        uint256 approvedAmount = token.allowance(caller, address(this));

        //Check that approved amount is greater than or equal to the instantiating cost times the number of tokens having stats instantiated
        require( approvedAmount >= amount, "ERR:AA");//AA => Approved Amount

        //Check that stats has not already been instantiated for these minters & tokens
        for(; i < length;){
            require(stats[minters[i]][tokenID[i]].strength == 0, "ERR:AS");
        }

        //Reset counter
        i = 0;

        //Bring the token to this contract
        token.transferFrom(caller,address(this),amount);

        //Calculate dev fee
        uint256 fee = amount /50;

        //Send funds to Dev
        token.transfer(deployer, fee);

        //Send funds to DAO
        token.transfer(DAO, amount - fee);

        //Set standard stats for these minters & token IDs
        for(; i < length;){
            stats[minters[i]][tokenID[i]] = STATS({
                strength:10,
                dexterity:10,
                constitution:10,
                intelligence:10,
                wisdom:10,
                charisma:10, 
                activeTime:uint64(block.timestamp),
                active:true
            });
        }

        //Emit Event

        //Return true    
        return true;

    }

    // function setActive(address minter, uint16 tokenId, bool active) external onlyGame returns(bool){

    //     //Check that the stats have been instantiated for this minter & token
    //     require(stats[minter][tokenId].strength != 0, "ERR:NS");//NS => Not Set

    //     //Set details

        
    //     //Return true
    // }

    function setActiveTime(address minter, uint16 tokenId, uint8 option) external onlyGame returns(bool){

        //Check that the stats have been instantiated for this token
        require(stats[minter][tokenId].strength != 0, "ERR:NS");//NS => Not Set

        //Check that the option is <= type(ourEnum).max
        require(option <= uint8(type(Time).max),"ERR:CO");// CO => Chosen Option

        //Increase the time that a token can be used at to the current time + the amount option determines
        stats[minter][tokenId].activeTime = uint64(block.timestamp) + getSeconds(option); 

        //Emit Event

        //Return true
        return true;

    }

    function increaseCharisma(address minter, uint16 tokenId, uint8 amount) external onlyGame returns(bool){

        //Check that the stats have been instantiated for the minter & token
        require(stats[minter][tokenId].strength != 0, "ERR:NS");//NS => Not Set

        //Check that the amount is > 0 & <= limit
        require(amount > 0 && amount <= limits.charismaIncrease, "ERR:CI");//CI => Charisma Increase

        //Set charisma
        stats[minter][tokenId].charisma += amount;

        //Emit event

        //Return true
        return true;

    }

    function increaseWisdom(address minter, uint16 tokenId, uint8 amount) external onlyGame returns(bool){
        //Check that the stats have been instantiated for the token & minter
        require(stats[minter][tokenId].strength != 0, "ERR:NS");//NS => Not Set

        //Check that the amount is > 0 & < limit
        require(amount > 0 && amount <= limits.wisdomIncrease,"ERR:WI");//WI => Wisdom Increase
        
        //Set Wisdom
        stats[minter][tokenId].wisdom += amount;

        //Emit event

        //Return true
        return true;
    }

    function increaseIntelligence(address minter, uint16 tokenId, uint8 amount) external onlyGame returns(bool){
        
        //Check that the stats have been instantiated for this minter & token 
        require(stats[minter][tokenId].strength != 0, "ERR:NS");//NS => Not Set

        //Check that the amount is > 0 & < limit
        require(amount > 0 && amount <= limits.intelligenceIncrease,"ERR:II");//II => Intelligence Increase
        
        //Set intelligence
        stats[minter][tokenId].intelligence += amount;

        //Emit event

        //Return true
        return true;
    }

    function increaseConstitution(address minter, uint16 tokenId, uint8 amount) external onlyGame returns(bool){
        
        //Check that the stats have been instantiated for this minter & token 
        require(stats[minter][tokenId].strength != 0, "ERR:NS");//NS => Not Set

        //Check that the amount is > 0 & < limit
        require(amount > 0 && amount <= limits.constitutionIncrease,"ERR:CI");//CI => Constitution Increase

        //Set Constitution
        stats[minter][tokenId].constitution += amount;

        //Emit event

        //Return true
        return true;
    }

    function increaseDexterity(address minter, uint16 tokenId, uint8 amount) external onlyGame returns(bool){
        
        //Check that the stats have been instantiated for this minter & token 
        require(stats[minter][tokenId].strength != 0, "ERR:NS");//NS => Not Set

        //Check that the amount is > 0 & < limit
        require(amount > 0 && amount <= limits.dexterityIncrease,"ERR:CI");//CI => Constitution Increase

        //Set Constitution
        stats[minter][tokenId].dexterity += amount;

        //Emit event

        //Return true
        return true;
    }

    function increaseStrength(address minter, uint16 tokenId, uint8 amount) external onlyGame returns(bool){

        //Check that the stats have been instantiated for this minter & token 
        require(stats[minter][tokenId].strength != 0, "ERR:NS");//NS => Not Set

        //Check that the amount is > 0 & < limit
        require(amount > 0 && amount <= limits.strengthIncrease,"ERR:CI");//CI => Constitution Increase

        //Set Constitution
        stats[minter][tokenId].strength += amount;

        //Emit event

        //Return true
        return true;

    }

    function getStats(address minter, uint16 tokenID) external view returns(STATS memory){

        return stats[minter][tokenID];

    }

    function getBatchStats(address[] memory minters, uint16[] memory tokenIDs ) external view returns(STATS[] memory){
        
        uint256 length = minters.length;

        //Check that the arrays are the same length
        require(length == tokenIDs.length,"ERR:WL");//WL => Wrong Length
        
        STATS[] memory _stats = new STATS[](length);

        for(uint8 i = 0; i < length;){

            _stats[i] = stats[minters[i]][tokenIDs[i]];

            unchecked {
                i++;
            }
        }
        return _stats;
    }

    function getStrength(address minter, uint16 tokenID) external view returns(uint64){
        return stats[minter][tokenID].strength;
    }

    function getBatchStrength(address[] memory minters, uint16[] memory tokenIDs) external view returns(uint64[] memory){
        
        uint256 length = minters.length;

        //Check that the arrays are the same length
        require(length == tokenIDs.length,"ERR:WL");//WL => Wrong Length

        uint64[] memory _stats = new uint64[](length);

        for(uint8 i = 0; i < length; ){

            _stats[i] = stats[minters[i]][tokenIDs[i]].strength;

            unchecked{
                i++;
            }
        }

        return _stats;
    }

    function getDexterity(address minter, uint16 tokenID) external view returns(uint64){
        return stats[minter][tokenID].dexterity;
    }


    function getBatchDexterity(address[] memory minters, uint16[] memory tokenIDs) external view returns(uint64[] memory){
        uint256 length = minters.length;

        //Check that the arrays are the same length
        require(length == tokenIDs.length,"ERR:WL");//WL => Wrong Length
        
        uint64[] memory _stats = new uint64[](length);

        for(uint8 i = 0; i < length;){

            _stats[i] = stats[minters[i]][tokenIDs[i]].dexterity;

            unchecked {
                i++;
            }
        }
        return _stats;
    }

    function getConstitution(address minter, uint16 tokenID) external view returns(uint64){
        return stats[minter][tokenID].constitution;
    }


    function getBatchConstitution(address[] memory minters, uint16[] memory tokenIDs) external view returns(uint64[] memory){
        uint256 length = minters.length;

        //Check that the arrays are the same length
        require(length == tokenIDs.length,"ERR:WL");//WL => Wrong Length
        
        uint64[] memory _stats = new uint64[](length);

        for(uint8 i = 0; i < length;){

            _stats[i] = stats[minters[i]][tokenIDs[i]].constitution;

            unchecked {
                i++;
            }
        }
        return _stats;
    }

    function getIntelligience(address minter, uint16 tokenID) external view returns(uint64){
        return stats[minter][tokenID].intelligence;

    }


    function getBatchIntelligence(address[] memory minters, uint16[] memory tokenIDs) external view returns(uint64[] memory){
        uint256 length = minters.length;

        //Check that the arrays are the same length
        require(length == tokenIDs.length,"ERR:WL");//WL => Wrong Length
        
        uint64[] memory _stats = new uint64[](length);

        for(uint8 i = 0; i < length;){

            _stats[i] = stats[minters[i]][tokenIDs[i]].intelligence;

            unchecked {
                i++;
            }
        }
        return _stats;
    }

    function getWisdom(address minter, uint16 tokenID) external view returns(uint64){
        return stats[minter][tokenID].wisdom;
    }


    function getBatchWisdom(address[] memory minters, uint16[] memory tokenIDs) external view returns(uint64[] memory){
        uint256 length = minters.length;

        //Check that the arrays are the same length
        require(length == tokenIDs.length,"ERR:WL");//WL => Wrong Length
        
        uint64[] memory _stats = new uint64[](length);

        for(uint8 i = 0; i < length;){

            _stats[i] = stats[minters[i]][tokenIDs[i]].wisdom;

            unchecked {
                i++;
            }
        }
        return _stats;
    }

    function getCharisma(address minter, uint16 tokenID) external view returns(uint64){
        return stats[minter][tokenID].charisma;
    }


    function getBatchCharisma(address[] memory minters, uint16[] memory tokenIDs) external view returns(uint64[] memory){
        uint256 length = minters.length;

        //Check that the arrays are the same length
        require(length == tokenIDs.length,"ERR:WL");//WL => Wrong Length
        
        uint64[] memory _stats = new uint64[](length);

        for(uint8 i = 0; i < length;){

            _stats[i] = stats[minters[i]][tokenIDs[i]].charisma;

            unchecked {
                i++;
            }
        }
        return _stats;
    }

    function getActiveTime(address minter, uint16 tokenID) external view returns(uint64){
        return stats[minter][tokenID].activeTime;
    }

    function getBatchActiveTime(address[] memory minters, uint16[] memory tokenIDs) external view returns(uint64[] memory){
        uint256 length = minters.length;

        //Check that the arrays are the same length
        require(length == tokenIDs.length,"ERR:WL");//WL => Wrong Length
        
        uint64[] memory _stats = new uint64[](length);

        for(uint8 i = 0; i < length;){

            _stats[i] = stats[minters[i]][tokenIDs[i]].activeTime;

            unchecked {
                i++;
            }
        }
        return _stats;
    }


    function isActive(address minter, uint16 tokenID) external view returns(bool){
        return stats[minter][tokenID].active;
    }

    function batchIsActive(address[] memory minters, uint16[] memory tokenIDs) external view returns(bool[] memory){
        uint256 length = minters.length;

        //Check that the arrays are the same length
        require(length == tokenIDs.length,"ERR:WL");//WL => Wrong Length
        
        bool[] memory _stats = new bool[](length);

        for(uint8 i = 0; i < length;){

            _stats[i] = stats[minters[i]][tokenIDs[i]].active;

            unchecked {
                i++;
            }
        }

        return _stats;
    }

    // struct STATS {
    //     uint64 strength;
    //     uint64 dexterity;
    //     uint64 constitution;
    //     uint64 intelligence;
    //     uint64 wisdom;
    //     uint64 charisma; 
    //     uint64 activeTime;
    //     bool active;
    // }




    fallback() external payable{}

    receive() external payable{
        (bool success, ) = DAO.call{value: msg.value}("");
        require(success,"ERR:OT");
    }

}