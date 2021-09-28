#!/usr/bin/env python

import ctypes
import io
import os, sys
import tempfile

import contextlib
import argparse

from conda_build.api import render, get_output_file_paths, build

from binstar_client.utils import get_server_api
from binstar_client import errors
from binstar_client.inspect_package.conda import (
    inspect_conda_package as get_attrs,
)

libc = ctypes.CDLL(None)
c_stdout = ctypes.c_void_p.in_dll(libc, 'stdout')

@contextlib.contextmanager
def stdout_redirector(stream):
    """Redirect all stdout to stream.py

    This redirector is stronger than the usual contextlib.redirect_stdout and
    has been taken from https://eli.thegreenplace.net/2015/redirecting-all-kinds-of-stdout-in-python/
    """
    # The original fd stdout points to. Usually 1 on POSIX systems.
    original_stdout_fd = sys.stdout.fileno()

    def _redirect_stdout(to_fd):
        """Redirect stdout to the given file descriptor."""
        # Flush the C-level buffer stdout
        libc.fflush(c_stdout)
        # Flush and close sys.stdout - also closes the file descriptor (fd)
        sys.stdout.close()
        # Make original_stdout_fd point to the same file as to_fd
        os.dup2(to_fd, original_stdout_fd)
        # Create a new sys.stdout that points to the redirected fd
        sys.stdout = io.TextIOWrapper(os.fdopen(original_stdout_fd, 'wb'))

    # Save a copy of the original stdout fd in saved_stdout_fd
    saved_stdout_fd = os.dup(original_stdout_fd)
    try:
        # Create a temporary file and redirect stdout to it
        tfile = tempfile.TemporaryFile(mode='w+b')
        _redirect_stdout(tfile.fileno())
        # Yield to caller, then redirect stdout back to the saved fd
        yield
        _redirect_stdout(saved_stdout_fd)
        # Copy contents of temporary file to the given stream
        tfile.flush()
        tfile.seek(0, io.SEEK_SET)
        stream.write(tfile.read())
    finally:
        tfile.close()
        os.close(saved_stdout_fd)


parser = argparse.ArgumentParser()

parser.add_argument("recipe_dir", help="Path to the recipe directory")


def main(parser_args=None):

    args = parser.parse_args(parser_args)

    with io.BytesIO() as f, stdout_redirector(f):
        metadata = render(args.recipe_dir)[0][0]

    package_meta = metadata.get_section("package")
    print("%(name)s==%(version)s" % package_meta)


if __name__ == "__main__":
    main()
