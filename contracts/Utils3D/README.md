# Fixedpoint32x32.sol
Fixedpoint32x32.sol is a reduced persicion of Fixedpoint64x64.sol and give the contract to reduce the size of the storage needed for vectors by half. and provide neccesary interface to make to cast it to fixedpoint64x64.sol, so it's possible to use [ABDKMath64x64.sol](https://github.com/abdk-consulting/abdk-libraries-solidity)
