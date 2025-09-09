#!/bin/bash

# Take a delightful sphinx_rtd_theme repo, and corrupt it by converting it into funtoo-theme. To allow easy pulling in of
# updates from the upstream.

if [ ! -d sphinx_funtoo_theme ]; then
	git mv sphinx_rtd_theme sphinx_funtoo_theme
fi
grep -r sphinx_rtd_theme * | grep -v "Binary file" | cut -f1 -d: | sort -u | xargs sed -i -e 's/sphinx_rtd_theme/sphinx_funtoo_theme/g' {} \;
