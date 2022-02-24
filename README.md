# dotfiles

my Linux (Arch btw) rice

[click here for README](dotfiles/README.md)

##

- Clone as a bare repository

```sh

git clone --bare <git-repo-url> $HOME/.cfg
```

- Define an alias in the current scope

```sh
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
```

- Checkout the actual content from the bare repository to your `$HOME`

```sh
config checkout
```

- May get an error similar to the following:

```sh
error: The following untracked working tree files would be overwritten by checkout:
    .bashrc
    .gitignore
Please move or remove them before you can switch branches.
Aborting
```

This occurs because your `$HOME` folder might already have some of the configuration files, which would be overwritten by git. Therefore, back up any files that are conflicting, or remove them if they are unimportant

The following command can be used to move all the offending files to a backup folder

```sh
mkdir -p .config-backup && \
config checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | \
xargs -I{} mv {} .config-backup/{}
```

- Set flag `showUntrackedFiles` to `no` on the specific (local) repository

```sh
config config --local status.showUntrackedFiles no
```
