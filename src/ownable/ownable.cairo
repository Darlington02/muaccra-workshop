use starknet::ContractAddress;

#[starknet::interface]
trait IOwnable<TContractState> {
    fn initializer(ref self: TContractState, owner: ContractAddress);
    fn get_owner(self: @TContractState) -> ContractAddress;
    fn transfer_ownership(ref self: TContractState, new_owner: ContractAddress);
}

#[starknet::component]
pub mod Ownable {
    use core::num::traits::zero::Zero;
    use starknet::{ContractAddress, get_caller_address};
    
    #[storage]
    struct Storage {
        owner: ContractAddress
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        OwnershipTransferred: OwnershipTransferred
    }

    #[derive(Drop, starknet::Event)]
    struct OwnershipTransferred {
        prev_owner: ContractAddress,
        new_owner: ContractAddress
    }
    
    #[embeddable_as(Ownable)]
    impl OwnableImpl<
        TContractState,
        +HasComponent<TContractState>
    > of super::IOwnable<ComponentState<TContractState>> {
        fn initializer(ref self: ComponentState<TContractState>, owner: ContractAddress) {
            self.owner.write(owner);
        }
        fn get_owner(self: @ComponentState<TContractState>) -> ContractAddress {
            self.owner.read()
        }

        fn transfer_ownership(ref self: ComponentState<TContractState>, new_owner: ContractAddress) {
            let owner = self.owner.read();
            assert(new_owner.is_non_zero(), 'owner is a zero address');
            assert(get_caller_address() == owner, 'caller is not owner');
            self.owner.write(new_owner);
            self.emit(
                OwnershipTransferred {
                    prev_owner: owner,
                    new_owner
                }
            );
        }
    }
}