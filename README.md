KipuBankV2

Sistema bancario descentralizado con soporte multi-token e integración de oráculos Chainlink.

Autor: NavarroPablo96

Solidity: 0.8.30

Red: Sepolia Testnet

Contrato: 0xabc9e64f772ba79720a8844173f30a7779539741





Descripción

 	KipuBankV2 es una evolución del contrato KipuBank original.

 	Los usuarios pueden depositar y retirar ETH y tokens ERC20 en bóvedas personales, con límites de seguridad y control administrativo.







Explicación mejoras realizadas:



Control de Acceso

 	Sistema de ownership con OpenZeppelin Ownable

 	Funciones administrativas para pausar el contrato y gestionar tokens

 	Patrón Circuit Breaker para emergencias



Soporte Multi-Token

 	Depósitos y retiros de ETH y tokens ERC20

 	Whitelist de tokens permitidos gestionada por el owner

 	Mapping anidado: usuario => token => saldo

 	address(0) representa ETH nativo



Integración Chainlink

 	Límite global del banco expresado en USD (estable)

 	Conversión automática ETH → USD usando Chainlink Price Feed

 	Validación de datos del oráculo (heartbeat, precio válido)



Conversión de Decimales

 	Normalización de decimales: ETH (18) × Chainlink (8) → USD (6)

 	Fórmula: (ethAmount \* chainlinkPrice) / DECIMAL\_FACTOR

 	Contabilidad interna consistente en formato USDC



Seguridad Mejorada

 	ReentrancyGuard: Protección adicional contra ataques de reentrancy

 	SafeERC20: Maneja tokens ERC20 con comportamientos no estándar

 	Patrón CEI: Checks → Effects → Interactions en todas las funciones

 	Receive/Fallback: Previene depósitos accidentales sin tracking



Optimización de Gas

 	Contadores en bloques unchecked (no hay riesgo de overflow)

 	Errores personalizados en lugar de require con strings

 	Variables constant e immutable donde corresponde







Instrucciones de Despliegue:

 	Para el despliegue se compilo el código en remix, se utilizó

 	el compilador versión 0.8.30+commit.73712a01.

 	Luego para el despliegue, se utilizó Sepolia Testnet - MetaMask.

 	Se ingresaron los parámetros indicados abajo, se desployó el contrato

 	y se confirmó la transsación desde la wallet de MetaMask en mi cuenta.

 

Parámetros del Constructor

solidity\_bankCap: 5000000000              // 5,000 USD (6 decimales)

\_umbral: 100000000000000000000    // 100 ETH (18 decimales)

\_owner: 0x031E970bdFC93D500c2F82fDF3C09bB5C77284AC

\_priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306  // Sepolia ETH/USD



Sobre los parámetros:

La dirección \_owner es la dirección de la wallet de la persona que desplega el contrato.

La dirección \_priceFeed es la dirección de una chain link, para está dirección se busco en la siguiente página.

https://docs.chain.link/data-feeds/price-feeds/addresses?page=1\&testnetPage=1

Es esa página se busco la dirección de la chainlink que pasa ETH a USD

ETH / USD		0x694AA1769357215DE4FAC081bf1f309aDC325306



 	El contrató finalmente quedó deployado en la siguiente dirección:

 	Dirección de contrato:	0xabc9e64f772ba79720a8844173f30a7779539741



 	Ir a Etherscan → Verify and Publish

 	Para la verifición y validación se utilizó etherscan:

 	https://sepolia.etherscan.io/address/0xabc9e64f772ba79720a8844173f30a7779539741#code

 	Fue necesario en Remix generar un archivo kipubankV2\_flattened.sol que agregó todos los

 	import al código en un solo archivo.











Decisiones de Diseño:



Variables Inmutables

 	Decisión: i\_bankCap e i\_umbral permanecen inmutables.

 	Justificación: Prioriza seguridad sobre flexibilidad. Los usuarios confían en que los límites no cambiarán arbitrariamente. Para ajustarlos, es necesario redesplegar.



Límite en USD vs ETH

 	Decisión: Límite global expresado en USD.

 	Justificación: Protege el banco de la volatilidad del ETH. Un cap de 5,000 USD siempre es 5,000 USD, independientemente del precio de ETH.

 	Trade-off: Dependencia de Chainlink y mayor costo de gas (~5,000 gas adicional por depósito ETH).



Whitelist de Tokens

 	Decisión: Solo tokens aprobados por el owner.

 	Justificación: Previene tokens maliciosos o con vulnerabilidades conocidas.

 	Trade-off: Centralización en el owner para decidir qué tokens aceptar.



ReentrancyGuard + CEI

 	Decisión: Usar ambos mecanismos.

 	Justificación: Defense in depth. CEI bien implementado debería ser suficiente, pero ReentrancyGuard añade una capa extra de seguridad.

 	Trade-off: ~2,400 gas adicional por transacción.

