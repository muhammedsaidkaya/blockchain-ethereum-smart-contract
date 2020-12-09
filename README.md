Name       : Muhammed Said
Surname    : Kaya
Student ID : 21627428

<------------The Problem-------------->
A group of people in the same neighborhood who would like to invest into an asset. They cannot invest
individually because each person has a very small amount of money, thus they can combine their holdings together
to invest into a bigger and more profitable investment.
They decided to combine their money and buy a car which will be used as a taxi and the profit will be shared
among participants every month. However, one problem is that they have no trust in each other. 



The problem was solved by a smart contract with struct structure suitable for object oriented programming.Lots of modifiers used for authorization and validation mechanisms. 

<------------Structs-------------->
Participant : Person involved in taxi purchases and sales.
	- This model includes below variables.
		- investor       :address payable
		- balance        :uint (total money)
		
TaxiDriver : The person driving the taxi owned by the participants.
	- This model includes below variables.
		- driver         : address payable
		- balance        : uint (total money)
		- salary         : uint
		- lastPayment    : uint (lastPaymentDate)
		
CarDealer : The person propose selling and buying car also driver proposal.
	- This model includes below variables.
		- addr           : address payable
		- lastPayment    : uint (lastPaymentDate)
		
Car : Object presented to participants in the sale and purchase.
	- This model includes below variables.
		- carID          : uint32
		- price          : uint
		
ProposedCar : Includes a car which is proposed by car dealer.
	- This model includes below variables.
		- car            : Car
		- offerValidTime : uint
			
CarPurchasingProposal : The propose for selling and buying car by car dealer.
	- This model includes below variables.
		- proposedCar    : ProposedCar
		- approvalNumber : uint
		- votes          : mapping(address=>bool)

DriverProposal : The propose of taking taxi driver by car dealer and participants approveTheDriver.Then this structu includes votes and yesVoteNumber : approvalNumber
	- This model includes below variables.
		- taxiDriver     : TaxiDriver
		- approvalNumber : uint
		- votes          : mapping(address=>bool)
		

<------------Functions-------------->
Public functions:
	- Payable Functions ( Ether value must filled.)
		- join() : Participants can join the investment
			- @modifiers : isNotMaxParticipantSize isParticipationFeeEnough 
		- rePurchaseCar() : Participants sell the car to the dealer.
			- @modifiers : isMoneyEnoughForPurchaseCar isEnoughYesVoteForPurchaseCar isCarDealer
		- payTaxiCharge() : Anyone who takes a taxi can afford to pay.
			- @modiifers : isGreaterThanZero
	- Other Functions
		- purchaseCar() : Participants can buy cars from car dealer.
			- @modifiers : isEnoughMoneyForPurchaseCar isEnoughYesVoteForPurchaseCar isManager
		- fireDriver() : Manager of smart contract can fire the taxi driver
			- @modifiers : isManager
		- releaseSalary() : The manager pays to the taxi driver's account.
			- @modifiers : isManager isOneMonthPassedAfterDriversLastPayment
		- getSalary() : The taxi driver can withdraw the money accumulated in her account.
			- @modifiers : isTaxiDriver isGreaterThanZero
		- payCarExpenses(): The manager pays the car dealer 10 ether every 6 months.
			- @modifiers : isManager isSixMonthPassedAfterCarDealerPayment
		- payDividend() : The administrator deposits the money accumulated in the system into the accounts of the participants every 6 months.
			- @modifiers : isManager isSixMonthPassedAfterPayDividend
		- getDividend() : The participant can withdraw the money accumulated in his / her account.
			- @modifiers : isParticipant
		- approvePurchaseCar(): The participant approves the vehicle purchase proposal.
			- @modifiers : isParticipant isOfferValidTime isParticipantNotAlreadyVotedOnProposal
		- approveSellProposal() : The participant approves the proposal for the vehicle sales process.
			- @modifiers : isParticipant isOfferValidTime isParticipantNotAlreadyVotedOnProposal
		- approveDriver() : Participants confirm the driver who will drive the vehicle.
			- @modifiers : isParticipant isParticipantNotAlreadyVotedOnDriverProposal
		- proposeDriver(address payable _taxiDriver, uint _price) : The car dealer will suggest the driver to drive the taxi.
			- @modifiers : isManager
		- carProposeToBusiness(uint32 _carID,uint _price,uint32 _offerValidTime) : The car dealer offers participants a vehicle that they can buy. 
			- @modifiers : isCarDealer
		- rePurchaseCarPropose(uint32 _carID,uint _price,uint32 _offerValidTime) : Participants make suggestions to sell the vehicle to the car dealer. 
			- @modifiers : isCarDealer
		- setCarDealer(address payable _carDealersAddress) : The manager assigns the car dealer.
			- @modifiers : isManager
		- setDriver() : The manager assigns the taxi driver.
			- @modifiers : isManager isEnougYesVoteForDriver
		- getTotalBalance()	-> returns(uint) : 	The total amount of money accumulated in the investment can be seen.
Private functions:
	- getTime() -> returns(uint32)
	- incrementYesVoteCount(CarPurchasingProposal memory proposal)
	- createCarPurchasingProposal(uint32 _carID,uint _price,uint32 _offerValidTime) -> returns(CarPurchasingProposal memory)
	- decreaseDriverMoney(uint _amount) -> returns(uint)
	- decreaseCarDealerMoney(uint _amount) -> returns(uint)

Fallback function()

	


		 