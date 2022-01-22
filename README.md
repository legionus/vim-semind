# Vim semind

The plugin provides integration with the semind indexer from the sparse[1]
project.

## Usage

First you need to create an index:

For linux kernel:

```bash
$ make C=1 CHECK='semind add --'
```

For any other project:

```bash
$ make CC=cgcc CHECK='semind add --'
```

Further in vim, you can use the following keybindings:

<C-s> s -- search the usage of the symbol under the cursor.
<C-s> d -- search definition of the symbol under the cursor.

the results will be opened in the quickfix buffer.

## References

[sparse]: https://git.kernel.org/pub/scm/devel/sparse/sparse.git/about/

## License

MIT License. See LICENSE.
