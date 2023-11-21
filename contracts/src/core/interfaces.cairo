use starknet::ContractAddress;
use starknet::ClassHash;

#[starknet::interface]
trait IGenericLottery<TComponentState> {
    fn asset(self: @TComponentState) -> ContractAddress;
    fn total_assets(self: @TComponentState) -> u256;
    fn shares(self: @TComponentState, owner: ContractAddress) -> u256;
    fn deposit(ref self: TComponentState, assets: u256, receiver: ContractAddress);
    fn withdraw(
        ref self: TComponentState, assets: u256, receiver: ContractAddress, owner: ContractAddress
    );
    fn redeem(
        ref self: TComponentState, shares: u256, receiver: ContractAddress, owner: ContractAddress
    );
    fn claim_winning_prize(ref self: TComponentState);
}

#[starknet::interface]
trait ILottery<TContractState> { // fn deposit(ref self: TContractState, assets: u256);
}


#[starknet::interface]
trait ISBT<TContractState> { // fn deposit(ref self: TContractState, assets: u256);
    fn mint(ref self: TContractState, token_id: u128);
    fn is_transferable(self: @TContractState) -> bool;
    fn _transfer(
        ref self: TContractState, from: ContractAddress, to: ContractAddress, token_id: u128
    );
}

#[starknet::interface]
trait IERC20MintableBurnable<TComponentState> {
    fn name(self: @TComponentState) -> felt252;
    fn symbol(self: @TComponentState) -> felt252;
    fn mint(ref self: TComponentState, recipient: ContractAddress, amount: u256);
    fn burn(ref self: TComponentState, owner: ContractAddress, amount: u256);
}
