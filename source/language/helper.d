module language.helper;

public enum string basic = `
	Comment <- :"'" Text+
	Text <- identifier / blank / '?' / '(' / ')' / "&&" / "||" / "!" / "=="

    String <~ doublequote (!doublequote Char)* doublequote

    Char   <~ backslash ( doublequote  # '\' Escapes
                        / quote
                        / backslash
                        / [bfnrt]
                        / [0-2][0-7][0-7]
                        / [0-7][0-7]?
                        / 'x' Hex Hex
                        / 'u' Hex Hex Hex Hex
                        / 'U' Hex Hex Hex Hex Hex Hex Hex Hex
                        )
             / . # Or any char, really

    Hex     <- [0-9a-fA-F]
`;
