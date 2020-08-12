pragma solidity ^0.5.4;
library KYCLibrary{
    
     struct GovDetails{
        address member;
        string country;
        string email;
    }
    
      struct Party{
        address member;
        string partyName;
        address[] users;
        string email;
        bool isSpecial;
    }
    
      /**
        * topic: `function addAdmin`.
        * 
        * @dev Adds `member` as an admin.
        * 
        * Requirements:
        * 
        * - `member` should not be an admin already.
        *
        */
    function addAdmin(address member,mapping(address=>bool) storage isAdmin,address[] storage admins)public{
        require(isAdmin[member]==false);
        isAdmin[member]=true;
        admins.push(member)-1;
        
    }
    
      /**
        * topic: `function removeAdmin`.
        * 
        * @dev Removes `member` from admin control.
        * 
        * Requirements:
        * 
        * - `member` should be an admin already.
        *
        */
    function removeAdmin(address member,mapping(address=>bool) storage isAdmin,address[] storage admins) public{
        require(isAdmin[member]==true);
        uint256 index;
        isAdmin[member]=false;
        for(uint256 i=0;i<admins.length;i++){
            if(member==admins[i]){
                index=i;
            }
        }
        admins[index] = admins[admins.length - 1];
        delete admins[admins.length - 1];
        admins.length--;
    }
    
    
      /**
        * topic: `function addToParty`.
        * 
        * @dev Adds `member` as a party.
        * 
        * Requirements:
        * 
        * - `member` should not be a party already.
        */
     function addToParty(address member,string memory name,string  memory _email,mapping(address=>bool)storage isParty,uint256 partyLen,Party storage p,mapping(string=>address)storage storedParties,bool isSpecial,mapping(string=>address)storage userAddress)public {
        require(isParty[member]==false && storedParties[name]==address(0) && userAddress[_email]==address(0));
        isParty[member]=true;
       
        p.member=member;
        p.partyName=name;
        p.email=_email;
        p.isSpecial=isSpecial;
        storedParties[name]=member;
       
         partyLen++;
      
    }
      /**
        * topic: `function removeParty`.
        * 
        * @dev Removes `party` from a party control.
        * 
        * Requirements:
        * 
        * - `party` should be a party already.
        * 
        */
    function removeParty(string memory party,mapping(address=>bool)storage isParty,uint256 partyLen,mapping(address=>Party) storage storedPartyDetails,mapping(string=>address)storage storedParties)public {
         require(storedParties[party]!=address(0) && isParty[storedParties[party]]);
         address member=storedParties[party];
      
         isParty[member]=false;
         partyLen--;
      
        delete storedPartyDetails[member];
        delete storedParties[party];
    }
    
     /**
        * topic: `function addSpecialStatus`.
        * 
        * @dev Adds a special status to the party connected with the given `party`.
        *
        * 
        * Requirements:
        * 
        * - Party connected with the given `party` should not have special status already.
        * 
        */
    function addSpecialStatus(string memory party,mapping(address=>Party) storage storedPartyDetails,mapping(string=>address)storage storedParties)public{
        KYCLibrary.Party storage p=storedPartyDetails[storedParties[party]];
         require(p.isSpecial==false && p.member!=address(0));
         p.isSpecial=true;
    }
     /**
        * topic: `function removeSpecialStatus`.
        * 
        * @dev Removes a special status frpm the party connected with the given `party`.
        *
        *
        * Requirements:
        * 
        * - Party connected with the given `party` should have special status already.
        *
        */
    function removeSpecialStatus(string memory party,mapping(address=>Party) storage storedPartyDetails,mapping(string=>address)storage storedParties)public{
        Party storage p=storedPartyDetails[storedParties[party]];
         require(p.isSpecial==true && p.member!=address(0));
         p.isSpecial=false;
    }
    
      /**
        * topic: `function addToGov`.
        * 
        * @dev Adds `member` as a Government.
        * 
        * Requirements:
        * 
        * - `member` should not be a government already.
        *
        */
     function addToGov(address member,string memory _email,string memory _country,mapping(address=>bool)storage isGov,mapping(address=>GovDetails)storage storedGovDetails,uint256 govLen)public {
         require(isGov[member]==false);
        isGov[member]=true;
        GovDetails storage details=storedGovDetails[member];
        details.member=member;
        details.email=_email;
        details.country=_country;
        govLen++;
       
       
    }
    
      /**
        * topic: `function removeGov`.
        * 
        * @dev Removes `member` from government control.
        * 
        * Requirements:
        * 
        * - `member` should  be an government already.
        * 
        */
    function removeGov(address member,mapping(address=>bool)storage isGov,mapping(address=>GovDetails)storage storedGovDetails,uint256 govLen)public{
          require(isGov[member]==true);
        isGov[member]=false;
       
        govLen--;
        delete storedGovDetails[member];
    }
    
      /**
        * topic: `function blockUser`.
        * 
        * @dev Blocks `member` from using contract.
        * 
        * Requirements:
        * 
        * - `member` should be a KYC verified user.
        * 
        */
    function blockUser(address member,mapping(address=>bool)storage blocked,mapping(address=>bool)storage KYCDone)public{
        require(blocked[member]==false && KYCDone[member]==true);
        blocked[member]=true;
    }
    
      /**
        * topic: `function unblockUser`.
        * 
        * @dev Unblocks `member` and allow to use contract.
        * 
        * Requirements:
        * 
        * - `member` should be a KYC verified user.
        * - `member` should be a blocked user.
        * 
        */
    function unblockUser(address member,mapping(address=>bool)storage blocked,mapping(address=>bool)storage KYCDone)public{
        require(blocked[member]==true && KYCDone[member]==true);
        blocked[member]=false;
     }
       
       /**
         * @dev Returns the addition of two unsigned integers, reverting on
         * overflow.
         *
         * Counterpart to Solidity's `+` operator.
         *
         * Requirements:
         * - Addition cannot overflow.
         */ 
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
       /**
         * @dev Returns the subtraction of two unsigned integers, reverting on
         * overflow (when the result is negative).
         *
         * Counterpart to Solidity's `-` operator.
         *
         * Requirements:
         * - Subtraction cannot overflow.
         */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }
    
       /**
         * @dev Returns the multiplication of two unsigned integers, reverting on
         * overflow.
         *
         * Counterpart to Solidity's `*` operator.
         *
         * Requirements:
         * - Multiplication cannot overflow.
         */
     function mul(uint256 a, uint256 b) internal pure returns (uint256) {
         if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
    
       /**
         * @dev Returns the integer division of two unsigned integers. Reverts on
         * division by zero. The result is rounded towards zero.
         *
         * Counterpart to Solidity's `/` operator. Note: this function uses a
         * `revert` opcode (which leaves remaining gas untouched) while Solidity
         * uses an invalid opcode to revert (consuming all remaining gas).
         *
         * Requirements:
         * - The divisor cannot be zero.
         */
     function div(uint256 a, uint256 b) internal pure returns (uint256) {
          require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
         
     }
    
          

     
}