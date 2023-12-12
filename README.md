# tarball

Download Urbit cages in a file-system hierarchy as a tarball.

To download the example tarball when you have the desk running go to `[your-url]/tarball` e.g. `localhost:8080/tarball` in your browser.

(this desk also uses `/lib/bind.hoon` to get rid of %eyre binding boilerplate)

## Installation
1. Clone this repo.
2. Boot up a ship (fakezod or moon or whatever you use).
3. `|new-desk %tarball` to create a new desk called `%tarball`.
4. `|mount %tarball` to access the `%tarball` desk from the unix command line.
5. At the unix command line `rm -rf [ship-name]/tarball/*` to empty out the contents of the desk.
6. `cp -rL tarball/* [ship-name]/tarball` to copy the contents of this repo into your new desk.
7. At the dojo command line `|commit %tarball`.
8. Install with `|install our %tarball`.
