
pragma solidity ^0.5.4;
import "./KYCLibrary.sol";




/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see `ERC20Detailed`.
 */
 


/**
 * @title KYC
 * 
 * @author KYC.Crypto (visit https://kyc-crypto.com)
 *
 * @dev Standard KYC contract to manage KYC verified users,Party and Government.
 * 
 */

contract KYCCryptocom{
    using KYCLibrary for *;
    
 
  
    uint256 public partyLen;
    uint256 public govLen;
    uint256 public totalUsers;
    uint256 public paymentAmount;
 
    address payable public Owner;
  
    address[]private admins;
   
    
   
     struct Details{
        string[] Email;
        string ipfsHash;
    }
    
   
   
   /**
     * topic: `event addedParty`.
     * 
     * @dev Emitted when `party` is added by a call to `addToParty`.
     * 
     */
  event addedParty(address  party,address  owner,string partyName,string email,bool  isSpecial);
  
   /**
     * topic: `event addedEmail`.
     * 
     * @dev Emitted when `email` is added for a `user` by a call to `addEmail`.
     * 
     */
  event addedEmail(address  user,string email);
  
   /**
     * topic: `event removedEmail`.
     * 
     * @dev Emitted when `email` is removed for a `user` by a call to `removeEmail`.
     * 
     */
  event removedEmail(address  user,string email);
  
   /**
     * topic: `event valueUpdated`. 
     * 
     * @dev Emitted when `value` is updated by an `owner` by a call to `updateValue`.
     * 
     */
  event valueUpdated(address  owner,uint256 value);
  
   /**
     * topic: `event paymentDone`
     * 
     * @dev Emitted when KYC is completed by `user` for `party` by a call to `storeInParty`.
     * 
     * Note that `discount` may be zero.
     * 
     */
   event paymentDone(address  user,string email,string fullName,string docType,address  party,string partyName,uint256 amount,uint256 discount,uint256 price);
  
      /**
        * topic: `event userUpdated`.
        * 
        * @dev Emitted when KYC details are updated for `user` by a call to `updateKYCDetails`.
        * 
        */
   event userUpdated(address  user,string email,string fullName,string  country,string pAddress,string docType);
  
      /**
        * topic: `event addedGov`.
        * 
        * @dev Emitted when `gov` is added by `owner`  by a call to `addedGov`.
        * 
        */
  event addedGov(address  owner,address gov,string country,string email);
  
      /** 
        * topic: `event partyRemoved`.
        * 
        * @dev Emitted when `party` is added by `owner`  by a call to `removeParty`.
        * 
        */
   event partyRemoved(address  party,string partyName);
  
      /**
        * topic: `event govRemoved`.
        * 
        * @dev Emitted when `gov` is removed by `owner`  by a call to `removeGov`.
        * 
        */
   event govRemoved(address  gov,string country);
   
      /**
        * topic: `event depositCompleted`.
        * 
        * @dev Emitted when `amount` is added by `party`  by a call to `depositAmount`.
        * 
        */     
   event depositCompleted(address  party,string partyName,uint256 amount);
   
      /**
        * topic: `event countryAdded`.
        * 
        * @dev Emitted when `gov` is entered by `user`  by a call to `addKYCDetails`.
        * 
        */
    event countryAdded(address  user,string fullName,string email,string pAddress,string docType,string  country);
    
    
    
    event removedAccess(address user,address party,string partyName);
   
   
    
    
    //All the required mappings
    mapping(address=>Details)private storedDetails;
    mapping(address=>uint256)public paidAmountParty;
    mapping(address=>KYCLibrary.GovDetails)private storedGovDetails;
    mapping(address=>KYCLibrary.Party)private storedPartyDetails;
    mapping(string=>address)private storedParties;
    mapping(address=>uint256)public kycCount;
    mapping(address=>bool)public isGov;
    mapping(address=>bool)public isParty;

    mapping(address=>bool)public KYCDone;
    mapping(address=>bool)public blocked;
    mapping(address=>bool)public isAdmin;
    mapping(string=>address)private userAddress;
    mapping(address=>mapping(address=>bool))public paymentDoneParty;
    mapping(string=>address)private isDocUsed;
    
  
    //All the required modifiers
    
    modifier onlyOwner(){
        require(msg.sender==Owner);
        _;
    }
  
    modifier validCall{
        require(KYCDone[msg.sender]==true || isGov[msg.sender]==true || isParty[msg.sender]==true);
        _;
    }
    
   
    
    
    modifier notBlocked(address user){
        require(blocked[user]==false);
        _;
    }
    
    modifier onlyAdmin(){
        require(msg.sender==Owner ||  isAdmin[msg.sender]==true);
        _;
    }
    
    constructor()public{
        Owner=msg.sender;
        paymentAmount=5000000000;
     
       
    }

    // ** Functions for admin and owner **
    
    
      /**
        * topic: `function addAdmin`.
        * 
        * @dev Adds `user` as an admin.
        * 
        * Requirements:
        * 
        * - `user` should not be an admin already.
        * - only `Owner` can call this function.
        */
    function addAdmin(address user)public onlyOwner{
      require(isAdmin[user]==false);
      KYCLibrary.addAdmin(user,isAdmin,admins);
    }
    
      /**
        * topic: `function removeAdmin`.
        * 
        * @dev Removes `user` from admin control.
        * 
        * Requirements:
        * 
        * - `user` should be an admin already.
        * - only `Owner` can call this function.
        */
    function removeAdmin(address user)public onlyOwner{
      require(isAdmin[user]);
       KYCLibrary.removeAdmin(user,isAdmin,admins);
    }
    
      /**
        * topic: `function addToGov`.
        * 
        * @dev Adds `user` as a Government.
        * Emits `aaddedGov` event.
        * 
        * Requirements:
        * 
        * - `user` should not be a government already.
        * - `email` should be a unique email and shouldn't be in use already.
        * - only `Owner` can call this function.
        */
     function addToGov(address user,string memory _country,string memory email)public onlyOwner{
         require(userAddress[email]==address(0) && isGov[user]==false);
        KYCLibrary.addToGov(user,email,_country,isGov,storedGovDetails,govLen);
        userAddress[email]=user;
        emit addedGov(Owner,user,_country,email);
       
    }
    
      /**
        * topic: `function removeGov`.
        * 
        * @dev Removes `user` from government control.
        * Emits `govRemoved` event.
        * 
        * Requirements:
        * 
        * - `user` should  be a government already.
        * - only `Owner` can call this function.
        */
    function removeGov(address user)public onlyOwner{
        require(isGov[user]);
        KYCLibrary.GovDetails storage gov=storedGovDetails[user];
        string storage country=gov.country;
       
         userAddress[gov.email]=address(0);
         KYCLibrary.removeGov(user,isGov,storedGovDetails,govLen);
         emit govRemoved(user,country);
    }
    
    
      /**
        * topic: `function addToParty`.
        * 
        * @dev Adds `user` as a party.
        * Emits `addedParty` event.
        * 
        * Requirements:
        * 
        * - `user` should not be a party already.
        * - `email` should be a unique email and shouldn't be in use already.
        * - `name` should be a unique name and shouldn't be in use already.
        * -  only `Owner` can call this function.
        */
     function addToParty(address user,string memory name,string memory email,bool isSpecial)public onlyOwner{
        require(isParty[user]==false);
        KYCLibrary.Party storage p=storedPartyDetails[user];
        KYCLibrary.addToParty(user,name,email,isParty,partyLen,p,storedParties,isSpecial,userAddress);
        userAddress[email]=user;
        emit addedParty(user,Owner,name,email,p.isSpecial); 
    }
    /**
        * topic: `function addSpecialStatus`.
        * 
        * @dev Adds a special status to the party connected with the given `name`.
        *
        * 
        * Requirements:
        * 
        * - Party connected with the given `name` should not have special status already.
        * - only `Owner` can call this function.
        */
    function addSpecialStatus(string memory name)public onlyOwner{
        require(isParty[storedParties[name]]==true);
          KYCLibrary.addSpecialStatus(name,storedPartyDetails,storedParties);
    }

     /**
        * topic: `function removeSpecialStatus`.
        * 
        * @dev Removes a special status frpm the party connected with the given `name`.
        *
        *
        * Requirements:
        * 
        * - Party connected with the given `name` should have special status already.
        * - only `Owner` can call this function.
        */
     function removeSpecialStatus(string memory name)public onlyOwner{
       require(isParty[storedParties[name]]==true);
        KYCLibrary.removeSpecialStatus(name,storedPartyDetails,storedParties);
    }
    
    
      /**
        * topic: `function removeParty`.
        * 
        * @dev Removes `party` from a party control.
        * Emits `partyRemoved` event.
        * 
        * Requirements:
        * 
        * - `party` should be a party already.
        * - only `Owner` can call this function.
        */
     function removeParty(string memory party)public onlyOwner{
        require(isParty[storedParties[party]]);
       
        address  user=storedParties[party];
       address payable partyAddress=address(uint160(user));
         uint256 amt=paidAmountParty[partyAddress];
         paidAmountParty[partyAddress]=0;
         KYCLibrary.Party storage details=storedPartyDetails[user];
         userAddress[details.email]=address(0);
        KYCLibrary.removeParty(party,isParty,partyLen,storedPartyDetails,storedParties);
          partyAddress.transfer(amt);
       
      
       
       emit partyRemoved(user,party);
    }
    
    
      /**
        * topic: `function blockUser`.
        * 
        * @dev Blocks `user` from using contract.
        * 
        * Requirements:
        * 
        * - `user` should be a KYC verified user and shouldn't be blocked already.
        * -  only `Owner` and `admins` can call this function.
        */
    function blockUser(address user)public onlyAdmin{
      
       KYCLibrary.blockUser(user,blocked,KYCDone);
     
    }
    
      /**
        * topic: `function unblockUser`.
        * 
        * @dev Unblocks `user` and allow to use contract.
        * 
        * Requirements:
        * 
        * - `user` should be a KYC verified user.
        * - `user` should be a blocked user.
        * -  only `Owner` and `admins` can call this function.
        */
     function unblockUser(address user)public onlyAdmin{
        KYCLibrary.unblockUser(user,blocked,KYCDone);
     
    }
     /**
        * topic: `function updatePaymentAmount`.
        * 
        * @dev Updates minimum `paymentAmount` for party.
        *
        * 
        * Requirements:
        * 
        * - Party connected with the given `name` should not have special sttaus already.
        * - only `Owner` can call this function.
        */
    function updatePaymentAmount(uint256 amount)public onlyOwner{
        paymentAmount=amount;
    }
   
    
      /**
        * topic: `function addKYCDetails`.
        * 
        * @dev Adds and Verifies KYC details of `user`.
        * Emits `countryAdded` event.
        * calls `storeInParty` private function.
        * 
        * Requirements:
        * 
        * -  All the parameters are required, none of them can be empty.
        * - `user` should not have completed KYC before.
        * - `user` should not be a blocked user.
        * - `_Email` should be a unique email and shouldn't be in use already.
        * - `_IDNumber` should be a unique IDNumber and shouldn't be in use already.
        * - `party` should be already added party.
        * - `party` should have deposited enough amount of trx to pay `amounts[0]` amount of trx.
        * -  only `Owner`  can call this function.
        */
    function addKYCDetails(address user,string memory party,string  memory _fullName,string memory _pAddress,string memory _country,string memory _IDType,string memory _IDNumber,string memory _Email ,string memory hash,uint256[] memory amounts)public  onlyOwner  {
         require(KYCDone[user]==false);
          require(storedParties[party]!=address(0) && userAddress[_Email]==address(0));
          require(paidAmountParty[storedParties[party]]>=amounts[0]);
          
          require(blocked[user]==false && isDocUsed[_IDNumber]==address(0));
          
         
          require(paymentDoneParty[user][storedParties[party]]==false);
        KYCDone[user]=true; 
        isDocUsed[_IDNumber]=user;
    
        Details storage details=storedDetails[user];
        
        details.Email.push(_Email);
        details.ipfsHash=hash;
     
        userAddress[_Email]=user;
        totalUsers++;
      
        
        storeInParty(party,_fullName,_IDType,user,_Email,amounts);
       emit countryAdded(user,_fullName,_Email,_pAddress,_IDType,_country);
      
        
      
    }
    
      /**
        * topic: `function updateKYCDetails`.
        * 
        * @dev Updates and verifies KYC details of `user`.
        * Emits `userUpdated` event.
        * 
        * Requirements:
        * 
        * - `user` should have completed KYC verfication before.
        * - `user` should not be a blocked user.
        * -  only `Owner` can call this function.
        */
    function updateKYCDetails(address user,string  memory _fullName,string memory _pAddress,string memory _country,string memory _IDType,string memory _IDNumber,string memory _Email,string memory ipfsHash)public  onlyOwner notBlocked(user){
         
          require(KYCDone[user]==true);
             Details storage details=storedDetails[user];
       
          if(userAddress[_Email]==address(0)){
              userAddress[_Email]=user;
              details.Email.push(_Email);
          }
          else if(userAddress[_Email]!=address(0)){
              require(userAddress[_Email]==user,"The given email address is already used.");
          }
          
          if(isDocUsed[_IDNumber]==address(0)){
              isDocUsed[_IDNumber]=user;
          }
          else if(isDocUsed[_IDNumber]!=address(0)){
              require(isDocUsed[_IDNumber]==user,"The given document is already used.");
          }
          
          details.ipfsHash=ipfsHash;
          
           //address storedParty=storedParties[party];
        
       emit userUpdated(user,_Email,_fullName,_country,_pAddress,_IDType);
       
  
    }
    
    
    function removeAccess(address user,string memory partyName)public onlyOwner  notBlocked(user){
        require(KYCDone[user]);
        address party=storedParties[partyName];
        require(isParty[party] && paymentDoneParty[user][party]);
        paymentDoneParty[user][party]=false;
        emit removedAccess(user,party,partyName);
    }
    
   
    
    
     
    
    
    
  
      /**
        * topic: `function storeInParty`.
        * 
        * @dev Maps KYC details of `user` with given `partyName`.
        * Calculates bonus depending on the amount of Mima tokens bought by `partyName`.
        * Deducts calculated bonus from `amounts[0]` and transfers final amount to `Owner`.
        * Emits `paymentDone` event.
        * 
        * Requirements:
        * 
        * - `user` should  be unique and payment for `user` is yet to be completed.
        * - `partyName` should have at least `amounts[0]` amount of trx. 
        * -  only `Owner`  can call this function.
        */
    function storeInParty(string memory partyName,string memory fullName,string memory IDType,address user,string memory email,uint256[] memory amounts)onlyOwner private{
        address party=storedParties[partyName];
      
        require(paidAmountParty[party]>=amounts[0] &&  paymentDoneParty[user][party]==false);
        KYCLibrary.Party storage p=storedPartyDetails[party];
        
        
          
        
              
               uint256 amount=0;
            
          
         
             amount=amounts[0].sub(amounts[1]);
             paidAmountParty[party]=paidAmountParty[party].sub(amount);
                paymentDoneParty[user][party]=true;
                kycCount[party]+=1;
                 p.users.push(user);
                 Owner.transfer(amount);
         
                
                
            
        emit paymentDone(user,email,fullName,IDType,party,partyName,amount,amounts[1],amounts[2]);
    }
       
        
// ** All the user related functions **


      /**
        * topic: `function getPersonalUserDetails`.
        * 
        * return the personal details of `user` specified in parameters.
        * 
        * Requirements:
        * - `user` should have completed KYC verification before.
        * - `user` should not be a blocked user.
        * -  only KYC verified user, party and government  can call this function.
        */
    function getPersonalUserDetails(address user)public view validCall notBlocked(user)  returns(string memory hash){
         require(KYCDone[user]);
         Details storage details=storedDetails[user];
         if(isParty[msg.sender]){
             require(paymentDoneParty[user][msg.sender]);
         }
        
        return(details.ipfsHash);
    }
    
    
    
    
      /**
        * topic: `function getEmailUser`.
        * 
        * return the Email address of `user` at given `index`.
        * 
        * Requirements:
        * - `user` should have completed KYC verification before.
        * - `user` should not be a blocked user.
        * -  only KYC verified user, party and government  can call this function.
        */
    function getEmailUser(address user,uint256 index)public view validCall notBlocked(user) returns(string memory email){
         Details storage details=storedDetails[user];
         return details.Email[index];
    }
    
     
  
      /**
        * topic: `function addPartyUser`.
        * 
        * @dev Maps KYC details of `user` with given `party`.
        * Calls `storeInParty function`.
        * 
        * Requirements:
        * 
        * - `user` should  be unique and payment for `user` is yet to be completed.
        * - `user` should have completed KYC verification before.
        * - `user` should not be a blocked uer.
        * - `party` should have at least `amounts[0]` amount of trx. 
        * -  only `Owner`  can call this function.
        */
      function addPartyUser(address user,string memory fullName,string memory IDType,string memory party,string memory Email,uint256[] memory amounts)public onlyOwner{
          require(paymentDoneParty[user][storedParties[party]]==false && KYCDone[user]==true);
          require(blocked[user]==false);
          require(storedParties[party]!=address(0));
          storeInParty(party,fullName,IDType,user,Email,amounts);
        
      }
      
      /**
        * topic: `function addEmail`.
        * 
        * @dev Adds new email address for `user`.
        * Emits `addedEmail` event.
        * 
        * Requirements:
        * 
        * - `_Email` should  be unique.
        * - `user` should have completed KYC verification before.
        * - `user` should not be a blocked uer.
        * -  only `Owner` can call this function.
        */  
        function addEmail(address user,string memory _Email)onlyOwner notBlocked(user) public {
          require(KYCDone[user]==true && userAddress[_Email]==address(0));
         Details storage details=storedDetails[user];
         details.Email.push(_Email);
         userAddress[_Email]=user;
         emit addedEmail(user,_Email);
    }
    
     /**
        * topic: `function removeEmail`.
        * 
        * @dev Removes given email address for `user`.
        * Emits `removedEmail` event.
        * 
        * Requirements:
        * 
        * - `_Email` should  be already added.
        * - `user` should have completed KYC verification before.
        * - `user` should not be a blocked uer.
        * -  only `Owner` can call this function.
        */  
        function removeEmail(address user,uint256 index)onlyOwner notBlocked(user) public {
          require(KYCDone[user]==true);
         Details storage details=storedDetails[user];
          string memory _Email=  details.Email[index];
          require(userAddress[_Email]!=address(0));
        for (uint i = index; i<details.Email.length-1; i++){
            details.Email[i] = details.Email[i+1];
        }
      
        delete details.Email[details.Email.length-1];
        delete  userAddress[_Email];
        details.Email.length--;
        emit removedEmail(user,_Email);
    }

    // ** All the party related functions **
    
  
    
  
      /**
        * topic: `function getPartyDetails`.
        * 
        * @return party details of `msg.sender`.
        * 
        * Requirements:
        *
        * - only party  can call this function.
        */
      function getPartyDetails()public view  returns(string memory email,string memory partyName,address[] memory arr,bool isSpecial){
         require(isParty[msg.sender]==true);
         KYCLibrary.Party storage p=storedPartyDetails[msg.sender];
         return (p.email,p.partyName,p.users,p.isSpecial);
          
      }
       
     
      /**
        * topic: `function depositAmount`.
        * 
        * @dev Deposits `paymentAmount` of trx or more in party's pool amount`.
        * Emits `depositCompleted` event.
        * 
        * Requirements:
        *
        * -  party should have at least `paymentAmount` amount of trx  which is 5000 trx by default. 
        * -  only party  can call this function.
        */  
        function depositAmount() public payable{
    KYCLibrary.Party storage party=storedPartyDetails[msg.sender];
        require(isParty[msg.sender]==true && party.isSpecial==false);
        require(msg.value>=paymentAmount);
       paidAmountParty[msg.sender]=paidAmountParty[msg.sender].add(msg.value);
        emit depositCompleted(msg.sender,party.partyName,msg.value);
  
    }

    
    
    // ** All the gov related functions **
   
     
     
      /**
        * topic: `function getGovDetails`.
        * 
        * @return government  details of `user`.
        * 
        * Requirements:
        *
        * - `user` should be a government.
        */   
      function getGovDetails(address user)public view  returns(string memory,string memory){
          require(isGov[user]==true);
           KYCLibrary.GovDetails storage govDetails=storedGovDetails[user];
           return(govDetails.email,govDetails.country);
      }
      
     // ** common functions for all the users **
      
      
      /**
        * topic: `function getEmailLength`.
        * 
        * @return Number of email addresses stored for `user`.
        * 
        * Requirements:
        *
        * -  only KYC verfied user,party and government  can call this function.
        */
      function getEmailLength(address user)validCall public view returns(uint256){
          Details storage details=storedDetails[user];
          return details.Email.length;
          
      }
      
      
      
      
      /**
        * topic: `function getUserAddress`.
        * 
        * @return trx address connected with given `email`.
        * 
        * Requirements:
        *
        * -  only KYC verfied user,party and government  can call this function.
        */
     function getUserAddress(string memory email) public view returns(address){
      
         return userAddress[email];
     }
     
      /**
        * topic: `function getPartyAddress`.
        * 
        * @return trx address connected with given `partyName`.
        * 
        * Requirements:
        *
        */
     function getPartyAddress(string memory partyName)public view returns(address){
         return storedParties[partyName];
     }
     
      /**
        * topic: `function DocUsed`.
        * 
        * @return bool to check if the given `ID` is already used or not..
        * 
        */
        function DocUsed(string memory ID)public view returns(address){
         return isDocUsed[ID];
     }
    
      
     
    
}