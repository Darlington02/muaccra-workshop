# Installation

## Scarb
Linux & macOS - `curl --proto '=https' --tlsv1.2 -sSf https://docs.swmansion.com/scarb/install.sh | sh`

Windows installation - https://docs.swmansion.com/scarb/download.html#windows

​asdf​ - a CLI tool that can manage multiple language runtime versions on a per-project basis. `asdf plugin add scarb`

## Resources 
- Cairo Book: Components - https://book.cairo-lang.org/ch16-02-00-composability-and-components.html
- Cairo Book: Cross-contract interaction - https://book.cairo-lang.org/ch15-00-starknet-cross-contract-interactions.html

# Introduction to Components
Before the introduction of components on Starknet, composability was difficult to achieve on Starknet.
Think of components as lego blocks, modular add-ons encapsulating reusable logic, storage, and events that can be incorporated into multiple contracts. They can be used to extend a contract's functionality, without having to reimplement the same logic over and over again.

## Architecture of a Component
A component is very similar to a contract. It can contain:
- Storage variables
- Events
- External and internal functions
  
But unlike a contract, a component cannot be deployed on its own. The component's code becomes part of the contract it's embedded to.

```rust
#[starknet::component]
pub mod ownable_component {
    use starknet::ContractAddress;
    use starknet::get_caller_address;
    use super::Errors;
    use core::num::traits::Zero;

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
        previous_owner: ContractAddress,
        new_owner: ContractAddress,
    }

    #[embeddable_as(Ownable)]
    impl OwnableImpl<
        TContractState, +HasComponent<TContractState>
    > of super::IOwnable<ComponentState<TContractState>> {
        fn owner(self: @ComponentState<TContractState>) -> ContractAddress {
            self.owner.read()
        }

        fn transfer_ownership(
            ref self: ComponentState<TContractState>, new_owner: ContractAddress
        ) {
            assert(!new_owner.is_zero(), Errors::ZERO_ADDRESS_OWNER);
            self.assert_only_owner();
            self._transfer_ownership(new_owner);
        }

        fn renounce_ownership(ref self: ComponentState<TContractState>) {
            self.assert_only_owner();
            self._transfer_ownership(Zero::zero());
        }
    }
}
```

# Introduction to Cross-contract interactions
Cross-contract interaction enables contracts communicate with each other. To understand how this is made possible, we need to take a look at ABIs and Interfaces.

## Application Binary Interface (ABIs)
On Starknet, the ABI of a contract is a JSON representation of the contract's functions and structures, giving anyone (or any other contract) the ability to form encoded calls to it. It is a blueprint that instructs how functions should be called, what input parameters they expect, and in what format.

## Interfaces
The interface of a contract is a list of the functions it exposes publicly. It specifies the function signatures (name, parameters, visibility and return value) contained in a smart contract without including the function body.


Contract interfaces in Cairo are traits annotated with the #[starknet::interface] attribute and this trait must be generic over the `TContractState` type.

```rust
use starknet::ContractAddress;

#[starknet::interface]
trait IERC20<TContractState> {
    fn name(self: @TContractState) -> felt252;

    fn symbol(self: @TContractState) -> felt252;

    fn decimals(self: @TContractState) -> u8;

    fn total_supply(self: @TContractState) -> u256;

    fn balance_of(self: @TContractState, account: ContractAddress) -> u256;

    fn allowance(self: @TContractState, owner: ContractAddress, spender: ContractAddress) -> u256;

    fn transfer(ref self: TContractState, recipient: ContractAddress, amount: u256) -> bool;

    fn transfer_from(
        ref self: TContractState, sender: ContractAddress, recipient: ContractAddress, amount: u256
    ) -> bool;

    fn approve(ref self: TContractState, spender: ContractAddress, amount: u256) -> bool;
}
```

## Dispatchers
Each time a contract interface is defined, two dispatchers are automatically created and exported by the compiler:

- The Contract Dispatcher
- The Library Dispatcher
  
The compiler also generates a trait IERC20DispatcherTrait, allowing us to call the functions defined in the interface on the dispatcher struct.

The difference between both Dispatchers, is while one calls function on a contract (stateful), the other calls functions on a class (stateless).

E.g of calling contracts using the contract dispatcher:
```
IERC20Dispatcher { contract_address }.transfer(recipient, amount);
```

E.g of calling contracts using the library dispatcher:
```
IContractALibraryDispatcher { class_hash: class_hash }.set_value(value)
```

Another way to call other contracts and classes is to use the `starknet::call_contract_syscall` and `starknet::library_call_syscall` system calls. The dispatchers we described in the previous sections are high-level syntaxes for these low-level system calls.
