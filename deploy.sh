#!/bin/bash
#!/bin/bash

echo -e "\033[0;32mDeploying updates to GitHub...\033[0m"

# Build the project.
hugo -t hyde

# Commit changes to theme
cd themes/hyde
git add .
git commit -m "updating theme `date`"
git push origin/master
cd ../..

# Add changes to git.
git add .

# Commit changes.
msg="rebuilding site `date`"
if [ $# -eq 1 ]
  then msg="$1"
fi
git commit -m "$msg"

# Push source and build repos.
git push origin master

# Trigger netlify build
curl -X POST -d {} https://api.netlify.com/build_hooks/5d7bf76d8d171b0181af0a8b