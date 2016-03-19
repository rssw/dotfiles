# .files
My Dotfiles - tmux, vim, bash, zsh, git.

All of these files create an enviorment with powerline for vim, tmux and the shell.
I use as well key-bindings/key-mappings that integrate tmux and vim beautifully together so it could be much easier to remember mine then the originals.
Here are some screenshots: (my host-name is NUC)
![powerline example](https://lh3.googleusercontent.com/-69tCFbgPqRo/Vu1eaLbmnaI/AAAAAAAAHBw/TqLRZnW1Y7EnAvHstdagbOCC-x94oJPkg/s0/Screenshot+from+2016-03-19+16-12-30.png "powerline.png")
In the image you can see I even have live syntax highlighting for the terminal itself. I'm pretty sure it's possible or available only for zsh but it's pretty awesome. Maybe it's not as impressive as vim's syntax highlighting but it's good enough.
It is possible thanks to: https://github.com/zsh-users/zsh-syntax-highlighting

----------
**Notes**

* I use powerline exported from this repo: https://github.com/powerline/powerline and it can be installed with:
 * `sudo apt-get install powerline` # wide-system, (ubuntu only)
 * `pip install powerline-status` # for current user only
 * I believe it's also possible to install these powerline bindings directly from source but I'm sure about it.
* I use zsh but my dotfiles will work almost as well for bash thanks to the flexibility of the powerline bindings.
* I don't use 'Oh-My-zsh' -- I just don't like it because I'm not sure it's stable as the python based powerline I do use.

`git clone && ./export && echo enjoy!`
