#!/bin/bash

cd $(dirname $0)

echo '==> Reading plugin metadata...'
data=($(python3 -c 'import sys,json;o=json.load(open("mcdreforged.plugin.json","r"));n=o["name"];d=o["id"];v=o["version"];an=o.get("archive_name");print(((n and n.replace(" ", ""))or d)+"-v"+v if not an else an.format(id=d,version=v));print(v)'))
if [ $? -ne 0 ]; then
	echo '[ERROR] Cannot parse "mcdreforged.plugin.json"'
	exit 1
fi
name="${data[0]}"
version="v${data[1]}"

echo '==> Packing source files...'
python3 -m mcdreforged pack -o ./output -n "$name" || exit $?

echo '==> Commiting git repo...'
( git add . && git commit -m "$version" && git push ) || exit $?

echo '==> Creating github release...'
gh release create "$version" "./output/${name}.mcdr" -t "$version" -n '' || exit $?

echo '==> Done'
