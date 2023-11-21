#[starknet::component]
mod GenericSBT {

    use starknet::{ContractAddress, get_caller_address, get_block_timestamp};
    use openzeppelin::token::erc20::interface::{
        IERC20Camel, IERC20CamelDispatcherImpl, IERC20CamelDispatcher
    };
    use openzeppelin::token::erc721::interface::{
        IERC721, IERC721DispatcherImpl, IERC721Dispatcher
    };
    use bountive::core::interfaces::{
        IERC20MintableBurnableDispatcher, IERC20MintableBurnableDispatcherImpl
    };
    use bountive::utils::errors::{DEPOSIT_ZERO, NOT_ACTIVE, TRANSFER_FAILED};

    #[storage]
    struct Storage {
        ERC721_name: felt252,
        ERC721_symbol: felt252,
        ERC721_owners: LegacyMap<u256, ContractAddress>,
        ERC721_balances: LegacyMap<ContractAddress, u256>,
        ERC721_token_approvals: LegacyMap<u256, ContractAddress>,
        ERC721_operator_approvals: LegacyMap<(ContractAddress, ContractAddress), bool>,
        ERC721_token_uri: LegacyMap<u256, felt252>,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        Transfer: Transfer,
        Approval: Approval,
        ApprovalForAll: ApprovalForAll,
    }


    /// Emitted when `token_id` token is transferred from `from` to `to`.
    #[derive(Drop, starknet::Event)]
    struct Transfer {
        #[key]
        from: ContractAddress,
        #[key]
        to: ContractAddress,
        #[key]
        token_id: u256
    }

    /// Emitted when `owner` enables `approved` to manage the `token_id` token.
    #[derive(Drop, starknet::Event)]
    struct Approval {
        #[key]
        owner: ContractAddress,
        #[key]
        approved: ContractAddress,
        #[key]
        token_id: u256
    }

    /// Emitted when `owner` enables or disables (`approved`) `operator` to manage
    /// all of its assets.
    #[derive(Drop, starknet::Event)]
    struct ApprovalForAll {
        #[key]
        owner: ContractAddress,
        #[key]
        operator: ContractAddress,
        approved: bool
    }

}