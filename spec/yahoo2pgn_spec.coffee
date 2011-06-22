yahoo2pgn = require '../lib/yahoo2pgn'
describe "Yahoo2Pgn", ->
  it "can convert a chess game", ->

    yahoo = '''
      ;Title: Yahoo! Chess Game
      ;White: gridsid55
      ;Black: jeram2010
      ;Date: Sat Jun 18 18:40:44 PDT 2011

      1. d2-d4 d7-d5
      2. c2-c4 d5xc4
      3. g1-f3 b7-b5
      4. e2-e3 e7-e6
      5. b1-c3 f8-b4
      6. c1-d2 a7-a6
      7. a2-a4 b4xc3
      8. d2xc3 c8-b7
      9. f1-e2 g8-f6
      10. b2-b3 c4xb3
      11. d1xb3 b7-d5
      12. b3-b4 f6-e4
      13. o-o e4xc3
      14. b4xc3 o-o
      15. a4xb5 b8-d7
      16. b5xa6 d7-f6
      17. f1-c1 c7-c6
      18. f3-e5 f6-e4
      19. c3-d3 d8-f6
      20. e2-f3 e4xf2
      21. g1xf2 d5xf3
      22. e5xf3 e6-e5
      23. d4xe5 f6-e6
      24. f3-g5 e6-h6
      25. g5-f3 a8-d8
      26. d3-e4 f7-f6
      27. e4xc6 h6-h5
      28. f2-g1 f6xe5
      29. a6-a7 d8-a8
      30. c6-e6+ g8-h8
      31. c1-c8 f8xc8
      32. e6xc8+ a8xc8
      33. a7-a8 h5-g4
      34. f3xe5 g4-e6
      35. e5-f7+ h8-g8
      36. a8-b7 e6xe3+
      37. g1-h1 c8-c1+
      '''

    expected = '''
      [Event "Yahoo! Chess Game"]
      [Site "Yahoo! Chess"]
      [Date "2011.06.18"]
      [Round ""]
      [White "gridsid55"]
      [Black "jeram2010"]
      [Result "0-1"]

      1. d4 d5  2. c4 dxc4  3. Nf3 b5  4. e3 e6  5. Nc3 Bb4  6. Bd2 a6  7. a4 Bxc3  8. Bxc3 Bb7  9. Be2 Nf6  10. b3 cxb3  11. Qxb3 Bd5  12. Qb4 Ne4  13. O-O Nxc3  14. Qxc3 O-O  15. axb5 Nd7  16. bxa6 Nf6  17. Rfc1 c6  18. Ne5 Ne4  19. Qd3 Qf6  20. Bf3 Nxf2  21. Kxf2 Bxf3  22. Nxf3 e5  23. dxe5 Qe6  24. Ng5 Qh6  25. Nf3 Rad8  26. Qe4 f6  27. Qxc6 Qh5  28. Kg1 fxe5  29. a7 Ra8  30. Qe6+ Kh8  31. Rc8 Rfxc8  32. Qxc8+ Rxc8  33. a8=Q Qg4  34. Nxe5 Qe6  35. Nf7+ Kg8  36. Qb7 Qxe3+  37. Kh1 Rc1+
      '''

    converter = new yahoo2pgn.converter(yahoo, '0-1')
    converter.convert()
    expect(converter.pgn).toEqual(expected)
    console.log("")