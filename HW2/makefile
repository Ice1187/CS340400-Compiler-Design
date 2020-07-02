all:parser.y
	flex scanner.l
	byacc -d parser.y
	gcc lex.yy.c y.tab.c -lfl -o parser
	chmod a+x parser

scanner:scanner.l
	flex scanner.l
	gcc lex.yy.c -lfl -v -o scanner
	chmod a+x scanner
