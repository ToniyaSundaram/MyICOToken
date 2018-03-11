pragma solidity ^0.4.4;

contract Token {
    
    //@ returns the total amount of tokens
    function totalSupply() constant returns(uint256 supply){ }
    
    // This funciton checks the balance of the owner 
    //@Param _owner is the address from whihch the balance will be retreived
    //@return balance returns the balance 
    function balanceOf(address _owner) constant returns (uint256 balance){ }
    
    //@notice send '_value' token to '_to' from msg.sender
    //@Param _to is the address of the receiver
    //@Param _value is the amount of the token to be transferred
    //@return whether the transfer was successfull or not
    function transfer(address _to,uint256 _value)constant returns (bool success){ }
    
    //@notice sends the '_value' token from '_from' address to '_to' address on the condition it is approved by _from 
    //@Param _value is the amount of the token to be transferred
    //@Param _from is the address of the sender 
    //@Param _to address of the receiver of the tokens
    //@return whether the trans is successfull or not
    function transferFrom (address _from, address _to, uint256 _value) constant returns(bool success){ }
    
    //@notice msg.sender should approve to spend _value tokens from the address _spender
    //@Param _spender is the address from which the tokens is transferred
    //@Param _value is the amount of wei needs to be approved for transferred
    //@return whether the apprval is successfull or not
    function approve(address _spender, uint256 _value)returns (bool success){ }
    
    
    //@Param _owner is the address of the account owning the tokens
    //@Param _spender is the address of the account able to transfer tokens
    //@return amount of remaining tokens left to spend 
    function allowance(address _owner,address _spender)returns (uint256 remaining) { }
    
    event Transfer(address indexed _from, address indexed _to,uint256 _value);
    event Approval(address indexed _owner, address indexed _spender,uint256 _value);

 }
 
 contract StandardToken is Token {
    
    // Mapping the balances to thier address 
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;
    uint256 public totalSupply;
        
    function balanceOf(address _owner) constant returns (uint256 balance){
        return balances[_owner];
    }    
            
    function transfer(address _to,uint256 _value)constant returns (bool success){ 
        //Default assumes totalSupply can't  exceed (2^256-1)
        // We will issue tokens which is always less than the totalSupply
        if(balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -=_value;
            balances[_to] +=_value;
            Transfer(msg.sender,_to,_value);
            return true;
        }else {
            return false;
        }
        
    }
            
    function transferFrom(address _from, address _to,uint256 _value) constant returns(bool success) {
        //By default we assume that the totalSupply should not exceed (2^256 -1)
        //We will now mention the fromaddress which may or may not be the sender 
        if(balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0){
            balances[_from] -=_value;
            balances[_to] +=_value;
            allowed[_from][msg.sender] -=_value;
            Transfer(_from,_to,_value);
            return true;
        }else{
            return false;
        }
    }
     
    function approve(address _spender, uint256 _value)returns (bool success){ 
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender,_spender,_value);
        return true;
    }        
      
    function allowance(address _owner,address _spender,uint256 _value) constant returns(uint256 remaining) {
        return allowed[_owner][_spender];
    }             
 }
 
 
contract ToniyaCoin is StandardToken {
    string public tokenName; // tokenName
    uint8 public decimals; //  How many deceimal places to show . standard 18 
    string public symbol;  // An identifier eg: BTC, ETH
    string public version= "T1.0"; 
    uint256 public uintOneEthCanBuy;    // How many units of your coin can be bought by 1ETH 
    uint256 public totalEthinWei;       //Wei is the smallest uint of eth We'll store the total ETH raised via our ICO here.  
    address public fundsWallet;          // where should the raised ICO go          
    
    
    // A constructor which gives all initial tokens to the creater. 
    function ToniyaCoin () {
        balances[msg.sender] = 1000000000000000000000;
        totalSupply = 1000000000000000000000;   // update the tototalSupply to the initialcoins
        tokenName = "ToniyaCoin";            // Set the name for display purpose
        decimals=18;
        symbol = "TCN";
        uintOneEthCanBuy = 10;              // Set the price of your tokenName
        fundsWallet = msg.sender;            // The owner of the ETH
    }
    
    function () payable {
        totalEthinWei = totalEthinWei+msg.value;
        uint256 amount = msg.value *uintOneEthCanBuy;
        if(balances[fundsWallet] < amount) {
            return;
        }
        
        balances[fundsWallet] = balances[fundsWallet] - amount;
        balances[msg.sender] = balances[msg.sender] +amount;
        
        Transfer(fundsWallet, msg.sender,amount);   // Broadcast the message to the blockchain
        
        //Transfer funds to Eth wallet
        fundsWallet.transfer(msg.value);
    }
    
    // Approves and calls the receiving contract
    function approveAndCall(address _spender,address _to,uint256 _value, bytes _extraData) constant returns(bool success){
        allowed[msg.sender][_spender]= _value;
        Approval(msg.sender,_spender,_value);
        
        //it is assumed that when does this that the call *should* succeed, otherwise one would use vanilla approve instead.
        if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { throw; }
        return true;
        
    }

    
} 
