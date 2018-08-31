KEYWORD = '^(class|method|function|constructor|int|boolean|char|void|var|static|field|let|do|if|else|while|return|true|false|null|this)'
SYMBOL = '[\{\}\(\)\[\]\.,;\+\-\*&\|<>\/=~]'
IDENTIFIER = '[a-zA-Z_]\w*'
INT_CONST = '\d+'
STRING_CONST = '"[^\n]*"'
REGEX = /(#{KEYWORD}|#{SYMBOL}|#{IDENTIFIER}|#{INT_CONST}|#{STRING_CONST})/
XML_CONVSERSIONS = { '<': '&lt;', '>': '&gt;', '&': '&amp;' }
INLINE_COMMENT_REGEX = /\/\/.*/
MULTILINE_COMMENT_REGEX = /(\*.*?\*| \* | \*\/)/
