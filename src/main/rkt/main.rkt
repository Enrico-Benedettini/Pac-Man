;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-advanced-reader.ss" "lang")((modname WORKING-MAIN) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #t #t none #f () #f)))
;PAC-MAN REMAKE

(require 2htdp/universe)
(require 2htdp/image)

;;CONSTANTS
(define BACKGROUND (bitmap "../../../public/img/base-canvas.jpg")) ; Background

(define END-COOKIE-TIME 8) ; the limit of cookie's effect
(define CELL-SIZE 20) ; size of the cell
(define TICK-RATE 0.025) ; tick-rate for big-bang
(define PAC-SPEED 2) ; speed of pacman
(define GHOST-SPEED 2) ; ghost speed
(define HEADER (bitmap "../../../public/img/header.jpg"))
(define PAC-IMG (bitmap "../../../public/img/pacman/pacman_open.png")) ; pacman open img
(define PAC-SHIFTED-IMG (bitmap "../../../public/img/pacman/pacman_closed.png")) ; pacman closed img
; inky images
(define INKY-UP (bitmap "../../../public/img/inky/inky_up_1.png"))
(define INKY-UP-2 (bitmap "../../../public/img/inky/inky_up_2.png"))
(define INKY-DOWN (bitmap "../../../public/img/inky/inky_down_1.png"))
(define INKY-DOWN-2 (bitmap "../../../public/img/inky/inky_down_2.png"))
(define INKY-LEFT (bitmap "../../../public/img/inky/inky_left_1.png"))
(define INKY-LEFT-2 (bitmap "../../../public/img/inky/inky_left_2.png"))
(define INKY-RIGHT (bitmap "../../../public/img/inky/inky_right_1.png"))
(define INKY-RIGHT-2 (bitmap "../../../public/img/inky/inky_right_2.png"))
; pinky images
(define PINKY-UP (bitmap "../../../public/img/pinky/pinky_up_1.png")) 
(define PINKY-UP-2 (bitmap "../../../public/img/pinky/pinky_up_2.png"))
(define PINKY-DOWN (bitmap "../../../public/img/pinky/pinky_down_1.png")) 
(define PINKY-DOWN-2 (bitmap "../../../public/img/pinky/pinky_down_2.png"))
(define PINKY-LEFT (bitmap "../../../public/img/pinky/pinky_left_1.png")) 
(define PINKY-LEFT-2 (bitmap "../../../public/img/pinky/pinky_left_2.png"))
(define PINKY-RIGHT (bitmap "../../../public/img/pinky/pinky_right_1.png")) 
(define PINKY-RIGHT-2 (bitmap "../../../public/img/pinky/pinky_right_2.png"))
; clyde images
(define CLYDE-UP (bitmap "../../../public/img/clyde/clyde_up_1.png")) 
(define CLYDE-UP-2 (bitmap "../../../public/img/clyde/clyde_up_2.png"))
(define CLYDE-DOWN (bitmap "../../../public/img/clyde/clyde_down_1.png")) 
(define CLYDE-DOWN-2 (bitmap "../../../public/img/clyde/clyde_down_2.png"))
(define CLYDE-LEFT (bitmap "../../../public/img/clyde/clyde_left_1.png")) 
(define CLYDE-LEFT-2 (bitmap "../../../public/img/clyde/clyde_left_2.png"))
(define CLYDE-RIGHT (bitmap "../../../public/img/clyde/clyde_right_1.png")) 
(define CLYDE-RIGHT-2 (bitmap "../../../public/img/clyde/clyde_right_2.png"))
 ; blinky images
(define BLINKY-LEFT (bitmap "../../../public/img/blinky/blinky_left_1.png"))
(define BLINKY-LEFT-2 (bitmap "../../../public/img/blinky/blinky_left_2.png"))
(define BLINKY-RIGHT (bitmap "../../../public/img/blinky/blinky_right_1.png"))
(define BLINKY-RIGHT-2 (bitmap "../../../public/img/blinky/blinky_right_2.png"))
(define BLINKY-DOWN (bitmap "../../../public/img/blinky/blinky_down_1.png"))
(define BLINKY-DOWN-2 (bitmap "../../../public/img/blinky/blinky_down_2.png"))
(define BLINKY-UP (bitmap "../../../public/img/blinky/blinky_up_1.png"))
(define BLINKY-UP-2 (bitmap "../../../public/img/blinky/blinky_up_2.png"))

(define POINT-IMG (bitmap "../../../public/img/cookies/save_cookie.png")) ; classical point img
(define COOKIE-IMG (bitmap "../../../public/img/cookies/super_cookie.png")) ; special point img
(define SCARED-IMG (bitmap "../../../public/img/scared/scared_1.png")); scared ghost
(define SCARED-IMG-2 (bitmap "../../../public/img/scared/scared_2.png")); shifted scared ghost
(define SCARED-IMG-3 (bitmap "../../../public/img/scared/scared_3.png")); scared white ghost
(define SCARED-IMG-4 (bitmap "../../../public/img/scared/scared_4.png")); shifted scared white ghost
(define COOKIE-TIME 0) ; time since the special cookie has been eaten
(define ABSOLUTE-TIME 0); time in the game

;;Data Type
(define-struct GameState [pacman inky pinky clyde blinky base background cookie_time absolute_time])
;where:
; - pacman is a Pacman
; - inky, blinky, pinky, clyde are Ghosts
; - base is the GRID
; - background is an Image representing the state
; - cookie_time and absolute_time are Numbers representing the time passed
; respectively since the cookie has been eaten and the game has started

(define-struct Pacman [img pix_pos grid_pos dir stored_dir speed point life])
; where:
; - img is a Image representing the pacman
; - pix_pos is a Posn indicating the actual position of pacman
; - grid_pos is a Posn indicating the actual grid position of pacman
; - dir and stored_dir are vector representing pacman direction and stored direction 
; - speed, point and life are Numbers indicating the velocity, the points and the lives of the pacman

;;Data Example
;Pacman initialize
(define PACMAN-INIT
  (make-Pacman PAC-IMG
               (make-posn (+ (* CELL-SIZE 10) 10) (+ (* CELL-SIZE 15) 10))
               (make-posn 10 15)
               (vector 0 0) (vector 0 0)
               PAC-SPEED 0 3))

(define-struct Ghost [img pix_pos grid_pos dir stored_dir speed status])
;where everything is the same as pacman but without point and life and with:
; - status which is a String indicating the state in which the ghost is

;;Data Example
;Ghosts initialize
(define INKY-INIT
  (make-Ghost INKY-RIGHT
              (make-posn (+ (* CELL-SIZE 9) 10) (+ (* CELL-SIZE 9) 10))
              (make-posn 9 9)
              (vector 1 0)  (vector 0 0)
              GHOST-SPEED "chase"))

(define PINKY-INIT
  (make-Ghost PINKY-UP
              (make-posn (+ (* CELL-SIZE 10) 10) (+ (* CELL-SIZE 9) 10))
              (make-posn 10 9)
              (vector 0 -1)  (vector 0 0)
              GHOST-SPEED "chase"))

(define CLYDE-INIT
  (make-Ghost CLYDE-LEFT
              (make-posn (+ (* CELL-SIZE 11) 10) (+ (* CELL-SIZE 9) 10))
              (make-posn 11 9)
              (vector -1 0)  (vector 0 0)
              GHOST-SPEED "chase"))

(define BLINKY-INIT
  (make-Ghost BLINKY-LEFT
              (make-posn (+ (* CELL-SIZE 10) 10) (+ (* CELL-SIZE 7) 10))
              (make-posn 10 7)
              (vector -1 0)  (vector 0 0)
              GHOST-SPEED "chase"))

;Grid map initialize
(define GRID
  (vector
   (vector "W" "W" "W" "W" "W" "W" "W" "W" "W" "W" "W" "W" "W" "W" "W" "W" "W" "W" "W" "W" "W")
   (vector "W" "W" "P" "P" "P" "P" "P" "P" "P" "P" "W" "P" "P" "P" "P" "P" "P" "P" "P" "W" "W")
   (vector "W" "W" "C" "W" "W" "P" "W" "W" "W" "P" "W" "P" "W" "W" "W" "P" "W" "W" "C" "W" "W")
   (vector "W" "W" "P" "P" "P" "P" "P" "P" "P" "P" "P" "P" "P" "P" "P" "P" "P" "P" "P" "W" "W")
   (vector "W" "W" "P" "W" "W" "P" "W" "P" "W" "W" "W" "W" "W" "P" "W" "P" "W" "W" "P" "W" "W")
   (vector "W" "W" "P" "P" "P" "P" "W" "P" "P" "P" "W" "P" "P" "P" "W" "P" "P" "P" "P" "W" "W")
   (vector "W" "W" "W" "W" "W" "P" "W" "W" "W" "E" "W" "E" "W" "W" "W" "P" "W" "W" "W" "W" "W")
   (vector "W" "W" "W" "W" "W" "P" "W" "E" "E" "E" "E" "E" "E" "E" "W" "P" "W" "W" "W" "W" "W")
   (vector "W" "W" "W" "W" "W" "P" "W" "E" "W" "W" "D" "W" "W" "E" "W" "P" "W" "W" "W" "W" "W")

   (vector "E" "E" "E" "E" "E" "P" "E" "E" "W" "E" "E" "E" "W" "E" "E" "P" "E" "E" "E" "E" "E")

   (vector "W" "W" "W" "W" "W" "P" "W" "E" "W" "W" "W" "W" "W" "E" "W" "P" "W" "W" "W" "W" "W")
   (vector "W" "W" "W" "W" "W" "P" "W" "E" "E" "E" "E" "E" "E" "E" "W" "P" "W" "W" "W" "W" "W")
   (vector "W" "W" "W" "W" "W" "P" "W" "E" "W" "W" "W" "W" "W" "E" "W" "P" "W" "W" "W" "W" "W")
   (vector "W" "W" "P" "P" "P" "P" "P" "P" "P" "P" "W" "P" "P" "P" "P" "P" "P" "P" "P" "W" "W")
   (vector "W" "W" "P" "W" "W" "P" "W" "W" "W" "P" "W" "P" "W" "W" "W" "P" "W" "W" "P" "W" "W")
   (vector "W" "W" "C" "P" "W" "P" "P" "P" "P" "P" "E" "P" "P" "P" "P" "P" "W" "P" "C" "W" "W")
   (vector "W" "W" "W" "P" "W" "P" "W" "P" "W" "W" "W" "W" "W" "P" "W" "P" "W" "P" "W" "W" "W")
   (vector "W" "W" "P" "P" "P" "P" "W" "P" "P" "P" "W" "P" "P" "P" "W" "P" "P" "P" "P" "W" "W")
   (vector "W" "W" "P" "W" "W" "W" "W" "W" "W" "P" "W" "P" "W" "W" "W" "W" "W" "W" "P" "W" "W")
   (vector "W" "W" "P" "P" "P" "P" "P" "P" "P" "P" "P" "P" "P" "P" "P" "P" "P" "P" "P" "W" "W")
   (vector "W" "W" "W" "W" "W" "W" "W" "W" "W" "W" "W" "W" "W" "W" "W" "W" "W" "W" "W" "W" "W")))
;where:
; - W stays for a wall
; - P stays for a normal point
; - C stays for a special cookie
; - E stays for an empty cell
; - D stays for the special wall only ghosts can pass (their house's door)

;state initialize
(define STATE-INIT
  (make-GameState PACMAN-INIT INKY-INIT PINKY-INIT CLYDE-INIT BLINKY-INIT GRID BACKGROUND COOKIE-TIME ABSOLUTE-TIME))

;-----------------------------------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------------------------------

;;RENDERS

;; DRAW-HUD
;; author: Francesco Casarella
;draw-hud: GameState -> Image
; Takes the GameState and the Image of the current game and adds the header
; at the top and a few informations at the bottom
;header: (define (draw-hud state) BACKGROUND)

;; Examples

;when you have 3 lives and 0 points
(define 3-lives (make-GameState (GameState-pacman STATE-INIT)
                                  (GameState-inky STATE-INIT)
                                  (GameState-pinky STATE-INIT)
                                  (GameState-clyde STATE-INIT)
                                  (GameState-blinky STATE-INIT)
                                  (GameState-base STATE-INIT)
                                  (GameState-background STATE-INIT)
                                  (GameState-cookie_time STATE-INIT)
                                  (GameState-absolute_time STATE-INIT)))
(check-expect (draw-hud 3-lives)
              (above HEADER
                     (draw-game 3-lives)
                     (beside
                      (overlay
                       (beside (text "Points:" 20 "white")
                               (text (number->string (Pacman-point (GameState-pacman 3-lives))) 20 "white"))
                       (rectangle 210 40 "solid" "black"))
                      (overlay
                       (beside (text "Lives:" 20 "white")
                               (beside
                                PAC-IMG
                                PAC-IMG
                                PAC-IMG))
                       (rectangle 210 40 "solid" "black")))))

;when you have 2 lives and 10 points
(define 2-lives (make-GameState (make-Pacman
                                 (Pacman-img (GameState-pacman STATE-INIT))
                                 (Pacman-pix_pos (GameState-pacman STATE-INIT))
                                 (Pacman-grid_pos (GameState-pacman STATE-INIT))
                                 (Pacman-dir (GameState-pacman STATE-INIT))
                                 (Pacman-stored_dir (GameState-pacman STATE-INIT))
                                 (Pacman-speed (GameState-pacman STATE-INIT))
                                 10
                                 2)
                                (GameState-inky STATE-INIT)
                                (GameState-pinky STATE-INIT)
                                (GameState-clyde STATE-INIT)
                                (GameState-blinky STATE-INIT)
                                (GameState-base STATE-INIT)
                                (GameState-background STATE-INIT)
                                (GameState-cookie_time STATE-INIT)
                                (GameState-absolute_time STATE-INIT)))
(check-expect (draw-hud 2-lives)
              (above HEADER
                     (draw-game 2-lives)
                     (beside
                      (overlay
                       (beside (text "Points:" 20 "white")
                               (text (number->string (Pacman-point (GameState-pacman 2-lives))) 20 "white"))
                       (rectangle 210 40 "solid" "black"))
                      (overlay
                       (beside (text "Lives:" 20 "white")
                               (beside
                                PAC-IMG
                                PAC-IMG
                                (rectangle 20 20 "solid" "black")))
                       (rectangle 210 40 "solid" "black")))))

;when you have 1 lives and 100 points
(define 1-lives (make-GameState (make-Pacman
                                 (Pacman-img (GameState-pacman STATE-INIT))
                                 (Pacman-pix_pos (GameState-pacman STATE-INIT))
                                 (Pacman-grid_pos (GameState-pacman STATE-INIT))
                                 (Pacman-dir (GameState-pacman STATE-INIT))
                                 (Pacman-stored_dir (GameState-pacman STATE-INIT))
                                 (Pacman-speed (GameState-pacman STATE-INIT))
                                 100
                                 1)
                                (GameState-inky STATE-INIT)
                                (GameState-pinky STATE-INIT)
                                (GameState-clyde STATE-INIT)
                                (GameState-blinky STATE-INIT)
                                (GameState-base STATE-INIT)
                                (GameState-background STATE-INIT)
                                (GameState-cookie_time STATE-INIT)
                                (GameState-absolute_time STATE-INIT)))
(check-expect (draw-hud 1-lives)
              (above HEADER
                     (draw-game 1-lives)
                     (beside
                      (overlay
                       (beside (text "Points:" 20 "white")
                               (text (number->string (Pacman-point (GameState-pacman 1-lives))) 20 "white"))
                       (rectangle 210 40 "solid" "black"))
                      (overlay
                       (beside (text "Lives:" 20 "white")
                               (beside
                                PAC-IMG
                                (rectangle 20 20 "solid" "black")
                                (rectangle 20 20 "solid" "black")))
                       (rectangle 210 40 "solid" "black")))))
;when you have 0 lives and 110 points
(define 0-lives (make-GameState (make-Pacman
                                 (Pacman-img (GameState-pacman STATE-INIT))
                                 (Pacman-pix_pos (GameState-pacman STATE-INIT))
                                 (Pacman-grid_pos (GameState-pacman STATE-INIT))
                                 (Pacman-dir (GameState-pacman STATE-INIT))
                                 (Pacman-stored_dir (GameState-pacman STATE-INIT))
                                 (Pacman-speed (GameState-pacman STATE-INIT))
                                 110
                                 0)
                                (GameState-inky STATE-INIT)
                                (GameState-pinky STATE-INIT)
                                (GameState-clyde STATE-INIT)
                                (GameState-blinky STATE-INIT)
                                (GameState-base STATE-INIT)
                                (GameState-background STATE-INIT)
                                (GameState-cookie_time STATE-INIT)
                                (GameState-absolute_time STATE-INIT)))
(check-expect (draw-hud 0-lives)
              (above HEADER
                     (draw-game 0-lives)
                     (beside
                      (overlay
                       (beside (text "Points:" 20 "white")
                               (text (number->string (Pacman-point (GameState-pacman 0-lives))) 20 "white"))
                       (rectangle 210 40 "solid" "black"))
                      (overlay
                       (beside (text "Lives:" 20 "white")
                               (beside
                                (rectangle 20 20 "solid" "black")
                                (rectangle 20 20 "solid" "black")
                                (rectangle 20 20 "solid" "black")))
                       (rectangle 210 40 "solid" "black")))))              

;; Code

(define (draw-hud state)
  (local (
          (define square (rectangle 20 20 "solid" "black"))
          )
    (above HEADER
           (draw-game state)
           (beside
            (overlay
             (beside (text "Points:" 20 "white")
                     (text (number->string (Pacman-point (GameState-pacman state))) 20 "white"))
             (rectangle 210 40 "solid" "black"))
            (overlay
             (beside (text "Lives:" 20 "white")
                     (cond
                       [(=(Pacman-life (GameState-pacman state))3)
                        (beside
                         PAC-IMG
                         PAC-IMG
                         PAC-IMG)]
                       [(=(Pacman-life (GameState-pacman state))2)
                        (beside
                         PAC-IMG
                         PAC-IMG
                         square)]
                       [(=(Pacman-life (GameState-pacman state))1)
                        (beside
                         PAC-IMG
                         square
                         square)]
                       [else
                        (beside
                         square
                         square
                         square)]
                       ))
             (rectangle 210 40 "solid" "black"))))))

;; draw-game
;; author: Enrico Benedettini, Francesco Casarella
;draw-game: Gamestate -> Image
; it draws the Image representing the GameState placing images over the background
; header: (define (draw-game state) BACKGROUND)

;; Examples
(check-expect (draw-game STATE-INIT)
              (place-image PAC-IMG
                           (+ (* 20 10) 10)
                           (+ (* 20 15) 10)
                           (place-image INKY-RIGHT
                                        (+ (* 20 9) 10)
                                        (+ (* 20 9) 10)
                                        (place-image PINKY-UP
                                                     (+ (* 20 10) 10)
                                                     (+ (* 20 9) 10)
                                                     (place-image CLYDE-LEFT
                                                                  (+ (* 20 11) 10)
                                                                  (+ (* 20 9) 10)
                                                                  (place-image BLINKY-LEFT
                                                                               (+ (* 20 10) 10)
                                                                               (+ (* 20 7) 10)
                                                                               (points 0
                                                                                       (vector->list GRID)
                                                                                       BACKGROUND)))))))



(define (draw-game state)
  (place-image (Pacman-img (GameState-pacman state)) ; placing pacman
               (posn-x (Pacman-pix_pos (GameState-pacman state)))
               (posn-y (Pacman-pix_pos (GameState-pacman state)))
               (place-image (Ghost-img (GameState-inky state)) ; placing inky
                            (posn-x (Ghost-pix_pos (GameState-inky state))) 
                            (posn-y (Ghost-pix_pos (GameState-inky state)))
                            (place-image (Ghost-img (GameState-pinky state)); placing pinky
                                         (posn-x (Ghost-pix_pos (GameState-pinky state)))
                                         (posn-y (Ghost-pix_pos (GameState-pinky state)))
                                         (place-image (Ghost-img (GameState-clyde state)) ; placing clyde
                                                      (posn-x (Ghost-pix_pos (GameState-clyde state)))
                                                      (posn-y (Ghost-pix_pos (GameState-clyde state)))
                                                      (place-image (Ghost-img (GameState-blinky state)) ; placing blinky
                                                                   (posn-x (Ghost-pix_pos (GameState-blinky state)))
                                                                   (posn-y (Ghost-pix_pos (GameState-blinky state)))
                                                                   (points 0 ; placing cookies on the baground
                                                                           (vector->list (GameState-base state))
                                                                           (GameState-background state))))))))


;;line-points
;; author: Enrico Benedettini
;line-points: Vector<String> -> Image
; takes a vector of string containing the grid values and returns the image with
; the line of points represented over the background given
;header: (define (line-points index-x index-y lop base) BACKGROUND)

;;Examples
(check-error (line-points 0 0 '() BACKGROUND))

(check-expect (line-points 0 0 (list "W" "W" "P" "W" "W" "P") BACKGROUND)
              (place-image POINT-IMG
                           (+ 10 (* 20 2))
                           (+ 10 (* 20 0))
                           (place-image POINT-IMG
                                        (+ 10 (* 20 5))
                                        (+ 10 (* 20 0))
                                        BACKGROUND)))

(check-expect (line-points 0 1 (list "W" "W" "C" "P" "W" "W" "P" "C" "W" "P") BACKGROUND)
              (place-image COOKIE-IMG
                           (+ 10 (* 20 2))
                           (+ 10 (* 20 1))
                           (place-image POINT-IMG
                                        (+ 10 (* 20 3))
                                        (+ 10 (* 20 1))
                                        (place-image POINT-IMG
                                                     (+ 10 (* 20 6))
                                                     (+ 10 (* 20 1))
                                                     (place-image COOKIE-IMG
                                                                  (+ 10 (* 20 7))
                                                                  (+ 10 (* 20 1))
                                                                   (place-image POINT-IMG
                                                                                (+ 10 (* 20 9))
                                                                                (+ 10 (* 20 1))
                                                                                BACKGROUND))))))

(check-expect (line-points 0 0 (list "W" "W" "W" "W" "W" "W" "W") BACKGROUND)
              BACKGROUND)

;;Code

(define (line-points index-x index-y lop base)
  (local (; overlap: Number Number String Image -> Image
          ; places the image of a cookie or of a normal point 
          ; in x y pixel position according to the val
          (define (overlap x y val img2)
            (cond
              [(equal? val "P")
               (place-image POINT-IMG
                            (+ (/ CELL-SIZE 2) (* CELL-SIZE x))
                            (+ (/ CELL-SIZE 2) (* CELL-SIZE y)) img2)]
              [(equal? val "C")
               (place-image COOKIE-IMG
                            (+ (/ CELL-SIZE 2) (* CELL-SIZE x))
                            (+ (/ CELL-SIZE 2) (* CELL-SIZE y))
                            img2)]
              [else img2])))
  (cond
    [(empty? (rest lop))
     (overlap index-x index-y (first lop) base)]
    [else (overlap index-x index-y (first lop)
                   (line-points (+ index-x 1) index-y (rest lop) base))] ; recursive call
    )))

;;points
;; author: Enrico Benedettini
;points: List<List<String>> Image -> Image
; where a List<List<String>> is a non empty-list

;header: (define (points index lolop base) BACKGROUND)

;; Examples

(check-error (points 0 '() BACKGROUND))
(check-expect (points 0 (list (vector "W" "W")) BACKGROUND) BACKGROUND)
(check-expect (points 0 (list (vector "W" "W" "W") (vector "P" "W")) BACKGROUND)
              (line-points 0 1 (list "P" "W") BACKGROUND))

(define (points index lolop base)
  (cond
    [(empty? (rest lolop))
     (line-points 0 index (vector->list (first lolop)) base)]
     [else (points (+ index 1) (rest lolop)
                   (line-points 0 index (vector->list (first lolop)) base))]; recursive call
     ))


;;can-move?
;; author: Albi Geldehuys
;can-move?: Pacman -> Boolean
; it checks walls
;header: (define (can-move? entity) #true)

;; Examples
(check-expect (can-move? PACMAN-INIT) #true)

;; Code

(define (can-move? entity)
  (local (;grid-pos-stored-dir-pac: Pacman -> String
          ; returns the value of the position next to pacman
          ; according to its direction in the GRID 
          (define (grid-pos-stored-dir-pac entity) 
            (vector-ref
             (vector-ref GRID
                         (+ (posn-y (Pacman-grid_pos entity))
                            (vector-ref (Pacman-stored_dir entity) 1)))
             (+ (posn-x (Pacman-grid_pos entity))
                (vector-ref (Pacman-stored_dir entity) 0))))
          (define (check-walls entity)
            (cond
              [(or (< (+ (posn-x (Pacman-grid_pos entity))
                         (vector-ref (Pacman-stored_dir entity) 0)) 0)
                   (> (+ (posn-x (Pacman-grid_pos entity))
                         (vector-ref (Pacman-stored_dir entity) 0)) 20))
               #true]
              [(or (string=? (grid-pos-stored-dir-pac entity) "W")
                   (string=? (grid-pos-stored-dir-pac entity) "D"))
               #false]
              [else #true]))
          )
    (check-walls entity)
    ))

;; wall-pac?
;; author: Albi Geldenhuys
;wall-pac?: Pacman -> Boolean
; takes a pacman and returns wether there's a wall or not on its direction
;header: (define (wall-pac? entity) #false)

;; Examples
(check-expect (wall-pac? PACMAN-INIT) #false)

;; Code

(define (wall-pac? entity)
  (cond
    [(or
      (< (+ (posn-x (Pacman-grid_pos entity))
            (vector-ref (Pacman-stored_dir entity) 0)) 0)
      (> (+ (posn-x (Pacman-grid_pos entity))
            (vector-ref (Pacman-stored_dir entity) 0)) 20)) #false]
    [(or
      (< (+ (posn-x (Pacman-grid_pos entity))
            (vector-ref (Pacman-dir entity) 0)) 0)
      (> (+ (posn-x (Pacman-grid_pos entity))
            (vector-ref (Pacman-dir entity) 0)) 20)) #false]
    [(string=? (vector-ref
                (vector-ref GRID
                            (+ (posn-y (Pacman-grid_pos entity))
                               (vector-ref (Pacman-dir entity) 1)))
                (+ (posn-x (Pacman-grid_pos entity))
                   (vector-ref (Pacman-dir entity) 0))) "W") #true]
    [else #false]))


;;PACMAN-MOVE
;; author: Albi Geldehuys
;; revised by Enrico Benedettini

;pacman-move: GameState -> GameState
; it takes a GameState and returns the pacman movements state
;header: (define (pacman-move key-event state) STATE-INIT)

;; Examples
(check-expect (pacman-move STATE-INIT "right")
              (make-GameState
               (make-Pacman PAC-IMG
                            (make-posn (+ (* CELL-SIZE 10) 10) (+ (* CELL-SIZE 15) 10))
                            (make-posn 10 15)
                            (vector 0 0) (vector 1 0)
                            PAC-SPEED 0 3)
               INKY-INIT PINKY-INIT CLYDE-INIT BLINKY-INIT GRID BACKGROUND COOKIE-TIME ABSOLUTE-TIME))

;; Code

(define (pacman-move state key-press)
  (local (;make-gamestate: Number, Number -> GameState
          ; it sets the direction values of the GameState creating a new one
          (define (make-gamestate dir-x dir-y)
            (make-GameState
             (make-Pacman (Pacman-img (GameState-pacman state))
                          (Pacman-pix_pos (GameState-pacman state))
                          (Pacman-grid_pos (GameState-pacman state))
                          (Pacman-dir (GameState-pacman state))
                          (vector dir-x dir-y)
                          (Pacman-speed (GameState-pacman state))
                          (Pacman-point (GameState-pacman state))
                          (Pacman-life (GameState-pacman state)))
             (GameState-inky state)
             (GameState-pinky state)
             (GameState-clyde state)
             (GameState-blinky state)
             (GameState-base state)
             (GameState-background state)
             (GameState-cookie_time state)
             (GameState-absolute_time state))))
  (cond
    [(key=? key-press "left")
     (make-gamestate -1 0)]
    [(key=? key-press "right")
     (make-gamestate 1 0)]
    [(key=? key-press "up")
     (make-gamestate 0 -1)]
    [(key=? key-press "down")
     (make-gamestate 0 1)]
    [else state])))

;; calc-grid-pos
;; author: Albi Geldehuys

;calc-grid-pos: X -> Posn
; where X is one of:
; - Pacman ; the Pacman entity
; - Ghost  ; one of the four ghosts in the state
; it calculates the grid position based on the pixel position
;header: (define (calc-grid-pos entity) (make-posn 0 0))

;; Examples
(check-expect (calc-grid-pos PACMAN-INIT) (make-posn 10 15))
(check-expect (calc-grid-pos BLINKY-INIT) (make-posn 10 7))

;; Code

(define (calc-grid-pos entity)
  (cond
    [(Pacman? entity)
     (make-posn (floor (/ (posn-x (Pacman-pix_pos entity)) CELL-SIZE))
                (floor (/ (posn-y (Pacman-pix_pos entity)) CELL-SIZE)))]
    [else (make-posn (floor (/ (posn-x (Ghost-pix_pos entity)) CELL-SIZE))
                     (floor (/ (posn-y (Ghost-pix_pos entity)) CELL-SIZE)))]))

;; move-fix
;; author: Albi Geldehuys
;; revised by Enrico Benedettini

;move-fix: Pacman -> Boolean
; checks that pacman is on the proper x or y axis --> meaning that it remains in the center of a cell
;header: (define (move-fix entity) #true)

(define (move-fix entity)
  (local (; value representing the half of a CELL-SIZE
          (define half (/ CELL-SIZE 2))
          ; actual direction of pacman
          (define dir (Pacman-dir entity)))
  (cond
    [(and (equal? (modulo (posn-x (Pacman-pix_pos entity)) CELL-SIZE) half)
          (or (equal? dir (vector 1 0))
              (equal? dir (vector -1 0))))
     #true]
    [(and (equal? (modulo (posn-y (Pacman-pix_pos entity)) CELL-SIZE) half)
          (or (equal? dir (vector 0 1))
              (equal? dir (vector 0 -1))))
     #true]
    [else #false])))


;; fix
;; author: Albi Geldehuys

;fix: Pacman, GameState -> Pacman
; makes it so that pacman only moves when stored direction is allowed
;header: (define (fix entity) PACMAN-INIT)

;; Examples
(check-expect (fix PACMAN-INIT) PACMAN-INIT)
(check-expect (fix (make-Pacman PAC-IMG
                                (make-posn (+ (* CELL-SIZE 10) 10) (+ (* CELL-SIZE 15) 10))
                                (make-posn 10 15)
                                (vector 0 0) (vector 1 0)
                                PAC-SPEED 0 3))
              (make-Pacman PAC-IMG
                           (make-posn (+ (* CELL-SIZE 10) 10) (+ (* CELL-SIZE 15) 10))
                           (make-posn 10 15)
                           (vector 1 0) (vector 1 0)
                           PAC-SPEED 0 3))
(check-expect (fix (make-Pacman PAC-IMG
                                (make-posn -1 (+ (* CELL-SIZE 9) 10))
                                (make-posn 0 9)
                                (vector -1 0) (vector -1 0)
                                PAC-SPEED 0 3))
              (make-Pacman PAC-IMG
                                (make-posn 420 (+ (* CELL-SIZE 9) 10))
                                (make-posn 0 9)
                                (vector -1 0) (vector -1 0)
                                PAC-SPEED 0 3))

;; Code

(define (fix entity)
  (local (; Vector -> Pacman
          ; it takes a vector and sets it as new Pacman's direction
          (define (make-pacman pix-pos vec)
            (make-Pacman (Pacman-img entity)
                         pix-pos
                         (Pacman-grid_pos entity)
                         vec
                         (Pacman-stored_dir entity)
                         (Pacman-speed entity)
                         (Pacman-point entity)
                         (Pacman-life entity)))
          ; actual pacman's pixel position
          (define pac (Pacman-pix_pos entity))
          ; actual pacman's direction
          (define dir (Pacman-dir entity)))
  (cond
    [(and (or (not (false? (move-fix entity)))              
              (equal? dir (vector 0 0)))
          (can-move? entity))
     (make-pacman pac
                  (Pacman-stored_dir entity))]
    [(and (wall-pac? entity)
          (move-fix entity))
     (make-pacman pac
                  (vector 0 0))]
    [(< (posn-x pac) 0)
     (make-pacman (make-posn 420 190)
                  dir)]
    [(> (posn-x pac) 420)
     (make-pacman (make-posn 0 190)
                  dir)]
    [else entity])))


;; calc-dist
;; author: Albi Geldehuys

;calc-dist: Number, Number -> Number
; it calculates the distance from a grid start point (posn) to an end point
;header: (define (calc-dist start end) 0)

(define (calc-dist start end)
  (local (
          (define (x-diff start end)
            (- (posn-x end) (posn-x start)))
          (define (y-diff start end)
            (- (posn-y end) (posn-y start)))
          )
    (inexact->exact (floor (sqrt (+ (expt (x-diff start end) 2) (expt (y-diff start end) 2))))))
  )


;; poss-dir
;; author: Albi Geldehuys

;poss-dir: Ghost -> List< Vector< Number > >
; it checks the possible directions of a ghost
; where List< Vector < Number > > is one of:
;  - '()                         ; the empty list
;  - List< Vector < Number > >   ; the list containing possible
                                ; directions where:
; Vector < Number > is a list of two elements indicating
; the direction as a combination of them compared to the grid, so
; 0, -1 stays for UP direction
; 0, 1 stays for DOWN direction
; 1, 0 stays for RIGHT direction
; -1, 0 stays for LEFT direction
;header: (define (poss-dir ghost)
;          (list (vector 1 0) (vector -1 0) (vector 0 1) (vector 0 -1)))

;; Examples
(check-expect (poss-dir BLINKY-INIT) (list (vector -1 0)))
(check-expect (poss-dir PINKY-INIT) (list (vector 0 -1)))
(check-expect (poss-dir (make-Ghost CLYDE-LEFT
                                    (make-posn (+ (* CELL-SIZE 2) 10) (+ (* CELL-SIZE 1) 10))
                                    (make-posn 2 1)
                                    (vector 0 0)  (vector 0 0)
                                    GHOST-SPEED "chase"))
              (list (vector 1 0) (vector 0 1)))

;; Code

(define (poss-dir ghost)
  (local (; list of al possible directions that an entity can take
          (define POSSIBLE-DIR (list (vector 1 0) (vector -1 0) (vector 0 1) (vector 0 -1)))
          ;grid-pos-dir-ghost: Ghost Vector<Number> -> String
          ; takes a Ghost and a direction and returns the value of the next GRID cell
          (define (grid-pos-dir-ghost ghost dir)
            (vector-ref
             (vector-ref GRID
                         (+ (posn-y (Ghost-grid_pos ghost)) (vector-ref dir 1)))
             (+ (posn-x (Ghost-grid_pos ghost)) (vector-ref dir 0))))
          ;wall?: Ghost Vector<Number> -> Boolean
          ; takes a Ghost and a direction and returns wether the next value is a wall or not
          (define (wall? ghost dir)
            (cond
              [(> (+ (posn-x (Ghost-grid_pos ghost)) 1) 20) #false]
              [(or (string=? (grid-pos-dir-ghost ghost dir) "W")
                   (string=? (grid-pos-dir-ghost ghost dir) "D")) #true]
              [else #false]))
          ;invert-dir: Vector<Number> -> Vector<Number>
          ; inverts the given direction
          (define (invert-dir dir)
            (cond
              [(equal? dir (vector 1 0))
               (vector -1 0)]
              [(equal? dir (vector -1 0))
               (vector 1 0)]
              [(equal? dir (vector 0 1))
               (vector 0 -1)]
              [(equal? dir (vector 0 -1))
               (vector 0 1)]
              [else (vector 0 0)]))
          ;remove-dir: Ghost List<Vector<Number>> -> List<Vector<Number>>
          ; takes a ghost and a list of directions and returns the list of
          ; all the possible directions
          (define (remove-dir ghost DIR-LIST)
            (cond
              [(empty? DIR-LIST) '()]
              [(and (equal? (posn-y (Ghost-grid_pos ghost)) 9)
                    (< (posn-x (Ghost-grid_pos ghost)) 5)
                    (equal? (Ghost-dir ghost) (vector -1 0)))
               (cons (vector -1 0) '())]
              [(and (equal? (posn-y (Ghost-grid_pos ghost)) 9)
                    (> (posn-x (Ghost-grid_pos ghost)) 16)
                    (equal? (Ghost-dir ghost) (vector 1 0)))
               (cons (vector 1 0) '())]
              [(or (equal? (Ghost-grid_pos ghost) (make-posn 10 9))
                   (equal? (Ghost-grid_pos ghost) (make-posn 10 8)))
               (cons (vector 0 -1) '())]
              [(equal? (Ghost-grid_pos ghost)
                       (make-posn 8 9))
               (cons (vector 1 0) '())]
              [(equal? (Ghost-grid_pos ghost)
                       (make-posn 11 9))
               (cons (vector -1 0) '())]
              [(or (equal? (invert-dir (Ghost-dir ghost))
                           (first DIR-LIST))
                   (wall? ghost (first DIR-LIST)))
               (remove-dir ghost (rest DIR-LIST))]
              [else (cons (first DIR-LIST) (remove-dir ghost (rest DIR-LIST)))]; recursive call
              ))
          )
    (remove-dir ghost POSSIBLE-DIR)
    ))

;; compare-dist
;; author: Albi Geldehuys

;compare-dist: Ghost, Number -> Vector<Number>
;compares the distance of all possible directions and outputs the smallest one
;header: (define (compare-dist ghost goal) (vector 1 0))

;; Examples
(check-expect (compare-dist PINKY-INIT (make-posn 10 15)) (vector 0 -1))

(check-expect (compare-dist (make-Ghost CLYDE-LEFT
                                        (make-posn (+ (* CELL-SIZE 2) 10) (+ (* CELL-SIZE 1) 10))
                                        (make-posn 2 1)
                                        (vector 0 0)  (vector 0 0)
                                        GHOST-SPEED "chase")
                            (make-posn 10 15))
              (vector 0 1))

;; Code

(define (compare-dist ghost goal)
  (local (; list of all actual possible directions for the ghost
          (define DIR-LIST (poss-dir ghost))
          ;dist-from-pos: Ghost Number Vector<Number> -> Number
          ; takes a ghost and its goal point and returns the distance between them
          (define (dist-from-pos ghost goal dir)
            (calc-dist (make-posn (+ (posn-x (Ghost-grid_pos ghost))
                                     (vector-ref dir 0))
                                  (+ (posn-y (Ghost-grid_pos ghost))
                                     (vector-ref dir 1))) goal))
          ;compare: Ghost Number Vector<Number> -> Vector<Number>
          (define (compare ghost goal dir-list)
            (cond
              [(empty? (rest dir-list)) (first dir-list)]
              [else (if (< (dist-from-pos ghost goal (first dir-list))
                           (dist-from-pos ghost goal (compare ghost goal (rest dir-list))))
                        (first dir-list)
                        (compare ghost goal (rest dir-list)))] ;recursive call
              ))
          )
    (compare ghost goal DIR-LIST)
    ))

;; move-pacman
;; author: Albi Geldehuys

;move-pacman: Pacman -> Pacman
; it changes pixel coordinates of Pacman
;header: (define (move-pacman entity) PACMAN-INIT)

(define (move-pacman entity)
  (make-Pacman (Pacman-img entity)
               (make-posn (+ (posn-x (Pacman-pix_pos entity))
                             (* (vector-ref (Pacman-dir entity) 0) (Pacman-speed entity)))
                          (+ (posn-y (Pacman-pix_pos entity))
                             (* (vector-ref (Pacman-dir entity) 1) (Pacman-speed entity))))
               (calc-grid-pos entity)
               (Pacman-dir entity)
               (Pacman-stored_dir entity)
               (Pacman-speed entity)
               (Pacman-point entity)
               (Pacman-life entity)))


;; eaten?
;; author: Francesco Casarella

;eaten?: GameState -> Boolean
; it takes a GameState and checks whether
; any ghost is touching pacman or not
;header: (define (eaten? state) #false)

;Examples

;inky
(define PacInk
  (make-GameState (GameState-pacman STATE-INIT)
                  (make-Ghost (Ghost-img (GameState-inky STATE-INIT))
                              (Ghost-pix_pos (GameState-inky STATE-INIT))
                              (make-posn 10 15)
                              (Ghost-dir (GameState-inky STATE-INIT))
                              (Ghost-stored_dir (GameState-inky STATE-INIT))
                              (Ghost-speed (GameState-inky STATE-INIT))
                              (Ghost-status (GameState-inky STATE-INIT)))
                  (GameState-pinky STATE-INIT)
                  (GameState-clyde STATE-INIT)
                  (GameState-blinky STATE-INIT)
                  (GameState-base STATE-INIT)
                  (GameState-background STATE-INIT)
                  (GameState-cookie_time STATE-INIT)
                  (GameState-absolute_time STATE-INIT)))
(check-expect (eaten? PacInk) #true)

;pinky
(define PacPin
  (make-GameState (GameState-pacman STATE-INIT)
                  (GameState-inky STATE-INIT)
                  (make-Ghost (Ghost-img (GameState-pinky STATE-INIT))
                              (Ghost-pix_pos (GameState-pinky STATE-INIT))
                              (make-posn 10 15)
                              (Ghost-dir (GameState-pinky STATE-INIT))
                              (Ghost-stored_dir (GameState-pinky STATE-INIT))
                              (Ghost-speed (GameState-pinky STATE-INIT))
                              (Ghost-status (GameState-pinky STATE-INIT)))
                  (GameState-clyde STATE-INIT)
                  (GameState-blinky STATE-INIT)
                  (GameState-base STATE-INIT)
                  (GameState-background STATE-INIT)
                  (GameState-cookie_time STATE-INIT)
                  (GameState-absolute_time STATE-INIT)))
(check-expect (eaten? PacPin) #true)

;clyde
(define PacCly
  (make-GameState (GameState-pacman STATE-INIT)
                  (GameState-inky STATE-INIT)
                  (GameState-pinky STATE-INIT)
                  (make-Ghost (Ghost-img (GameState-clyde STATE-INIT))
                              (Ghost-pix_pos (GameState-clyde STATE-INIT))
                              (make-posn 10 15)
                              (Ghost-dir (GameState-clyde STATE-INIT))
                              (Ghost-stored_dir (GameState-clyde STATE-INIT))
                              (Ghost-speed (GameState-clyde STATE-INIT))
                              (Ghost-status (GameState-clyde STATE-INIT)))
                  (GameState-blinky STATE-INIT)
                  (GameState-base STATE-INIT)
                  (GameState-background STATE-INIT)
                  (GameState-cookie_time STATE-INIT)
                  (GameState-absolute_time STATE-INIT)))
(check-expect (eaten? PacCly) #true)

;blinky
(define PacBli
  (make-GameState (GameState-pacman STATE-INIT)
                  (GameState-inky STATE-INIT)
                  (GameState-pinky STATE-INIT)
                  (GameState-clyde STATE-INIT)
                  (make-Ghost (Ghost-img (GameState-blinky STATE-INIT))
                              (Ghost-pix_pos (GameState-blinky STATE-INIT))
                              (make-posn 10 15)
                              (Ghost-dir (GameState-blinky STATE-INIT))
                              (Ghost-stored_dir (GameState-blinky STATE-INIT))
                              (Ghost-speed (GameState-blinky STATE-INIT))
                              (Ghost-status (GameState-blinky STATE-INIT)))
                  (GameState-base STATE-INIT)
                  (GameState-background STATE-INIT)
                  (GameState-cookie_time STATE-INIT)
                  (GameState-absolute_time STATE-INIT)))
(check-expect (eaten? PacBli) #true)

;no-eat
(define no-eat
  (make-GameState (GameState-pacman STATE-INIT)
                  (GameState-inky STATE-INIT)
                  (GameState-pinky STATE-INIT)
                  (GameState-clyde STATE-INIT)
                  (GameState-blinky STATE-INIT)
                  (GameState-base STATE-INIT)
                  (GameState-background STATE-INIT)
                  (GameState-cookie_time STATE-INIT)
                  (GameState-absolute_time STATE-INIT)))
(check-expect (eaten? no-eat) #false)


(define (eaten? state)
  (local (; actual grid position of pacman and the ghosts
          (define Pac (Pacman-grid_pos (GameState-pacman state)))
          (define Ink (Ghost-grid_pos (GameState-inky state)))
          (define Pin (Ghost-grid_pos (GameState-pinky state)))
          (define Cly (Ghost-grid_pos (GameState-clyde state)))
          (define Bli (Ghost-grid_pos (GameState-blinky state)))
          )
  (cond
    [(equal? Pac Ink) #true] ; check inky
    [(equal? Pac Pin) #true] ; check pinky
    [(equal? Pac Cly) #true] ; check clyde
    [(equal? Pac Bli) #true] ; check blinky
    [else #false]
    )
   )
  )

;; move-ghost
;; author: Albi Geldehuys
;; revised by Enrico Benedettini

;move-ghost: Ghost -> Ghost
; it updates pixel coordinates of Ghost
;header: (define (move-ghost entity) INKY-INIT)

(define (move-ghost entity)
  (make-Ghost (Ghost-img entity)
              (make-posn (+ (posn-x (Ghost-pix_pos entity))
                            (* (vector-ref (Ghost-dir entity) 0) (Ghost-speed entity)))
                         (+ (posn-y (Ghost-pix_pos entity))
                            (* (vector-ref (Ghost-dir entity) 1) (Ghost-speed entity))))
               (calc-grid-pos entity)
               (Ghost-dir entity)
               (Ghost-stored_dir entity)
               (Ghost-speed entity)
               (Ghost-status entity)))


;change-state
;; author: Francesco Casarella
;Change-State: GameState -> GameState
; takes a GameState and returns the state with set ghosts according to
; what happens in the game
;header: (define (Change-state state) STATE-INIT)

;; Examples

;when out of range
(define Out-of (make-GameState (make-Pacman
                                (Pacman-img (GameState-pacman STATE-INIT))
                                (Pacman-pix_pos (GameState-pacman STATE-INIT))
                                (make-posn 21 9)
                                (Pacman-dir (GameState-pacman STATE-INIT))
                                (Pacman-stored_dir (GameState-pacman STATE-INIT))
                                (Pacman-speed (GameState-pacman STATE-INIT))
                                (Pacman-point (GameState-pacman STATE-INIT))
                                (Pacman-life (GameState-pacman STATE-INIT)))
                               (GameState-inky STATE-INIT)
                               (GameState-pinky STATE-INIT)
                               (GameState-clyde STATE-INIT)
                               (GameState-blinky STATE-INIT)
                               (GameState-base STATE-INIT)
                               (GameState-background STATE-INIT)
                               (GameState-cookie_time STATE-INIT)
                               (GameState-absolute_time STATE-INIT)))
;(check-expect (Change-State Out-of) Out-of)

;change-state of ghosts when the timer ends
(define Ghost-to-chase (make-GameState(GameState-pacman STATE-INIT) 
                                      (make-Ghost (Ghost-img (GameState-inky STATE-INIT))
                                                  (Ghost-pix_pos (GameState-inky STATE-INIT))
                                                  (Ghost-grid_pos (GameState-inky STATE-INIT))
                                                  (Ghost-dir (GameState-inky STATE-INIT))
                                                  (Ghost-stored_dir (GameState-inky STATE-INIT))
                                                  1
                                                  "scared")
                                      (make-Ghost (Ghost-img (GameState-pinky STATE-INIT))
                                                  (Ghost-pix_pos (GameState-pinky STATE-INIT))
                                                  (Ghost-grid_pos (GameState-pinky STATE-INIT))
                                                  (Ghost-dir (GameState-pinky STATE-INIT))
                                                  (Ghost-stored_dir (GameState-pinky STATE-INIT))
                                                  1
                                                  "scared")
                                      (make-Ghost (Ghost-img (GameState-clyde STATE-INIT))
                                                  (Ghost-pix_pos (GameState-clyde STATE-INIT))
                                                  (Ghost-grid_pos (GameState-clyde STATE-INIT))
                                                  (Ghost-dir (GameState-clyde STATE-INIT))
                                                  (Ghost-stored_dir (GameState-clyde STATE-INIT))
                                                  1
                                                  "scared")
                                      (make-Ghost (Ghost-img (GameState-blinky STATE-INIT))
                                                   (Ghost-pix_pos (GameState-blinky STATE-INIT))
                                                   (Ghost-grid_pos (GameState-blinky STATE-INIT))
                                                   (Ghost-dir (GameState-blinky STATE-INIT))
                                                   (Ghost-stored_dir (GameState-blinky STATE-INIT))
                                                   1
                                                   "scared")
                                       (GameState-base STATE-INIT)
                                       (GameState-background STATE-INIT)
                                       8.25
                                       10))
  
(check-expect (Change-State Ghost-to-chase) (make-GameState (GameState-pacman STATE-INIT)
                                                            (GameState-inky STATE-INIT)
                                                            (GameState-pinky STATE-INIT)
                                                            (GameState-clyde STATE-INIT)
                                                            (GameState-blinky STATE-INIT)
                                                            (GameState-base STATE-INIT)
                                                            (GameState-background STATE-INIT)
                                                            8.25
                                                            10))
;chage-state of ghosts when pacman eats the super cookie
(define Ghost-to-scared (make-GameState (make-Pacman
                                  (Pacman-img (GameState-pacman STATE-INIT))
                                  (Pacman-pix_pos (GameState-pacman STATE-INIT))
                                  (make-posn 2 2)
                                  (Pacman-dir (GameState-pacman STATE-INIT))
                                  (Pacman-stored_dir (GameState-pacman STATE-INIT))
                                  (Pacman-speed (GameState-pacman STATE-INIT))
                                  (Pacman-point (GameState-pacman STATE-INIT))
                                  (Pacman-life (GameState-pacman STATE-INIT)))
                                 (GameState-inky STATE-INIT)
                                 (GameState-pinky STATE-INIT)
                                 (GameState-clyde STATE-INIT)
                                 (GameState-blinky STATE-INIT)
                                 (GameState-base STATE-INIT)
                                 (GameState-background STATE-INIT)
                                 (GameState-cookie_time STATE-INIT)
                                 (GameState-absolute_time STATE-INIT)))
;  (check-expect (Change-State Ghost-to-scared)
;                (make-GameState (make-Pacman
;                                 (Pacman-img (GameState-pacman STATE-INIT))
;                                 (Pacman-pix_pos (GameState-pacman STATE-INIT))
;                                 (make-posn 2 2)
;                                 (Pacman-dir (GameState-pacman STATE-INIT))
;                                 (Pacman-stored_dir (GameState-pacman STATE-INIT))
;                                 (Pacman-speed (GameState-pacman STATE-INIT))
;                                 (Pacman-point (GameState-pacman STATE-INIT))
;                                 (Pacman-life (GameState-pacman STATE-INIT)))
;                                (make-Ghost (Ghost-img (GameState-inky STATE-INIT))
;                                            (Ghost-pix_pos (GameState-inky STATE-INIT))
;                                            (Ghost-grid_pos (GameState-inky STATE-INIT))
;                                            (Ghost-dir (GameState-inky STATE-INIT))
;                                            (Ghost-stored_dir (GameState-inky STATE-INIT))
;                                            1
;                                            "scared")
;                                (make-Ghost (Ghost-img (GameState-pinky STATE-INIT))
;                                            (Ghost-pix_pos (GameState-pinky STATE-INIT))
;                                            (Ghost-grid_pos (GameState-pinky STATE-INIT))
;                                            (Ghost-dir (GameState-pinky STATE-INIT))
;                                            (Ghost-stored_dir (GameState-pinky STATE-INIT))
;                                            1
;                                            "scared")
;                                (make-Ghost (Ghost-img (GameState-clyde STATE-INIT))
;                                            (Ghost-pix_pos (GameState-clyde STATE-INIT))
;                                            (Ghost-grid_pos (GameState-clyde STATE-INIT))
;                                            (Ghost-dir (GameState-clyde STATE-INIT))
;                                            (Ghost-stored_dir (GameState-clyde STATE-INIT))
;                                            1
;                                            "scared")
;                                (make-Ghost (Ghost-img (GameState-blinky STATE-INIT))
;                                             (Ghost-pix_pos (GameState-blinky STATE-INIT))
;                                             (Ghost-grid_pos (GameState-blinky STATE-INIT))
;                                             (Ghost-dir (GameState-blinky STATE-INIT))
;                                             (Ghost-stored_dir (GameState-blinky STATE-INIT))
;                                             1
;                                             "scared")
;                                 (GameState-base STATE-INIT)
;                                 (GameState-background STATE-INIT)
;                                 (GameState-cookie_time STATE-INIT)
;                                 (GameState-absolute_time STATE-INIT)))
;when nothing happens
(define Nothing (make-GameState (GameState-pacman STATE-INIT)
                                (GameState-inky STATE-INIT)
                                (GameState-pinky STATE-INIT)
                                (GameState-clyde STATE-INIT)
                                (GameState-blinky STATE-INIT)
                                (GameState-base STATE-INIT)
                                (GameState-background STATE-INIT)
                                (GameState-cookie_time STATE-INIT)
                                (GameState-absolute_time STATE-INIT)))
(check-expect (Change-State Nothing) Nothing)

;; Code
(define (Change-State state)
  (local (; actual x's pacman's grid's position 
          (define Pac-X (posn-x (Pacman-grid_pos (GameState-pacman state))))
          ; actual y's pacman's grid's position
          (define Pac-Y (posn-y (Pacman-grid_pos (GameState-pacman state))))
          ;make-scared-ghost: Ghost -> Ghost
          ; sets a ghost to its scared state
          (define (make-scared-ghost ghost)
            (make-Ghost
             (Ghost-img ghost)
             (Ghost-pix_pos ghost)
             (Ghost-grid_pos ghost)
             (Ghost-dir ghost)
             (Ghost-stored_dir ghost)
             1
             "scared"))
          ;make-chase-ghost: Ghost -> Ghost
          ; sets a ghost to its chase state
          (define (make-chase-ghost ghost)
            (make-Ghost
             (Ghost-img ghost)
             (Ghost-pix_pos ghost)
             (Ghost-grid_pos ghost)
             (Ghost-dir ghost)
             (Ghost-stored_dir ghost)
             GHOST-SPEED
             "chase"))
          )
  (cond
    [(< 20 Pac-X) state]
    [(> (GameState-cookie_time state) END-COOKIE-TIME)
     ; sets each ghost to chase when the cookie effect ends
     (make-GameState (GameState-pacman state)
                     (make-chase-ghost (GameState-inky state))
                     (make-chase-ghost (GameState-pinky state))
                     (make-chase-ghost (GameState-clyde state))
                     (make-chase-ghost (GameState-blinky state))
                     (GameState-base state)
                     (GameState-background state)
                     (GameState-cookie_time state)
                     (GameState-absolute_time state))]
    [(equal? (vector-ref (vector-ref (GameState-base state) Pac-Y)Pac-X) "C")
     ; sets each ghost to chase when the special cookie is eaten
     (make-GameState (GameState-pacman state)
                     (make-scared-ghost (GameState-inky state))
                     (make-scared-ghost (GameState-pinky state))
                     (make-scared-ghost (GameState-clyde state))
                     (make-scared-ghost (GameState-blinky state))
                     (GameState-base state)
                     (GameState-background state)
                     0
                     (GameState-absolute_time state))]
    [else state])))

;; check-ghost
;; author: Enrico Benedettini, Francesco Casarella
;check-ghost: GameState -> GameState
; takes a state and returns the state with updated ghost according to their state
;header: (define (check-ghost state) STATE-INIT)

;;Examples
;(check-expect (check-ghost STATE-INIT)
 ;             (make-GameState
               

(define (check-ghost state)
  (local (;reset: Ghost Image -> Ghost
          ; takes a ghost and sets it to its initial state
          (define (reset ghost)
            (make-Ghost (Ghost-img ghost)
                        (Ghost-pix_pos ghost)
                        (Ghost-grid_pos ghost)
                        (Ghost-dir ghost)
                        (Ghost-stored_dir ghost)
                        GHOST-SPEED
                        "chase")))
  (if (< (GameState-cookie_time state) END-COOKIE-TIME)
      ; if the cookie time is not at the end updates the time
      (make-GameState (GameState-pacman state)
                      (GameState-inky state)
                      (GameState-pinky state)
                      (GameState-clyde state)
                      (GameState-blinky state)
                      (GameState-base state)
                      (GameState-background state)
                      (+ TICK-RATE (GameState-cookie_time state))
                      (GameState-absolute_time state))
      (make-GameState (GameState-pacman state)
                      (reset (GameState-inky state))
                      (reset (GameState-pinky state))
                      (reset (GameState-clyde state))
                      (reset (GameState-blinky state))
                      (GameState-base state)
                      (GameState-background state)
                      (GameState-cookie_time state)
                      (GameState-absolute_time state)))))

;; scatter-chase? function
;; authors: Alessandro Cravioglio, Albi Geldenhuys
;scatter-chase?: GameState Ghost -> Ghost
; Structure Structure -> Structure
; this function takes as input the GameState and a Ghost and,
; following a precise timing schedule, changes the Ghost-status
; between chase and scatter
; header: (define scatter-chase? state ghost) state ghost)

(define (scatter-chase? state ghost)
  (local (;make-ghost: Ghost String -> Ghost
          ; sets the given ghost to the new status
          (define (make-ghost ghost status)
            (make-Ghost
             (Ghost-img ghost)
             (Ghost-pix_pos ghost)
             (Ghost-grid_pos ghost)
             (Ghost-dir ghost)
             (Ghost-stored_dir ghost)
             (Ghost-speed ghost)
             status))
          (define (check-status ghost)
            (cond
              [(and (not (string=? (Ghost-status ghost) "scared"))
                   (not (string=? (Ghost-status ghost) "eaten")))
               #true]
              [else #false]))
          )
    (cond
      [(and (< (GameState-absolute_time state) 7) (check-status ghost))
       (make-ghost ghost "scatter")]
      [(and (and (<= 7 (GameState-absolute_time state))(< (GameState-absolute_time state) 27))
            (check-status ghost))
       (make-ghost ghost "chase")]
      [(and (and (<= 27 (GameState-absolute_time state))(< (GameState-absolute_time state) 34))
            (check-status ghost))
        (make-ghost ghost "scatter")]
      [(and (and (<= 34 (GameState-absolute_time state))(< (GameState-absolute_time state) 54))
            (check-status ghost))
       (make-ghost ghost "chase")]
      [(and (and (<= 54 (GameState-absolute_time state))(< (GameState-absolute_time state) 59))
            (check-status ghost))
       (make-ghost ghost "scatter")]
      [(and (<= 59 (GameState-absolute_time state))
            (check-status ghost))
       (make-ghost ghost "chase")]
      [else ghost])
    ))


;; UPDATE
;; authors: Albi Geldehuys, Enrico Benedettini, Francesco Casarella
;update: GameState -> GameState
; it takes a GameState and returns an updated gamestate containing
; the various elements in their new positions
;header: (define (update state) STATE-INIT)

(define (update state)
  (check-time
   (death
    (Eat-Cookie
     (check-ghost
      (Change-State
       (make-GameState (fix (move-pacman (pacman-animation state (GameState-pacman state))))
                       (fix-ghost (move-ghost (inky-movement
                                               state
                                               (scatter-chase?
                                                state
                                                (inky-animation state (GameState-inky state))))))
                       (fix-ghost (move-ghost (pinky-movement
                                               state
                                               (scatter-chase?
                                                state
                                                (pinky-animation state (GameState-pinky state)))
                                               (GameState-pacman state))))
                       (fix-ghost (move-ghost (clyde-movement
                                               state
                                               (scatter-chase?
                                                state
                                                (clyde-animation state (GameState-clyde state)))
                                               (GameState-pacman state))))
                       (fix-ghost (move-ghost (blinky-movement
                                               state
                                               (scatter-chase?
                                                state
                                                (blinky-animation state (GameState-blinky state)))
                                               (GameState-pacman state))))
                       (GameState-base state)
                       (GameState-background state)
                       (GameState-cookie_time state)
                       (+ TICK-RATE (GameState-absolute_time state)))))))))

;; check-time
;; author: Enrico Benedettini
;check-time: GameState -> GameState
; takes a state and returns the unchanged state within the 4 first seconds
;header: (define (check-time state) STATE-INIT)

;; Examples
(check-expect (check-time STATE-INIT)
              (make-GameState PACMAN-INIT INKY-INIT PINKY-INIT CLYDE-INIT BLINKY-INIT GRID BACKGROUND 0 0.025))

;; Code
(define (check-time state)
  (cond
    [(< (GameState-absolute_time state) 4)
     (make-GameState
      (make-Pacman
       (Pacman-img (GameState-pacman state))
       (Pacman-pix_pos (GameState-pacman STATE-INIT))
       (Pacman-grid_pos (GameState-pacman STATE-INIT))
       (Pacman-dir (GameState-pacman STATE-INIT))
       (Pacman-stored_dir (GameState-pacman STATE-INIT))
       (Pacman-speed (GameState-pacman STATE-INIT))
       (Pacman-point (GameState-pacman state))
       (Pacman-life (GameState-pacman state)))
      (GameState-inky STATE-INIT)
      (GameState-pinky STATE-INIT)
      (GameState-clyde STATE-INIT)
      (GameState-blinky STATE-INIT)
      (GameState-base STATE-INIT)
      (GameState-background STATE-INIT)
      (GameState-cookie_time STATE-INIT)
      (+ TICK-RATE (GameState-absolute_time state)))]
    [else state]))

;; GHOSTS ANIMATIONS FUNCTIONS
;; inky-animation
;; author: Enrico Benedettini
;inky-animation: GameState Ghost -> Ghost
; takes a ghost and applies inky animation on it
;header: (define (inky-animation state ghost) INKY-INIT)

(define (inky-animation state ghost)
  (animation state ghost INKY-UP INKY-UP-2 INKY-DOWN INKY-DOWN-2
             INKY-LEFT INKY-LEFT-2 INKY-RIGHT INKY-RIGHT-2))

;; pinky-animation
;; author: Enrico Benedettini
;pinky-animation: GameState Ghost -> Ghost
; takes a ghost and applies pinky animation on it
;header: (define (inky-animation state ghost) PINKY-INIT)

(define (pinky-animation state ghost)
  (animation state ghost PINKY-UP PINKY-UP-2 PINKY-DOWN PINKY-DOWN-2
             PINKY-LEFT PINKY-LEFT-2 PINKY-RIGHT PINKY-RIGHT-2))

;; clyde-animation
;; author: Enrico Benedettini
;clyde-animation: GameState Ghost -> Ghost
; takes a ghost and applies clyde animation on it
;header: (define (clyde-animation state ghost) CLYDE-INIT)

(define (clyde-animation state ghost)
  (animation state ghost CLYDE-UP CLYDE-UP-2 CLYDE-DOWN CLYDE-DOWN-2
             CLYDE-LEFT CLYDE-LEFT-2 CLYDE-RIGHT CLYDE-RIGHT-2))

;; blinky-animation
;; author: Enrico Benedettini
;blinky-animation: GameState Ghost -> Ghost
; takes a ghost and applies blinky animation on it
;header: (define (blinky-animation state ghost) BLINKY-INIT)

(define (blinky-animation state ghost)
  (animation state ghost BLINKY-UP BLINKY-UP-2 BLINKY-DOWN BLINKY-DOWN-2
             BLINKY-LEFT BLINKY-LEFT-2 BLINKY-RIGHT BLINKY-RIGHT-2))
;; animation
;; author: Enrico Benedettini
;animation: GameState Ghost -> Ghost
;header: (define (animation state ghost img-up1 img-up2 img-down1 img-down2
;                           img-left1 img-left2 img-right1 img-right2) INKY-INIT)

;;Examples
(check-expect (animation STATE-INIT INKY-INIT INKY-UP INKY-UP-2 INKY-DOWN
                         INKY-DOWN-2 INKY-LEFT INKY-LEFT-2 INKY-RIGHT INKY-RIGHT-2)
              (make-Ghost INKY-RIGHT
                          (make-posn (+ (* 20 9) 10) (+ (* 20 9) 10))
                          (make-posn 9 9)
                          (vector 1 0)  (vector 0 0)
                          2 "chase"))

(check-expect (animation STATE-INIT PINKY-INIT PINKY-UP PINKY-UP-2 PINKY-DOWN
                         PINKY-DOWN-2 PINKY-LEFT PINKY-LEFT-2 PINKY-RIGHT PINKY-RIGHT-2)
              (make-Ghost PINKY-UP
                          (make-posn (+ (* 20 10) 10) (+ (* 20 9) 10))
                          (make-posn 10 9)
                          (vector 0 -1)  (vector 0 0)
                          2 "chase"))

(check-expect (animation STATE-INIT CLYDE-INIT CLYDE-UP CLYDE-UP-2 CLYDE-DOWN CLYDE-DOWN-2
                         CLYDE-LEFT CLYDE-LEFT-2 CLYDE-RIGHT CLYDE-RIGHT-2)
              (make-Ghost CLYDE-LEFT
                          (make-posn (+ (* 20 11) 10) (+ (* 20 9) 10))
                          (make-posn 11 9)
                          (vector -1 0)  (vector 0 0)
                          2 "chase"))

(check-expect (animation STATE-INIT BLINKY-INIT BLINKY-UP BLINKY-UP-2 BLINKY-DOWN BLINKY-DOWN-2
                         BLINKY-LEFT BLINKY-LEFT-2 BLINKY-RIGHT BLINKY-RIGHT-2)
              (make-Ghost BLINKY-LEFT
                          (make-posn (+ (* 20 10) 10) (+ (* 20 7) 10))
                          (make-posn 10 7)
                          (vector -1 0)  (vector 0 0)
                          2 "chase"))

(define (animation state ghost img-up1 img-up2 img-down1 img-down2
                   img-left1 img-left2 img-right1 img-right2)
  (local (;make-img-ghost: Image -> Ghost
          ; takes an image and return the ghost with the new image set in it
          (define (make-img-ghost img)
            (make-Ghost
             img
             (Ghost-pix_pos ghost)
             (Ghost-grid_pos ghost)
             (Ghost-dir ghost)
             (Ghost-stored_dir ghost)
             (Ghost-speed ghost)
             (Ghost-status ghost)))
          ;number of tick-rates
          (define TICK-RATES (/ (GameState-absolute_time state) TICK-RATE))
          ;ghost's direction vector
          (define dir (Ghost-dir ghost))
          ;condition to make the animation
          (define (divide) (< (modulo TICK-RATES 8) 4)))
  (cond
    [(string=? (Ghost-status ghost) "eaten")
      ghost]
    [(or (string=? (Ghost-status ghost) "chase")
         (string=? (Ghost-status ghost) "scatter"))
     (cond
       [(and (divide) (= (vector-ref dir 0) 1))
        (make-img-ghost img-right1)]
       [(= (vector-ref dir 0) 1)
        (make-img-ghost img-right2)]
       [(and (divide) (= (vector-ref dir 0) -1))
        (make-img-ghost img-left1)]
       [(= (vector-ref dir 0) -1)
        (make-img-ghost img-left2)]
       [(and (divide) (= (vector-ref dir 1) 1))
        (make-img-ghost img-down1)]
       [(= (vector-ref dir 1) 1)
        (make-img-ghost img-down2)]
       [(and (divide) (= (vector-ref dir 1) -1))
         (make-img-ghost img-up1)]
       [else
         (make-img-ghost img-up2)])]
    [else (cond
            [(divide) (make-img-ghost SCARED-IMG)]
            [(and (divide) (< 3 (GameState-cookie_time state) 7))
             (make-img-ghost SCARED-IMG-3)]
            [(< 3 (GameState-cookie_time state) 7)
             (make-img-ghost SCARED-IMG-4)]
            [else (make-img-ghost SCARED-IMG-2)]
            )])))

;; pacman-animation
;; author: Enrico Benedettini
;pacman-animation: GameState Pacman -> Pacman
; gives and state and a pacman and returns the animated pacman
;header: (define (pacman-animation state pacman) PACMAN-INIT)

;;Examples
(check-expect (pacman-animation STATE-INIT PACMAN-INIT)
              (make-Pacman PAC-IMG
               (make-posn (+ (* 20 10) 10) (+ (* 20 15) 10))
               (make-posn 10 15)
               (vector 0 0) (vector 0 0)
               2 0 3))

;; Code

(define (pacman-animation state pacman)
  (local (;make-img-pacman: Image -> Pacman
          ; takes an image and returns the pacman with the set img
          (define (make-img-pacman img)
            (make-Pacman
             img
             (Pacman-pix_pos pacman)
             (Pacman-grid_pos pacman)
             (Pacman-dir pacman)
             (Pacman-stored_dir pacman)
             (Pacman-speed pacman)
             (Pacman-point pacman)
             (Pacman-life pacman)))
          ;pacman's direction's vector
          (define dir (Pacman-dir pacman))
          ;number of tick-rates
          (define TICK-RATES (/ (GameState-absolute_time state) TICK-RATE))
          ;condition to make the animation
          (define (divide) (< (modulo TICK-RATES 8) 4)))
    (cond
      [(and (divide) (= (vector-ref dir 0) 1))
       (make-img-pacman PAC-IMG)]
      [(= (vector-ref dir 0) 1)
       (make-img-pacman PAC-SHIFTED-IMG)]
      [(and (divide) (= (vector-ref dir 0) -1))
       (make-img-pacman (rotate 180 PAC-IMG))]
      [(= (vector-ref dir 0) -1)
       (make-img-pacman (rotate 180 PAC-SHIFTED-IMG))]
      [(and (divide) (= (vector-ref dir 1) 1))
       (make-img-pacman (rotate 270 PAC-IMG))]
      [(= (vector-ref dir 1) 1)
       (make-img-pacman (rotate 270 PAC-SHIFTED-IMG))]
      [(and (divide) (= (vector-ref dir 1) -1))
       (make-img-pacman (rotate 90 PAC-IMG))]
      [(= (vector-ref dir 1) -1)
       (make-img-pacman (rotate 90 PAC-SHIFTED-IMG))]
      [else pacman]
      )))

;; death
;; author : Francesco Casarella

;death: GameState -> GameState
; it takes a GameState, checks if pacman touches or not any ghost and
; eventually returns the updated state to stop the game and pacman with one life less
;header: (define (death state) STATE-INIT)

;; Examples
;pac-eats-inky
(define pac-eats-inky
  (make-GameState (GameState-pacman STATE-INIT)
                  (make-Ghost (Ghost-img (GameState-inky STATE-INIT))
                              (Ghost-pix_pos (GameState-inky STATE-INIT))
                              (make-posn 10 15)
                              (Ghost-dir (GameState-inky STATE-INIT))
                              (Ghost-stored_dir (GameState-inky STATE-INIT))
                              (Ghost-speed (GameState-inky STATE-INIT))
                              "scared")
                  (GameState-pinky STATE-INIT)
                  (GameState-clyde STATE-INIT)
                  (GameState-blinky STATE-INIT)
                  (GameState-base STATE-INIT)
                  (GameState-background STATE-INIT)
                  (GameState-cookie_time STATE-INIT)
                  (GameState-absolute_time STATE-INIT)))
(check-expect (death pac-eats-inky)
              (make-GameState (make-Pacman
                               (Pacman-img (GameState-pacman STATE-INIT))
                               (Pacman-pix_pos (GameState-pacman STATE-INIT))
                               (Pacman-grid_pos (GameState-pacman STATE-INIT))
                               (Pacman-dir (GameState-pacman STATE-INIT))
                               (Pacman-stored_dir (GameState-pacman STATE-INIT))
                               (Pacman-speed (GameState-pacman STATE-INIT))
                               (+ 200 (Pacman-point (GameState-pacman STATE-INIT)))
                               (Pacman-life (GameState-pacman STATE-INIT)))
                              (GameState-inky STATE-INIT)
                              (GameState-pinky STATE-INIT)
                              (GameState-clyde STATE-INIT)
                              (GameState-blinky STATE-INIT)
                              (GameState-base STATE-INIT)
                              (GameState-background STATE-INIT)
                              (GameState-cookie_time STATE-INIT)
                              (GameState-absolute_time STATE-INIT)))

;pac-eats-pinky
(define pac-eats-pinky
  (make-GameState (GameState-pacman STATE-INIT)
                  (GameState-inky STATE-INIT)
                  (make-Ghost (Ghost-img (GameState-pinky STATE-INIT))
                              (Ghost-pix_pos (GameState-pinky STATE-INIT))
                              (make-posn 10 15)
                              (Ghost-dir (GameState-pinky STATE-INIT))
                              (Ghost-stored_dir (GameState-pinky STATE-INIT))
                              (Ghost-speed (GameState-pinky STATE-INIT))
                              "scared")
                  (GameState-clyde STATE-INIT)
                  (GameState-blinky STATE-INIT)
                  (GameState-base STATE-INIT)
                  (GameState-background STATE-INIT)
                  (GameState-cookie_time STATE-INIT)
                  (GameState-absolute_time STATE-INIT)))
(check-expect (death pac-eats-pinky)
              (make-GameState (make-Pacman
                               (Pacman-img (GameState-pacman STATE-INIT))
                               (Pacman-pix_pos (GameState-pacman STATE-INIT))
                               (Pacman-grid_pos (GameState-pacman STATE-INIT))
                               (Pacman-dir (GameState-pacman STATE-INIT))
                               (Pacman-stored_dir (GameState-pacman STATE-INIT))
                               (Pacman-speed (GameState-pacman STATE-INIT))
                               (+ 200 (Pacman-point (GameState-pacman STATE-INIT)))
                               (Pacman-life (GameState-pacman STATE-INIT)))
                              (GameState-inky STATE-INIT)
                              (GameState-pinky STATE-INIT)
                              (GameState-clyde STATE-INIT)
                              (GameState-blinky STATE-INIT)
                              (GameState-base STATE-INIT)
                              (GameState-background STATE-INIT)
                              (GameState-cookie_time STATE-INIT)
                              (GameState-absolute_time STATE-INIT)))

;pac-eats-clyde
(define pac-eats-clyde
  (make-GameState (GameState-pacman STATE-INIT)
                  (GameState-inky STATE-INIT)
                  (GameState-pinky STATE-INIT)
                  (make-Ghost (Ghost-img (GameState-clyde STATE-INIT))
                              (Ghost-pix_pos (GameState-clyde STATE-INIT))
                              (make-posn 10 15)
                              (Ghost-dir (GameState-clyde STATE-INIT))
                              (Ghost-stored_dir (GameState-clyde STATE-INIT))
                              (Ghost-speed (GameState-clyde STATE-INIT))
                              "scared")
                  (GameState-blinky STATE-INIT)
                  (GameState-base STATE-INIT)
                  (GameState-background STATE-INIT)
                  (GameState-cookie_time STATE-INIT)
                  (GameState-absolute_time STATE-INIT)))
(check-expect (death pac-eats-clyde)
              (make-GameState (make-Pacman
                               (Pacman-img (GameState-pacman STATE-INIT))
                               (Pacman-pix_pos (GameState-pacman STATE-INIT))
                               (Pacman-grid_pos (GameState-pacman STATE-INIT))
                               (Pacman-dir (GameState-pacman STATE-INIT))
                               (Pacman-stored_dir (GameState-pacman STATE-INIT))
                               (Pacman-speed (GameState-pacman STATE-INIT))
                               (+ 200 (Pacman-point (GameState-pacman STATE-INIT)))
                               (Pacman-life (GameState-pacman STATE-INIT)))
                              (GameState-inky STATE-INIT)
                              (GameState-pinky STATE-INIT)
                              (GameState-clyde STATE-INIT)
                              (GameState-blinky STATE-INIT)
                              (GameState-base STATE-INIT)
                              (GameState-background STATE-INIT)
                              (GameState-cookie_time STATE-INIT)
                              (GameState-absolute_time STATE-INIT))) 
;pac-eats-blinky
(define pac-eats-blinky
  (make-GameState (GameState-pacman STATE-INIT)
                  (GameState-inky STATE-INIT)
                  (GameState-pinky STATE-INIT)
                  (GameState-clyde STATE-INIT)
                  (make-Ghost (Ghost-img (GameState-blinky STATE-INIT))
                              (Ghost-pix_pos (GameState-blinky STATE-INIT))
                              (make-posn 10 15)
                              (Ghost-dir (GameState-blinky STATE-INIT))
                              (Ghost-stored_dir (GameState-blinky STATE-INIT))
                              (Ghost-speed (GameState-blinky STATE-INIT))
                              "scared")
                  (GameState-base STATE-INIT)
                  (GameState-background STATE-INIT)
                  (GameState-cookie_time STATE-INIT)
                  (GameState-absolute_time STATE-INIT)))
(check-expect (death pac-eats-blinky)
              (make-GameState (make-Pacman
                               (Pacman-img (GameState-pacman STATE-INIT))
                               (Pacman-pix_pos (GameState-pacman STATE-INIT))
                               (Pacman-grid_pos (GameState-pacman STATE-INIT))
                               (Pacman-dir (GameState-pacman STATE-INIT))
                               (Pacman-stored_dir (GameState-pacman STATE-INIT))
                               (Pacman-speed (GameState-pacman STATE-INIT))
                               (+ 200 (Pacman-point (GameState-pacman STATE-INIT)))
                               (Pacman-life (GameState-pacman STATE-INIT)))
                              (GameState-inky STATE-INIT)
                              (GameState-pinky STATE-INIT)
                              (GameState-clyde STATE-INIT) 
                               (make-Ghost
                                (Ghost-img (GameState-blinky STATE-INIT))
                                (make-posn (+ (* CELL-SIZE 11) 10) (+ (* CELL-SIZE 9) 10))
                                (make-posn 11 9)
                                (Ghost-dir (GameState-blinky STATE-INIT))
                                (Ghost-stored_dir (GameState-blinky STATE-INIT))
                                (Ghost-speed (GameState-blinky STATE-INIT))
                                "chase")
                              (GameState-base STATE-INIT)
                              (GameState-background STATE-INIT)
                              (GameState-cookie_time STATE-INIT)
                              (GameState-absolute_time STATE-INIT)))

;pac-eaten-by-blinky
(define pac-eaten-by-blinky
  (make-GameState (GameState-pacman STATE-INIT)
                  (GameState-inky STATE-INIT)
                  (GameState-pinky STATE-INIT)
                  (GameState-clyde STATE-INIT)
                  (make-Ghost (Ghost-img (GameState-blinky STATE-INIT))
                              (Ghost-pix_pos (GameState-blinky STATE-INIT))
                              (make-posn 10 15)
                              (Ghost-dir (GameState-blinky STATE-INIT))
                              (Ghost-stored_dir (GameState-blinky STATE-INIT))
                              (Ghost-speed (GameState-blinky STATE-INIT))
                              "chase")
                  (GameState-base STATE-INIT)
                  (GameState-background STATE-INIT)
                  (GameState-cookie_time STATE-INIT)
                  (GameState-absolute_time STATE-INIT)))
(check-expect (death pac-eaten-by-blinky)
              (make-GameState (make-Pacman
                               (Pacman-img (GameState-pacman STATE-INIT))
                               (Pacman-pix_pos (GameState-pacman STATE-INIT))
                               (Pacman-grid_pos (GameState-pacman STATE-INIT))
                               (Pacman-dir (GameState-pacman STATE-INIT))
                               (Pacman-stored_dir (GameState-pacman STATE-INIT))
                               (Pacman-speed (GameState-pacman STATE-INIT))
                               (Pacman-point (GameState-pacman STATE-INIT))
                               (- (Pacman-life (GameState-pacman STATE-INIT)) 1))
                              (GameState-inky STATE-INIT)
                              (GameState-pinky STATE-INIT)
                              (GameState-clyde STATE-INIT) 
                              (GameState-blinky STATE-INIT)
                              (GameState-base STATE-INIT)
                              (GameState-background STATE-INIT)
                              (GameState-cookie_time STATE-INIT)
                              (GameState-absolute_time STATE-INIT)))

;; Code

(define (death state)
  (local (; actual grid position of pacman and of all the ghosts
          (define Pac (Pacman-grid_pos (GameState-pacman state)))
          (define Ink (Ghost-grid_pos (GameState-inky state)))
          (define Pin (Ghost-grid_pos (GameState-pinky state)))
          (define Cly (Ghost-grid_pos (GameState-clyde state)))
          (define Bli (Ghost-grid_pos (GameState-blinky state)))
          ; actual pacman
          (define pac (GameState-pacman state))
          ; Ghost Ghost Ghost Ghost -> GameState
          (define (make-ghosts-state inky pinky clyde blinky)
            (make-GameState
             (make-Pacman
              (Pacman-img pac)
              (Pacman-pix_pos pac)
              (Pacman-grid_pos pac)
              (Pacman-dir pac)
              (Pacman-stored_dir pac)
              (Pacman-speed pac)
              (+ 200 (Pacman-point pac))
              (Pacman-life pac))
             inky
             pinky
             clyde
             blinky
             (GameState-base state)
             (GameState-background state)
             (GameState-cookie_time state)
             (GameState-absolute_time state)))
          )
  (cond
    [(and(equal? (eaten? state) #true)(equal? (Ghost-status (GameState-inky state)) "scared")(equal? Pac Ink)) ;inky's death
     (make-ghosts-state
      (GameState-inky STATE-INIT)
      (GameState-pinky state)
      (GameState-clyde state)
      (GameState-blinky state))]
    [(and(equal? (eaten? state) #true)(equal? (Ghost-status (GameState-pinky state)) "scared")(equal? Pac Pin)) ;pinky's death
     (make-ghosts-state
      (GameState-inky state)
      (GameState-pinky STATE-INIT)
      (GameState-clyde state)
      (GameState-blinky state))]
    [(and(equal? (eaten? state) #true)(equal? (Ghost-status (GameState-clyde state)) "scared")(equal? Pac Cly)) ;clyde's death
     (make-ghosts-state
      (GameState-inky state)
      (GameState-pinky state)
      (GameState-clyde STATE-INIT)
      (GameState-blinky state))]
    [(and(equal? (eaten? state) #true)(equal? (Ghost-status (GameState-blinky state)) "scared")(equal? Pac Bli)) ;blinky's death
     (make-ghosts-state
      (GameState-inky state)
      (GameState-pinky state)
      (GameState-clyde state)
      (make-Ghost
       (Ghost-img (GameState-blinky STATE-INIT))
       (make-posn (+ (* CELL-SIZE 11) 10) (+ (* CELL-SIZE 9) 10))
       (make-posn 11 9)
       (Ghost-dir (GameState-blinky STATE-INIT))
       (Ghost-stored_dir (GameState-blinky STATE-INIT))
       (Ghost-speed (GameState-blinky STATE-INIT))
       "chase"))]
    [(equal? (eaten? state) #true)
     (make-GameState
      (make-Pacman
       (Pacman-img (GameState-pacman STATE-INIT))
       (Pacman-pix_pos (GameState-pacman STATE-INIT))
       (Pacman-grid_pos (GameState-pacman STATE-INIT))
       (Pacman-dir (GameState-pacman STATE-INIT))
       (Pacman-stored_dir (GameState-pacman STATE-INIT))
       (Pacman-speed (GameState-pacman STATE-INIT))
       (Pacman-point (GameState-pacman state))
       (- (Pacman-life (GameState-pacman state)) 1))
      (GameState-inky STATE-INIT)
      (GameState-pinky STATE-INIT)
      (GameState-clyde STATE-INIT)
      (GameState-blinky STATE-INIT)
      (GameState-base state)
      (GameState-background state)
      (GameState-cookie_time state) 0)]
    [else state])))


;;eat cookies
;; author: Francesco Casarella
;Eat-Cookie: GameState -> GameState
;it changes the base if pacman eats a
;cookie and adds the points to the pacman
;header: (define (Eat-Cookie state) STATE-INIT)

;When Pacman is out of range
(define Out-of-range (make-GameState (make-Pacman
                                  (Pacman-img (GameState-pacman STATE-INIT))
                                  (Pacman-pix_pos (GameState-pacman STATE-INIT))
                                  (make-posn 21 9)
                                  (Pacman-dir (GameState-pacman STATE-INIT))
                                  (Pacman-stored_dir (GameState-pacman STATE-INIT))
                                  (Pacman-speed (GameState-pacman STATE-INIT))
                                  (Pacman-point (GameState-pacman STATE-INIT))
                                  (Pacman-life (GameState-pacman STATE-INIT)))
                                 (GameState-inky STATE-INIT)
                                 (GameState-pinky STATE-INIT)
                                 (GameState-clyde STATE-INIT)
                                 (GameState-blinky STATE-INIT)
                                 (GameState-base STATE-INIT)
                                 (GameState-background STATE-INIT)
                                 (GameState-cookie_time STATE-INIT)
                                 (GameState-absolute_time STATE-INIT)))
(check-expect (Eat-Cookie Out-of-range) Out-of-range)

;When Pacman does not eat any cookie
(define Not-Eat (make-GameState (make-Pacman
                                  (Pacman-img (GameState-pacman STATE-INIT))
                                  (Pacman-pix_pos (GameState-pacman STATE-INIT))
                                  (Pacman-grid_pos (GameState-pacman STATE-INIT))
                                  (Pacman-dir (GameState-pacman STATE-INIT))
                                  (Pacman-stored_dir (GameState-pacman STATE-INIT))
                                  (Pacman-speed (GameState-pacman STATE-INIT))
                                  (Pacman-point (GameState-pacman STATE-INIT))
                                  (Pacman-life (GameState-pacman STATE-INIT)))
                                 (GameState-inky STATE-INIT)
                                 (GameState-pinky STATE-INIT)
                                 (GameState-clyde STATE-INIT)
                                 (GameState-blinky STATE-INIT)
                                 (GameState-base STATE-INIT)
                                 (GameState-background STATE-INIT)
                                 (GameState-cookie_time STATE-INIT)
                                 (GameState-absolute_time STATE-INIT)))
(check-expect (Eat-Cookie Not-Eat) Not-Eat)

;When Pacman eats a normal cookie
(define Eat-N (make-GameState (make-Pacman
                                  (Pacman-img (GameState-pacman STATE-INIT))
                                  (Pacman-pix_pos (GameState-pacman STATE-INIT))
                                  (make-posn 11 15)
                                  (Pacman-dir (GameState-pacman STATE-INIT))
                                  (Pacman-stored_dir (GameState-pacman STATE-INIT))
                                  (Pacman-speed (GameState-pacman STATE-INIT))
                                  (Pacman-point (GameState-pacman STATE-INIT))
                                  (Pacman-life (GameState-pacman STATE-INIT)))
                                 (GameState-inky STATE-INIT)
                                 (GameState-pinky STATE-INIT)
                                 (GameState-clyde STATE-INIT)
                                 (GameState-blinky STATE-INIT)
                                 (GameState-base STATE-INIT)
                                 (GameState-background STATE-INIT)
                                 (GameState-cookie_time STATE-INIT)
                                 (GameState-absolute_time STATE-INIT)))

;(check-expect (Eat-Cookie Eat-N)
;              (make-GameState (make-Pacman
;                               (Pacman-img (GameState-pacman STATE-INIT))
;                               (Pacman-pix_pos (GameState-pacman STATE-INIT))
;                               (make-posn 11 15)
;                               (Pacman-dir (GameState-pacman STATE-INIT))
;                               (Pacman-stored_dir (GameState-pacman STATE-INIT))
;                               (Pacman-speed (GameState-pacman STATE-INIT))
;                               10
;                               (Pacman-life (GameState-pacman STATE-INIT)))
;                              (GameState-inky STATE-INIT)
;                              (GameState-pinky STATE-INIT)
;                              (GameState-clyde STATE-INIT)
;                              (GameState-blinky STATE-INIT)
;                              GRID
;                              (GameState-background STATE-INIT)
;                              (GameState-cookie_time STATE-INIT)
;                              (GameState-absolute_time STATE-INIT)))

;When Pacman eats a super cookie
(define Eat-S (make-GameState (make-Pacman
                                  (Pacman-img (GameState-pacman STATE-INIT))
                                  (Pacman-pix_pos (GameState-pacman STATE-INIT))
                                  (make-posn 2 2)
                                  (Pacman-dir (GameState-pacman STATE-INIT))
                                  (Pacman-stored_dir (GameState-pacman STATE-INIT))
                                  (Pacman-speed (GameState-pacman STATE-INIT))
                                  (Pacman-point (GameState-pacman STATE-INIT))
                                  (Pacman-life (GameState-pacman STATE-INIT)))
                                 (GameState-inky STATE-INIT)
                                 (GameState-pinky STATE-INIT)
                                 (GameState-clyde STATE-INIT)
                                 (GameState-blinky STATE-INIT)
                                 (GameState-base STATE-INIT)
                                 (GameState-background STATE-INIT)
                                 (GameState-cookie_time STATE-INIT)
                                 (GameState-absolute_time STATE-INIT)))
;(check-expect (Eat-Cookie Eat-S)
;              (make-GameState (make-Pacman
;                               (Pacman-img (GameState-pacman STATE-INIT))
;                               (Pacman-pix_pos (GameState-pacman STATE-INIT))
;                               (make-posn 2 2)
;                               (Pacman-dir (GameState-pacman STATE-INIT))
;                               (Pacman-stored_dir (GameState-pacman STATE-INIT))
;                               (Pacman-speed (GameState-pacman STATE-INIT))
;                               50
;                               (Pacman-life (GameState-pacman STATE-INIT)))
;                              (GameState-inky STATE-INIT)
;                              (GameState-pinky STATE-INIT)
;                              (GameState-clyde STATE-INIT)
;                              (GameState-blinky STATE-INIT)
;                              GRID
;                              (GameState-background STATE-INIT)
;                              (GameState-cookie_time STATE-INIT)
;                              (GameState-absolute_time STATE-INIT)))

;; Code

(define (Eat-Cookie state)
  (local (; actual x's grid's position of pacman
          (define Pac-X (posn-x (Pacman-grid_pos (GameState-pacman state))))
          ; actual y's grid's position of pacman
          (define Pac-Y (posn-y (Pacman-grid_pos (GameState-pacman state))))
          (define GRID-N (GameState-base state))
          )
  (cond
    [(< 20 Pac-X) state] ; out of range case
    [(equal? (vector-ref (vector-ref (GameState-base state) Pac-Y)Pac-X) "C")
     (make-GameState (make-Pacman
                      (Pacman-img (GameState-pacman state))
                      (Pacman-pix_pos (GameState-pacman state))
                      (Pacman-grid_pos (GameState-pacman state))
                      (Pacman-dir (GameState-pacman state))
                      (Pacman-stored_dir (GameState-pacman state))
                      (Pacman-speed (GameState-pacman state))
                      (+ (Pacman-point (GameState-pacman state)) 50)
                      (Pacman-life (GameState-pacman state)))
                     (GameState-inky state)
                     (GameState-pinky state)
                     (GameState-clyde state)
                     (GameState-blinky state)
                     (IsVoid? (vector-set! (vector-ref GRID-N  Pac-Y) Pac-X "E"))
                     (GameState-background state)
                     (GameState-cookie_time state)
                     (GameState-absolute_time state))]
    [(equal? (vector-ref (vector-ref (GameState-base state) Pac-Y)Pac-X) "P")
     ; when the grid value is a point it has to be removed
     (make-GameState (make-Pacman
                      (Pacman-img (GameState-pacman state))
                      (Pacman-pix_pos (GameState-pacman state))
                      (Pacman-grid_pos (GameState-pacman state))
                      (Pacman-dir (GameState-pacman state))
                      (Pacman-stored_dir (GameState-pacman state))
                      (Pacman-speed (GameState-pacman state))
                      (+ (Pacman-point (GameState-pacman state)) 10)
                      (Pacman-life (GameState-pacman state)))
                     (GameState-inky state)
                     (GameState-pinky state)
                     (GameState-clyde state)
                     (GameState-blinky state)
                     (IsVoid? (vector-set! (vector-ref GRID-N Pac-Y) Pac-X "E"))
                     (GameState-background state)
                     (GameState-cookie_time state)
                     (GameState-absolute_time state))]
    [else state]
  )))

;Is Void?
;; author: Francesco Casarella
;IsVoid?: X -> Base
; where X is one of:
; - Void        ; a void element
; - Base        ; the base grid
; takes a grid and returns th
;header: (define (IsVoid? element) GRID)
(define (IsVoid? element)
  (cond
    [(void? element) GRID]
    [else element]))


;;GHOST MOVEMENTS

;; PINKY-GOAL FUNCTION
;; author: Alessandro Cravioglio
;pinky-goal: Ghost Posn -> Posn
; the function takes as input a pacman and a ghost and outputs a posn,
; structured in that way: the final point is
; the vertex of a vector that point from the ghost to pacman, then
; double its modulo and translates the end point by +2 in the x axys
;header: (define (pinky-goale ghost pac_pos) (make-posn 0 0))

;; Code
(define (pinky-goal ghost pac_pos)
  (make-posn
   (+ (* (- (posn-x pac_pos)  (posn-x (Ghost-grid_pos ghost))) 2) 2)
   (* (- (posn-y pac_pos)  (posn-y (Ghost-grid_pos ghost))) 2)))

;; PINKY MOVEMENT FUNCTION
;; author: Alessandro Cravioglio
; pinky-movement: Ghost Pacman -> Ghost
; Structure Structure -> Structure
; the function PINKY-MOVEMENT takes as argument a ghost and a pacman, and outputs a
; ghost with the stored-dir changed following the ghost-mode, to reach in the fastest
; way the goal of the ghost
;header: (define (pinky-movement state ghost pacman) INKY-INIT)

;; Examples
(check-expect (pinky-movement STATE-INIT PINKY-INIT PACMAN-INIT)
              (make-Ghost
               PINKY-UP
               (make-posn 210 190)
               (make-posn 10 9)
               (vector 0 -1)
               (vector 0 -1)
               2
               "chase"))

(check-expect (pinky-movement
               STATE-INIT
               (make-Ghost
                PINKY-DOWN
                (make-posn 210 190)
                (make-posn 10 9)
                (vector 0 -1)
                (vector 0 -1)
                1
                "scared")
              PACMAN-INIT)
              (make-Ghost
               PINKY-DOWN
               (make-posn 210 190)
               (make-posn 10 9)
               (vector 0 -1)
               (vector 0 -1)
               1
               "scared"))

;; Code

(define (pinky-movement state ghost pacman)
  (local (;make-ghost: Vector<Number> -> Ghost
          ; returns the ghost with the set direction
          (define (make-ghost dir)
            (make-Ghost
             (Ghost-img ghost)
             (Ghost-pix_pos ghost)
             (Ghost-grid_pos ghost)
             (Ghost-dir ghost)
             dir
             (Ghost-speed ghost)
             (Ghost-status ghost))))
    (cond
      [(string=? (Ghost-status ghost) "chase")
       (make-ghost (compare-dist ghost (pinky-goal ghost (Pacman-grid_pos pacman))))]
      [(string=? (Ghost-status ghost) "scatter")
       (make-ghost (compare-dist ghost (make-posn 1 2)))]
      [(string=? (Ghost-status ghost) "scared")
       (random-movement state ghost)]
      [(string=? (Ghost-status ghost) "eaten")
       (make-ghost (compare-dist ghost (make-posn 9 9)))]
      )))


;; CAN-MOVE-GHOST? FUNCTIONS
;; author: Albi Geldenhuys
; GameState -> Boolean
; Structure -> Boolean
; Auxiliary functions to determine if the next cell is a valid cell for movement.
; If the output is #true, the cell is valid.
; the function takes as input a GameState and a Ghost, and outputs a boolean,
; indicating if the next cell in the same direction is a "W" or not.
; header: (define (can-move-ghost? entity) state ghost)

;; Code

(define (can-move-ghost? entity)
  (cond
    [(or (< (+ (posn-x (Ghost-grid_pos entity))
               (vector-ref (Ghost-stored_dir entity) 0)) 0)
         (> (+ (posn-x (Ghost-grid_pos entity))
               (vector-ref (Ghost-stored_dir entity) 0)) 20)) #true]
    [(string=? (vector-ref
                (vector-ref GRID (+ (posn-y (Ghost-grid_pos entity))
                                    (vector-ref (Ghost-stored_dir entity) 1)))
                (+ (posn-x (Ghost-grid_pos entity))
                   (vector-ref (Ghost-stored_dir entity) 0))) "W") #false]
    [else #true]))

;; move-fix-ghost
;; author: Albi Geldenhuys
;; revised by: Enrico Benedettini
;move-fix-ghost: Ghost -> Boolean
; it takes a Ghost and returns wether it's to fix or not 
;header: (define (move-fix-ghost entity) #true)

(define (move-fix-ghost entity)
  (cond
    [(and (equal? (modulo (posn-x (Ghost-pix_pos entity))
                          CELL-SIZE) (/ CELL-SIZE 2))
          (or (equal? (Ghost-dir entity) (vector 1 0))
              (equal? (Ghost-dir entity) (vector -1 0)))) #true]
    [(and (equal?
           (modulo (posn-y (Ghost-pix_pos entity))
                   CELL-SIZE) (/ CELL-SIZE 2))
          (or (equal? (Ghost-dir entity) (vector 0 1))
              (equal? (Ghost-dir entity) (vector 0 -1)))) #true]
    [else #false]))

;; FIX GHOST FUNCTION

;; fix-ghost
;; author: Albi Geldenhuys
;; revised by Enrico Benedettini
;fix-ghost: Ghost -> Ghost
; it returns the fixed position ghost
;header: (define (fix-ghost entity) INKY-INIT)

(define (fix-ghost entity)
  (local (;make-ghost: Posn Vector<Number> -> Ghost
          ; returns the ghost with the set position and actual direction
          (define (make-ghost pix-pos vec)
            (make-Ghost (Ghost-img entity)
                         pix-pos
                         (Ghost-grid_pos entity)
                         vec
                         (Ghost-stored_dir entity)
                         (Ghost-speed entity)
                         (Ghost-status entity))))
    (cond
      [(and (or (not (false? (move-fix-ghost entity)))              
                (equal? (Ghost-dir entity) (vector 0 0)))
            (can-move-ghost? entity))
       (make-ghost (Ghost-pix_pos entity)
                   (Ghost-stored_dir entity))]
      [(< (posn-x (Ghost-pix_pos entity)) 0)
       (make-ghost (make-posn 420 190)
                   (Ghost-dir entity))]
      [(> (posn-x (Ghost-pix_pos entity)) 420)
       (make-ghost (make-posn 0 190)
                   (Ghost-dir entity))]
      [else entity])))


; HERE ARE CONTAINED THE FUNCTIONS THAT MAKE INKY RANDOMLY MOVE TROUGH THE MAP, THAT MEANS
; THAT INKY WILL FOLLOW A STRAIGHT PATH UNTIL THE NEXT WALL, THEN IT WILL TAKE A RANDOM DIRECTION

;; FUNCTION go-direction
;; author: Alessandro Cravioglio
;; revised by Enrico Benedettini
; the functions takes as input a ghost and outputs a ghost with position changed
; in a specific direction
; go: Ghost -> Ghost
;header: (define (go x y ghost) INKY-INIT)

;; Code
(define (go x y ghost)
  (make-Ghost
   (Ghost-img ghost)
   (Ghost-pix_pos ghost)
   (calc-grid-pos ghost)
   (Ghost-dir ghost)
   (vector x y)
   (Ghost-speed ghost)
   (Ghost-status ghost)))


;; RANDOM-DIRECTION-(X/Y) FUNCTIONS
; GameState Ghost -> Ghost
; Structure Structure -> Structure
; the two random functions have basically the same goal: they
; take as input the GameState and the Ghost, the output is a ghost
; with the direction randomically changed.
; The functions are triggered when the corrispective possible?-direction function outputs #false.
; There are only two functions, because the direction can change only to the other axis.
; header: (define (random-direction-x/y state ghost) state ghost)

; x RANDOM

(define (random-direction-x state ghost)
  (local
    (; random number between 0 and 1
     (define RandomGenerator (random 2)))
    (cond
      [(and (equal? RandomGenerator 0) (member (vector 1 0) (poss-dir ghost)))
       (go 1 0 ghost)]
      [(and (equal? RandomGenerator 1) (member (vector -1 0) (poss-dir ghost)))
       (go -1 0 ghost)]
      [else (random-direction-x state ghost)])))

; y RANDOM

(define (random-direction-y state ghost)
  (local
    (; random number between 0 and 1
     (define RandomGenerator (random 2)))
    (cond
      [(and (equal? RandomGenerator 0) (member (vector 0 -1) (poss-dir ghost)))
       (go 0 -1 ghost)]
      [(and (equal? RandomGenerator 1) (member (vector 0 1) (poss-dir ghost)))
       (go 0 1 ghost)]
      [else (random-direction-y state ghost)])))

;; FUNCTION CROSS VALIDATION
; this function outputs #true if the ghost is in a cross, meaning that
; can take 3 possible directions
; random-cross: Ghost -> Boolean
; Structure -> Boolean
;header: (define (random-cross ghost) #false)

(define (random-cross ghost)
    (cond
      [(equal? (length (poss-dir ghost)) 2)
      (make-Ghost
       (Ghost-img ghost)
       (Ghost-pix_pos ghost)
       (calc-grid-pos ghost)
       (Ghost-dir ghost)
       (list-ref (poss-dir ghost) (random 2))
       (Ghost-speed ghost)
       (Ghost-status ghost))]
      [(equal? (length (poss-dir ghost)) 3)
      (make-Ghost
       (Ghost-img ghost)
       (Ghost-pix_pos ghost)
       (calc-grid-pos ghost)
       (Ghost-dir ghost)
       (list-ref (poss-dir ghost) (random 3))
       (Ghost-speed ghost)
       (Ghost-status ghost))]))
  

;; author: Alessandro Cravioglio
;; PATH-BLOCK FUNCTION
; GameState Ghost -> Boolean
; Structure Structure -> Boolean
; the function has as input the GameState and the Ghost, and outputs a boolean, indicating
; if the ghost can proceed in the same direction as before. In this case the output is #false
; header: (define (path-block state ghost) state ghost)

;; Examples
(check-expect (path-block STATE-INIT INKY-INIT)
              #false)

;; Code

(define (path-block state ghost)
  (cond 
    [(and (equal? (vector-ref (Ghost-dir ghost) 1) -1) (not (member (vector 0 -1) (poss-dir ghost)))) #true]
    [(and (equal? (vector-ref (Ghost-dir ghost) 1) 1) (not (member (vector 0 1) (poss-dir ghost)))) #true]
    [(and (equal? (vector-ref (Ghost-dir ghost) 0) 1) (not (member (vector 1 0) (poss-dir ghost)))) #true]
    [(and (equal? (vector-ref (Ghost-dir ghost) 0) -1) (not (member (vector -1 0) (poss-dir ghost)))) #true]  
    [else #false]))

;; author: Alessandro Cravioglio
;; RANDOM-MOVEMENT FUNCTION
; random-movement: GameState -> Ghost
; Structure -> Structure
; the function random-movement takes as input the GameState and the Ghost, and
; outputs the ghost with the pos updated. The direction of the ghost remains unchanged
; until it reaches a roads' cross, then it goes in a random direction until the next wall
; header: (define (random-movement state ghost) state ghost)

;; to do local

; Code

(define (random-movement state ghost)
  (cond
    [(path-block state ghost)
     (cond
       [(equal? (vector-ref (Ghost-dir ghost) 1) -1) (random-direction-x state ghost)]
       [(equal? (vector-ref (Ghost-dir ghost) 1) 1) (random-direction-x state ghost)]
       [(equal? (vector-ref (Ghost-dir ghost) 0) 1) (random-direction-y state ghost)]
       [(equal? (vector-ref (Ghost-dir ghost) 0) -1) (random-direction-y state ghost)])]
    [(or (equal? (length (poss-dir ghost)) 2)
         (equal? (length (poss-dir ghost)) 3))
     (random-cross ghost)]
    [(and (string=? (Ghost-status ghost) "scared")
          (and
           (equal? (posn-y (Ghost-grid_pos ghost)) 9)
           (< (posn-x (Ghost-grid_pos ghost)) 5)))
     (go 1 0 ghost)]
    
    [(and (string=? (Ghost-status ghost) "scared")
          (and
           (equal? (posn-y (Ghost-grid_pos ghost)) 9)
           (> (posn-x (Ghost-grid_pos ghost)) 15)))
     (go -1 0 ghost)]
    [else
     (cond
       [(equal? (vector-ref (Ghost-dir ghost) 1) -1) (go 0 -1 ghost)]
       [(equal? (vector-ref (Ghost-dir ghost) 1) 1) (go 0 1 ghost)]
       [(equal? (vector-ref (Ghost-dir ghost) 0) 1) (go 1 0 ghost)]
       [(equal? (vector-ref (Ghost-dir ghost) 0) -1) (go -1 0 ghost)])]))

;; author: Alessandro Cravioglio
;; FUNCTION MOVE-GHOST FOR INKY
; inky-movement: GameState Ghost -> Ghost
; Structure Structure -> Structure
; Specified only for a ghost because in this function
; it's called the specific function inky-movement.
; it takes an GameState and a Ghost and returns the Ghost translated by 1 pixel in one
; of the four directions
; header: (define (inky-movement state ghost) state ghost)

;; Examples
(check-expect (inky-movement STATE-INIT INKY-INIT)
              (make-Ghost INKY-RIGHT
                          (make-posn 190 190)
                          (make-posn 9 9)
                          (vector 1 0)
                          (vector 1 0)
                          GHOST-SPEED
                          "chase"))

(check-expect (inky-movement
               STATE-INIT
               (make-Ghost
                INKY-RIGHT
                (make-posn 190 190)
                (make-posn 9 9)
                (vector 1 0)
                (vector 1 0)
                GHOST-SPEED
                "scared"))
              (make-Ghost
               INKY-RIGHT
               (make-posn 190 190)
               (make-posn 9 9)
               (vector 1 0)
               (vector 1 0)
               2
               "scared"))
              
;; Code

(define (inky-movement state ghost)
  (cond 
    [(or (string=? (Ghost-status ghost) "scared")(string=? (Ghost-status ghost) "chase"))
     (random-movement state ghost)]
    [(string=? (Ghost-status ghost) "scatter")
     (make-ghost ghost (compare-dist ghost (make-posn 18 19)))]))

;make-ghost: Ghost Vector<Number> -> Ghost
; takes a direction and returns the ghost
; with the stored updated direction
;header: (define (make-ghost dir) INKY-INIT)

(define (make-ghost ghost dir)
  (make-Ghost
   (Ghost-img ghost)
   (Ghost-pix_pos ghost)
   (Ghost-grid_pos ghost)
   (Ghost-dir ghost)
   dir
   (Ghost-speed ghost)
   (Ghost-status ghost)))


;; blinky-movement
;; author: Albi Geldenhuys
;blinky-movement: Ghost Pacman -> Ghost
; takes a Ghost, pacman and moves him according to its state
;header: (define (blinky-movement ghost pacman) BLINKY-INIT)

;; Examples
(check-expect (blinky-movement STATE-INIT BLINKY-INIT PACMAN-INIT)
              (make-Ghost BLINKY-LEFT
                          (make-posn (+ (* CELL-SIZE 10) 10) (+ (* CELL-SIZE 7) 10))
                          (make-posn 10 7)
                          (vector -1 0)  (vector -1 0)
                          GHOST-SPEED "chase"))
(check-expect (blinky-movement STATE-INIT
                               (make-Ghost
                                BLINKY-LEFT
                                (make-posn (+ (* CELL-SIZE 10) 10) (+ (* CELL-SIZE 7) 10))
                                (make-posn 10 7)
                                (vector 0 0)  (vector -1 0)
                                GHOST-SPEED "scatter")
                               PACMAN-INIT)
              (make-Ghost BLINKY-LEFT
                          (make-posn (+ (* CELL-SIZE 10) 10) (+ (* CELL-SIZE 7) 10))
                          (make-posn 10 7)
                          (vector 0 0)  (vector 1 0)
                          GHOST-SPEED "scatter"))

;; Code

(define (blinky-movement state ghost pacman)
          (cond
     [(string=? (Ghost-status ghost) "chase")
      (make-ghost ghost (compare-dist ghost (Pacman-grid_pos pacman)))]
     [(string=? (Ghost-status ghost) "scatter")
      (make-ghost ghost (compare-dist ghost (make-posn 18 1)))]
     [(string=? (Ghost-status ghost) "scared")
      (random-movement state ghost)]
     [(string=? (Ghost-status ghost) "eaten")
      (make-ghost ghost (compare-dist ghost (make-posn 18 1)))]
   ))

;; clyde-movement
;; author: Albi Geldenhuys
;clyde-movement: Ghost Pacman -> Ghost
; takes a Ghost, pacman and moves him according to its state
;header: (define (clyde-movement ghost pacman) BLINKY-INIT)

;; Examples

(check-expect (clyde-movement STATE-INIT CLYDE-INIT PACMAN-INIT)
              (make-Ghost CLYDE-LEFT
                          (make-posn (+ (* CELL-SIZE 11) 10) (+ (* CELL-SIZE 9) 10))
                          (make-posn 11 9)
                          (vector -1 0)  (vector -1 0)
                          GHOST-SPEED "chase"))
(check-expect (clyde-movement STATE-INIT
                              (make-Ghost
                               CLYDE-LEFT
                               (make-posn (+ (* CELL-SIZE 9) 10) (+ (* CELL-SIZE 15) 10))
                               (make-posn 9 15)
                               (vector 0 0)  (vector 0 0)
                               GHOST-SPEED "chase")
                              PACMAN-INIT)
              (make-Ghost CLYDE-LEFT
                          (make-posn (+ (* CELL-SIZE 9) 10) (+ (* CELL-SIZE 15) 10))
                          (make-posn 9 15)
                          (vector 0 0)  (vector -1 0)
                          GHOST-SPEED "chase"))

(define (clyde-movement state ghost pacman)
  (cond
    [(string=? (Ghost-status ghost) "chase")
     (make-ghost ghost (if (< (calc-dist (Ghost-grid_pos ghost)
                                   (Pacman-grid_pos pacman))
                        8)
                     (compare-dist ghost (make-posn 1 19))
                     (compare-dist ghost (Pacman-grid_pos pacman))))]
    [(string=? (Ghost-status ghost) "scatter")
     (make-ghost ghost (compare-dist ghost (make-posn 1 19)))]
    [(string=? (Ghost-status ghost) "scared")
     (random-movement state ghost)]
    [(string=? (Ghost-status ghost) "eaten")
     (make-ghost ghost (compare-dist ghost (make-posn 9 9)))]
    ))

;; ghost-scatter
;; author: Albi Geldenhuys
;ghost-scatter: Ghost Number -> Ghost
; it takes a Ghost and returns the Ghost directed to a certain corner
;header:(define (ghost-scatter ghost corner) INKY-INIT)

(define (ghost-scatter ghost corner)
  (make-Ghost (Ghost-img ghost)
              (Ghost-pix_pos ghost)
              (Ghost-grid_pos ghost)
              (Ghost-dir ghost)
              (compare-dist ghost corner)
              (Ghost-speed ghost)
              (Ghost-status ghost)))

;-----------------------------------------------------------------------------------------------------
;; WIN-LOSE?
;; author: Francesco Casarella
;win-lose?: GameState -> Image
;takes a GameState and if the game is finished
;displays the right screen (you won/game over)
;header: (define (win-lose? state) BACKGROUND)

;; Examples
;in case you win
(define When-Win (make-GameState (make-Pacman
                                  (Pacman-img (GameState-pacman STATE-INIT))
                                  (Pacman-pix_pos (GameState-pacman STATE-INIT))
                                  (Pacman-grid_pos (GameState-pacman STATE-INIT))
                                  (Pacman-dir (GameState-pacman STATE-INIT))
                                  (Pacman-stored_dir (GameState-pacman STATE-INIT))
                                  (Pacman-speed (GameState-pacman STATE-INIT))
                                  (Pacman-point (GameState-pacman STATE-INIT))
                                  (Pacman-life (GameState-pacman STATE-INIT)))
                                 (GameState-inky STATE-INIT)
                                 (GameState-pinky STATE-INIT)
                                 (GameState-clyde STATE-INIT)
                                 (GameState-blinky STATE-INIT)
                                 (GameState-base STATE-INIT)
                                 (GameState-background STATE-INIT)
                                 (GameState-cookie_time STATE-INIT)
                                 (GameState-absolute_time STATE-INIT)))
(check-expect (win-lose? When-Win) 
              (overlay
           (above(text "YOU WON!" 40 "White")
                 (beside(text "Points:" 20 "White")
                        (text (number->string (Pacman-point (GameState-pacman STATE-INIT))) 20 "white")))
           (rectangle 420 500 "solid" "black")))

;in case you lose
(define When-Lose
  (make-GameState
   (make-Pacman
    (Pacman-img (GameState-pacman STATE-INIT))
    (Pacman-pix_pos (GameState-pacman STATE-INIT))
    (Pacman-grid_pos (GameState-pacman STATE-INIT))
    (Pacman-dir (GameState-pacman STATE-INIT))
    (Pacman-stored_dir (GameState-pacman STATE-INIT))
    (Pacman-speed (GameState-pacman STATE-INIT))
    (Pacman-point (GameState-pacman STATE-INIT))
    -1)
   (GameState-inky STATE-INIT)
   (GameState-pinky STATE-INIT)
   (GameState-clyde STATE-INIT)
   (GameState-blinky STATE-INIT)
   (GameState-base STATE-INIT)
   (GameState-background STATE-INIT)
   (GameState-cookie_time STATE-INIT)
   (GameState-absolute_time STATE-INIT)))
(check-expect (win-lose? When-Lose) 
              (overlay
               (above
                (text "GAME OVER" 40 "red")
                (text "Pacman was eaten" 20 "red"))
               (rectangle 420 500 "solid" "black")))

;; Code

(define (win-lose? state)
  (cond
    [(< (Pacman-life (GameState-pacman state)) 0)
     (overlay
      (above
       (text "GAME OVER" 40 "red")
       (text "Pacman was eaten" 20 "red"))
      (rectangle 420 500 "solid" "black"))]
    [else (overlay
           (above (text "YOU WON!" 40 "White")
                  (beside (text "Points:" 20 "White")
                          (text (number->string (Pacman-point (GameState-pacman state))) 20 "white")))
           (rectangle 420 500 "solid" "black"))]))


;; GAME-OVER?
;; author: Federico Soresina
;; revised by Enrico Benedettini
;game-over? : GameState -> Boolean
; it takes a GameState and checks if pacman lives' value is zero
;header: (define (game-over? state) #false)

(define PACMAN-OVER
  (make-Pacman PAC-IMG
               (make-posn 94 80)
               (make-posn 4 4)
               (vector 1 0)
               (vector 1 0)
               2 0 -1))

(define INKY-MOVED
  (make-Ghost INKY-UP
              (make-posn 230 354)
              (make-posn 11 17)
              (vector 1 0)  (vector 0 0)
              2 "scatter"))

(define BLINKY-MOVED
  (make-Ghost BLINKY-RIGHT
              (make-posn 230 354)
              (make-posn 11 17)
              (vector 1 0)  (vector 0 0)
              2 "scatter"))

(define PINKY-MOVED
  (make-Ghost INKY-UP
              (make-posn 230 354)
              (make-posn 11 17)
              (vector 1 0)  (vector 0 0)
              2 "scatter"))

(define CLYDE-MOVED
  (make-Ghost BLINKY-RIGHT
              (make-posn 230 354)
              (make-posn 11 17)
              (vector 1 0)  (vector 0 0)
              2 "scatter"))

(define GAME-OVER-LIVES
  (make-GameState PACMAN-OVER INKY-MOVED PINKY-MOVED CLYDE-MOVED BLINKY-MOVED
                  GRID BACKGROUND 0 13))

(define GAME-OVER-LIST
  (make-GameState PACMAN-INIT INKY-MOVED PINKY-MOVED CLYDE-MOVED BLINKY-MOVED
                  (vector (vector "W" "W" "W" "E" "E" "E")) BACKGROUND 0 13))

;(check-expect (game-over? STATE-INIT) #false)
(check-expect (game-over? GAME-OVER-LIVES) #true)
(check-expect (game-over? GAME-OVER-LIST) #true)

(define (game-over? gs)
  (cond
    [(or (< (Pacman-life (GameState-pacman gs)) 0)
         (empty-grid? (GameState-base gs))) #t]
    [else #f]))

;; empty-line-list?
;; author: Federico Soresina
; empty-line-list?: List<String> -> Boolean
; Checks wether a list representing a line contains only walls and empty cells
;header: (define (empty-line-list? L) #f)

(define (empty-line-list? L)
  (cond
    [(empty? L) #t]
    [else (if (or (string=? (first L) "C") (string=? (first L) "P"))
              #f (empty-line-list? (rest L)))]))

;; empty-line?
;; author: Federico Soresina
; empty-line?: Vector<String> -> Boolean
; Reuses empty-line-list for checking the same thing, but on a vector
;header: (define (empty-line? V) #f)

(define (empty-line? V)
  (empty-line-list? (vector->list V)))

;; empty-grid-list?
;; author: Federico Soresina
; empty-grid-list?: List<Vector<String>> -> Boolean
; Given a list of vectors representing a line in the grid for each vector, checks wetherthe grid is empty
;header: (define (empty-grid-list? L) #f)

(define (empty-grid-list? L)
  (cond
    [(empty? L) #t]
    [else (if (not (empty-line? (first L)))
              #f
              (empty-grid-list? (rest L)))]))
;; empty-grid?
;; author: Federico Soresina
; empty-grid?: Vector<Vector<String>> -> Boolean
; Same thing, but on a grid represented by a vector
;header: (define (empty-grid? V) #f)

(define (empty-grid? V)
  (empty-grid-list? (vector->list V)))

;-------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------

;final BIG BANG
(define (Game state rate)
  (big-bang state
    [to-draw draw-hud]
    [on-key pacman-move]
    [on-tick update rate]
    [stop-when game-over? win-lose?]))

(Game STATE-INIT TICK-RATE)

;;The whole code has been revised and commented by Enrico Benedettini sometimes helped by Francesco Casarella.
;;Where the comment 'revised by Group-Member-Name' appears it means that member
;; has been part of the reasoning or of the correctness of that function;
;; as correctness what is meant is its working functionalities, logical disposition
;; efficiency or code quality