# Integration softeq development environment with VSCode IDE

Install [Visual Studio Code](https://code.visualstudio.com/download) as root  
`sudo apt install vscode`

Launch VS Code and install the following addons from the Extensions tab:  
- `C/C++ Extension Pack` by Microsoft  
- `Shell Command` by mngrm3a

Switch to your softeq-dev-env directory i.e.  
`cd ~/repos/softeq-dev-env`

Copy contents of the `./ide/.vscode` directory to `~/.vscode`  
`cp -R ./ide/vscode/. ~/.vscode/`

Adjust `~/.vscode/launch.json` to meet your requirements

## Intergration VSCode with Git

To make VSCode your default git editor  
`git config --global core.editor "code -w"`

As an alternative of setting `core.editor` export following environment variables   
```
export EDITOR="code -w"
export VISUAL="$EDITOR"
```
To make this settings permanent consider editing your `~/.profile`  
```bash
if [[ -n $SSH_CONNECTION ]]; then # SSH mode - no GUI available
  export EDITOR='vim'
  # replace vim with your favorite non-GUI editor
else # Local terminal mode
  export EDITOR='code -w'
fi
export VISUAL="$EDITOR"
```
This way not only git, but many other applications will use VS Code as an editor

## To leverage the `--diff` option you can pass to VS Code to compare two files side by side  
`git config --global -e`  
And add following section into the git configuration file  
```
[diff]
    tool = default-difftool
[difftool "default-difftool"]
    cmd = code -w --diff $LOCAL $REMOTE
```

## Using VS Code for debugging
`TBD`
