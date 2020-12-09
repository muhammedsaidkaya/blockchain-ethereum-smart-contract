pragma solidity 0.6.11;

contract TaxiInvestmentContract{
    
    //Structs
    struct Participant{
        address payable investor;
        uint balance;
    }
    struct Car{
        uint32 carID;
        uint price;
    }
    struct TaxiDriver{
        address payable driver;
        uint balance;
        uint salary;
        uint lastPayment;
    }
    struct CarDealer{
        address payable addr;
        uint lastPayment;
    }
    struct ProposedCar{
        Car car;
        uint offerValidTime;
    }
    struct CarPurchasingProposal{
        ProposedCar proposedCar;
        uint approvalNumber;
        mapping(address=>bool) votes;
    }
    struct DriverProposal{
        TaxiDriver taxiDriver;
        uint approvalNumber;
        mapping(address=>bool) votes;
    }
    
    
    //State Variables
    address public manager;
    uint private managerPayDividendTime;
    
    CarDealer public carDealer;
    uint32 public ownedCar;
    TaxiDriver public taxiDriver;    

    address[] participantsAddresses;
    mapping(address=>Participant) public participants;
    
    CarPurchasingProposal purchaseProposal;
    CarPurchasingProposal rePurchaseProposal;
    DriverProposal taxiDriverProposal;
    
    //Constructor
    constructor() public {
        manager = msg.sender;
    }
    
    
    

    
    
    //Modifiers
    modifier isNotMaxParticipantSize() {
        require(participantsAddresses.length != 9);
        _;
    }
    modifier isParticipationFeeEnough(){
        require(msg.value == 100 ether);
        _;
    }
    modifier isManager(){
        require(msg.sender == manager);
        _;
    }
    modifier isCarDealer(){
        require(msg.sender == carDealer.addr);
        _;
    }
    modifier isParticipant(){
        require(msg.sender == participants[msg.sender].investor);
        _;
    }
    modifier isTaxiDriver(){
        require(msg.sender == taxiDriver.driver);
        _;
    }
    modifier isOfferValidTime(CarPurchasingProposal memory proposal){
        require(proposal.proposedCar.offerValidTime >= now);
        _;
    }
    modifier isParticipantNotAlreadyVotedOnProposal(CarPurchasingProposal storage proposal){
        require(!proposal.votes[msg.sender]);
        _;
    }
    modifier isParticipantNotAlreadyVotedOnDriverProposal(){
        require(!taxiDriverProposal.votes[msg.sender]);
        _;
    }
    modifier isEnoughMoneyForPurchaseCar(CarPurchasingProposal memory proposal){
        require(proposal.proposedCar.car.price == msg.value);
        _;
    }
    modifier isEnoughYesVoteForPurchaseCar(CarPurchasingProposal memory proposal){
        require(participantsAddresses.length/2 < proposal.approvalNumber);
        _;
    }
    modifier isEnougYesVoteForDriver(){
        require(participantsAddresses.length/2 < taxiDriverProposal.approvalNumber);
        _;
    }
    modifier isGreaterThanZero(uint value){
        require(value > 0);
        _;
    }
    modifier isOneMonthPassedAfterDriversLastPayment(){
        require(60 * 60 * 24 * 30 < now - taxiDriver.lastPayment);
        _;
    }
    modifier isSixMonthPassedAfterCarDealerPayment(){
        require(60 * 60 * 24 * 30 * 6 < now - carDealer.lastPayment);
        _;
    }
    modifier isSixMonthPassedAfterPayDividend(){
        require(now - managerPayDividendTime > 60 * 60 * 24 * 30 * 6 );
        _;
    }
    
    //Private Functions
    function getTime() private view returns(uint32){
        return uint32(now);
    }
    function incrementYesVoteCount(CarPurchasingProposal memory proposal) private pure {
        proposal.approvalNumber += 1;
    }
    function creteaCarPurchasinProposal(uint32 _carID,uint _price,uint32 _offerValidTime) private pure returns(CarPurchasingProposal memory){
        return CarPurchasingProposal({
            proposedCar: ProposedCar({
                car: Car({
                    carID : _carID,
                    price : _price
                }),
                offerValidTime : _offerValidTime
            }),
            approvalNumber : 0
        });
    }
    function decreaseDriverMoney(uint _amount) private view returns(uint){
        uint oneMonth = 60 * 60 * 24 * 30;
        if(now - taxiDriver.lastPayment > oneMonth) _amount -= taxiDriver.salary; 
        return _amount;
    }
    function decreaseCarDealerMoney(uint _amount) private view returns(uint){
        uint sixMonth = 60 * 60 * 24 * 30 * 6;
        if(now - carDealer.lastPayment > sixMonth) _amount -= 10 ether;
        return _amount;
    } 
    
    
    //Public Functions
    
    function getTotalBalance() public view returns(uint){
        return address(this).balance;
    }
    
    //Joining
    function join() payable public isNotMaxParticipantSize isParticipationFeeEnough{
        participants[msg.sender] = Participant(msg.sender,0);
        participantsAddresses.push(msg.sender);
    }
    
    //Sets
    function setCarDealer(address payable _carDealersAddress) public isManager{
        carDealer = CarDealer({
            addr:_carDealersAddress,
            lastPayment : 0
        });
    }
    function setDriver() public isManager isEnougYesVoteForDriver{
        taxiDriver = taxiDriverProposal.taxiDriver;
    }
    
    
    //Proposes
    function carProposeToBusiness(uint32 _carID,uint _price,uint32 _offerValidTime) public isCarDealer{
        purchaseProposal = creteaCarPurchasinProposal(_carID,_price,_offerValidTime);
    }
    function rePurchaseCarPropose(uint32 _carID,uint _price,uint32 _offerValidTime) public isCarDealer{
        rePurchaseProposal = creteaCarPurchasinProposal(_carID,_price,_offerValidTime);
    }
    function proposeDriver(address payable _taxiDriver, uint _price) public isManager{
        taxiDriverProposal = DriverProposal({
           taxiDriver: TaxiDriver({
               driver : _taxiDriver,
               balance : 0,
               salary : _price,
               lastPayment : 0
           }),
           approvalNumber : 0
        });
    }
    
    
    //Approves
    function approvePurchaseCar() public isParticipant isOfferValidTime(purchaseProposal) isParticipantNotAlreadyVotedOnProposal(purchaseProposal){
        purchaseProposal.votes[msg.sender] = true;
        incrementYesVoteCount(purchaseProposal);
    }
    function approveSellProposal() public isParticipant isOfferValidTime(rePurchaseProposal) isParticipantNotAlreadyVotedOnProposal(rePurchaseProposal){
        rePurchaseProposal.votes[msg.sender] = true;
        incrementYesVoteCount(rePurchaseProposal);
    }
    function approveDriver() public isParticipant isParticipantNotAlreadyVotedOnDriverProposal{
        taxiDriverProposal.votes[msg.sender] = true;
        taxiDriverProposal.approvalNumber += 1;
    }
    
    
    //Payables
    function purchaseCar() payable public isEnoughMoneyForPurchaseCar(purchaseProposal) isEnoughYesVoteForPurchaseCar(purchaseProposal) isManager{
        Car memory temp = purchaseProposal.proposedCar.car;
        carDealer.addr.transfer(temp.price);
        ownedCar = temp.carID;
        delete purchaseProposal;
    }
    function rePurchaseCar() payable public isEnoughMoneyForPurchaseCar(rePurchaseProposal) isEnoughYesVoteForPurchaseCar(rePurchaseProposal) isCarDealer{
        ownedCar = 0;
        delete rePurchaseProposal;
    }
    function fireDriver() public {
        taxiDriver.driver.transfer(taxiDriver.salary);
        delete taxiDriver;
    }
    function payTaxiCharge() public payable isGreaterThanZero(msg.value){}
    function releaseSalary() public isManager isOneMonthPassedAfterDriversLastPayment{
        taxiDriver.balance += taxiDriver.salary;
        taxiDriver.lastPayment = uint(now);
    }
    function getSalary() public isTaxiDriver isGreaterThanZero(taxiDriver.balance){
        taxiDriver.driver.transfer(taxiDriver.balance);
        taxiDriver.balance = 0;
    }
    function payCarExpenses() public isManager isSixMonthPassedAfterCarDealerPayment{
        carDealer.addr.transfer(10 ether);
        carDealer.lastPayment = uint(now);
    }
    function payDividend() public isManager isSixMonthPassedAfterPayDividend{
        uint amount = decreaseCarDealerMoney(decreaseDriverMoney(address(this).balance));
        for(uint i=0; i< participantsAddresses.length ; i++){
            address temp = participantsAddresses[i];
            participants[temp].balance += amount/ participantsAddresses.length;
        }
        managerPayDividendTime = uint(now);
    }
    function getDividend() public isParticipant{
        assert(address(this).balance >= participants[msg.sender].balance);
        participants[msg.sender].investor.transfer(participants[msg.sender].balance);
        participants[msg.sender].balance = 0;
    }
    
    fallback () external {
        
    }
}
