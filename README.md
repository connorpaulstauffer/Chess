# Chess

## Description

Ruby implementation of chess. Playable in the command line.


## Features

 * Maximizes code DRYness
   * Modules refactor logic for specific move types
     * [Diagonalable][diagonal]
     * [Slideable][slide]
     * [Stepable][step]
     * [Straightable][straight]
   * Pieces inherit from base piece class
 * Responsive interface
   * $stdin.getch method and [cursor logic][cursor] enables players to navigate the board
   with the w, a, s, and d keys
   * Highlights valid moves based on cursor position
 * Utilizes the Null Object Pattern for empty squares
   * [Empty square][empty] class redefines piece methods to provide an appropriate response
   to interactions as opposed error messages
 * Simple [AI][ai] implementation makes moves in the following order of outcome preference
   * Puts opponent in checkmate
   * Puts opponent in check
   * Takes an opponent's piece
   * Random valid move

[diagonal]: ./modules/diagonalable.rb
[slide]: ./modules/slideable.rb
[step]: ./modules/stepable.rb
[straight]: ./modules/straightable.rb
[cursor]: ./board.rb
[empty]: ./empty_square.rb
[ai]: ./players/computer_player.rb


## Instructions

Clone this repository to a local directory. ```cd``` into the repository. Run
```ruby game.rb```. You will be prompted to choose the game settings. On your
turn, navigate the board with the w, a, s, and d keys. Select a piece
with the enter key, navigate to where you would like the move, and confirm the
move with the enter key.
