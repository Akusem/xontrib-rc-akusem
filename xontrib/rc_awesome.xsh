"""
Awesome snippets code to make .xonshrc better - https://github.com/anki-code/xontrib-rc-awesome
If you like the idea click ⭐ on the repo and stay tuned. 
""" 

# -------------------------------------------------------------------------------------------------------------------------------------------------------------
# Imports
# -------------------------------------------------------------------------------------------------------------------------------------------------------------

import shutil, time


# -------------------------------------------------------------------------------------------------------------------------------------------------------------
# Cross platform
# -------------------------------------------------------------------------------------------------------------------------------------------------------------

if __xonsh__.env.get('XONTRIB_RC_AWESOME_SHELL_TYPE_CHECK', True) and $SHELL_TYPE not in ['prompt_toolkit', 'none', 'best']:
    printx("{YELLOW}xontrib-rc-awesome: We recommend to use prompt_toolkit shell by installing `xonsh[full]` package.{RESET}")

# First of all replace `$` to `@` in the prompt to not to be confused with another shell.
# It will be good to read 
#  - https://github.com/anki-code/xonsh-cheatsheet#three-most-frequent-things-that-newcomers-missed
#  - https://github.com/xonsh/xonsh/issues/4152#issue-823993141
$PROMPT_FIELDS['prompt_end'] = '@'

# The SQLite history backend saves command immediately 
# unlike JSON backend that save the commands at the end of the session.
$XONSH_HISTORY_BACKEND = 'sqlite'

# What commands are saved to the history list. By default all commands are saved. 
# * The option ‘ignoredups’ will not save the command if it matches the previous command.
# * The option `erasedups` will remove all previous commands that matches and updates the command frequency. 
#   The minus of `erasedups` is that the history of every session becomes unrepeatable 
#   because it will have a lack of the command you repeat in another session.
# Docs: https://xonsh.github.io/envvars.html#histcontrol
$HISTCONTROL='ignoredups'


# Remove front dot in multiline input to make the code copy-pastable.
$MULTILINE_PROMPT=' '


# cd-ing shortcuts.
aliases['-'] = 'cd -'
aliases['..'] = 'cd ..'
aliases['....'] = 'cd ../..'


# Avoid typing cd just directory path. 
# Docs: https://xonsh.github.io/envvars.html#auto-cd
$AUTO_CD = True

#
# Xontribs - https://github.com/topics/xontrib
#
_xontribs = [
    'whole_word_jumping', # Jumping across whole words (non-whitespace) with Ctrl + Left/Right and Alt + Left/Right.
]
if _xontribs:
    xontrib load @(_xontribs)

# -------------------------------------------------------------------------------------------------------------------------------------------------------------
# Platform specific
# -------------------------------------------------------------------------------------------------------------------------------------------------------------

from xonsh.platform import ON_LINUX, ON_DARWIN #, ON_WINDOWS, ON_WSL, ON_CYGWIN, ON_MSYS, ON_POSIX, ON_FREEBSD, ON_DRAGONFLY, ON_NETBSD, ON_OPENBSD

if ON_LINUX or ON_DARWIN:
       
    # Globbing files with “*” or “**” will also match dotfiles, or those ‘hidden’ files whose names begin with a literal ‘.’. 
    # Note! This affects also on rsync and other tools.
    $DOTGLOB = True

    # Don't clear the screen after quitting a manual page.
    $MANPAGER = "less -X"
    $LESS = "--ignore-case --quit-if-one-screen --quit-on-intr FRXQ"

    # Flag for automatically pushing directories onto the directory stack i.e. `dirs -p` (https://xon.sh/aliases.html#dirs).
    # It's for `mc` alias (below).
    $AUTO_PUSHD = True

    # Add default bin paths
    for p in [p'/home/linuxbrew/.linuxbrew/bin', fp'/home/{$USER}/.local/bin', p'/opt/homebrew/opt/coreutils/libexec/gnubin']:
        if p.exists():
            $PATH.append(str(p))
    
    
    # List all files: sorted, with colors, directories will be first (Midnight Commander style).
    aliases['ll'] = "$LC_COLLATE='C' ls --group-directories-first -lAh --color @($args)"

    # Run Midnight Commander where left and right panel will be the current and the previous directory.
    # Required: $AUTO_PUSHD = True
    if shutil.which('mc'):
        aliases['mc'] = "mc @($PWD if not $args else $args) @($OLDPWD if not $args else $PWD)"

    # Make directory and cd into it.
    # Example: md /tmp/my/awesome/dir/will/be/here
    aliases['md'] = 'mkdir -p $arg0 && cd $arg0'
        
    # Using rsync instead of cp to get the progress and speed of copying.
    if shutil.which('rsync'):
        aliases['cp'] = 'rsync --progress --recursive --archive'
    
    # Grepping string occurrences recursively starting from current directory.
    # Example: cd ~/git/xonsh && greps environ
    aliases['greps'] = 'grep -ri'

    # Copy output to current clipboard using xclip. This snippet could be improved and packed into the xontrib. Start from https://github.com/xonsh/xontrib-template
    # Example: echo hello | clp
    if shutil.which('pbcopy'):  # DARWIN
        aliases['clp'] = 'pbcopy'
    elif shutil.which('xclip'):  # LINUX
        aliases['clp'] = 'xclip -sel clip'
    elif shutil.which('clip.exe'):  # WINDOWS
        aliases['clp'] = 'clip.exe'

    # SSH: Suppress "Connection close" message.
    aliases['ssh'] = 'ssh -o LogLevel=QUIET'

    # Run http server in the current directory.
    aliases['http-here'] = 'python3 -m http.server'
    
    
    # Universal pm aliases. This snippet could be improved and packed into the xontrib. Start from https://github.com/xonsh/xontrib-template
    if shutil.which('pacman'):
        # Aliases from https://devhints.io/pacman
        aliases['pm-install'] = 'sudo pacman -Sy'
        aliases['pm-uninstall'] = 'sudo pacman -Rsc'
        aliases['pm-search'] = 'sudo pacman -Ss'
        aliases['pm-upgrade-everything'] = 'sudo pacman -Syu'
        aliases['pm-package-info'] = 'sudo pacman -Qii'
        aliases['pm-package-unneeded-list'] = 'sudo pacman -Qdt'
        aliases['pm-package-unneeded-uninstall'] = 'sudo pacman -Rns @($(pacman -Qdtq).splitlines())'
    elif shutil.which('apt'):
        aliases['pm-install'] = 'sudo apt install'
        aliases['pm-uninstall'] = 'sudo apt uninstall'
        aliases['pm-search'] = 'sudo apt search'
    
    
    #
    # Xontribs - https://github.com/topics/xontrib
    #
    _xontribs = [
        'back2dir',          # Back to the latest used directory when starting xonsh shell. URL: https://github.com/anki-code/xontrib-back2dir
        'prompt_bar',       # The bar prompt for xonsh shell with customizable sections. URL: https://github.com/anki-code/xontrib-prompt-bar
        'pipeliner',        # Let your pipe lines flow thru the Python code. URL: https://github.com/anki-code/xontrib-pipeliner
        'sh',               # Paste and run commands from bash, zsh, fish, tcsh in xonsh shell. URL: https://github.com/anki-code/xontrib-sh
        #'output_search',    # Get words from the previous command output for the next command. URL: https://github.com/tokenizer/xontrib-output-search
    ]
    if _xontribs:
        xontrib load @(_xontribs)

        
    if shutil.which('lsb_release'):
        if 'Ubuntu' in $(lsb_release --id --release --short).strip():
            xontrib load apt_tabcomplete

            
    #        
    # The command to pull history from other SQLite history backend sessions. 
    #        
    
    $XONSH_HISTORY_SQLITE_PULL_TIME = __xonsh__.history[0].ts[0] if __xonsh__.history else time.time()
    def _history_pull():

        if $XONSH_HISTORY_BACKEND != 'sqlite':
            printx('{RED}To pull history use SQLite history backend.{RESET}')
            return -1

        if not shutil.which('sqlite3'):
            printx('{RED}Install sqlite3.{RESET}')
            return -1

        sessionid = __xonsh__.history.info()['sessionid']
        sql_records = f"SELECT inp FROM xonsh_history WHERE tsb > '{$XONSH_HISTORY_SQLITE_PULL_TIME}' AND sessionid != '{sessionid}' ORDER BY tsb"
        rows = $(sqlite3 $XONSH_HISTORY_FILE @(sql_records)).splitlines()
        i = 0
        for r in rows:
            __xonsh__.shell.shell.prompter.history.append_string(r)
            print(r)
            i += 1

        $XONSH_HISTORY_SQLITE_PULL_TIME = time.time()

        if i > 0:
            printx(f'{{GREEN}}Added {i} records!{{RESET}}')
        else:
            printx(f'{{YELLOW}}No new records found.{{RESET}}')

    aliases['history-pull'] = _history_pull
    del _history_pull
    
    
    #
    # Binding the hotkeys - https://xon.sh/tutorial_ptk.html
    # List of keys - https://github.com/prompt-toolkit/python-prompt-toolkit/blob/master/src/prompt_toolkit/keys.py
    #
    
    from prompt_toolkit.keys import Keys

    @events.on_ptk_create
    def custom_keybindings(bindings, **kw):

        # Press F1 and get the list of files
        @bindings.add(Keys.F1)
        def run_ls(event):
            ls -l
            event.cli.renderer.erase()

        # Press F3 to insert the grep command
        @bindings.add(Keys.F3)
        def say_hi(event):
            event.current_buffer.insert_text(' | grep -i ')            

            
          
# -------------------------------------------------------------------------------------------------------------------------------------------------------------
# Final
# -------------------------------------------------------------------------------------------------------------------------------------------------------------        
        
# For the experienced users

# Suppress line "xonsh: For full traceback set: $XONSH_SHOW_TRACEBACK = True" 
# in case of exceptions or wrong command.
$XONSH_SHOW_TRACEBACK = False

# Suppress line "Did you mean one of the following?"
$SUGGEST_COMMANDS = False
    
   
