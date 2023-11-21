#[starknet::component]
mod GenericLotteryComponent {
    use starknet::{ContractAddress, get_caller_address, get_block_timestamp};
    use openzeppelin::token::erc20::interface::{
        IERC20Camel, IERC20CamelDispatcherImpl, IERC20CamelDispatcher
    };
    use bountive::core::interfaces::{
        IERC20MintableBurnableDispatcher, IERC20MintableBurnableDispatcherImpl
    };
    use bountive::utils::errors::{DEPOSIT_ZERO, NOT_ACTIVE, TRANSFER_FAILED};

    #[derive(Drop, PartialEq, starknet::Store)]
    enum Phase {
        Active,
        Pending,
        Close,
    }

    #[storage]
    struct Storage {
        asset_contract: ContractAddress,
        shares_contract: ContractAddress,
        contract_status: Phase,
        share_holder: LegacyMap<ContractAddress, u256>,
        total_assets: u256,
        opening_time: u64,
        closing_time: u64,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        Deposit: Deposit,
        Withdraw: Withdraw,
    }

    #[derive(Drop, starknet::Event)]
    struct Deposit {
        #[key]
        sender: ContractAddress,
        #[key]
        owner: ContractAddress,
        assets: u256,
        timestamp: u64,
    }

    #[derive(Drop, starknet::Event)]
    struct Withdraw {
        #[key]
        sender: ContractAddress,
        #[key]
        receiver: ContractAddress,
        shares: u256,
    }

    #[embeddable_as(GenericLotteryImpl)]
    impl GenericLottery<
        TContractState, +HasComponent<TContractState>, +Drop<TContractState>
    > of bountive::core::interfaces::IGenericLottery<ComponentState<TContractState>> {
        /// @description Returns the address of the asset's contract.
        fn asset(self: @ComponentState<TContractState>) -> ContractAddress {
            self.asset_contract.read()
        }

        /// @description Returns the total amount of underlying assets held in the lottery.
        fn total_assets(self: @ComponentState<TContractState>) -> u256 {
            self.total_assets.read()
        }

        /// @description Returns the number of shares of the owner.
        fn shares(self: @ComponentState<TContractState>, owner: ContractAddress) -> u256 {
            self.share_holder.read(owner)
        }

        /// @description Deposits the underlying token assets in the vault and grants ownership of shares to the receiver.
        /// @param assets - Amount of assets to deposit.
        fn deposit(
            ref self: ComponentState<TContractState>, assets: u256, receiver: ContractAddress
        ) {
            let caller_address = get_caller_address();
            assert(assets > 0, DEPOSIT_ZERO);
            assert(self.contract_status.read() == Phase::Active, NOT_ACTIVE);
            self._deposit(assets, caller_address, receiver);
            self
                .share_holder
                .write(caller_address, self.share_holder.read(caller_address) + assets);
            self.total_assets.write(self.total_assets.read() + assets);
        }

        /// @description Destroys the owner's shares and sends the exact assets token from the lottery to the receiver.
        /// @param assets - Amount of shares to withdraw.
        fn withdraw(
            ref self: ComponentState<TContractState>,
            assets: u256,
            receiver: ContractAddress,
            owner: ContractAddress
        ) {}

        /// @description Redeems a specific number of shares from the owner and sends underlying token assets from the lottery to the receiver.
        /// @param assets - Amount of shares to redeem.
        fn redeem(
            ref self: ComponentState<TContractState>,
            shares: u256,
            receiver: ContractAddress,
            owner: ContractAddress
        ) {}

        fn claim_winning_prize(ref self: ComponentState<TContractState>) {}
    }

    #[generate_trait]
    impl InternalImpl<
        TContractState, +HasComponent<TContractState>
    > of InternalTrait<TContractState> {
        fn _deposit(
            ref self: ComponentState<TContractState>,
            assets: u256,
            sender: ContractAddress,
            receiver: ContractAddress
        ) {
            let asset_contract = IERC20CamelDispatcher {
                contract_address: self.asset_contract.read()
            };
            let previous_contract_balance = asset_contract.balanceOf(receiver);
            asset_contract.transferFrom(sender, receiver, assets);
            assert(
                asset_contract.balanceOf(receiver) == previous_contract_balance + assets,
                TRANSFER_FAILED
            );

            IERC20MintableBurnableDispatcher { contract_address: self.shares_contract.read() }
                .mint(receiver, assets);

            self
                .emit(
                    Event::Deposit(
                        Deposit {
                            sender: get_caller_address(),
                            owner: receiver,
                            assets: assets,
                            timestamp: get_block_timestamp(),
                        }
                    )
                );
        }

        fn redeem(
            ref self: ComponentState<TContractState>, shares: u256, receiver: ContractAddress
        ) {}
    }
}
