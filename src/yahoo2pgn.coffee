 # Copyright 2011 Ben Marini
 #
 # Permission is hereby granted, free of charge, to any person obtaining
 # a copy of this software and associated documentation files (the
 # "Software"), to deal in the Software without restriction, including
 # without limitation the rights to use, copy, modify, merge, publish,
 # distribute, sublicense, and/or sell copies of the Software, and to
 # permit persons to whom the Software is furnished to do so, subject to
 # the following conditions:
 #
 # The above copyright notice and this permission notice shall be
 # included in all copies or substantial portions of the Software.
 #
 # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 # EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 # MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 # NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 # LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 # OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 # WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 #
 # History
 #
 # Originally written in 2001 by Ben Marini
 # Updated Apr 2007 to make use of the Prototype library
 #
 # Usage
 #
 #     converter = new Yahoo2Pgn([yahoo formatted game], [1-0, 1/2-1/2, 0-1]);
 #     converter.convert();
 #     console.log(converter.pgn);

class Yahoo2Pgn
  constructor: (yahoo_format, result) ->
    @yahoo_format = yahoo_format
    @result = result || "1-0"
    this.initBoard()

  initBoard: () ->
    @board = [["*","*","*","*","*","*","*","*","*","*","*","*"],
              ["*","*","*","*","*","*","*","*","*","*","*","*"],
              ["*","*","r","n","b","q","k","b","n","r","*","*"],
              ["*","*","p","p","p","p","p","p","p","p","*","*"],
              ["*","*"," "," "," "," "," "," "," "," ","*","*"],
              ["*","*"," "," "," "," "," "," "," "," ","*","*"],
              ["*","*"," "," "," "," "," "," "," "," ","*","*"],
              ["*","*"," "," "," "," "," "," "," "," ","*","*"],
              ["*","*","P","P","P","P","P","P","P","P","*","*"],
              ["*","*","R","N","B","Q","K","B","N","R","*","*"],
              ["*","*","*","*","*","*","*","*","*","*","*","*"],
              ["*","*","*","*","*","*","*","*","*","*","*","*"]]

  convert: () ->
    @pgn = this.convertHead() + "\n\n" + this.convertBody()
    this.initBoard()

  convertHead: () ->
    game_split = this.yahoo_format.split(/[\s\n]/)
    date_match = /;Date: (.*)/.exec(this.yahoo_format)

    head     = ['[Event "Yahoo! Chess Game"]',
                '[Site "Yahoo! Chess"]',
                '[Date "' + this.convertDate(date_match[1]) + '"]',
                '[Round ""]',
                '[White "' + game_split[5] + '"]',
                '[Black "' + game_split[7] + '"]',
                '[Result "' + this.result + '"]'].join("\n")

  convertDate: (date_string) ->
    date = new Date(date_string)
    zeropad = (n) -> if n > 9 then n else '0' + n
    date.getFullYear() + '.' + zeropad( date.getMonth() + 1 ) + '.' + zeropad( date.getDate() )

  convertBody: () ->
    game_split    = this.yahoo_format.split(/[\s\n]/)
    a_number      = /[0-9]/
    body          = ""
    player        = ['white','black']
    word_iterator = 0

    # for i = 15; i < game_split.length; i++
    for token in game_split[15..game_split.length]
      if token.length == 0
        # Do nothing, this is a blank line

      else if a_number.test(token.charAt(0))
        body += " " + token + " "
        word_iterator = -1

      else if token == "o-o"
        word_iterator++
        body += "O-O "
        this.castleKingside(player[word_iterator])

      else if token == "o-o-o"
        word_iterator++
        body += "O-O-O "
        this.castleQueenside(player[word_iterator])

      else 
        word_iterator++
        body += this.convertMove(token) + " "
        this.updateBoard(token)

    return body.trim()

  convertMove: (move) ->
    piece    = ""
    takes    = ""
    check    = ""
    promote  = ""
    backRank = /[18]/
    coord    = this.getCoordinates(move)

    letter_on_square = @board[coord.j][coord.i]

    if ! /[ pP]/.test(letter_on_square)
      piece = letter_on_square.toUpperCase()

    if move.charAt(2) == "x"
      if letter_on_square == "p" || letter_on_square == "P"
        takes = move.charAt(0) + "x"
      else
        takes = "x"

    if move.charAt(2) == "-" && letter_on_square.toUpperCase() == "P"
      if coord.i != coord.k
        takes = move.charAt(0) + "x"

    if move.length == 6
      check = "+"

    if move.length == 7
      check = "#"

    if (move.charAt(4) == '8') && (letter_on_square == "P")
      promote = "=Q";
      @board[coord.j][coord.i] = "Q";

    if (move.charAt(4) == '1') && (letter_on_square == "p")
      promote = "=Q"
      @board[coord.j][coord.i] = "q"

    return  piece + this.checkAmbig(move) + takes + move.charAt(3) + move.charAt(4) + promote + check;

  chy: (y) ->
    y_array = [0,9,8,7,6,5,4,3,2];
    return y_array[y];

  chx: (x) ->
    # a => 2, b => 3, etc...
    return x.charCodeAt(0) - 95;

  getCoordinates: (move) ->
    return {
      i: Number(this.chx(move.charAt(0))),
      j: Number(this.chy(move.charAt(1))),
      k: Number(this.chx(move.charAt(3))),
      l: Number(this.chy(move.charAt(4)))
    }

  updateBoard: (move) ->
    coord = this.getCoordinates(move);

    @board[coord.l][coord.k] = @board[coord.j][coord.i];
    @board[coord.j][coord.i] = " ";

  castleKingside: (player) ->
    if player == 'white'
      @board[9][9] = " ";
      @board[9][8] = "K";
      @board[9][7] = "R";
      @board[9][6] = " ";
    else
      @board[2][9] = " ";
      @board[2][8] = "k";
      @board[2][7] = "r";
      @board[2][6] = " ";

  castleQueenside: (player) ->
    if player == 'white'
      @board[9][2] = " ";
      @board[9][4] = "K";
      @board[9][5] = "R";
      @board[9][6] = " ";
    else
      @board[2][2] = " ";
      @board[2][4] = "k";
      @board[2][5] = "r";
      @board[2][6] = " ";

  checkAmbig: (move) ->
    coord = this.getCoordinates(move)
    piece = @board[coord.j][coord.i]

    if (piece == 'r') || (piece == 'R')
      return this.checkRook(piece, move)

    if (piece == 'n') || (piece == 'N')
      return this.checkKnight(piece, move)

    if (piece == 'q') || (piece == 'Q')
      return this.checkQueen(piece, move)

    return ""

  checkRook: (piece, move) ->
    coord = this.getCoordinates(move);

    up    = this.lookUp(piece, coord.l, coord.k, coord.i);
    down  = this.lookDown(piece, coord.l, coord.k, coord.i);
    left  = this.lookLeft(piece, coord.l, coord.k, coord.i);
    right = this.lookRight(piece, coord.l, coord.k, coord.i);

    rooks = up + down + left + right;

    if rooks > 100
      if up >= 1 && down >= 1
        return move.charAt(1)
      else
        return move.charAt(0)

    return ""

  look: (vector, piece, l, k, i) ->
    for limit in [1..8]
      row = l - (vector.y * limit)
      col = k - (vector.x * limit)
      return 0 if @board[row][col] == '*'
      return (if col == i then 100 else 1) if @board[row][col] == piece
      return 0 if @board[row][col] != ' '
    return 0

  lookUp: (piece,l,k,i) ->
    this.look({ x: 0, y: 1 }, piece, l, k, i)

  lookDown: (piece,l,k,i) ->
    this.look({ x: 0, y: -1 }, piece, l, k, i)

  lookLeft: (piece,l,k,i) ->
    this.look({ x: -1, y: 0 }, piece, l, k, i)

  lookRight: (piece,l,k,i) ->
    this.look({ x: 1, y: 0 }, piece, l, k, i)

  lookUpLeft: (piece,l,k,i) ->
    this.look({ x: -1, y: 1 }, piece, l, k, i)

  lookUpRight: (piece,l,k,i) ->
    this.look({ x: 1, y: 1 }, piece, l, k, i)

  lookDownRight: (piece,l,k,i) ->
    this.look({ x: 1, y: -1 }, piece, l, k, i)

  lookDownLeft: (piece,l,k,i) ->
    this.look({ x: -1, y: -1 }, piece, l, k, i)

  checkKnight: (piece, move) ->
    coord    = this.getCoordinates(move);
    knights  = 0;
    knights1 = 0;
    knights2 = 0;
    knights3 = 0;
    knights4 = 0;

    if @board[coord.l-2][coord.k+1] == piece then knights1++
    if @board[coord.l+2][coord.k+1] == piece then knights1++
    if @board[coord.l-2][coord.k-1] == piece then knights2++
    if @board[coord.l+2][coord.k-1] == piece then knights2++
    if @board[coord.l-1][coord.k+2] == piece then knights3++
    if @board[coord.l+1][coord.k+2] == piece then knights3++
    if @board[coord.l-1][coord.k-2] == piece then knights4++
    if @board[coord.l+1][coord.k-2] == piece then knights4++

    knights = knights1 + knights2 + knights3 + knights4;

    if knights1 > 1 || knights2 > 1 || knights3 > 1 || knights4 > 1 then return move.charAt(1)
    if knights > 1 then return move.charAt(0)
    return ""

  checkQueen: (piece, move) ->
    coord      = this.getCoordinates(move);

    upleft     = this.lookUpLeft(piece, coord.l, coord.k, coord.i);
    up         = this.lookUp(piece, coord.l, coord.k, coord.i);
    upright    = this.lookUpRight(piece, coord.l, coord.k, coord.i);
    downleft   = this.lookDownLeft(piece, coord.l, coord.k, coord.i);
    down       = this.lookDown(piece, coord.l, coord.k, coord.i);
    downright  = this.lookDownRight(piece, coord.l, coord.k, coord.i);
    left       = this.lookLeft(piece, coord.l, coord.k, coord.i);
    right      = this.lookRight(piece, coord.l, coord.k, coord.i);

    pieceUp    = this.lookUp(piece, coord.j, coord.i);
    pieceDown  = this.lookDown(piece, coord.j, coord.i);

    queens = upleft + up + upright + downleft + down + downright + left + right;

    if queens > 100
      if queens >= 200 then return move.charAt(1);
      return move.charAt(0);

    return "";

root = exports ? this
root.converter = Yahoo2Pgn