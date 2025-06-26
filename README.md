# Electrical-Energy-Trading-Dapp
Decentralized P2P Energy Trading DApp | Ethereum Smart Contracts | Real-time Market Pricing
# ⚡ Energy Trading DApp

A decentralized peer-to-peer energy marketplace built on Ethereum using Solidity and Ethers.js. This DApp allows users to **list**, **buy**, **bid**, and **match** energy offers securely using smart contracts.

---

## 🚀 Features

- 🔗 **Connect Wallet:** Seamless MetaMask integration  
- 📤 **List Offers:** Sellers can list energy units at their desired price  
- 💰 **Place Bids:** Buyers can place custom bids  
- 🛒 **Direct Buy:** Buy energy directly at the seller’s price  
- 🔄 **Match Trades:** Match bids with offers manually  
- 📊 **Market Clearing Price:** View real-time MCP based on listed offers  
- ❌ **Cancel Offers/Bids:** Cancel your listings if not fulfilled  
- 📄 **Trade History:** View your past transactions (via events)

---

## 🧠 Smart Contract

The smart contract is written in **Solidity (v0.8.19)** and includes:

- Structs for `EnergyOffer` and `EnergyBid`
- Full support for market matching and bid escrow
- Dynamic **Market Clearing Price (MCP)** calculation
- Secure ETH handling and refund logic
- Event emissions for all major actions

📄 `EnergyTrading.sol` is available in this repository.

---

## 🖥️ Frontend (HTML + JS)

Built with vanilla **JavaScript** using **Ethers.js** for blockchain interaction.

- Clean and responsive UI  
- Dark/light theme toggle 🌗  
- Real-time data fetching and blockchain transactions  
- Works as a static DApp (just open `index.html` in a browser)

📁 `index.html` is your entry point.

---

## 🧪 How to Run Locally

### 1. Clone the Repo  
Open your terminal and run: 
    
     git clone https://github.com/yourusername/energy-trading-dapp.git
     cd energy-trading-dapp


### 2. Install MetaMask
Download and install the MetaMask browser extension from the official website:
👉 https://metamask.io/

### 3. Deploy Smart Contract (Optional)
       Open Remix IDE

       Create a new file and paste the contents of EnergyTrading.sol

       Compile and deploy the contract to a local or test network (e.g., Sepolia)

       Copy the deployed contract address

       Replace the address in index.html where:

       const contractAddress = "your_deployed_contract_address";
### 4. Run the Frontend
     You can either:

    ✅ Option A: Open Directly
      Simply open index.html in your browser.

    ✅ Option B: Run via Local Server
       For better compatibility:


Then open the provided localhost URL (e.g., http://localhost:3000) in your browser.

⚠️ Ensure MetaMask is connected to the same network used during contract deployment.


