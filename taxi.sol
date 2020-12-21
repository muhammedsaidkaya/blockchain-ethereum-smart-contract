pragma solidity 0.6.11;

contract TaxiInvestmentContract{
    
    //Structs

    struct Car{
        uint32 carID;
        uint price;
    }
    struct Participant{
        address payable addr;
        uint balance;
    }    
    struct TaxiDriver{
        address payable addr;
        uint balance;
        uint salary;
        uint lastPayment;
    }
    struct CarDealer{
        address payable addr;
        uint lastPayment;
    }

    
    
    struct Proposal{
        uint approvalNumber;
        mapping(address=>bool) votes;
    }
    struct ProposedCar{
        Car car;
        uint offerValidTime;
    }
    struct CarPurchasingProposal{
        Proposal proposal;
        ProposedCar proposedCar;
    }
    struct DriverProposal{
        Proposal proposal;
        TaxiDriver proposedTaxiDriver;

    }
    
    
    //State Variables
    address public manager;
    uint private managerPayDividendTime;
    
    CarDealer public carDealer;
    uint32 public ownedCar;
    TaxiDriver public taxiDriver;    

    address[] participantsAddresses;
    mapping(address=>Participant) public participants;
    
    CarPurchasingProposal carPurchaseProposal;
    CarPurchasingProposal carRePurchaseProposal;
    DriverProposal taxiDriverProposal;

    
    //Constructor
    constructor() public {
        manager = msg.sender;
    }
    

    
    
    modifier isNotMaxParticipantSize() {
        require(participantsAddresses.length != 9,"Participant size already 9.");
        _;
    }
    modifier isParticipationFeeEnough(){
        require(msg.value == 100 ether,"In order to join , Value must be 100 ether.");
        _;
    }
    modifier isRightAddress(address _addr,string memory _desc){
        require(msg.sender == _addr,_desc);
        _;
    }
    modifier isEnougYesVoteForProposal(Proposal memory _proposal){
        require(participantsAddresses.length/2 < _proposal.approvalNumber,"Yes vote number is not enough.");
        _;
    }
    modifier isLessThan(uint _temp1,uint _temp2,bool _equality,string memory _desc){
        if(_equality)
            require(_temp1 <= _temp2,_desc);
        else
            require(_temp1 < _temp2,_desc);
        _;
    }
    modifier isSecondPassedAfterLastPayment(uint _time,uint _lastPayment){
        require(_time < now - _lastPayment,"The time not passed after last payment.");
        _;
    }



    
    function getTotalBalance() public view returns(uint){
        return address(this).balance;
    }
    
    function join() payable public isNotMaxParticipantSize isParticipationFeeEnough{
        participants[msg.sender] = Participant(msg.sender,0);
        participantsAddresses.push(msg.sender);
    }
    
    
    
    
    
    function proposeDriver(address payable _addr, uint _price) public isRightAddress(manager,"This function called by manager."){
        taxiDriverProposal = DriverProposal({
            proposal : Proposal({
                approvalNumber:0
            }),
            proposedTaxiDriver: TaxiDriver({
               addr : _addr,
               balance : 0,
               salary : _price,
               lastPayment : 0
           })
        });
    }
    function carProposeToBusiness(uint32 _carID,uint _price,uint _offerValidTime) public isRightAddress(carDealer.addr,"This function called by car dealer."){
        carPurchaseProposal = CarPurchasingProposal({
            proposal : Proposal({
                approvalNumber:0
            }),
            proposedCar: ProposedCar({
                car: Car({
                    carID : _carID,
                    price : _price
                }),
                offerValidTime : _offerValidTime
            })
        });
    }
    function rePurchaseCarPropose(uint32 _carID,uint _price,uint _offerValidTime) public isRightAddress(carDealer.addr,"This function called by car dealer."){
        carRePurchaseProposal = CarPurchasingProposal({
            proposal : Proposal({
                approvalNumber:0
            }),
            proposedCar: ProposedCar({
                car: Car({
                    carID : _carID,
                    price : _price
                }),
                offerValidTime : _offerValidTime
            })
        });
    }




    function setCarDealer(address payable _addr) public isRightAddress(manager,"This function called by manager."){
        carDealer = CarDealer({
            addr : _addr,
            lastPayment : 0
        });
    }
    function setDriver() public isRightAddress(manager,"This function called by manager.") isEnougYesVoteForProposal(taxiDriverProposal.proposal){
        taxiDriver = taxiDriverProposal.proposedTaxiDriver;
        delete taxiDriverProposal;
    }
    
    
    
    
    function approvePurchaseCar() public isRightAddress(participants[msg.sender].addr,"This function called by participant.") isLessThan(now , carPurchaseProposal.proposedCar.offerValidTime , true,"Offer valid time passed."){
        require(!carPurchaseProposal.proposal.votes[msg.sender]);
        carPurchaseProposal.proposal.votes[msg.sender] = true;
        carPurchaseProposal.proposal.approvalNumber += 1;
    }
    function approveSellProposal() public isRightAddress(participants[msg.sender].addr,"This function called by participant.") isLessThan(now , carRePurchaseProposal.proposedCar.offerValidTime , true,"Offer valid time passed."){
        require(!carRePurchaseProposal.proposal.votes[msg.sender]);
        carRePurchaseProposal.proposal.votes[msg.sender] = true;
        carRePurchaseProposal.proposal.approvalNumber += 1;
    }
    function approveDriver() public isRightAddress(participants[msg.sender].addr,"This function called by participant.") {
        require(!taxiDriverProposal.proposal.votes[msg.sender]);
        taxiDriverProposal.proposal.votes[msg.sender] = true;
        taxiDriverProposal.proposal.approvalNumber += 1;
    }
    
    
    
    function purchaseCar() public  isRightAddress(manager,"This function called by manager.") isLessThan(carPurchaseProposal.proposedCar.car.price , address(this).balance , true,"Contract balance is not enough.") isEnougYesVoteForProposal(carPurchaseProposal.proposal){
        Car memory temp = carPurchaseProposal.proposedCar.car;
        carDealer.addr.transfer(temp.price);
        ownedCar = temp.carID;
        delete carPurchaseProposal;
    }
    function rePurchaseCar() payable public isRightAddress(carDealer.addr,"This function called by car dealer.") isLessThan(carRePurchaseProposal.proposedCar.car.price , msg.value, true,"The paid value is not enough for car price.") isEnougYesVoteForProposal(carRePurchaseProposal.proposal) {
        ownedCar = 0;
        delete carRePurchaseProposal;
    }

    
    function payTaxiCharge() public payable isLessThan(0,msg.value,false,"Taxi charge money must be greater than zero."){}




    function fireDriver() public isRightAddress(manager,"This function called by manager.") {
        taxiDriver.addr.transfer(taxiDriver.salary);
        delete taxiDriver;
    }
    function releaseSalary() public isRightAddress(manager,"This function called by manager.") isSecondPassedAfterLastPayment(60 * 60 * 24 * 30,taxiDriver.lastPayment){
        taxiDriver.balance += taxiDriver.salary;
        taxiDriver.lastPayment = uint(now);
    }
    function getSalary() public isRightAddress(taxiDriver.addr,"This function called by taxi driver.") isLessThan(0,taxiDriver.balance,false,"Taxi Balance must be greater than zero."){
        taxiDriver.addr.transfer(taxiDriver.balance);
        taxiDriver.balance = 0;
    }
    
    
    
    
    
    function payCarExpenses() public isRightAddress(manager,"This function called by manager.") isSecondPassedAfterLastPayment(60 * 60 * 24 * 30 * 6,carDealer.lastPayment){
        carDealer.addr.transfer(10 ether);
        carDealer.lastPayment = uint(now);
    }
    
    
    
    
    function payDividend() public isRightAddress(manager,"This function called by manager.") isSecondPassedAfterLastPayment(60 * 60 * 24 * 30 * 6,managerPayDividendTime){
        uint amount = decreaseCarDealerMoney(decreaseDriverMoney(address(this).balance));
        for(uint i=0; i< participantsAddresses.length ; i++){
            address temp = participantsAddresses[i];
            participants[temp].balance += amount/ participantsAddresses.length;
        }
        managerPayDividendTime = uint(now);
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
    function getDividend() public isRightAddress(participants[msg.sender].addr,"This function called by participant.") isLessThan(participants[msg.sender].balance , address(this).balance , true,"Contract balance is not enough."){
        participants[msg.sender].addr.transfer(participants[msg.sender].balance);
        participants[msg.sender].balance = 0;
    }




    fallback () external {
        
    }
}
