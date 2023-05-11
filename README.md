# Vim semind

The plugin provides integration with the semind indexer from the
[sparse](https://git.kernel.org/pub/scm/devel/sparse/sparse.git/about/)
project.

The semind is a semantic C code indexer. You can search not only for functions
and symbols, but also for fields in structures and specify the type of access to
them. Such features are very useful in large projects such as the linux kernel.

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

* `<C-s> s` -- search the usage of the symbol under the cursor.
* `<C-s> d` -- search definition of the symbol under the cursor.
* `<C-s> q` -- show/hide the buffer with search results.

or just use the `SemindSearch` function:

```vim
:SemindSearch -m w task_struct.pid
```

the results will be opened in the quickfix buffer.

## Configuration

All parameters are optional.

```vimrc
" The path to the semind utility if it is not in `$PATH`.
let g:semind_prog="/path/to/semind"

" List of commands for specifying the position of the quickfix buffer.
" See `:help vertical` for more information.
let g:semind_window_position = [ "topleft" ]

" The parameter sets the size of the window (default: 10).
let g:semind_window_size = 10
```

## License

MIT License. See [LICENSE](LICENSE).
