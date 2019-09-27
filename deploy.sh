#!/bin/bash
#!/bin/bash

echo -e "\033[0;32mDeploying updates to GitHub...\033[0m"

# Build the project.
hugo -t hyde

# Commit changes to theme
echo -e "\033[0;32mCommitting changes to Hyde...\033[0m"
cd themes/hyde
git add .
git commit -m "Updating theme `date`"
git push
cd ../..
echo -e "\033[0;32mChanges pushed\033[0m"

echo -e "\033[0;32mCommitting changes to blog...\033[0m"
# Add changes to git.
git add .

# Commit changes.
msg="Update site `date`"
if [ $# -eq 1 ]
  then msg="$1"
fi
git commit -m "$msg"

# Push source and build repos.
git push origin master
echo -e "\033[0;32mChanges pushed\033[0m"

# Trigger netlify build
curl -X POST -d {} https://api.netlify.com/build_hooks/5d7bf76d8d171b0181af0a8b

echo -e "\033[0;32mNetlify build triggered\033[0m"