# Sample Duel Contract

Este projeto demonstra o uso básico do Hardhat com um contrato de exemplo (`P2PDuel`) e um módulo de deploy usando o Hardhat Ignition.

## Como o contrato P2PDuel funciona

O contrato `P2PDuel` permite que dois participantes realizem duelos apostando valores em Ether. O fluxo básico é:

1. **Criação do duelo:** Um usuário desafia outro, informando o endereço e uma descrição, e envia um valor em Ether como aposta.
2. **Aceitação:** O desafiado pode aceitar o duelo enviando o mesmo valor apostado. O duelo se torna ativo.
3. **Finalização:** Um dos participantes pode aceitar a derrota, e o vencedor recebe todo o valor apostado.
4. **Cancelamento:** Se o duelo não for aceito dentro do prazo, pode ser cancelado e o valor é devolvido ao desafiante.

Principais funções:
- `create(address _challenged, string calldata _description)`: Cria um novo duelo.
- `accept(uint256 _id)`: Aceita um duelo existente.
- `acceptDefeat(uint256 _id)`: Um participante aceita a derrota, transferindo o prêmio ao vencedor.
- `cancel(uint256 _id)`: Cancela um duelo não aceito no prazo.

## Passo a passo para rodar localmente

1. **Clone o repositório:**
   ```shell
   git clone <url-do-repositorio>
   cd hardhat-sample-project
   ```
2. **Instale as dependências:**
   ```shell
   yarn install
   # ou
   npm install
   ```
3. **Compile os contratos:**
   ```shell
   npx hardhat compile
   ```
4. **Execute a rede local do Hardhat:**
   ```shell
   npx hardhat node
   ```
5. **Abra outro terminal e faça o deploy do contrato:**
   ```shell
   npx hardhat ignition deploy ./ignition/modules/P2PDuel.js
   ```

> **NOTA**: Certifique-se de que sua configuração de rede e variáveis de ambiente (como chaves privadas) estejam corretas antes de executar o deploy.
