#!/usr/bin/env python
import os
import os.path as osp
import argparse

from conda_build.api import render, get_output_file_paths, build

from binstar_client.utils import get_server_api
from binstar_client import errors
from binstar_client.inspect_package.conda import (
    inspect_conda_package as get_attrs,
)


from ._version import get_versions

__version__ = get_versions()["version"]
del get_versions


parser = argparse.ArgumentParser()

parser.add_argument("recipe_dir", help="Path to the recipe directory")

parser.add_argument(
    "-V",
    "--version",
    help="Show the version and exit",
    action="version",
    version=__version__,
)

parser.add_argument(
    "-py",
    "--python",
    help=(
        "The python version. If None, it will be taken from the "
        "PYTHON_VERSION environment variable (i.e. Default: %(default)s)."
    ),
    default=os.getenv("PYTHON_VERSION"),
)

parser.add_argument(
    "-t",
    "--token",
    help=(
        "The token to use for uploading. If None, it will be taken from the "
        "BINSTAR_API_TOKEN or ANACONDA_API_TOKEN environment variable. This is "
        "required for the upload."
    ),
    default=(
        os.getenv("BINSTAR_API_TOKEN", os.getenv("ANACONDA_API_TOKEN")) or None
    ),
)

parser.add_argument(
    "-l",
    "--label",
    help="The label for the file. Default: %(default)s",
    default="main",
)

parser.add_argument(
    "-u",
    "--user",
    help=(
        "The anaconda user. If None, it will be taken from the token. "
        "Note that either the token or the user must be specified."
    ),
)

parser.add_argument(
    "-n",
    "--dry-run",
    help="Perform a dry run and to not change anything on anaconda",
    action="store_true",
)


def main(parser_args=None):

    args = parser.parse_args(parser_args)

    kws = {"python": args.python} if args.python else {}

    metadata = render(args.recipe_dir, **kws)[0][0]

    # get the full path to the output
    ofile = get_output_file_paths(metadata, **kws)[0]

    # will be something like `linux-64/package-version-py38.tar.bz2`
    filename = osp.basename(osp.dirname(ofile)) + "/" + osp.basename(ofile)

    package_meta = metadata.get_section("package")
    package = package_meta["name"]
    version = package_meta["version"]

    aserver_api = get_server_api(args.token)
    if args.user is not None:
        user = args.user
    else:
        user = aserver_api.user()["login"]

    # check if the file exists already
    try:
        dist = aserver_api.distribution(user, package, version, filename)
    except errors.NotFound as e:
        # do the upload
        print(f"Uploading new file: {filename}")
        build(metadata, notest=True, copy_test_source_files=False)

        with open(ofile, "rb") as fd:
            package_attrs, release_attrs, file_attrs = get_attrs(ofile, fd)

        if not args.dry_run:
            try:
                # Check if the release already exists
                aserver_api.release(user, package, version)
            except errors.NotFound:
                # if not, create it
                aserver_api.add_release(
                    user,
                    package,
                    version,
                    dependencies=[],
                    announce=None,
                    release_attrs=release_attrs,
                )

            with open(ofile, "rb") as fd:
                aserver_api.upload(
                    user,
                    package,
                    version,
                    filename,
                    fd,
                    distribution_type="conda",
                    channels=(args.label,),
                    dependencies=file_attrs.get("dependencies"),
                    attrs=file_attrs.get("attrs"),
                )
        print("Success!")
    else:
        # add the label
        print("Package is already available on anaconda.")
        if args.label in dist["labels"]:
            print(f"Package is already available under the {args.label} label.")
            print("Nothing to do for me here.")
        else:
            print(f"Adding the label {args.label}")
            if not args.dry_run:
                aserver_api.add_channel(
                    args.label, user, package, version, filename
                )
            print("Success!")


if __name__ == "__main__":
    main()
