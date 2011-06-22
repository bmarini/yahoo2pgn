(function() {
  var Yahoo2Pgn, root;
  Yahoo2Pgn = (function() {
    function Yahoo2Pgn(yahoo_format, result) {
      this.yahoo_format = yahoo_format;
      this.result = result || "1-0";
      this.initBoard();
    }
    Yahoo2Pgn.prototype.initBoard = function() {
      return this.board = [["*", "*", "*", "*", "*", "*", "*", "*", "*", "*", "*", "*"], ["*", "*", "*", "*", "*", "*", "*", "*", "*", "*", "*", "*"], ["*", "*", "r", "n", "b", "q", "k", "b", "n", "r", "*", "*"], ["*", "*", "p", "p", "p", "p", "p", "p", "p", "p", "*", "*"], ["*", "*", " ", " ", " ", " ", " ", " ", " ", " ", "*", "*"], ["*", "*", " ", " ", " ", " ", " ", " ", " ", " ", "*", "*"], ["*", "*", " ", " ", " ", " ", " ", " ", " ", " ", "*", "*"], ["*", "*", " ", " ", " ", " ", " ", " ", " ", " ", "*", "*"], ["*", "*", "P", "P", "P", "P", "P", "P", "P", "P", "*", "*"], ["*", "*", "R", "N", "B", "Q", "K", "B", "N", "R", "*", "*"], ["*", "*", "*", "*", "*", "*", "*", "*", "*", "*", "*", "*"], ["*", "*", "*", "*", "*", "*", "*", "*", "*", "*", "*", "*"]];
    };
    Yahoo2Pgn.prototype.convert = function() {
      this.pgn = this.convertHead() + "\n\n" + this.convertBody();
      return this.initBoard();
    };
    Yahoo2Pgn.prototype.convertHead = function() {
      var date_match, game_split, head;
      game_split = this.yahoo_format.split(/[\s\n]/);
      date_match = /;Date: (.*)/.exec(this.yahoo_format);
      return head = ['[Event "Yahoo! Chess Game"]', '[Site "Yahoo! Chess"]', '[Date "' + this.convertDate(date_match[1]) + '"]', '[Round ""]', '[White "' + game_split[5] + '"]', '[Black "' + game_split[7] + '"]', '[Result "' + this.result + '"]'].join("\n");
    };
    Yahoo2Pgn.prototype.convertDate = function(date_string) {
      var date, zeropad;
      date = new Date(date_string);
      zeropad = function(n) {
        if (n > 9) {
          return n;
        } else {
          return '0' + n;
        }
      };
      return date.getFullYear() + '.' + zeropad(date.getMonth() + 1) + '.' + zeropad(date.getDate());
    };
    Yahoo2Pgn.prototype.convertBody = function() {
      var a_number, body, game_split, player, token, word_iterator, _i, _len, _ref;
      game_split = this.yahoo_format.split(/[\s\n]/);
      a_number = /[0-9]/;
      body = "";
      player = ['white', 'black'];
      word_iterator = 0;
      _ref = game_split.slice(15, (game_split.length + 1) || 9e9);
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        token = _ref[_i];
        if (token.length === 0) {} else if (a_number.test(token.charAt(0))) {
          body += " " + token + " ";
          word_iterator = -1;
        } else if (token === "o-o") {
          word_iterator++;
          body += "O-O ";
          this.castleKingside(player[word_iterator]);
        } else if (token === "o-o-o") {
          word_iterator++;
          body += "O-O-O ";
          this.castleQueenside(player[word_iterator]);
        } else {
          word_iterator++;
          body += this.convertMove(token) + " ";
          this.updateBoard(token);
        }
      }
      return body.trim();
    };
    Yahoo2Pgn.prototype.convertMove = function(move) {
      var backRank, check, coord, letter_on_square, piece, promote, takes;
      piece = "";
      takes = "";
      check = "";
      promote = "";
      backRank = /[18]/;
      coord = this.getCoordinates(move);
      letter_on_square = this.board[coord.j][coord.i];
      if (!/[ pP]/.test(letter_on_square)) {
        piece = letter_on_square.toUpperCase();
      }
      if (move.charAt(2) === "x") {
        if (letter_on_square === "p" || letter_on_square === "P") {
          takes = move.charAt(0) + "x";
        } else {
          takes = "x";
        }
      }
      if (move.charAt(2) === "-" && letter_on_square.toUpperCase() === "P") {
        if (coord.i !== coord.k) {
          takes = move.charAt(0) + "x";
        }
      }
      if (move.length === 6) {
        check = "+";
      }
      if (move.length === 7) {
        check = "#";
      }
      if ((move.charAt(4) === '8') && (letter_on_square === "P")) {
        promote = "=Q";
        this.board[coord.j][coord.i] = "Q";
      }
      if ((move.charAt(4) === '1') && (letter_on_square === "p")) {
        promote = "=Q";
        this.board[coord.j][coord.i] = "q";
      }
      return piece + this.checkAmbig(move) + takes + move.charAt(3) + move.charAt(4) + promote + check;
    };
    Yahoo2Pgn.prototype.chy = function(y) {
      var y_array;
      y_array = [0, 9, 8, 7, 6, 5, 4, 3, 2];
      return y_array[y];
    };
    Yahoo2Pgn.prototype.chx = function(x) {
      return x.charCodeAt(0) - 95;
    };
    Yahoo2Pgn.prototype.getCoordinates = function(move) {
      return {
        i: Number(this.chx(move.charAt(0))),
        j: Number(this.chy(move.charAt(1))),
        k: Number(this.chx(move.charAt(3))),
        l: Number(this.chy(move.charAt(4)))
      };
    };
    Yahoo2Pgn.prototype.updateBoard = function(move) {
      var coord;
      coord = this.getCoordinates(move);
      this.board[coord.l][coord.k] = this.board[coord.j][coord.i];
      return this.board[coord.j][coord.i] = " ";
    };
    Yahoo2Pgn.prototype.castleKingside = function(player) {
      if (player === 'white') {
        this.board[9][9] = " ";
        this.board[9][8] = "K";
        this.board[9][7] = "R";
        return this.board[9][6] = " ";
      } else {
        this.board[2][9] = " ";
        this.board[2][8] = "k";
        this.board[2][7] = "r";
        return this.board[2][6] = " ";
      }
    };
    Yahoo2Pgn.prototype.castleQueenside = function(player) {
      if (player === 'white') {
        this.board[9][2] = " ";
        this.board[9][4] = "K";
        this.board[9][5] = "R";
        return this.board[9][6] = " ";
      } else {
        this.board[2][2] = " ";
        this.board[2][4] = "k";
        this.board[2][5] = "r";
        return this.board[2][6] = " ";
      }
    };
    Yahoo2Pgn.prototype.checkAmbig = function(move) {
      var coord, piece;
      coord = this.getCoordinates(move);
      piece = this.board[coord.j][coord.i];
      if ((piece === 'r') || (piece === 'R')) {
        return this.checkRook(piece, move);
      }
      if ((piece === 'n') || (piece === 'N')) {
        return this.checkKnight(piece, move);
      }
      if ((piece === 'q') || (piece === 'Q')) {
        return this.checkQueen(piece, move);
      }
      return "";
    };
    Yahoo2Pgn.prototype.checkRook = function(piece, move) {
      var coord, down, left, right, rooks, up;
      coord = this.getCoordinates(move);
      up = this.lookUp(piece, coord.l, coord.k, coord.i);
      down = this.lookDown(piece, coord.l, coord.k, coord.i);
      left = this.lookLeft(piece, coord.l, coord.k, coord.i);
      right = this.lookRight(piece, coord.l, coord.k, coord.i);
      rooks = up + down + left + right;
      if (rooks > 100) {
        if (up >= 1 && down >= 1) {
          return move.charAt(1);
        } else {
          return move.charAt(0);
        }
      }
      return "";
    };
    Yahoo2Pgn.prototype.look = function(vector, piece, l, k, i) {
      var col, limit, row;
      for (limit = 1; limit <= 8; limit++) {
        row = l - (vector.y * limit);
        col = k - (vector.x * limit);
        if (this.board[row][col] === '*') {
          return 0;
        }
        if (this.board[row][col] === piece) {
          if (col === i) {
            return 100;
          } else {
            return 1;
          }
        }
        if (this.board[row][col] !== ' ') {
          return 0;
        }
      }
      return 0;
    };
    Yahoo2Pgn.prototype.lookUp = function(piece, l, k, i) {
      return this.look({
        x: 0,
        y: 1
      }, piece, l, k, i);
    };
    Yahoo2Pgn.prototype.lookDown = function(piece, l, k, i) {
      return this.look({
        x: 0,
        y: -1
      }, piece, l, k, i);
    };
    Yahoo2Pgn.prototype.lookLeft = function(piece, l, k, i) {
      return this.look({
        x: -1,
        y: 0
      }, piece, l, k, i);
    };
    Yahoo2Pgn.prototype.lookRight = function(piece, l, k, i) {
      return this.look({
        x: 1,
        y: 0
      }, piece, l, k, i);
    };
    Yahoo2Pgn.prototype.lookUpLeft = function(piece, l, k, i) {
      return this.look({
        x: -1,
        y: 1
      }, piece, l, k, i);
    };
    Yahoo2Pgn.prototype.lookUpRight = function(piece, l, k, i) {
      return this.look({
        x: 1,
        y: 1
      }, piece, l, k, i);
    };
    Yahoo2Pgn.prototype.lookDownRight = function(piece, l, k, i) {
      return this.look({
        x: 1,
        y: -1
      }, piece, l, k, i);
    };
    Yahoo2Pgn.prototype.lookDownLeft = function(piece, l, k, i) {
      return this.look({
        x: -1,
        y: -1
      }, piece, l, k, i);
    };
    Yahoo2Pgn.prototype.checkKnight = function(piece, move) {
      var coord, knights, knights1, knights2, knights3, knights4;
      coord = this.getCoordinates(move);
      knights = 0;
      knights1 = 0;
      knights2 = 0;
      knights3 = 0;
      knights4 = 0;
      if (this.board[coord.l - 2][coord.k + 1] === piece) {
        knights1++;
      }
      if (this.board[coord.l + 2][coord.k + 1] === piece) {
        knights1++;
      }
      if (this.board[coord.l - 2][coord.k - 1] === piece) {
        knights2++;
      }
      if (this.board[coord.l + 2][coord.k - 1] === piece) {
        knights2++;
      }
      if (this.board[coord.l - 1][coord.k + 2] === piece) {
        knights3++;
      }
      if (this.board[coord.l + 1][coord.k + 2] === piece) {
        knights3++;
      }
      if (this.board[coord.l - 1][coord.k - 2] === piece) {
        knights4++;
      }
      if (this.board[coord.l + 1][coord.k - 2] === piece) {
        knights4++;
      }
      knights = knights1 + knights2 + knights3 + knights4;
      if (knights1 > 1 || knights2 > 1 || knights3 > 1 || knights4 > 1) {
        return move.charAt(1);
      }
      if (knights > 1) {
        return move.charAt(0);
      }
      return "";
    };
    Yahoo2Pgn.prototype.checkQueen = function(piece, move) {
      var coord, down, downleft, downright, left, pieceDown, pieceUp, queens, right, up, upleft, upright;
      coord = this.getCoordinates(move);
      upleft = this.lookUpLeft(piece, coord.l, coord.k, coord.i);
      up = this.lookUp(piece, coord.l, coord.k, coord.i);
      upright = this.lookUpRight(piece, coord.l, coord.k, coord.i);
      downleft = this.lookDownLeft(piece, coord.l, coord.k, coord.i);
      down = this.lookDown(piece, coord.l, coord.k, coord.i);
      downright = this.lookDownRight(piece, coord.l, coord.k, coord.i);
      left = this.lookLeft(piece, coord.l, coord.k, coord.i);
      right = this.lookRight(piece, coord.l, coord.k, coord.i);
      pieceUp = this.lookUp(piece, coord.j, coord.i);
      pieceDown = this.lookDown(piece, coord.j, coord.i);
      queens = upleft + up + upright + downleft + down + downright + left + right;
      if (queens > 100) {
        if (queens >= 200) {
          return move.charAt(1);
          return move.charAt(0);
        }
      }
      return "";
    };
    return Yahoo2Pgn;
  })();
  root = typeof exports !== "undefined" && exports !== null ? exports : this;
  root.converter = Yahoo2Pgn;
}).call(this);
