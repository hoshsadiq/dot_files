#!/usr/bin/env zsh
{
	exec > >(sed 's/^/foo: /')
	exec 2> >(sed 's/^/foo: (stderr) /' >&2)
	echo foo
	echo bar >&2
	date
} &


{
	exec > >(sed 's/^/baz: /')
	exec 2> >(sed 's/^/baz: (stderr) /' >&2)
	echo foo2
	echo bar2 >&2
	date
} &

echo "root"
