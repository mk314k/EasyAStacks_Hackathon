
;; title: demo
;; version:
;; summary:
;; description:

;; traits
;;

;; token definitions
;;
(define-constant BITCOIN_TO_KCOIN_RATE u100)

(define-map bitcoin-staked {owner: principal} {amount: uint})
(define-map kcoin-borrowed {owner: principal} {amount: uint})

;; constants
;;

;; data vars
;;

;; data maps
;;

;; public functions
;;
(define-public (stake-bitcoin (amount uint))
    (begin
        (let ((current-amount (default-to u0 (get? amount (map-get? bitcoin-staked {owner: tx-sender})))))
            (map-set bitcoin-staked
                     {owner: tx-sender}
                     {amount: (+ current-amount amount)}))
        (ok true)))


(define-public (borrow-kcoin (request-amount uint))
    (let ((staked-btc (default-to u0 (map-get? bitcoin-staked { owner: tx-sender }))))
        (let ((max-borrowable (* staked-btc BITCOIN_TO_KCOIN_RATE)))
            (if (<= (+ (default-to u0 (map-get? kcoin-borrowed { owner: tx-sender })) request-amount) (* max-borrowable 75 100))
                (mint-kcoin request-amount)
                (err "Requested amount exceeds borrowing limit")))))

(define-public (repay-kcoin (amount uint))
    (begin
        (map-set kcoin-borrowed
                 { owner: tx-sender }
                 (- (default-to u0 (map-get? kcoin-borrowed { owner: tx-sender })) amount))
        (ok true)))

(define-public (unstake-bitcoin (amount uint))
    (let ((current-staked (default-to u0 (map-get? bitcoin-staked { owner: tx-sender }))))
        (if (>= current-staked amount)
            (begin
                (map-set bitcoin-staked
                         { owner: tx-sender }
                         (- current-staked amount))
                (ok true))
            (err "Not enough Bitcoin staked"))))


;; read only functions
;;

;; private functions
;;
(define-private (mint-kcoin (amount uint))
    (begin
        (map-set kcoin-borrowed
                 { owner: tx-sender }
                 (+ (default-to u0 (map-get? kcoin-borrowed { owner: tx-sender })) amount))
        (ok true)))

