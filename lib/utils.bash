#!/usr/bin/env bash

set -euo pipefail

GH_REPO="https://github.com/potassco/clingo"
TOOL_NAME="clingo"
TOOL_TEST="clingo --version"

fail() {
	echo -e "asdf-$TOOL_NAME: $*"
	exit 1
}

curl_opts=(-fsSL)

if [ -n "${GITHUB_API_TOKEN:-}" ]; then
	curl_opts=("${curl_opts[@]}" -H "Authorization: token $GITHUB_API_TOKEN")
fi

sort_versions() {
	sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' |
		LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}

list_github_tags() {
	git ls-remote --tags --refs "$GH_REPO" |
		grep -o 'refs/tags/.*' | cut -d/ -f3- |
		sed 's/^v//' |
		grep -E '^[0-9]+\.[0-9]+\.[0-9]+$'
}

list_all_versions() {
	list_github_tags
}

download_release() {
	local version filename url
	version="$1"
	filename="$2"

	url="$GH_REPO/archive/refs/tags/v${version}.tar.gz"

	echo "* Downloading $TOOL_NAME release v${version}..."
	curl "${curl_opts[@]}" -o "$filename" -C - "$url" || fail "Could not download $url"
}

install_version() {
	local install_type="$1"
	local version="$2"
	local install_path="$3"

	if [ "$install_type" != "version" ]; then
		fail "asdf-$TOOL_NAME supports release installs only"
	fi

	(
		local source_path
		source_path="$ASDF_DOWNLOAD_PATH"

		local build_path
		build_path="$(mktemp -d)"

		local jobs
		jobs="${ASDF_CONCURRENCY:-$(nproc 2>/dev/null || echo 1)}"

		echo "* Building $TOOL_NAME v${version}..."

		cmake \
			-S"$source_path" \
			-B"$build_path" \
			-DCMAKE_BUILD_TYPE=Release \
			-DCMAKE_INSTALL_PREFIX="$install_path" \
			-DCLINGO_BUILD_APPS=ON \
			-DCLINGO_BUILD_WITH_PYTHON=OFF \
			-DCLINGO_BUILD_WITH_LUA=OFF \
			-DCLINGO_MANAGE_RPATH=ON

		cmake --build "$build_path" -j "$jobs"
		cmake --install "$build_path"

		rm -rf "$build_path"

		local tool_cmd
		tool_cmd="$(echo "$TOOL_TEST" | cut -d' ' -f1)"
		test -x "$install_path/bin/$tool_cmd" || fail "Expected $install_path/bin/$tool_cmd to be executable."

		echo "$TOOL_NAME $version installation was successful!"
	) || (
		rm -rf "$install_path"
		fail "An error occurred while installing $TOOL_NAME $version."
	)
}
