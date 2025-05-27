;;STX-AstraMint Token Contract
;; Enhanced fungible token implementation with advanced features and security

;; Constants
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-INSUFFICIENT-BALANCE (err u101))
(define-constant ERR-INVALID-AMOUNT (err u102))
(define-constant ERR-INVALID-RECIPIENT (err u103))
(define-constant ERR-INVALID-SPENDER (err u104))
(define-constant ERR-OVERFLOW (err u105))
(define-constant ERR-PAUSED (err u106))
(define-constant ERR-ALREADY-INITIALIZED (err u107))
(define-constant ERR-NOT-INITIALIZED (err u108))
(define-constant ERR-BLACKLISTED (err u109))
(define-constant ERR-MAX-SUPPLY-REACHED (err u110))
(define-constant ERR-ZERO-ADDRESS (err u111))
(define-constant ERR-SELF-TRANSFER (err u112))
(define-constant ERR-EXPIRED-ALLOWANCE (err u113))



(define-constant MAX-SUPPLY u1000000000000000) ;; 1 trillion tokens
(define-constant PRECISION u1000000) ;; 6 decimal places

;; Define token
(define-fungible-token stellar)


;; Data Variables
(define-data-var contract-owner principal tx-sender)
(define-data-var token-name (string-ascii 32) "Stellar Token")
(define-data-var token-symbol (string-ascii 10) "STLR")
(define-data-var token-decimals uint u6)
(define-data-var total-supply uint u0)
(define-data-var paused bool false)
(define-data-var initialized bool false)
(define-data-var last-event-id uint u0)



;;;;;;;; Data Maps;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-map allowances 
    { owner: principal, spender: principal }
    { amount: uint, expiry: uint })

;;
(define-map locked-tokens
    { address: principal }
    { amount: uint, unlock-height: uint })

;;
(define-map governance-tokens
    { holder: principal }
    { voting-power: uint, last-vote-height: uint })

;;
(define-map restricted-addresses 
    { address: principal } 
    { blocked-height: uint })

;;
(define-map minter-roles 
    { address: principal } 
    { can-mint: bool, mint-allowance: uint })


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; Private Functions ;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-private (is-contract-owner)
    (is-eq tx-sender (var-get contract-owner)))

(define-private (is-valid-recipient (recipient principal))
    (and 
        (not (is-eq recipient tx-sender))
        (not (is-eq recipient (as-contract tx-sender)))
        (not (is-restricted recipient))
        (not (is-eq recipient (var-get contract-owner)))))

(define-private (is-restricted (address principal))
    (match (map-get? restricted-addresses { address: address })
        restriction-data true
        false))

(define-private (check-initialized)
    (if (var-get initialized)
        (ok true)
        ERR-NOT-INITIALIZED))

(define-private (check-not-paused)
    (if (not (var-get paused))
        (ok true)
        ERR-PAUSED))

(define-private (safe-add (a uint) (b uint))
    (let ((sum (+ a b)))
        (if (>= sum a)
            (ok sum)
            ERR-OVERFLOW)))

(define-private (emit-transfer-event (from principal) (to principal) (amount uint))
    (begin
        (var-set last-event-id (+ (var-get last-event-id) u1))
        (print { type: "transfer", id: (var-get last-event-id), from: from, to: to, amount: amount })))

(define-private (emit-mint-event (to principal) (amount uint))
    (begin
        (var-set last-event-id (+ (var-get last-event-id) u1))
        (print { type: "mint", id: (var-get last-event-id), to: to, amount: amount })))

(define-private (emit-burn-event (from principal) (amount uint))
    (begin
        (var-set last-event-id (+ (var-get last-event-id) u1))
        (print { type: "burn", id: (var-get last-event-id), from: from, amount: amount })))

