@REM install lakos - see https://pub.dev/packages/lakos/install
@REM dart pub global activate lakos
@REM export PATH="$PATH":"$HOME/.pub-cache/bin"
echo "Generate Graph dependencies"

del graph.dot
del graph.svg

@REM no folders
@REM call lakos . --no-tree -o graph.dot -i example/**

@REM woth folders
call lakos -o graph.dot .

call dot -Tsvg graph.dot -Grankdir=TB -Gcolor=lightgray -Ecolor="#aabbaa88" -o graph.svg
@REM fdp -Tsvg graph.dot -Gcolor=lightgray -Ecolor="#aabbaa99" -o graph.svg
