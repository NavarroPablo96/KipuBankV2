//SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

//Versión KipubankV2

/*///////////////////////   Imports   ///////////////////////*/
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol"; 

/*///////////////////////  Libraries   ///////////////////////*/
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/*///////////////////////  Interfaces  ///////////////////////*/
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

/*
 @title Contrato KipuBankV2
 @author NavarroPablo96
 @notice Este contrato es una recreación del contrato KipuBank,
 en este contrato los usuarios pueden depositar y retirar fondos de su boveda personal.
 */
contract KipuBank is Ownable, ReentrancyGuard {

/*///////////////////////   DECLARACIÓN DE TIPOS    ///////////////////////*/
    using SafeERC20 for IERC20;


/*///////////////////////////////////     Variables      ///////////////////////////////////*/

    /// @notice Almacena el saldo de cada usuario por tipo de token.
    /// @dev Mapping anidado: dirección del usuario => dirección del token => saldo en Wei/unidades mínimas.
    /// @dev Usa address(0) para representar ETH nativo. Otras direcciones corresponden a tokens ERC20.
    mapping(address usuario => mapping(address token => uint256 saldo)) public s_bovedas;
    
    /// @notice Indica si el contrato está pausado
    /// @dev Cuando es true, se bloquean depósitos y retiros
    bool public s_pausado;

    /// @notice Mapping de tokens ERC20 permitidos
    /// @dev true si el token está en la whitelist, false en caso contrario
    mapping(address token => bool permitido) public s_tokensPermitidos;

    //Actualización de Price Feed
    /// @notice Dirección del Chainlink Price Feed para ETH/USD
    AggregatorV3Interface public s_priceFeed;

    //CONVERSION DE DECIMALES
    ///@notice Variable constante para almacenar el factor de decimales
    ///@dev Se usa para convertir de (ETH 18 decimales * Chainlink 8 decimales) a USDC 6 decimales
    ///@dev Cálculo: 10^(18 + 8 - 6) = 10^20
    uint256 constant DECIMAL_FACTOR = 1 * 10 ** 20;

    ///@notice Constante para almacenar el latido (heartbeat) del Data Feed ETH/USD
    ///@dev Si la última actualización supera este tiempo, el precio se considera obsoleto
    uint16 constant ORACLE_HEARTBEAT = 3600; // 1 hora en segundos

    /// @notice Límite máximo global del banco expresado en USD (6 decimales)
    /// @dev Variable inmutable establecida en el constructor. Representa el cap en términos de USDC.
    uint256 public immutable i_bankCap;
    
    /// @notice Límite máximo de Ether (en Wei) que un usuario puede retirar en una sola transacción.
    /// @dev Variable inmutable establecida en el constructor.
    uint256 public immutable i_umbral;

    /// @notice El número total de depósitos exitosos realizados en el contrato KipuBank.
    /// @dev Variable de estado que se incrementa en cada llamada exitosa a la función deposito().
    uint256 public s_CantDepositos;

    /// @notice El número total de retiros exitosos realizados en el contrato KipuBank.
    /// @dev Variable de estado que se incrementa en cada llamada exitosa a la función retiro().
    uint256 public s_CantRetiros;

/*/////////////////////////////////// Events ///////////////////////////////////*/
    event DepositoExitoso(address indexed usuario, address indexed token, uint256 cantidad);
    event RetiroExitoso(address indexed usuario, address indexed token, uint256 cantidad);
    //Pausado
    event ContratoPausado(address indexed admin);
    event ContratoReanudado(address indexed admin); 
    //WhiteList de Tokens
    event TokenAgregado(address indexed token);
    event TokenRemovido(address indexed token);
    //Actualización de Price Feed
    event PriceFeedActualizado(address indexed nuevoPriceFeed);
/*/////////////////////////////////// Errors ///////////////////////////////////*/
    error BankCapExcedido(uint256 TotalActual, uint256 Limite);
    error UmbralExcedido();
    error SaldoInsuficiente();
    //Pausado
    error ContratoEstaPausado();
    //WhiteList de Tokens
    error TokenNoPermitido(address token);
    //CONVERSION DE DECIMALES
    ///@notice Error emitido cuando el retorno del oráculo es incorrecto
    error KipuBank_OracleCompromised();
    ///@notice Error emitido cuando la última actualización del oráculo supera el heartbeat
    error KipuBank_StalePrice();
/*/////////////////////////////////// Modifiers ///////////////////////////////////*/

    /// @notice Verifica que el depósito propuesto no exceda el límite global de Ether (BANK_CAP) del contrato.
    modifier verificaBankCap() {
        // La verificación utiliza el saldo actual del contrato(balancaActualUSD) MÁS el deposito (depositoUSD)
        // que se intenta enviar.Si la suma supera el límite, se revierte.
        
        // Convertir balance actual de ETH a USD
        uint256 balanceActualUSD = convertirEthEnUSD(address(this).balance);
        // Convertir el depósito entrante a USD
        uint256 depositoUSD = convertirEthEnUSD(msg.value);
        // Verificar límite en USD
        if (balanceActualUSD + depositoUSD > i_bankCap) {
            revert BankCapExcedido(balanceActualUSD + depositoUSD, i_bankCap);
        }
        _;
    }

    /// @notice Verifica que el monto de retiro solicitado no exceda el umbral máximo (UMBRAL) por transacción.
    /// @param _cantidad La cantidad de Ether (en Wei) que el usuario intenta retirar.
    modifier verificaUmbral(uint256 _cantidad) {
        if (_cantidad > i_umbral) {
            revert UmbralExcedido();
        }
        _;
    }

    /// @notice Verifica que el contrato no esté pausado
    modifier cuandoNoPausado() {
        if (s_pausado) {
            revert ContratoEstaPausado();
        }
        _;
    }

/*/////////////////////////////////// Functions ///////////////////////////////////*/

    /**
    * @notice Permite a los usuarios depositar tokens nativos (ETH) en su bóveda personal
    * @dev Verifica el límite global del banco en USD antes de aceptar el depósito
    * @dev Sigue el patrón CEI: actualiza estado antes de emitir eventos
    * @custom:security Protegida contra reentrancy con nonReentrant
    * @custom:security Verifica límite global mediante verificaBankCap que consulta Chainlink
    */
    function depositoETH() external payable verificaBankCap cuandoNoPausado nonReentrant  {
        s_bovedas[msg.sender][address(0)] += msg.value;
        unchecked { s_CantDepositos++; }
        emit DepositoExitoso(msg.sender, address(0), msg.value);
    }

        
    /**
    * @notice Permite a los usuarios depositar tokens ERC20 en su bóveda personal
    * @dev Utiliza SafeERC20 para manejar tokens con comportamientos no estándar
    * @dev Sigue el patrón CEI: checks → interactions → effects
    * @param _token Dirección del contrato del token ERC20 a depositar
    * @param _cantidad Cantidad de tokens a depositar en sus unidades mínimas
    * @custom:security Protegida contra reentrancy con nonReentrant
    * @custom:security Solo acepta tokens en la whitelist (s_tokensPermitidos)
    * @custom:security Usa SafeERC20.safeTransferFrom para proteger contra tokens maliciosos
    */
    function depositoToken(address _token, uint256 _cantidad) external cuandoNoPausado nonReentrant   {

        require(_cantidad > 0, "Cantidad debe ser mayor a 0");
        if (!s_tokensPermitidos[_token]) {
            revert TokenNoPermitido(_token);
        }

        IERC20(_token).safeTransferFrom(msg.sender, address(this), _cantidad);

        s_bovedas[msg.sender][_token] += _cantidad;
        unchecked { s_CantDepositos++; }
        emit DepositoExitoso(msg.sender, _token, _cantidad);
    }


    /**
    * @notice Permite a los usuarios retirar tokens nativos (ETH) de su bóveda personal
    * @dev Sigue el patrón CEI: checks → effects → interactions
    * @param _cantidad La cantidad de ETH (en Wei) que el usuario desea retirar
    * @custom:security Protegida contra reentrancy con nonReentrant
    * @custom:security Actualiza saldo ANTES de transferir ETH (previene reentrancy)
    * @custom:security Usa call{value} en lugar de transfer para mayor compatibilidad
    */
    function retiroETH(uint256 _cantidad) external verificaUmbral(_cantidad) cuandoNoPausado nonReentrant   {
        _verificarSaldo(msg.sender, address(0), _cantidad);
        s_bovedas[msg.sender][address(0)] -= _cantidad;
        unchecked { s_CantRetiros++; }
        emit RetiroExitoso(msg.sender, address(0), _cantidad);
        (bool exito, ) = payable(msg.sender).call{value: _cantidad}("");
        require(exito, "Transferencia ETH fallida");
    }

    /**
    * @notice Permite a los usuarios retirar tokens ERC20 de su bóveda personal
    * @dev Sigue el patrón CEI: checks → effects → interactions
    * @dev Utiliza SafeERC20.safeTransfer para manejar tokens no estándar
    * @param _token Dirección del contrato del token ERC20 a retirar
    * @param _cantidad La cantidad de tokens a retirar en sus unidades mínimas
    * @custom:security Protegida contra reentrancy con nonReentrant
    * @custom:security Actualiza saldo ANTES de transferir tokens (previene reentrancy)
    */
    function retiroToken(address _token, uint256 _cantidad) external verificaUmbral(_cantidad) cuandoNoPausado nonReentrant   {
        _verificarSaldo(msg.sender, _token, _cantidad);
        s_bovedas[msg.sender][_token] -= _cantidad;
        unchecked { s_CantRetiros++; }
        emit RetiroExitoso(msg.sender, _token, _cantidad);
        IERC20(_token).safeTransfer(msg.sender, _cantidad);
    }

    /**
    * @notice Devuelve el límite disponible en USD que aún se puede depositar en el banco
    * @dev Calcula la diferencia entre i_bankCap y el balance actual convertido a USD
    * @dev Utiliza el precio de ETH/USD obtenido del oráculo de Chainlink
    * @return limiteDisponible_ Cantidad en USD (6 decimales, formato USDC) disponible antes de alcanzar el cap
    */
    function obtenerLimiteDisponible() public view returns (uint256 limiteDisponible_) {
        uint256 balanceActualUSD = convertirEthEnUSD(address(this).balance);
        
        if (balanceActualUSD >= i_bankCap) {
            return 0;
        }
        
        limiteDisponible_ = i_bankCap - balanceActualUSD;
    }

//Funciones Administrativas onlyOwner:
    /**
    * @notice Pausa todas las operaciones del contrato en caso de emergencia
    * @dev Solo puede ser llamada por el owner
    * @dev Activa s_pausado que bloquea depósitos y retiros mediante cuandoNoPausado
    * @custom:access Restringida al owner mediante onlyOwner
    * @custom:security Patrón Circuit Breaker para detener operaciones en caso de vulnerabilidad
    */
    function pausar() external onlyOwner {
        s_pausado = true;
        emit ContratoPausado(msg.sender);
    }

    /**
    * @notice Reanuda las operaciones del contrato después de una pausa
    * @dev Solo puede ser llamada por el owner
    * @dev Desactiva s_pausado permitiendo depósitos y retiros nuevamente
    * @custom:access Restringida al owner mediante onlyOwner
    */
    function despausar() external onlyOwner {
        s_pausado = false;
        emit ContratoReanudado(msg.sender);
    }

    /**
    * @notice Permite al owner añadir tokens ERC20 a la whitelist de tokens permitidos
    * @dev Solo puede ser llamada por el owner
    * @param _token Dirección del contrato del token ERC20 a agregar
    * @custom:access Restringida al owner mediante onlyOwner
    * @custom:security Previene address(0) para evitar confusión con ETH
    */
    function agregarTokenPermitido(address _token) external onlyOwner {
        require(_token != address(0), "Token invalido");
        s_tokensPermitidos[_token] = true;
        emit TokenAgregado(_token);
    }

    /**
    * @notice Permite al owner remover tokens ERC20 de la whitelist
    * @dev Solo puede ser llamada por el owner
    * @dev No afecta depósitos ya realizados, solo previene nuevos depósitos
    * @param _token Dirección del contrato del token a remover de la whitelist
    * @custom:access Restringida al owner mediante onlyOwner
    */
    function removerTokenPermitido(address _token) external onlyOwner {
        s_tokensPermitidos[_token] = false;
        emit TokenRemovido(_token);
    }

    /**
    * @notice Permite al owner actualizar la dirección del Chainlink Price Feed
    * @dev Solo puede ser llamada por el owner
    * @dev Útil si el price feed de Chainlink cambia o se depreca
    * @param _nuevoPriceFeed Nueva dirección del contrato AggregatorV3Interface
    * @custom:access Restringida al owner mediante onlyOwner
    * @custom:security Valida que la dirección no sea address(0)
    */
    function actualizarPriceFeed(address _nuevoPriceFeed) external onlyOwner {
        require(_nuevoPriceFeed != address(0), "Direccion invalida");
        s_priceFeed = AggregatorV3Interface(_nuevoPriceFeed);
        emit PriceFeedActualizado(_nuevoPriceFeed);
    }

/*/////////////////////////////////// Receive & Fallback ///////////////////////////////////*/

    /**
    * @notice Permite al contrato recibir ETH directamente sin datos
    * @dev Se ejecuta cuando se envía ETH sin calldata
    */
    receive() external payable {
        // Rechazar depósitos directos
        revert("Usar depositoETH() para depositar");
    }

    /**
    * @notice Maneja llamadas a funciones inexistentes o con calldata
    * @dev Se ejecuta cuando se llama a una función que no existe
    */
    fallback() external payable {
        revert("Funcion no existe");
    }

/*///////////////////////// constructor /////////////////////////*/
    /**
    * @notice Construye e inicializa el contrato KipuBank.
    * @dev Establece de forma permanente el límite global de depósitos en USD y el umbral de retiro.
    * @param _bankCap El límite máximo en USD (6 decimales, formato USDC) que el contrato puede contener.
    * @param _umbral El monto máximo de ETH (en Wei) que un usuario puede retirar en una sola transacción.
    * @param _owner La dirección del propietario del contrato.
    * @param _priceFeed La dirección del Chainlink Price Feed ETH/USD.
    */
    constructor(uint256 _bankCap, uint256 _umbral, address _owner, address _priceFeed) Ownable(_owner) {
        require(_bankCap > 0, "Bank cap debe ser mayor a 0");
        require(_umbral > 0, "Umbral debe ser mayor a 0");
        require(_priceFeed != address(0), "Price feed invalido");

        i_bankCap = _bankCap;
        i_umbral = _umbral;
        s_CantDepositos = 0;
        s_CantRetiros = 0;
        //CONVERSION DE DECIMALES
        s_priceFeed = AggregatorV3Interface(_priceFeed); 
    }

/*///////////////////////// internal /////////////////////////*/

    /**
    * @notice Consulta el precio actual de ETH en USD desde el oráculo de Chainlink
    * @dev Verifica que el precio sea válido (> 0) y no esté obsoleto (< ORACLE_HEARTBEAT)
    * @dev Esta es una implementación simplificada sin manejo de rounds
    * @return ethUSDPrice_ El precio de ETH en USD con 8 decimales
    * @custom:security Revierte si ethUSDPrice <= 0 (KipuBank_OracleCompromised)
    * @custom:security Revierte si updatedAt > ORACLE_HEARTBEAT (KipuBank_StalePrice)
    */
    function chainlinkFeed() internal view returns (uint256 ethUSDPrice_) { //CONVERSION DE DECIMALES
        (, int256 ethUSDPrice,, uint256 updatedAt,) = s_priceFeed.latestRoundData();

        if (ethUSDPrice <= 0) revert KipuBank_OracleCompromised();
        if (block.timestamp - updatedAt > ORACLE_HEARTBEAT) revert KipuBank_StalePrice();

        ethUSDPrice_ = uint256(ethUSDPrice);
    }

    /**
    * @notice Convierte una cantidad de ETH a su equivalente en USD
    * @dev Multiplica ETH (18 decimales) por precio Chainlink (8 decimales) y normaliza a 6 decimales
    * @dev Fórmula: (ethAmount * chainlinkPrice) / DECIMAL_FACTOR donde DECIMAL_FACTOR = 10^20
    * @param _ethAmount La cantidad de ETH a convertir en Wei (18 decimales)
    * @return convertedAmount_ El valor equivalente en USD con 6 decimales (formato USDC)
    */
    function convertirEthEnUSD(uint256 _ethAmount) internal view returns (uint256 convertedAmount_) {
        convertedAmount_ = (_ethAmount * chainlinkFeed()) / DECIMAL_FACTOR;
    }   //CONVERSION DE DECIMALES

    /**
    * @notice Verifica si el usuario tiene saldo suficiente antes de un retiro
    * @dev Función interna usada por retiroETH() y retiroToken()
    * @param _usuario La dirección del usuario a verificar
    * @param _token La dirección del token (address(0) para ETH)
    * @param _cantidad El monto que se desea retirar
    * @custom:security Revierte con SaldoInsuficiente si el saldo es menor a la cantidad
    */
    function _verificarSaldo(address _usuario, address _token, uint256 _cantidad) internal view {
        if (s_bovedas[_usuario][_token] < _cantidad) {
            revert SaldoInsuficiente();
        }
    }

/*///////////////////////// View & Pure /////////////////////////*/
    /**
    * @notice Devuelve el saldo de un token específico en la bóveda de un usuario
    * @dev Consulta el mapping anidado s_bovedas[usuario][token]
    * @param _usuario La dirección del usuario cuyo saldo se desea consultar
    * @param _token La dirección del token (usar address(0) para ETH nativo)
    * @return El saldo del usuario en Wei (para ETH) o unidades mínimas del token (para ERC20)
    */
    function getSaldo(address _usuario, address _token) public view returns (uint256) {
    return s_bovedas[_usuario][_token];
    }
}
