// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

// We take Audius as an example. For more details, you can refer to Audius Governance Takeover Post-Mortem 7/23/22 and Remediation.
// https://blog.audius.co/article/audius-governance-takeover-post-mortem-7-23-22

interface ILogic {
    function getguardianAddress() external returns (address);

    function getproxyAdmin() external returns (address);

    function initialize(address) external;

    function getinitializing() external returns (bool);

    function getinitialized() external returns (bool);

    function isConstructor() external view returns (bool);
}



contract TestProxy is TransparentUpgradeableProxy {
    address private proxyAdmin; // slot 0 - storage collision here

    constructor(
        address _logic,
        address _admin,
        address guardianAddress
    )
        TransparentUpgradeableProxy(
            _logic,
            _admin,
            abi.encodeWithSelector(
                bytes4(0xc4d66de8), // bytes4(keccak256("initialize(address)"))
                guardianAddress
            )
        )
    {
        proxyAdmin = _admin;
    }
}

contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private initializing;

    /**
     * @dev Modifier to use in the initializer function of a contract.
     */
    modifier initializer() {
        require(
            initializing || isConstructor() || !initialized,
            "Contract instance has already been initialized"
        );

        bool isTopLevelCall = !initializing;
        if (isTopLevelCall) {
            initializing = true;
            initialized = true;
        }

        _;

        if (isTopLevelCall) {
            initializing = false;
        }
    }

    /// @dev Returns true if and only if the function is running in the constructor
    function isConstructor() private view returns (bool) {
        // extcodesize checks the size of the code stored in an address, and
        // address returns the current address. Since the code is still not
        // deployed when running a constructor, any checks on its code size will
        // yield zero, making it an effective way to detect if a contract is
        // under construction or not.
        address self = address(this);
        uint256 cs;
        assembly {
            cs := extcodesize(self)
        }
        return cs == 0;
    }

    // Reserved storage space to allow for layout changes in the future.
    uint256[50] private ______gap;

    function getinitializing() public view returns (bool) {
        return initializing;
    }

    function getinitialized() public view returns (bool) {
        return initialized;
    }
}

contract Logic is Initializable {
    address private guardianAddress;

    function initialize(address _guardianAddress) public initializer {
        guardianAddress = _guardianAddress; //Guardian address becomes the only party
    }

    function getguardianAddress() public view returns (address) {
        return guardianAddress;
    }
}