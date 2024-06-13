use starknet::ContractAddress;

#[starknet::interface]
trait IOwnable<TContractState> {
    fn get_owner(self: @TContractState) -> ContractAddress;
    fn transfer_ownership(ref self: TContractState, new_owner: ContractAddress);
}

#[starknet::component]
pub mod Ownable {
    use core::num::traits::zero::Zero;
    use starknet::{ContractAddress, get_caller_address};
    
    #[storage]
    struct Storage {
        
    }

    
}