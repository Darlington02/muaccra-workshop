#[starknet::contract]
mod Airdrop {
    use starknet::{ContractAddress, get_block_timestamp, get_contract_address, get_caller_address};

    use people::interfaces::IERC20::{IERC20Dispatcher, IERC20DispatcherTrait};
    use people::interfaces::IAirdrop::IAirdrop;

    #[storage]
    struct Storage {
        token_address: ContractAddress,
        registered_address: LegacyMap::<ContractAddress, bool>,
        claimed_address: LegacyMap::<ContractAddress, bool>,
        airdrop_start_time: u64,
        airdrop_end_time: u64,
    }

    const REGPRICE: u256 = 1000000000000000;
    const ICO_DURATION: u64 = 86400_u64;
    const ETH_ADDRESS: felt252 = 0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7;

    #[constructor]
    fn constructor (
        ref self: ContractState,
        token_address: ContractAddress,
    ) {
        self.token_address.write(token_address);

        let current_time: u64 = get_block_timestamp();
        let end_time: u64 = current_time + ICO_DURATION;
        self.airdrop_start_time.write(current_time);
        self.airdrop_end_time.write(end_time);
    }

    #[abi(embed_v0)]
    impl AirdropImpl of IAirdrop<ContractState> {
        fn register(ref self: ContractState) {
            // TODO: check ICO has not ended
            // TODO: check user is not already registered
            // TODO: transfer REGPRICE from caller to this contract
        }

        fn claim(ref self: ContractState, address: ContractAddress) {
            // TODO: check that user is registered
            // TODO: check that ICO has ended
            // TODO: check that user has not previously claimed
            // TODO: transfer PEOPLE token from contract to user
        }

        fn is_registered(self: @ContractState, address: ContractAddress) -> bool {
            // TOOD: check user's registration status
            false
        }
    }
}