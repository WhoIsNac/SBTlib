#[starknet::contract]
mod ERC20MintableBurnable {
    use starknet::{ContractAddress, get_caller_address};

    use openzeppelin::token::erc20::interface::IERC20;
    use openzeppelin::token::erc20::erc20::ERC20Component;
    use openzeppelin::token::erc20::erc20::ERC20Component::InternalTrait as ERC20InternalTrait;
    use openzeppelin::introspection::src5::SRC5Component;
    use openzeppelin::introspection::src5::SRC5Component::InternalTrait as SRC5InternalTrait;
    use openzeppelin::introspection::interface::ISRC5_ID;

    component!(path: ERC20Component, storage: erc20, event: ERC20Event);
    component!(path: SRC5Component, storage: src5, event: SRC5Event);

    #[abi(embed_v0)]
    impl ERC20Impl = ERC20Component::ERC20Impl<ContractState>;
    impl ERC20InternalImpl = ERC20Component::InternalImpl<ContractState>;
    #[abi(embed_v0)]
    impl SRC5Impl = SRC5Component::SRC5Impl<ContractState>;
    impl SRC5InternalImpl = SRC5Component::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        erc20: ERC20Component::Storage,
        #[substorage(v0)]
        src5: SRC5Component::Storage,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        ERC20Event: ERC20Component::Event,
        SRC5Event: SRC5Component::Event,
    }

    #[constructor]
    fn constructor(ref self: ContractState, name: felt252, symbol: felt252) {
        self.erc20.initializer(name, symbol);
        self.src5.register_interface(ISRC5_ID);
    }

    #[external(v0)]
    impl ERC20MintableBurnableImpl of bountive::core::interfaces::IERC20MintableBurnable<
        ContractState
    > {
        fn name(self: @ContractState) -> felt252 {
            self.erc20.ERC20_name.read()
        }

        fn symbol(self: @ContractState) -> felt252 {
            self.erc20.ERC20_symbol.read()
        }

        fn mint(ref self: ContractState, recipient: ContractAddress, amount: u256) {
            self.erc20._mint(recipient, amount);
        }

        fn burn(ref self: ContractState, owner: ContractAddress, amount: u256) {
            let caller = get_caller_address();
            self.erc20._spend_allowance(owner, caller, amount);
            self.erc20._burn(owner, amount)
        }
    }
}
