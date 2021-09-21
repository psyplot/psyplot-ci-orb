#!/usr/bin/env python
import os

import contextlib
import argparse

from conda_build.api import render, get_output_file_paths, build

from binstar_client.utils import get_server_api
from binstar_client import errors
from binstar_client.inspect_package.conda import (
    inspect_conda_package as get_attrs,
)

parser = argparse.ArgumentParser()

parser.add_argument("recipe_dir", help="Path to the recipe directory")


def main(parser_args=None):

    args = parser.parse_args(parser_args)

    with open(os.devnull, 'w') as devnull:
        with contextlib.redirect_stdout(devnull):
            metadata = render(args.recipe_dir)[0][0]

    package_meta = metadata.get_section("package")
    print("%(name)s==%(version)s" % package_meta)


if __name__ == "__main__":
    main()
