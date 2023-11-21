#[starknet::contract]
mod Lottery {
    use starknet::{ContractAddress, get_caller_address};

    use bountive::components::generic_lottery::GenericLotteryComponent;
    use openzeppelin::token::erc20::interface::IERC20;
    use openzeppelin::token::erc20::erc20::ERC20Component;
    use openzeppelin::token::erc20::erc20::ERC20Component::InternalTrait as ERC20InternalTrait;
    use openzeppelin::upgrades::upgradeable::UpgradeableComponent;
    use openzeppelin::upgrades::upgradeable::UpgradeableComponent::InternalTrait as UpgradeableInternalTrait;

    component!(path: GenericLotteryComponent, storage: generic_lottery, event: GenericLotteryEvent);
    component!(path: ERC20Component, storage: erc20, event: ERC20Event);
    component!(path: UpgradeableComponent, storage: upgradeable, event: UpgradeableEvent);

    #[abi(embed_v0)]
    impl GenericLottery =
        GenericLotteryComponent::GenericLotteryImpl<ContractState>;
    #[abi(embed_v0)]
    impl ERC20Impl = ERC20Component::ERC20Impl<ContractState>;
    impl ERC20InternalImpl = ERC20Component::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        generic_lottery: GenericLotteryComponent::Storage,
        #[substorage(v0)]
        erc20: ERC20Component::Storage,
        #[substorage(v0)]
        upgradeable: UpgradeableComponent::Storage,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        GenericLotteryEvent: GenericLotteryComponent::Event,
        ERC20Event: ERC20Component::Event,
        UpgradeableEvent: UpgradeableComponent::Event,
    }


    #[constructor]
    fn constructor(ref self: ContractState) {}

    #[external(v0)]
    impl LotteryImpl of bountive::core::interfaces::ILottery<ContractState> {
        // fn deposit(ref self: ContractState, assets: u256) {
        //     let caller_address = get_caller_address();
        // // Assert min/max deposit and max users
        // // self.generic_lottery.deposit(assets, caller_address);
        // }
    }
}
