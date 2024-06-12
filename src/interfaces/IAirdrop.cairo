use starknet::ContractAddress;

#[starknet::interface]
pub trait IAirdrop<TState> {
    fn register(ref self: TState);
    fn claim(ref self: TState, address: ContractAddress);
    fn is_registered(self: @TState, address: ContractAddress) -> bool;
}