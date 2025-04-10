# ~/.bashrc: executed by bash for non-login shells

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# Set aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Activate Python virtual environment
if [ -f "$HOME/venv/bin/activate" ]; then
    . "$HOME/venv/bin/activate"
fi

# Set prompt
PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

# Load Python virtual environment
if [ -f "$HOME/venv/bin/activate" ]; then
    . "$HOME/venv/bin/activate"
fi

# Alias for starting Spark UI
alias start-spark-ui='python3 /workspace/src/python/spark_test.py &'
