#[starknet::contract]
mod Sbt {
    use starknet::{ContractAddress, get_caller_address, class_hash::ClassHash};
    use openzeppelin::{
        account, access::ownable::OwnableComponent,
        upgrades::{UpgradeableComponent, interface::IUpgradeable},
        token::erc721::{
            ERC721Component, erc721::ERC721Component::InternalTrait as ERC721InternalTrait,
            interface::IERC721,
        },
        introspection::{src5::SRC5Component, dual_src5::{DualCaseSRC5, DualCaseSRC5Trait}}
    };


    #[storage]
    struct Storage {
        user_data: LegacyMap<ContractAddress, felt252>,
        id_by_addr: LegacyMap<ContractAddress, u128>,
        #[substorage(v0)]
        erc721: ERC721Component::Storage,
        #[substorage(v0)]
        upgradeable: UpgradeableComponent::Storage,
        #[substorage(v0)]
        src5: SRC5Component::Storage,
        #[substorage(v0)]
        ownable: OwnableComponent::Storage,
    }

    #[derive(Drop, starknet::Event)]
    struct UserIdUpdate {
        #[key]
        owner: ContractAddress,
        id: u128,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        ERC721Event: ERC721Component::Event,
        SRC5Event: SRC5Component::Event,
        UpgradeableEvent: UpgradeableComponent::Event,
        OwnableEvent: OwnableComponent::Event,
        UserdUpdate: UserIdUpdate,
    }

    component!(path: SRC5Component, storage: src5, event: SRC5Event);
    component!(path: ERC721Component, storage: erc721, event: ERC721Event);
    component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);
    component!(path: UpgradeableComponent, storage: upgradeable, event: UpgradeableEvent);

    // #[abi(embed_v0)]
    // impl ERC721Impl = ERC721Component::ERC721Impl<ContractState>;
    #[abi(embed_v0)]
    impl SRC5Impl = SRC5Component::SRC5Impl<ContractState>;
    #[abi(embed_v0)]
    impl OwnableImpl = OwnableComponent::OwnableImpl<ContractState>;
    impl OwnableInternalImpl = OwnableComponent::InternalImpl<ContractState>;
    impl ERC721CamelOnlyImpl = ERC721Component::ERC721CamelOnlyImpl<ContractState>;
    #[abi(embed_v0)]
    impl SRC5CamelImpl = SRC5Component::SRC5CamelImpl<ContractState>;
    impl SRC5InternalImpl = SRC5Component::InternalImpl<ContractState>;
    impl UpgradeableInternalImpl = UpgradeableComponent::InternalImpl<ContractState>;


    #[constructor]
    fn constructor(ref self: ContractState, owner: ContractAddress, token_uri_base: felt252,) {
        self.ownable.initializer(owner);
        self.erc721.initializer('BountSBT', 'SBT');
    //self.custom_uri.set_base_uri(token_uri_base);
    }


    #[external(v0)]
    impl UpgradeableImpl of IUpgradeable<ContractState> {
        fn upgrade(ref self: ContractState, new_class_hash: ClassHash) {
            self.ownable.assert_only_owner();
            self.upgradeable._upgrade(new_class_hash);
        }
    }

    #[external(v0)]
    impl ERC721Impl of IERC721<ContractState> {
        fn safe_transfer_from(
            ref self: ContractState,
            from: ContractAddress,
            to: ContractAddress,
            token_id: u256,
            data: Span<felt252>
        ) {
            assert(self.is_transferable(), 'Transfer blocked for sbt token');
            self.erc721.safe_transfer_from(from, to, token_id.into(), data);
        }


        fn transfer_from(
            ref self: ContractState, from: ContractAddress, to: ContractAddress, token_id: u256
        ) {
            assert(self.is_transferable(), 'Transfer blocked for sbt token');
            self.erc721.transfer_from(from, to, token_id.into());
        }

        fn balance_of(self: @ContractState, account: ContractAddress) -> u256 {
            self.erc721.balance_of(account).into()
        }

        fn owner_of(self: @ContractState, token_id: u256) -> ContractAddress {
            self.erc721.owner_of(token_id.into())
        }

        fn approve(ref self: ContractState, to: ContractAddress, token_id: u256) {
            self.erc721.approve(to, token_id.into());
        }

        fn get_approved(self: @ContractState, token_id: u256) -> ContractAddress {
            self.erc721.get_approved(token_id.into())
        }

        fn set_approval_for_all(
            ref self: ContractState, operator: ContractAddress, approved: bool
        ) {
            self.erc721.set_approval_for_all(operator, approved);
        }
        fn is_approved_for_all(
            self: @ContractState, owner: ContractAddress, operator: ContractAddress
        ) -> bool {
            self.erc721.is_approved_for_all(owner, operator)
        }
    }


    #[external(v0)]
    impl SBTImpl of bountive::core::interfaces::ISBT<ContractState> {
        fn _transfer(
            ref self: ContractState, from: ContractAddress, to: ContractAddress, token_id: u128
        ) {
            assert(self.is_transferable(), 'Transfer blocked for sbt token');
            self.erc721._transfer(from, to, token_id.into());
        }

        fn mint(ref self: ContractState, token_id: u128) {
            self.erc721._mint(get_caller_address(), token_id.into());
        }

        fn is_transferable(self: @ContractState) -> bool {
            false
        }
    }
}
