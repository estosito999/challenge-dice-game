// Indica la versión de Solidity permitida para compilar este contrato.
// Aquí acepta cualquier versión desde 0.8.0 hasta menor que 0.9.0.
pragma solidity >=0.8.0 <0.9.0;

// Licencia del código. MIT es una licencia permisiva.
 //SPDX-License-Identifier: MIT

// Importa console.log de Hardhat.
// Solo sirve para pruebas en desarrollo, no para producción real en blockchain.
import "hardhat/console.sol";

// Define el contrato llamado DiceGame.
contract DiceGame {

    // Sección visual para agrupar errores personalizados.
    /////////////////
    /// Errors //////
    /////////////////

    // Error personalizado que se lanza cuando envían menos ETH del requerido.
    error NotEnoughEther();

    // Sección visual para variables de estado.
    //////////////////////
    /// State Variables //
    //////////////////////

    // Guarda cuántas veces se ha lanzado el dado.
    // Empieza en 0.
    uint256 public nonce = 0;

    // Guarda el premio actual que se entregará al ganador.
    // Empieza en 0, pero se actualiza en el constructor.
    uint256 public prize = 0;

    // Sección visual para eventos.
    ////////////////
    /// Events /////
    ////////////////

    // Evento que se emite cada vez que alguien tira el dado.
    // Guarda:
    // - la dirección del jugador
    // - cuánto ETH apostó
    // - qué número salió
    event Roll(address indexed player, uint256 amount, uint256 roll);

    // Evento que se emite cuando alguien gana.
    // Guarda:
    // - la dirección del ganador
    // - cuánto premio recibió
    event Winner(address winner, uint256 amount);

    // Sección visual para el constructor.
    ///////////////////
    /// Constructor ///
    ///////////////////

    // El constructor se ejecuta una sola vez al desplegar el contrato.
    // "payable" permite que el contrato reciba ETH al momento del deploy.
    constructor() payable {
        // Llama a resetPrize para calcular el premio inicial.
        resetPrize();
    }

    // Sección visual para funciones.
    ///////////////////
    /// Functions /////
    ///////////////////

    // Función privada: solo puede usarse dentro del contrato.
    // Recalcula el premio actual.
    function resetPrize() private {

        // El premio será el 10% del balance actual del contrato.
        // address(this).balance = cuánto ETH tiene el contrato.
        // * 10 / 100 = 10%
        prize = ((address(this).balance * 10) / 100);
    }

    // Función principal para tirar el dado.
    // Es pública: cualquiera puede llamarla.
    // Es payable: quien la llama puede enviar ETH.
    function rollTheDice() public payable {

        // Verifica que el usuario envió al menos 0.002 ETH.
        // Si envió menos, revierte la transacción.
        if (msg.value < 0.002 ether) {
            revert NotEnoughEther();
        }

        // Obtiene el hash del bloque anterior.
        // block.number - 1 = bloque inmediatamente anterior.
        bytes32 prevHash = blockhash(block.number - 1);

        // Crea un nuevo hash usando:
        // - el hash del bloque anterior
        // - la dirección de este contrato
        // - el nonce actual
        // Esto intenta generar un número "aleatorio".
        bytes32 hash = keccak256(abi.encodePacked(prevHash, address(this), nonce));

        // Convierte el hash a uint256 y toma módulo 16.
        // Así obtiene un número entre 0 y 15.
        uint256 roll = uint256(hash) % 16;

        // Muestra en consola de Hardhat el resultado del dado.
        // Esto solo se ve en entorno local de desarrollo.
        console.log("\t", "   Dice Game Roll:", roll);

        // Incrementa el nonce para que la próxima tirada use otro valor.
        nonce++;

        // Aumenta el premio con el 40% de lo que envió el jugador.
        prize += ((msg.value * 40) / 100);

        // Emite el evento Roll para registrar quién jugó,
        // cuánto apostó y qué número salió.
        emit Roll(msg.sender, msg.value, roll);

        // Si el número salió mayor que 5, el jugador pierde.
        // Como aquí hace return, la función termina y no paga premio.
        if (roll > 5) {
            return;
        }

        // Si llegó hasta aquí, el jugador ganó.
        // Guarda el premio actual en la variable amount.
        uint256 amount = prize;

        // Envía el premio al jugador que llamó la función.
        // msg.sender = quien ejecutó rollTheDice()
        (bool sent, ) = msg.sender.call{ value: amount }("");

        // Verifica que el envío fue exitoso.
        // Si no, revierte con ese mensaje.
        require(sent, "Failed to send Ether");

        // Después de pagar, recalcula el premio base otra vez.
        resetPrize();

        // Emite el evento Winner indicando quién ganó y cuánto recibió.
        emit Winner(msg.sender, amount);
    }

    // Función especial receive.
    // Permite que el contrato reciba ETH directamente sin llamar otra función.
    receive() external payable {}
}