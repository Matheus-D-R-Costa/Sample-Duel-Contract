require("dotenv").config();
const { ethers } = require("ethers");
const fs = require("fs");
const path = require("path");

// Configurações
const config = {
    rpcUrl: "https://rpc-amoy.polygon.technology",
    contractArtifact: path.resolve(
        __dirname,
        "../artifacts/contracts/P2PDuel.sol/P2PDuel.json"
    ),
    journalPath: path.resolve(
        __dirname,
        "../ignition/deployments/chain-80002/journal.jsonl"
    ),
};

function getDeployedAddress(journalPath) {
    const lines = fs.readFileSync(journalPath, "utf-8").split("\n");
    for (const line of lines) {
        if (line.includes("DEPLOYMENT_EXECUTION_STATE_COMPLETE")) {
            const obj = JSON.parse(line);
            if (obj.result && obj.result.address) {
                return obj.result.address;
            }
        }
    }
    throw new Error("Endereço do contrato não encontrado no journal.");
}

function parseArgs() {
    const [, , challenged, description, value] = process.argv;
    if (!challenged || !description || !value) {
        console.error(
            "Uso: node scripts/create-duel.js <endereco_desafiado> <descricao> <valor_em_ether>"
        );
        process.exit(1);
    }
    if (!ethers.isAddress(challenged)) {
        console.error("Endereço do desafiado inválido.");
        process.exit(1);
    }
    if (isNaN(Number(value)) || Number(value) <= 0) {
        console.error("Valor da aposta deve ser um número positivo.");
        process.exit(1);
    }
    return { challenged, description, value };
}

async function main() {
    const privateKey = process.env.PRIVATE_KEY || 'ead4264aaa1d6aed6bc6ded7dd2c6632dfafa2f00736aca50840807dd934af75';
    if (!privateKey) throw new Error("PRIVATE_KEY não definido no .env");

    const provider = new ethers.JsonRpcProvider(config.rpcUrl);
    const wallet = new ethers.Wallet(privateKey, provider);

    const contractAddress = getDeployedAddress(config.journalPath);
    const abi = JSON.parse(fs.readFileSync(config.contractArtifact, "utf-8")).abi;
    const contract = new ethers.Contract(contractAddress, abi, wallet);

    const { challenged, description, value } = parseArgs();
    const valueWei = ethers.parseEther(value);

    console.log("Enviando transação para criar aposta...");
    const tx = await contract.create(challenged, description, {
        value: valueWei,
    });
    console.log("Transação enviada. Hash:", tx.hash);
    const receipt = await tx.wait();
    console.log("Aposta criada com sucesso no bloco:", receipt.blockNumber);
}

main().catch((error) => {
    console.error("Erro ao criar aposta:", error.message);
    process.exit(1);
});
