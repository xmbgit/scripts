# Scripts
A repository of scripts I use on my Ubuntu Server. Achitecture independent and used to automate many administrative tasks.

Feel free to use them as you wish. Some are incredibly complex, more are incredibly simple and useful.

To add these to your path use:

```bash
# Add ~/scripts to PATH if it exists
if [ -d "$HOME/scripts" ]; then
    export PATH="$HOME/scripts:$PATH"
fi
```

To view them and a kewl message add these to `.bashrc` file:
```bash
echo -e "\e[31mRed Text\e[0m"
echo -e "NOTICE: VIEW SCRIPTS WITH lscripts \n\e[31mSCRIPTS AVAILABLE ARE:\e[0m $(lscripts)\n"

# Date
echo "Today is $(date)"
echo "Welcome Home Master $(whoami)"
```

