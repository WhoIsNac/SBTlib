#[starknet::contract]
mod Sbtlib {
    use traits::Into;
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

    use traits::TryInto;


    #[storage]
    struct Storage {
        user_data: LegacyMap<ContractAddress, felt252>,
        id_by_addr: LegacyMap<ContractAddress, u128>,
        counter: felt252,
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
    fn constructor(ref self: ContractState, owner: ContractAddress) {
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
    impl SBTImpl of bountive::core::interfaces::ISBT<ContractState> {
        fn mint(ref self: ContractState, token_id: u128) {
            self.erc721._mint(get_caller_address(), token_id.into());
        }

        fn is_transferable(self: @ContractState) -> bool {
            false
        }
    }
}
