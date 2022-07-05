//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract Dex is ERC20 {
    address public token_address;
    constructor(address _token) ERC20("tokenLP","TLP") {
        require(_token!= address(0),"its a null address");
        _token= token_address;
        
    }

    function getreserve() public view returns(uint256){
        return ERC20(token_address).balanceOf(address(this));

    }

    function addliquidity(uint256 _amount) public payable returns(uint256) {
        uint256 liquidity;
        uint256 ethbalance= address(this).balance;
        uint256 tokenreserve= getreserve();
        ERC20 token = ERC20(token_address);
//if the reserve is empty ,take any amt of token(eth an viper) coz there is no ratio
        if ( tokenreserve==0){
            token.transferFrom(msg.sender, address(this), _amount);
            //take ethbalance and mint ethbalance amt of lp token
            //liquidity provided == ethbalance(as he is the 1st provider)
            liquidity= ethbalance;
            _mint(msg.sender, liquidity);
        }
        else {
            uint256 ethreserve = ethbalance - msg.value;
            uint256 tokenamount = (msg.value * tokenreserve)/(ethreserve);
            require(_amount >= tokenamount, " amt of token is less than the token required");
            token.transferFrom(msg.sender, address(this), tokenamount);
            liquidity = (totalSupply() * msg.value)/(ethreserve);
            _mint(msg.sender, liquidity);




        }
        return liquidity;
        
    }

    function remove_liquidity(uint256 _amount) public payable returns(uint256,uint256){
        require(_amount > 0 ," the amount should be greater then zero");
        uint256 ethreserve = address(this).balance;
        uint256 ethamount = (ethreserve * _amount)/totalSupply();
        uint256 tokenamount = (getreserve() * _amount)/totalSupply();
        _burn(msg.sender, _amount);//burn lp token from user wallet
        payable(msg.sender).transfer(ethamount);
        ERC20(token_address).transfer(msg.sender, tokenamount);
        return(ethamount, tokenamount);



        
    }
//it returns amt of eth/token retured to user
    function getamttoken(uint256 inputamt, uint256 inputreserve, uint256 outputreserve) public pure returns (uint256){
        require(inputreserve>0 && outputreserve >0, "invalid");
        uint256 inputamtwithfee = inputamt * 99/100;
        return (inputamtwithfee * outputreserve)/(inputreserve + inputamtwithfee);
    }

    function ethtotoken(uint256 _mintoken) public payable{
        uint256 tokenreserve= getreserve();
        uint256 tokenbought= getamttoken(msg.value, address(this).balance - msg.value, getreserve());
        require(tokenbought > _mintoken, "insuffcient output amt");
        ERC20(token_address).transfer(msg.sender, tokenbought);

    }

    function tokentoeth(uint256 tokensold,uint256 _mineth) public payable{
        uint256 tokenreserve= getreserve();
        uint256 ethbought= getamttoken(tokensold, tokenreserve, address(this).balance);
        require(ethbought > _mineth, "insuffcient output amt");
        payable(msg.sender).transfer(ethbought);


    }

}

